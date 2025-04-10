import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:bidmygoldflutter/app/modules/pawnbroker/registration/controllers/pawnbroker_registration_controller.dart';
import 'package:image_picker/image_picker.dart';

class PawnbrokerRegistrationScreen
    extends GetView<PawnbrokerRegistrationController> {
  const PawnbrokerRegistrationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('pawnbroker_registration'.tr),
        elevation: 0,
      ),
      body: Obx(() => controller.isLoading.value
          ? const Center(child: CircularProgressIndicator())
          : _buildStepper()),
    );
  }

  Widget _buildStepper() {
    return Stepper(
      currentStep: controller.currentStep.value,
      onStepContinue: () {
        if (controller.currentStep.value == 2) {
          controller.submitRegistration();
        } else {
          controller.nextStep();
        }
      },
      onStepCancel: controller.previousStep,
      controlsBuilder: (context, details) {
        return Padding(
          padding: const EdgeInsets.only(top: 20.0),
          child: Row(
            children: [
              if (controller.currentStep.value > 0)
                Expanded(
                  child: OutlinedButton(
                    onPressed: details.onStepCancel,
                    child: Text('previous'.tr),
                  ),
                ),
              if (controller.currentStep.value > 0) const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: details.onStepContinue,
                  child: Text(
                    controller.currentStep.value == 2 ? 'submit'.tr : 'next'.tr,
                  ),
                ),
              ),
            ],
          ),
        );
      },
      steps: [
        Step(
          title: Text('shop_information'.tr),
          content: _buildShopInfoForm(),
          isActive: controller.currentStep.value >= 0,
          state: controller.currentStep.value > 0
              ? StepState.complete
              : StepState.indexed,
        ),
        Step(
          title: Text('document_upload'.tr),
          content: _buildDocumentUploadForm(),
          isActive: controller.currentStep.value >= 1,
          state: controller.currentStep.value > 1
              ? StepState.complete
              : StepState.indexed,
        ),
        Step(
          title: Text('additional_details'.tr),
          content: _buildAdditionalDetailsForm(),
          isActive: controller.currentStep.value >= 2,
          state: controller.currentStep.value > 2
              ? StepState.complete
              : StepState.indexed,
        ),
      ],
    );
  }

  Widget _buildShopInfoForm() {
    return Form(
      key: controller.formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextFormField(
            controller: controller.shopNameController,
            decoration: InputDecoration(
              labelText: 'shop_name'.tr,
              border: const OutlineInputBorder(),
            ),
            validator: controller.validateShopName,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: controller.ownerNameController,
            decoration: InputDecoration(
              labelText: 'owner_name'.tr,
              border: const OutlineInputBorder(),
            ),
            validator: controller.validateOwnerName,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: controller.addressController,
            decoration: InputDecoration(
              labelText: 'address'.tr,
              border: const OutlineInputBorder(),
            ),
            maxLines: 3,
            validator: controller.validateAddress,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: controller.cityController,
                  decoration: InputDecoration(
                    labelText: 'city'.tr,
                    border: const OutlineInputBorder(),
                  ),
                  validator: controller.validateCity,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextFormField(
                  controller: controller.stateController,
                  decoration: InputDecoration(
                    labelText: 'state'.tr,
                    border: const OutlineInputBorder(),
                  ),
                  validator: controller.validateState,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: controller.pinCodeController,
            decoration: InputDecoration(
              labelText: 'pin_code'.tr,
              border: const OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
            maxLength: 6,
            validator: controller.validatePinCode,
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: controller.emailController,
            decoration: InputDecoration(
              labelText: 'email_optional'.tr,
              border: const OutlineInputBorder(),
            ),
            keyboardType: TextInputType.emailAddress,
            validator: controller.validateEmail,
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentUploadForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'upload_documents_instruction'.tr,
          style: TextStyle(color: Colors.grey[600], fontSize: 14),
        ),
        const SizedBox(height: 24),

        // Shop License Upload
        _buildDocumentSection(
          title: 'shop_license'.tr,
          description: 'shop_license_description'.tr,
          file: controller.shopLicenseFile.value,
          isUploading: controller.uploadingShopLicense.value,
          fileUrl: controller.shopLicenseUrl.value,
          onPickCamera: () => controller.pickImage(
            ImageSource.camera,
            controller.shopLicenseFile,
          ),
          onPickGallery: () => controller.pickImage(
            ImageSource.gallery,
            controller.shopLicenseFile,
          ),
          onUpload: controller.uploadShopLicense,
        ),
        const Divider(height: 32),

        // ID Proof Upload
        _buildDocumentSection(
          title: 'id_proof'.tr,
          description: 'id_proof_description'.tr,
          file: controller.idProofFile.value,
          isUploading: controller.uploadingIdProof.value,
          fileUrl: controller.idProofUrl.value,
          onPickCamera: () => controller.pickImage(
            ImageSource.camera,
            controller.idProofFile,
          ),
          onPickGallery: () => controller.pickImage(
            ImageSource.gallery,
            controller.idProofFile,
          ),
          onUpload: controller.uploadIdProof,
        ),
        const Divider(height: 32),

        // Shop Photo Upload (Optional)
        _buildDocumentSection(
          title: '${'shop_photo'.tr} (${'optional'.tr})',
          description: 'shop_photo_description'.tr,
          file: controller.shopPhotoFile.value,
          isUploading: controller.uploadingShopPhoto.value,
          fileUrl: controller.shopPhotoUrl.value,
          onPickCamera: () => controller.pickImage(
            ImageSource.camera,
            controller.shopPhotoFile,
          ),
          onPickGallery: () => controller.pickImage(
            ImageSource.gallery,
            controller.shopPhotoFile,
          ),
          onUpload: controller.uploadShopPhoto,
          isOptional: true,
        ),
      ],
    );
  }

  Widget _buildDocumentSection({
    required String title,
    required String description,
    required XFile? file,
    required bool isUploading,
    required String? fileUrl,
    required VoidCallback onPickCamera,
    required VoidCallback onPickGallery,
    required VoidCallback onUpload,
    bool isOptional = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          description,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 16),

        // Preview of selected file
        if (file != null || fileUrl != null)
          Stack(
            children: [
              Container(
                height: 150,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: file != null
                      ? Image.file(
                          File(file.path),
                          fit: BoxFit.cover,
                        )
                      : fileUrl != null
                          ? Image.network(
                              fileUrl,
                              fit: BoxFit.cover,
                              loadingBuilder: (_, child, loadingProgress) {
                                if (loadingProgress == null) return child;
                                return Center(
                                  child: CircularProgressIndicator(
                                    value: loadingProgress.expectedTotalBytes !=
                                            null
                                        ? loadingProgress
                                                .cumulativeBytesLoaded /
                                            loadingProgress.expectedTotalBytes!
                                        : null,
                                  ),
                                );
                              },
                            )
                          : const SizedBox(),
                ),
              ),

              // Upload indicator or upload button
              if (file != null && fileUrl == null)
                Positioned(
                  right: 8,
                  top: 8,
                  child: isUploading
                      ? const CircularProgressIndicator()
                      : IconButton(
                          icon: const Icon(Icons.upload_file),
                          onPressed: onUpload,
                          tooltip: 'upload'.tr,
                          color: Colors.blue,
                        ),
                ),
            ],
          )
        else
          Container(
            height: 100,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Center(
              child: Text(
                'no_file_selected'.tr,
                style: TextStyle(color: Colors.grey[500]),
              ),
            ),
          ),
        const SizedBox(height: 16),

        // Camera and Gallery buttons
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: onPickCamera,
                icon: const Icon(Icons.camera_alt),
                label: Text('camera'.tr),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[700],
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: onPickGallery,
                icon: const Icon(Icons.photo_library),
                label: Text('gallery'.tr),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[600],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAdditionalDetailsForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // License number
        TextFormField(
          controller: controller.licenseNumberController,
          decoration: InputDecoration(
            labelText: 'license_number'.tr,
            border: const OutlineInputBorder(),
          ),
          validator: controller.validateLicenseNumber,
        ),
        const SizedBox(height: 16),

        // GST number (optional)
        TextFormField(
          controller: controller.gstNumberController,
          decoration: InputDecoration(
            labelText: '${'gst_number'.tr} (${'optional'.tr})',
            border: const OutlineInputBorder(),
          ),
          validator: controller.validateGstNumber,
        ),
        const SizedBox(height: 24),

        // Experience
        Text(
          'years_of_experience'.tr,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),

        ...controller.experienceOptions
            .map((exp) => Obx(() => RadioListTile<String>(
                  title: Text(exp),
                  value: exp,
                  groupValue: controller.selectedExperience.value,
                  onChanged: (value) {
                    if (value != null) {
                      controller.selectExperience(value);
                    }
                  },
                ))),

        const SizedBox(height: 16),
        const Divider(),
        const SizedBox(height: 16),

        // Terms and conditions
        Text(
          'registration_note'.tr,
          style: TextStyle(
            color: Colors.grey[700],
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}
