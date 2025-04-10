import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:bidmygoldflutter/app/modules/user/kyc/controllers/kyc_controller.dart';
import 'package:bidmygoldflutter/app/modules/user/kyc/screens/selfie_guided_capture_screen.dart';

class KycScreen extends GetView<KycController> {
  const KycScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('upload_kyc'.tr),
        centerTitle: true,
        // Consider if back navigation is needed here or handled differently
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'kyc_instruction'.tr,
              style: Get.textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),

            // ID Proof Section
            _buildDocumentSection(
              titleKey: 'id_proof',
              fileVariable: controller.idProofFile,
              uploadingVariable: controller.idProofUploading,
              progressVariable: controller.idProofProgress,
              downloadUrlVariable: controller.idProofUrl,
            ),
            const SizedBox(height: 20),

            // Address Proof Section
            _buildDocumentSection(
              titleKey: 'address_proof',
              fileVariable: controller.addressProofFile,
              uploadingVariable: controller.addressProofUploading,
              progressVariable: controller.addressProofProgress,
              downloadUrlVariable: controller.addressProofUrl,
            ),
            const SizedBox(height: 20),

            // Selfie Section (New)
            _buildSelfieSection(),

            const SizedBox(height: 40),

            // Submit Button
            Obx(() => ElevatedButton(
                  onPressed: controller.isUploading.value ||
                          controller.idProofFile.value == null ||
                          controller.addressProofFile.value == null ||
                          controller.selfieFile.value == null
                      ? null // Disable if uploading or files not selected
                      : controller.submitKyc,
                  child: controller.isUploading.value
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white))
                      : Text('submit_kyc'.tr),
                )),
          ],
        ),
      ),
    );
  }

  // Helper widget for document upload sections
  Widget _buildDocumentSection({
    required String titleKey,
    required Rxn<XFile> fileVariable,
    required RxBool uploadingVariable,
    required RxDouble progressVariable,
    required RxnString downloadUrlVariable,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(titleKey.tr, style: Get.textTheme.titleMedium),
            const SizedBox(height: 15),
            Obx(() => fileVariable.value != null
                ? Column(
                    children: [
                      Image.file(
                        File(fileVariable.value!.path),
                        height: 150,
                        width: double.infinity,
                        fit: BoxFit.contain,
                      ),
                      const SizedBox(height: 10),
                    ],
                  )
                : Container(
                    height: 100,
                    width: double.infinity,
                    color: Colors.grey[200],
                    child: Center(child: Text('no_file_selected'.tr)),
                  )),
            Obx(() {
              if (uploadingVariable.value) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: LinearProgressIndicator(value: progressVariable.value),
                );
              } else if (downloadUrlVariable.value != null) {
                return Text('upload_complete'.tr,
                    style: TextStyle(color: Colors.green));
              } else {
                return const SizedBox.shrink();
              }
            }),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: () =>
                      controller.pickImage(ImageSource.camera, fileVariable),
                  icon: const Icon(Icons.camera_alt),
                  label: Text('camera'.tr),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[700]),
                ),
                ElevatedButton.icon(
                  onPressed: () =>
                      controller.pickImage(ImageSource.gallery, fileVariable),
                  icon: const Icon(Icons.photo_library),
                  label: Text('gallery'.tr),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[700]),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  // New Helper widget for the selfie section
  Widget _buildSelfieSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('selfie'.tr,
                style: Get.textTheme.titleMedium), // Use 'selfie' key
            const SizedBox(height: 10),
            Text('selfie_instruction'.tr,
                style: Get.textTheme.bodySmall), // Instruction text
            const SizedBox(height: 15),
            Obx(() => controller.selfieFile.value != null
                ? Column(
                    children: [
                      Image.file(
                        File(controller.selfieFile.value!.path),
                        height: 150,
                        width: double.infinity,
                        fit: BoxFit.contain,
                      ),
                      const SizedBox(height: 10),
                    ],
                  )
                : Container(
                    height: 100,
                    width: double.infinity,
                    color: Colors.grey[200],
                    child: Center(
                        child: Text(
                            'no_file_selected'.tr)), // Re-use no file selected
                  )),
            // Simple upload indicator for selfie (could reuse progress bar if needed)
            Obx(() {
              if (controller.selfieUploading.value) {
                // Check the local variable in the controller if you implement more detailed state
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                          height: 15,
                          width: 15,
                          child: CircularProgressIndicator(strokeWidth: 2)),
                      SizedBox(width: 10),
                      Text('selfie_uploading'.tr),
                    ],
                  ),
                );
              } else if (controller.selfieUrl.value != null) {
                return Text(
                    'selfie_capture_complete'.tr, // Use selfie complete key
                    style: TextStyle(color: Colors.green));
              } else {
                return const SizedBox.shrink();
              }
            }),
            const SizedBox(height: 10),
            Center(
              child: ElevatedButton.icon(
                onPressed: () => _showSelfieInstructions(Get.context!),
                icon: const Icon(Icons.camera_enhance), // Selfie-like icon
                label: Obx(() => Text(controller.selfieFile.value == null
                    ? 'take_selfie'.tr
                    : 'retake_selfie'.tr)), // Dynamic button text
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent),
              ),
            )
          ],
        ),
      ),
    );
  }

  // Show selfie instructions screen
  void _showSelfieInstructions(BuildContext context) {
    Get.to(() => SelfieGuidedCaptureScreen(
          onComplete: (XFile image) {
            controller.selfieFile.value = image;
          },
        ));
  }
}
