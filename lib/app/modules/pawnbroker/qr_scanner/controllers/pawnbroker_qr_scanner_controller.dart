import 'package:get/get.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Assuming UserModel exists and has a fromJson method
// import '../../../data/models/user_model.dart'; // Adjust import path if needed

class PawnbrokerQrScannerController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final MobileScannerController cameraController = MobileScannerController();

  // State observables
  final RxBool isLoading = false.obs;
  final RxBool isScanning = true.obs; // Start in scanning mode
  final Rxn<Map<String, dynamic>> verifiedUser = Rxn<
      Map<String,
          dynamic>>(); // Store verified user data as a map for simplicity
  final Rxn<String> errorMessage = Rxn<String>();

  @override
  void onClose() {
    cameraController.dispose();
    super.onClose();
  }

  void onDetect(BarcodeCapture capture) async {
    if (isLoading.value || !isScanning.value) return;

    final List<Barcode> barcodes = capture.barcodes;
    final String? scannedData = barcodes.first.rawValue;

    if (scannedData != null && scannedData.isNotEmpty) {
      print("QR Code Detected: $scannedData"); // Log scanned data
      isScanning.value = false; // Stop scanning animations/overlays
      errorMessage.value = null;
      verifiedUser.value = null;

      await verifyUserById(scannedData);
    }
  }

  Future<void> verifyUserById(String userId) async {
    isLoading.value = true;
    errorMessage.value = null;
    verifiedUser.value = null;

    try {
      final userDoc = await _firestore.collection('users').doc(userId).get();

      if (!userDoc.exists) {
        throw Exception("User not found.");
      }

      final userData = userDoc.data();
      if (userData == null) {
        throw Exception("Failed to retrieve user data.");
      }

      final String kycStatus = userData['kycStatus'] ?? 'pending';

      verifiedUser.value = userData..['id'] = userDoc.id;

      if (kycStatus != 'verified') {
        throw Exception(
            "User KYC not verified (Status: ${kycStatus.capitalize})");
      }

      await _logScan(userId, true);
    } catch (e) {
      print("User Verification Error: $e");
      errorMessage.value = e.toString().replaceFirst("Exception: ", "");
      await _logScan(userId, false, errorMessage.value);
    } finally {
      isLoading.value = false;
    }
  }

  void startScanAgain() {
    errorMessage.value = null;
    verifiedUser.value = null;
    isLoading.value = false;
    isScanning.value = true;
    // Optional: Restart camera if it was stopped
    // if (!cameraController.isScanning) {
    //   cameraController.start();
    // }
  }

  // Optional: Log scan attempts
  Future<void> _logScan(String scannedUserId, bool success,
      [String? error]) async {
    try {
      // TODO: Replace with actual pawnbroker ID from auth service
      String pawnbrokerId = "PLACEHOLDER_PAWNBROKER_ID";

      await _firestore.collection('qr_scan_logs').add({
        'pawnbrokerId': pawnbrokerId,
        'scannedUserId': scannedUserId,
        'timestamp': FieldValue.serverTimestamp(),
        'success': success,
        'error': error, // Log error message if verification failed
        'location': null, // TODO: Add location data if available/required
      });
    } catch (e) {
      print("Failed to log QR scan: $e");
    }
  }
}
