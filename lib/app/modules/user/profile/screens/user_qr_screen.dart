import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart'; // For sharing QR code
import '../controllers/user_qr_controller.dart';

class UserQrScreen extends GetView<UserQrController> {
  const UserQrScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Verification QR Code'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: controller.generateQrCode,
            tooltip: 'Refresh QR Code',
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.errorMessage.value.isNotEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    controller.errorMessage.value,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: controller.loadUserData,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          );
        }

        if (!controller.canGenerateQr.value) {
          return _buildNotVerifiedView();
        }

        return _buildQrCodeView(context);
      }),
    );
  }

  Widget _buildNotVerifiedView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.person_pin_circle, size: 64, color: Colors.orange),
            const SizedBox(height: 24),
            const Text(
              'KYC Verification Required',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Text(
              'Your KYC status is: ${controller.kycStatus.value.capitalize}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 24),
            const Text(
              'Please complete your KYC verification to generate your verification QR code.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () => Get.toNamed('/kyc-upload'),
              child: const Text('Complete KYC Verification'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQrCodeView(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // User info card
          Card(
            margin: const EdgeInsets.only(bottom: 24.0),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  const CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.blue,
                    child: Icon(Icons.person, size: 40, color: Colors.white),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    controller.userName.value,
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    controller.userPhone.value,
                    style: const TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.green.shade100,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.verified_user,
                            size: 16, color: Colors.green.shade700),
                        const SizedBox(width: 4),
                        Text(
                          'KYC Verified',
                          style: TextStyle(
                              color: Colors.green.shade700,
                              fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // QR code container
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.3),
                  spreadRadius: 2,
                  blurRadius: 5,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                const Text(
                  'Your Verification QR Code',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Show this to pawnbrokers for verification',
                  style: TextStyle(color: Colors.black54),
                ),
                const SizedBox(height: 24),
                // QR Code
                Obx(() {
                  if (controller.qrData.isEmpty) {
                    return const SizedBox(
                      height: 250,
                      child: Center(
                        child: Text('QR Code data is empty',
                            style: TextStyle(color: Colors.red)),
                      ),
                    );
                  }

                  return QrImageView(
                    data: controller.qrData.value,
                    version: QrVersions.auto,
                    size: 250,
                    backgroundColor: Colors.white,
                    errorStateBuilder: (context, error) {
                      return const Center(
                        child: Text(
                          'Error generating QR code',
                          style: TextStyle(color: Colors.red),
                        ),
                      );
                    },
                  );
                }),
                const SizedBox(height: 24),
                const Text(
                  'Valid for 24 hours',
                  style: TextStyle(
                      color: Colors.black54, fontStyle: FontStyle.italic),
                ),
              ],
            ),
          ),

          // Share button
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () => _shareQrCode(context),
            icon: const Icon(Icons.share),
            label: const Text('Share QR Code'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),

          const SizedBox(height: 16),
          const Text(
            'Note: This QR code contains your verified identity information. Only share it with trusted pawnbrokers.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  void _shareQrCode(BuildContext context) {
    // TODO: Implement QR code sharing with an image
    // For now, just call the controller method
    controller.shareQrCode();
  }
}
