const functions = require("firebase-functions");
const admin = require("firebase-admin");

// Initialize Firebase Admin if not already initialized
if (!admin.apps.length) {
  admin.initializeApp();
}

const db = admin.firestore();
const fcm = admin.messaging();

/**
 * Updates a user's KYC status and sends a notification
 */
exports.updateKycStatus = functions.https.onCall(async (data, context) => {
  // Verify caller is an admin
  if (!context.auth) {
    throw new functions.https.HttpsError(
      "unauthenticated",
      "User must be authenticated"
    );
  }

  const adminId = context.auth.uid;
  const { userId, status, rejectionReason = null } = data;

  if (
    !userId ||
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

    // Update the user document
    const userRef = db.collection("users").doc(userId);
    const userSnap = await userRef.get();

    if (!userSnap.exists) {
      throw new functions.https.HttpsError("not-found", "User not found");
    }

    const userData = userSnap.data();

    // Update user KYC status
    await userRef.update({
      kycStatus: status,
      kycVerifiedBy: adminId,
      kycVerificationDate: admin.firestore.FieldValue.serverTimestamp(),
      ...(status === "rejected" && { kycRejectionReason: rejectionReason }),
    });

    // Log the admin action
    await db.collection("adminLogs").add({
      adminId,
      adminName: adminData.name || adminData.email,
      action: `KYC ${status}`,
      details: `${
        status === "approved" ? "Approved" : "Rejected"
      } KYC for user ${userData.name || userData.email}`,
      timestamp: admin.firestore.FieldValue.serverTimestamp(),
      targetCollection: "users",
      targetDocId: userId,
    });

    // Send notification to user
    const title =
      status === "approved"
        ? "KYC Verification Approved"
        : "KYC Verification Rejected";

    const body =
      status === "approved"
        ? "Your identity verification has been approved. You can now use all features of the app."
        : `Your identity verification was rejected. Reason: ${rejectionReason}`;

    // Only send if user has FCM token
    if (userData.fcmToken) {
      await fcm.send({
        token: userData.fcmToken,
        notification: {
          title,
          body,
        },
        data: {
          type: "KYC_UPDATE",
          status,
        },
      });
    }

    return { success: true };
  } catch (error) {
    console.error("Error updating KYC status:", error);
    throw new functions.https.HttpsError("internal", error.message);
  }
});
