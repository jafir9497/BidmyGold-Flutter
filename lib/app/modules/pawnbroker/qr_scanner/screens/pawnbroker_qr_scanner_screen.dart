import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../controllers/pawnbroker_qr_scanner_controller.dart';

// Assuming UserModel exists and has necessary fields
// import '../../../data/models/user_model.dart'; // Adjust import path if needed

// Enum to represent verification status clearly (Moved outside class)
enum VerificationStatus { success, error, notVerified }

class PawnbrokerQrScannerScreen extends GetView<PawnbrokerQrScannerController> {
  const PawnbrokerQrScannerScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan User QR Code'),
      ),
      body: Obx(() {
        // Show verification results if available
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        if (controller.errorMessage.value != null) {
          return _buildResultView(
            icon: Icons.error_outline,
            color: Colors.red,
            message: controller.errorMessage.value!,
            user:
                controller.verifiedUser.value, // Show partial info if available
            verificationStatus: VerificationStatus.error,
          );
        }
        if (controller.verifiedUser.value != null &&
            !controller.isScanning.value) {
          return _buildResultView(
            icon: Icons.verified_user,
            color: Colors.green,
            message: 'User Verified Successfully!',
            user: controller.verifiedUser.value!,
            verificationStatus: VerificationStatus.success,
          );
        }

        // Show Scanner View
        return Stack(
          alignment: Alignment.center,
          children: [
            MobileScanner(
              controller: controller.cameraController,
              onDetect: controller.onDetect,
              // Fit the scanner to the screen
              fit: BoxFit.cover,
            ),
            // Example overlay with instructions
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: Get.width * 0.7,
                  height: Get.width * 0.7,
                  decoration: BoxDecoration(
                    border: Border.all(
                        color: Colors.white.withOpacity(0.8), width: 3.0),
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.transparent,
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'Point camera at the User QR code',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
            // Temporarily remove Torch toggle button due to linter issues
            // Positioned(
            //   bottom: 30,
            //   child: IconButton(
            //     color: Colors.white,
            //     // Access torchState directly from the controller
            //     icon: ValueListenableBuilder<TorchState>(
            //        valueListenable: controller.cameraController.torchState,
            //        builder: (context, state, child) {
            //          // Handle potential null state if necessary, though usually defaults to off
            //          final currentTorchState = state ?? TorchState.off;
            //          switch (currentTorchState) {
            //            case TorchState.off:
            //              return const Icon(Icons.flash_off, color: Colors.grey);
            //            case TorchState.on:
            //              return const Icon(Icons.flash_on, color: Colors.yellow);
            //            default: // Handles unavailable or other states
            //               return const Icon(Icons.flash_off, color: Colors.grey);
            //          }
            //        },
            //     ),
            //     iconSize: 32.0,
            //     onPressed: () => controller.cameraController.toggleTorch(),
            //   ),
            // ),
          ],
        );
      }),
    );
  }

  // Builds the result view (success or error)
  Widget _buildResultView({
    required IconData icon,
    required Color color,
    required String message,
    required VerificationStatus verificationStatus,
    Map<String, dynamic>? user, // Use Map<String, dynamic> for user data
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 80, color: color),
            const SizedBox(height: 20),
            Text(
              message,
              style: Get.textTheme.headlineSmall?.copyWith(color: color),
              textAlign: TextAlign.center,
            ),
            // Display user details if available
            if (user != null) ...[
              const SizedBox(height: 20),
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.person_outline,
                              size: 18), // Use appropriate icons
                          const SizedBox(width: 8),
                          Text('Name: ${user['name'] ?? 'N/A'}',
                              style: Get.textTheme.titleMedium),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.phone_outlined, size: 18),
                          const SizedBox(width: 8),
                          Text('Phone: ${user['phoneNumber'] ?? 'N/A'}'),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          _buildKycStatusWidget(
                              user?['kycStatus']?.toString() ?? 'unknown'),
                          const SizedBox(width: 8),
                          Text(
                            'KYC Status: ${user?['kycStatus']?.toString().capitalize ?? 'Unknown'}',
                            style: TextStyle(
                                color: _getKycStatusColor(
                                    user?['kycStatus']?.toString() ??
                                        'unknown'),
                                fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
            const SizedBox(height: 30),
            ElevatedButton.icon(
              icon: const Icon(Icons.qr_code_scanner),
              label: const Text('Scan Again'),
              onPressed: controller.startScanAgain,
              style: ElevatedButton.styleFrom(
                backgroundColor: Get.theme.primaryColor,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                textStyle: const TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper to get appropriate icon/color for KYC status chip
  Widget _buildKycStatusWidget(String kycStatus) {
    IconData icon;
    Color color;
    switch (kycStatus.toLowerCase()) {
      case 'verified':
        icon = Icons.verified_outlined;
        color = Colors.green;
        break;
      case 'pending':
        icon = Icons.pending_outlined;
        color = Colors.orange;
        break;
      case 'rejected':
        icon = Icons.cancel_outlined;
        color = Colors.red;
        break;
      default:
        icon = Icons.help_outline;
        color = Colors.grey;
    }
    return Icon(icon, size: 18, color: color);
  }

  Color _getKycStatusColor(String kycStatus) {
    switch (kycStatus.toLowerCase()) {
      case 'verified':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
