import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:bidmygoldflutter/app/theme/app_theme.dart';
import '../controllers/pawnbroker_registration_controller.dart';

class PawnbrokerRegistrationScreen extends GetView<PawnbrokerRegistrationController> {
  const PawnbrokerRegistrationScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
        title: const Text('Pawnbroker Registration'),
      ),
      body: Obx(() => Stepper(
            currentStep: controller.currentStep.value,
            onStepContinue: controller.nextStep,
            onStepCancel: controller.previousStep,
            controlsBuilder: (context, details) => Padding(
              padding: const EdgeInsets.only(top: 24),
              child: Row(
                children: [
                  if (details.currentStep > 0)
                    Expanded(
                      child: OutlinedButton(
                        onPressed: details.onStepCancel,
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('Previous'),
                      ),
                    ),
                  if (details.currentStep > 0) const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: details.onStepContinue,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: Text(
                        details.currentStep == 3 ? 'Submit' : 'Next',
                      ),
                    ),
                  ),
                ],
              ),
            ),
            steps: [
              _buildBasicInfoStep(),
              _buildBusinessInfoStep(),
              _buildDocumentsStep(),
              _buildVerificationStep(),
            ],
          )),
    );
  }

  Step _buildBasicInfoStep() {
    return Step(
      title: const Text('Basic Information'),
      content: Form(
        key: controller.formKey,
        child: Column(
          children: [
            TextFormField(
              controller: controller.shopNameController,
              decoration: const InputDecoration(
                labelText: 'Shop Name',
                hintText: 'Enter your shop name',
              ),
              validator: controller.validateShopName,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: controller.ownerNameController,
              decoration: const InputDecoration(
                labelText: 'Owner Name',
                hintText: 'Enter owner\'s full name',
              ),
              validator: controller.validateOwnerName,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: controller.addressController,
              decoration: const InputDecoration(
                labelText: 'Shop Address',
                hintText: 'Enter complete shop address',
              ),
              validator: controller.validateAddress,
              maxLines: 3,
            ),
          ],
        ),
      ),
      isActive: controller.currentStep.value >= 0,
    );
  }

  Step _buildBusinessInfoStep() {
    return Step(
      title: const Text('Business Details'),
      content: Column(
        children: [
          TextFormField(
            controller: controller.gstNumberController,
            decoration: const InputDecoration(
              labelText: 'GST Number',
              hintText: 'Enter GST registration number',
            ),
            validator: controller.validateGstNumber,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: controller.licenseNumberController,
            decoration: const InputDecoration(
              labelText: 'License Number',
              hintText: 'Enter business license number',
            ),
            validator: controller.validateLicenseNumber,
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: controller.selectedExperience.value,
            decoration: const InputDecoration(
              labelText: 'Experience',
            ),
            items: controller.experienceOptions
                .map((exp) => DropdownMenuItem(
                      value: exp,
                      child: Text(exp),
                    ))
                .toList(),
            onChanged: (value) => controller.selectExperience(value ?? ''),
          ),
        ],
      ),
      isActive: controller.currentStep.value >= 1,
    );
  }

  Step _buildDocumentsStep() {
    return Step(
      title: const Text('Documents'),
      content: Column(
        children: [
          _buildDocumentUpload(
            title: 'Shop License',
            description: 'Upload your shop license',
            file: controller.shopLicenseFile.value,
            isUploading: controller.uploadingShopLicense.value,
            onPickCamera: () =>
                controller.pickImage(ImageSource.camera, controller.shopLicenseFile),
            onPickGallery: () =>
                controller.pickImage(ImageSource.gallery, controller.shopLicenseFile),
            onUpload: controller.uploadShopLicense,
          ),
          const SizedBox(height: 24),
          _buildDocumentUpload(
            title: 'ID Proof',
            description: 'Upload any government ID proof',
            file: controller.idProofFile.value,
            isUploading: controller.uploadingIdProof.value,
            onPickCamera: () =>
                controller.pickImage(ImageSource.camera, controller.idProofFile),
            onPickGallery: () =>
                controller.pickImage(ImageSource.gallery, controller.idProofFile),
            onUpload: controller.uploadIdProof,
          ),
        ],
      ),
      isActive: controller.currentStep.value >= 2,
    );
  }

  Step _buildVerificationStep() {
    return Step(
      title: const Text('Verification'),
      content: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Please verify all information is correct before submitting.',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 16),
            _buildVerificationItem('Shop Name', controller.shopNameController.text),
            _buildVerificationItem('Owner Name', controller.ownerNameController.text),
            _buildVerificationItem('Address', controller.addressController.text),
            _buildVerificationItem('GST Number', controller.gstNumberController.text),
            _buildVerificationItem(
                'License Number', controller.licenseNumberController.text),
            _buildVerificationItem('Experience', controller.selectedExperience.value),
          ],
        ),
      ),
      isActive: controller.currentStep.value >= 3,
    );
  }

  Widget _buildDocumentUpload({
    required String title,
    required String description,
    required XFile? file,
    required bool isUploading,
    required VoidCallback onPickCamera,
    required VoidCallback onPickGallery,
    required VoidCallback onUpload,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: AppTheme.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Get.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: Get.textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onPickCamera,
                  icon: const Icon(Icons.camera_alt),
                  label: const Text('Camera'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onPickGallery,
                  icon: const Icon(Icons.photo_library),
                  label: const Text('Gallery'),
                ),
              ),
            ],
          ),
          if (file != null) ...[
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Text(
                    file.name,
                    style: Get.textTheme.bodyMedium,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: isUploading ? null : onUpload,
                  child: isUploading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text('Upload'),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildVerificationItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Get.textTheme.bodyMedium?.copyWith(
              color: AppTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: Get.textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
