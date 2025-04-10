import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:bidmygoldflutter/app/modules/user/loan_request/controllers/loan_request_controller.dart';
import 'package:image_picker/image_picker.dart';

class LoanRequestReviewScreen extends GetView<LoanRequestController> {
  const LoanRequestReviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('review_request'.tr),
        elevation: 0,
      ),
      body: Obx(() => controller.isLoading.value
          ? const Center(child: CircularProgressIndicator())
          : _buildReviewContent()),
    );
  }

  Widget _buildReviewContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header section
          Center(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  const Icon(Icons.check_circle, color: Colors.green, size: 48),
                  const SizedBox(height: 8),
                  Text(
                    'review_instruction'.tr,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'review_verify'.tr,
                    style: TextStyle(color: Colors.grey[600], fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Jewel Details Section
          _buildSectionTitle('jewel_details_section'.tr),
          const SizedBox(height: 16),
          _buildInfoRow('jewel_type'.tr, controller.jewelTypeController.text),
          _buildInfoRow(
              'jewel_weight'.tr, '${controller.jewelWeightController.text} g'),
          _buildInfoRow('jewel_purity'.tr, controller.jewelPurity.value),
          const SizedBox(height: 24),

          // Photos Section
          _buildSectionTitle('photos_section'.tr),
          const SizedBox(height: 16),
          _buildPhotoGrid(),
          const SizedBox(height: 16),

          // Video Section (if available)
          if (controller.jewelVideo.value != null) ...[
            _buildSectionTitle('video_section'.tr),
            const SizedBox(height: 16),
            _buildVideoPreview(),
            const SizedBox(height: 24),
          ],

          // Loan Details Section
          _buildSectionTitle('loan_details_section'.tr),
          const SizedBox(height: 16),
          _buildInfoRow('enter_requested_amount'.tr,
              '₹${controller.loanAmountController.text}'),
          if (controller.loanPurposeController.text.isNotEmpty)
            _buildInfoRow(
                'loan_purpose'.tr, controller.loanPurposeController.text),
          _buildInfoRow('loan_tenure'.tr,
              '${controller.loanTenure.value} ${'months'.tr}'),
          _buildInfoRow('estimated_monthly_payment'.tr.split(': ')[0],
              '₹${controller.estimatedMonthlyPayment.value.toStringAsFixed(2)}'),
          const SizedBox(height: 32),

          // Submit Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Get.back(),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: Text('edit_request'.tr),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: _submitFinalRequest,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: Text('submit_final_request'.tr),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  void _submitFinalRequest() async {
    try {
      // Submit the loan request to Firestore
      await controller.submitFinalLoanRequest();

      // Navigate to home or a success screen
      Get.offAllNamed('/home'); // Adjust this route as needed
    } catch (e) {
      Get.snackbar('Error', 'Failed to submit request: $e');
    }
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

  // Helper to build info rows
  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: TextStyle(color: Colors.grey[600]),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  // Helper to build photo grid
  Widget _buildPhotoGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: controller.jewelPhotos.length,
      itemBuilder: (context, index) {
        final photo = controller.jewelPhotos[index];
        return ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.file(
            File(photo.path),
            fit: BoxFit.cover,
          ),
        );
      },
    );
  }

  // Helper to build video preview
  Widget _buildVideoPreview() {
    if (controller.jewelVideo.value == null) {
      return const SizedBox.shrink();
    }

    return Container(
      height: 200,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.asset(
              'assets/images/video_placeholder.png', // You'll need to add this asset
              fit: BoxFit.cover,
              width: double.infinity,
              errorBuilder: (context, error, stackTrace) {
                return Icon(
                  Icons.video_file,
                  size: 64,
                  color: Colors.grey[400],
                );
              },
            ),
          ),
          Icon(
            Icons.play_circle_fill,
            size: 64,
            color: Colors.white.withOpacity(0.8),
          ),
          Positioned(
            bottom: 8,
            left: 8,
            child: Text(
              'video_attached'.tr,
              style: TextStyle(
                color: Colors.white,
                backgroundColor: Colors.black.withOpacity(0.5),
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
