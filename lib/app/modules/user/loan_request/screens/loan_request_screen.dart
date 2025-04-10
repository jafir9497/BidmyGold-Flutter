import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:bidmygoldflutter/app/modules/user/loan_request/controllers/loan_request_controller.dart';
import 'package:image_picker/image_picker.dart';

class LoanRequestScreen extends GetView<LoanRequestController> {
  const LoanRequestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('loan_request'.tr),
        elevation: 0,
      ),
      body: Obx(() => controller.isLoading.value
          ? const Center(child: CircularProgressIndicator())
          : _buildForm()),
    );
  }

  Widget _buildForm() {
    return Form(
      key: controller.formKey,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Jewel Details Section
            _buildSectionTitle('jewel_details'.tr),
            const SizedBox(height: 16),

            // Jewel Type
            TextFormField(
              controller: controller.jewelTypeController,
              decoration: InputDecoration(
                labelText: 'jewel_type'.tr,
                hintText: 'enter_jewel_type'.tr,
                border: const OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter jewel type';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Jewel Weight
            TextFormField(
              controller: controller.jewelWeightController,
              decoration: InputDecoration(
                labelText: 'jewel_weight'.tr,
                border: const OutlineInputBorder(),
                suffixText: 'g',
              ),
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter jewel weight';
                }
                try {
                  double weight = double.parse(value);
                  if (weight <= 0) {
                    return 'Weight must be greater than 0';
                  }
                } catch (e) {
                  return 'Please enter a valid number';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Jewel Purity
            _buildDropdownField(
              label: 'jewel_purity'.tr,
              value: controller.jewelPurity.value,
              items: controller.purityOptions.map((purity) {
                return DropdownMenuItem(
                  value: purity,
                  child: Text(purity),
                );
              }).toList(),
              onChanged: (String? value) {
                if (value != null) {
                  controller.updatePurity(value);
                }
              },
            ),
            const SizedBox(height: 24),

            // Photo Upload Section
            _buildSectionTitle('upload_jewel_photos'.tr),
            const SizedBox(height: 8),
            Text(
              'photo_instruction'.tr,
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
            ),
            const SizedBox(height: 16),

            // Photo Grid
            _buildPhotoGrid(),
            const SizedBox(height: 24),

            // Video Upload Section (Optional)
            _buildSectionTitle('record_video'.tr),
            const SizedBox(height: 8),
            Text(
              'video_instruction'.tr,
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
            ),
            const SizedBox(height: 16),

            // Video Upload/Preview
            _buildVideoUpload(),
            const SizedBox(height: 24),

            // Loan Amount Section
            _buildSectionTitle('loan_amount_request'.tr),
            const SizedBox(height: 16),

            // Display max eligible amount
            Obx(() => Text(
                  'max_eligible_amount'.tr.replaceAll(
                      '{0}', controller.maxLoanAmount.value.toStringAsFixed(2)),
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16),
                )),
            const SizedBox(height: 16),

            // Loan Amount
            TextFormField(
              controller: controller.loanAmountController,
              decoration: InputDecoration(
                labelText: 'enter_requested_amount'.tr,
                border: const OutlineInputBorder(),
                prefixText: '₹ ',
              ),
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter loan amount';
                }
                try {
                  double amount = double.parse(value);
                  if (amount <= 0) {
                    return 'Amount must be greater than 0';
                  }
                  if (controller.maxLoanAmount.value > 0 &&
                      amount > controller.maxLoanAmount.value) {
                    return 'Amount exceeds maximum eligible amount';
                  }
                } catch (e) {
                  return 'Please enter a valid number';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Loan Purpose (Optional)
            TextFormField(
              controller: controller.loanPurposeController,
              decoration: InputDecoration(
                labelText: 'loan_purpose'.tr,
                hintText: 'loan_purpose_hint'.tr,
                border: const OutlineInputBorder(),
              ),
              maxLines: 2,
              // No validator as this is optional
            ),
            const SizedBox(height: 16),

            // Loan Tenure
            _buildDropdownField(
              label: 'loan_tenure'.tr,
              value: controller.loanTenure.value,
              items: controller.tenureOptions.map((tenure) {
                return DropdownMenuItem(
                  value: tenure,
                  child: Text('$tenure ${'months'.tr}'),
                );
              }).toList(),
              onChanged: (int? value) {
                if (value != null) {
                  controller.updateTenure(value);
                }
              },
            ),
            const SizedBox(height: 16),

            // Estimated Monthly Payment
            Obx(() => Text(
                  'estimated_monthly_payment'.tr.replaceAll(
                      '{0}',
                      controller.estimatedMonthlyPayment.value
                          .toStringAsFixed(2)),
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16),
                )),
            const SizedBox(height: 32),

            // Submit Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: controller.submitLoanRequest,
                child: Text('submit_request'.tr,
                    style: const TextStyle(fontSize: 16)),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  // Helper to build section titles
  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  // Helper to build dropdown fields
  Widget _buildDropdownField<T>({
    required String label,
    required T value,
    required List<DropdownMenuItem<T>> items,
    required void Function(T?) onChanged,
  }) {
    return InputDecorator(
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          isDense: true,
          isExpanded: true,
          items: items,
          onChanged: onChanged,
        ),
      ),
    );
  }

  // Helper to build photo grid
  Widget _buildPhotoGrid() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Photo grid
        Obx(() => controller.jewelPhotos.isEmpty
            ? _buildEmptyPhotosPlaceholder()
            : GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                  childAspectRatio: 1,
                ),
                itemCount:
                    controller.jewelPhotos.length + 1, // +1 for add button
                itemBuilder: (context, index) {
                  if (index < controller.jewelPhotos.length) {
                    // Photo item
                    return _buildPhotoItem(index);
                  } else {
                    // Add photo button
                    return _buildAddPhotoButton();
                  }
                },
              )),

        // Photo count indicator
        Obx(() => Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(
                '${controller.jewelPhotos.length}/3 ${controller.jewelPhotos.length < 3 ? 'min_3_photos_required'.tr : ''}',
                style: TextStyle(
                  color: controller.jewelPhotos.length < 3
                      ? Colors.red
                      : Colors.green,
                  fontSize: 14,
                ),
              ),
            )),
      ],
    );
  }

  // Helper to build empty photos placeholder
  Widget _buildEmptyPhotosPlaceholder() {
    return Container(
      height: 120,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.photo_camera, size: 40, color: Colors.grey.shade400),
            const SizedBox(height: 8),
            Text(
              'min_3_photos_required'.tr,
              style: TextStyle(color: Colors.grey.shade600),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _showPhotoOptions,
              child: Text('add_photo'.tr),
            ),
          ],
        ),
      ),
    );
  }

  // Helper to build a photo item
  Widget _buildPhotoItem(int index) {
    return Stack(
      children: [
        // Photo
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
            image: DecorationImage(
              image: FileImage(File(controller.jewelPhotos[index].path)),
              fit: BoxFit.cover,
            ),
          ),
        ),

        // Remove button
        Positioned(
          top: 4,
          right: 4,
          child: GestureDetector(
            onTap: () => controller.removePhotoAt(index),
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: Colors.black54,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.close,
                size: 16,
                color: Colors.white,
              ),
            ),
          ),
        ),

        // Photo label
        Positioned(
          bottom: 4,
          left: 4,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.black54,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              index < 3 ? '${'photo'.tr} ${index + 1}' : 'additional_photos'.tr,
              style: const TextStyle(color: Colors.white, fontSize: 10),
            ),
          ),
        ),
      ],
    );
  }

  // Helper to build add photo button
  Widget _buildAddPhotoButton() {
    return GestureDetector(
      onTap: _showPhotoOptions,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Icon(
            Icons.add_a_photo,
            size: 36,
            color: Colors.grey.shade400,
          ),
        ),
      ),
    );
  }

  // Helper to show photo options (Camera or Gallery)
  void _showPhotoOptions() {
    Get.bottomSheet(
      Container(
        color: Colors.white,
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'add_photo'.tr,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: Text('camera'.tr),
              onTap: () {
                Get.back();
                controller.pickJewelPhoto();
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: Text('gallery'.tr),
              onTap: () {
                Get.back();
                controller.pickJewelPhotoFromGallery();
              },
            ),
          ],
        ),
      ),
    );
  }

  // Helper to build video upload section
  Widget _buildVideoUpload() {
    return Obx(() {
      if (controller.jewelVideo.value != null) {
        // Display selected video
        return Stack(
          children: [
            Container(
              height: 120,
              width: double.infinity,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
                color: Colors.black87,
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.videocam,
                      size: 36,
                      color: Colors.white,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'video'.tr,
                      style: const TextStyle(color: Colors.white),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      controller.jewelVideo.value!.name,
                      style:
                          const TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              top: 4,
              right: 4,
              child: GestureDetector(
                onTap: controller.removeVideo,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.close,
                    size: 16,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        );
      } else {
        // Show record button
        return SizedBox(
          height: 100,
          child: Center(
            child: ElevatedButton.icon(
              onPressed: controller.recordJewelVideo,
              icon: const Icon(Icons.videocam),
              label: Text('record_video'.tr),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
              ),
            ),
          ),
        );
      }
    });
  }
}
