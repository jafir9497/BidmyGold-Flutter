import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../controllers/pawnbroker_loan_request_details_controller.dart';
import '../../../../translations/app_translations.dart';

class PawnbrokerLoanRequestDetailsScreen
    extends GetView<PawnbrokerLoanRequestDetailsController> {
  const PawnbrokerLoanRequestDetailsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('loan_request_details'.tr),
        elevation: 0,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.loanRequestData.isEmpty) {
          return Center(child: Text('no_data_found'.tr));
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildUserInfoSection(),
              const SizedBox(height: 20),
              _buildLoanDetailsSection(),
              const SizedBox(height: 20),
              _buildJewelPhotosSection(),
              const SizedBox(height: 20),
              _buildYourBidSection(),
              const SizedBox(height: 30),
              _buildActionButton(),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildUserInfoSection() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'customer_details'.tr,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(Icons.person, size: 18),
                const SizedBox(width: 8),
                Text(
                  '${'name'.tr}: ${controller.userData['name'] ?? 'N/A'}',
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.phone, size: 18),
                const SizedBox(width: 8),
                Text(
                  '${'phone'.tr}: ${controller.userData['phone'] ?? 'N/A'}',
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
            if (controller.userData['email'] != null &&
                controller.userData['email'].isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Row(
                  children: [
                    const Icon(Icons.email, size: 18),
                    const SizedBox(width: 8),
                    Text(
                      '${'email'.tr}: ${controller.userData['email']}',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoanDetailsSection() {
    final createdAt = controller.loanRequestData['createdAt'] != null
        ? controller.formatTimestamp(controller.loanRequestData['createdAt'])
        : 'N/A';

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'loan_details'.tr,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            _buildDetailRow('requested_amount'.tr,
                '₹${controller.loanRequestData['requestedAmount'] ?? 'N/A'}'),
            _buildDetailRow('gold_weight'.tr,
                '${controller.loanRequestData['goldWeight'] ?? 'N/A'} ${'grams'.tr}'),
            _buildDetailRow('gold_purity'.tr,
                '${controller.loanRequestData['goldPurity'] ?? 'N/A'} K'),
            _buildDetailRow('status'.tr,
                '${controller.loanRequestData['status'] ?? 'pending'.tr}'),
            _buildDetailRow('created_at'.tr, createdAt),
            if (controller.loanRequestData['description'] != null &&
                controller.loanRequestData['description'].isNotEmpty)
              _buildDetailRow(
                  'description'.tr, controller.loanRequestData['description']),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildJewelPhotosSection() {
    final List<dynamic> photos =
        controller.loanRequestData['jewelPhotos'] ?? [];

    if (photos.isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'jewel_photos'.tr,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 120,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: photos.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: GestureDetector(
                      onTap: () {
                        // Show full screen image view
                        Get.to(() => Scaffold(
                              appBar: AppBar(
                                backgroundColor: Colors.black,
                                elevation: 0,
                              ),
                              backgroundColor: Colors.black,
                              body: Center(
                                child: InteractiveViewer(
                                  child: Image.network(
                                    photos[index],
                                    fit: BoxFit.contain,
                                    loadingBuilder:
                                        (context, child, loadingProgress) {
                                      if (loadingProgress == null) return child;
                                      return Center(
                                          child: CircularProgressIndicator());
                                    },
                                    errorBuilder: (context, error, stackTrace) {
                                      return Center(child: Icon(Icons.error));
                                    },
                                  ),
                                ),
                              ),
                            ));
                      },
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          photos[index],
                          width: 120,
                          height: 120,
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return SizedBox(
                              width: 120,
                              height: 120,
                              child: Center(
                                child: CircularProgressIndicator(
                                  value: loadingProgress.expectedTotalBytes !=
                                          null
                                      ? loadingProgress.cumulativeBytesLoaded /
                                          loadingProgress.expectedTotalBytes!
                                      : null,
                                ),
                              ),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              width: 120,
                              height: 120,
                              color: Colors.grey[300],
                              child: const Icon(Icons.error),
                            );
                          },
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildYourBidSection() {
    return Obx(() {
      if (controller.existingBid.value == null) {
        return const SizedBox.shrink();
      }

      final bid = controller.existingBid.value!;

      return Card(
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'your_bid'.tr,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              _buildDetailRow(
                  'offered_amount'.tr, '₹${bid['offeredAmount'] ?? 'N/A'}'),
              _buildDetailRow(
                  'interest_rate'.tr, '${bid['interestRate'] ?? 'N/A'}%'),
              _buildDetailRow('loan_tenure'.tr,
                  '${bid['loanTenure'] ?? 'N/A'} ${'months'.tr}'),
              if (bid['note'] != null && bid['note'].toString().isNotEmpty)
                _buildDetailRow('note'.tr, bid['note']),
              _buildDetailRow(
                  'bid_status'.tr, '${bid['status'] ?? 'pending'.tr}'),
              const SizedBox(height: 5),
              if (bid['status'] != 'accepted')
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () =>
                        controller.navigateToBidPlacement(edit: true),
                    child: Text('edit_bid'.tr),
                  ),
                ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildActionButton() {
    return Obx(() {
      if (controller.existingBid.value != null) {
        return const SizedBox.shrink();
      }

      return SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () => controller.navigateToBidPlacement(),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 12),
          ),
          child: Text(
            'place_bid'.tr,
            style: const TextStyle(fontSize: 16),
          ),
        ),
      );
    });
  }
}
