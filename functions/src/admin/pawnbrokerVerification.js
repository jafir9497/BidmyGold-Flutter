const functions = require("firebase-functions");
const admin = require("firebase-admin");

// Initialize Firebase Admin if not already initialized
if (!admin.apps.length) {
  admin.initializeApp();
}

const db = admin.firestore();
const fcm = admin.messaging();

/**
 * Updates a pawnbroker's verification status and sends a notification
 */
exports.updatePawnbrokerStatus = functions.https.onCall(
  async (data, context) => {
    // Verify caller is an admin
    if (!context.auth) {
      throw new functions.https.HttpsError(
        "unauthenticated",
        "User must be authenticated"
      );
    }

    const adminId = context.auth.uid;
    const { pawnbrokerId, status, rejectionReason = null } = data;

    if (
      !pawnbrokerId ||
      !status ||
      (status !== "approved" && status !== "rejected" && !rejectionReason)
    ) {
      throw new functions.https.HttpsError(
        "invalid-argument",
        "Invalid arguments provided"
      );
    }

    try {
      // Get admin data for the log
      const adminSnap = await db.collection("admins").doc(adminId).get();
      if (!adminSnap.exists) {
        throw new functions.https.HttpsError(
          "permission-denied",
          "User is not an admin"
        );
      }
      const adminData = adminSnap.data();

      // Update the pawnbroker document
      const pawnbrokerRef = db.collection("pawnbrokers").doc(pawnbrokerId);
      const pawnbrokerSnap = await pawnbrokerRef.get();

      if (!pawnbrokerSnap.exists) {
        throw new functions.https.HttpsError(
          "not-found",
          "Pawnbroker not found"
        );
      }

      const pawnbrokerData = pawnbrokerSnap.data();

      // Update pawnbroker verification status
      await pawnbrokerRef.update({
        verificationStatus: status,
        verifiedBy: adminId,
        verificationDate: admin.firestore.FieldValue.serverTimestamp(),
        ...(status === "rejected" && { rejectionReason: rejectionReason }),
      });

      // Log the admin action
      await db.collection("adminLogs").add({
        adminId,
        adminName: adminData.name || adminData.email,
        action: `Pawnbroker ${status}`,
        details: `${
          status === "approved" ? "Approved" : "Rejected"
        } pawnbroker ${pawnbrokerData.shopName}`,
        timestamp: admin.firestore.FieldValue.serverTimestamp(),
        targetCollection: "pawnbrokers",
        targetDocId: pawnbrokerId,
      });

      // Get the user ID associated with this pawnbroker
      const userId = pawnbrokerData.userId;

      if (userId) {
        // Get user's FCM token
        const userSnap = await db.collection("users").doc(userId).get();

        if (userSnap.exists) {
          const userData = userSnap.data();

          // Send notification to user if they have an FCM token
          if (userData.fcmToken) {
            const title =
              status === "approved"
                ? "Pawnbroker Verification Approved"
                : "Pawnbroker Verification Rejected";

            const body =
              status === "approved"
                ? `Your pawnbroker shop "${pawnbrokerData.shopName}" has been verified. You can now use all pawnbroker features.`
                : `Your pawnbroker shop "${pawnbrokerData.shopName}" verification was rejected. Reason: ${rejectionReason}`;

            await fcm.send({
              token: userData.fcmToken,
              notification: {
                title,
                body,
              },
              data: {
                type: "PAWNBROKER_UPDATE",
                status,
              },
            });
          }
        }
      }

      return { success: true };
    } catch (error) {
      console.error("Error updating pawnbroker status:", error);
      throw new functions.https.HttpsError("internal", error.message);
    }
  }
);
