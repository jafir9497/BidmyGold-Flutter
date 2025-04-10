import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:bidmygoldflutter/app/modules/appointment/controllers/appointment_details_controller.dart';
import 'package:intl/intl.dart';

class AppointmentDetailsScreen extends GetView<AppointmentDetailsController> {
  const AppointmentDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('appointment_details'.tr),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildStatusBanner(),
              const SizedBox(height: 24),
              _buildAppointmentCard(),
              const SizedBox(height: 24),
              _buildPartiesCard(),
              const SizedBox(height: 24),
              if (controller.appointmentNotes.isNotEmpty) _buildNotesCard(),
              const SizedBox(height: 24),

              // Show Rating Section only if appointment is completed
              if (controller.appointmentStatus.value == 'completed') ...[
                _buildRatingSection(context),
                const SizedBox(height: 24),
              ],

              _buildActionButtons(),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildStatusBanner() {
    Color bannerColor;
    IconData bannerIcon;
    String statusText;

    switch (controller.appointmentStatus.value) {
      case 'confirmed':
        bannerColor = Colors.green;
        bannerIcon = Icons.check_circle;
        statusText = 'appointment_confirmed'.tr;
        break;
      case 'cancelled':
        bannerColor = Colors.grey;
        bannerIcon = Icons.cancel;
        statusText = 'appointment_cancelled'.tr;
        break;
      case 'completed':
        bannerColor = Colors.blue;
        bannerIcon = Icons.task_alt;
        statusText = 'appointment_completed'.tr;
        break;
      case 'pending':
      default:
        bannerColor = Colors.orange;
        bannerIcon = Icons.access_time;
        statusText = 'appointment_pending'.tr;
        break;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: bannerColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: bannerColor),
      ),
      child: Row(
        children: [
          Icon(bannerIcon, color: bannerColor),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'appointment_status'.tr,
                  style: TextStyle(
                    color: Colors.grey[700],
                    fontSize: 12,
                  ),
                ),
                Text(
                  statusText,
                  style: TextStyle(
                    color: bannerColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppointmentCard() {
    final formattedDate = controller.appointmentDateTime != null
        ? DateFormat('EEEE, MMMM d, yyyy')
            .format(controller.appointmentDateTime!)
        : 'Unknown date';

    final formattedTime = controller.appointmentDateTime != null
        ? DateFormat('h:mm a').format(controller.appointmentDateTime!)
        : 'Unknown time';

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'appointment_details'.tr,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildDetailRow(
              Icons.calendar_today,
              'appointment_date'.tr,
              formattedDate,
            ),
            const SizedBox(height: 16),
            _buildDetailRow(
              Icons.access_time,
              'appointment_time'.tr,
              formattedTime,
            ),
            const SizedBox(height: 16),
            _buildDetailRow(
              Icons.account_balance_wallet,
              'loan_amount'.tr,
              controller.formattedLoanAmount,
            ),
            const SizedBox(height: 16),
            _buildDetailRow(
              Icons.diamond_outlined,
              'jewel_type'.tr,
              controller.jewelType.value,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPartiesCard() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'parties'.tr,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildPartyInfo(
              'pawnbroker'.tr,
              controller.shopName.value,
              controller.shopAddress.value,
              Icons.store,
            ),
            const SizedBox(height: 16),
            _buildPartyInfo(
              'customer'.tr,
              controller.userName.value,
              '',
              Icons.person,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotesCard() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'notes'.tr,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(controller.appointmentNotes),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    if (controller.appointmentStatus.value == 'cancelled' ||
        controller.appointmentStatus.value == 'completed') {
      return Center(
        child: ElevatedButton.icon(
          onPressed: controller.startChat,
          icon: const Icon(Icons.chat),
          label: Text('chat'.tr),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
        ),
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        if (controller.appointmentStatus.value == 'pending')
          Expanded(
            child: ElevatedButton.icon(
              onPressed: controller.confirmAppointment,
              icon: const Icon(Icons.check_circle),
              label: Text('confirm'.tr),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        if (controller.appointmentStatus.value == 'pending')
          const SizedBox(width: 8),
        if (controller.appointmentStatus.value != 'completed')
          Expanded(
            child: ElevatedButton.icon(
              onPressed: controller.rescheduleAppointment,
              icon: const Icon(Icons.schedule),
              label: Text('reschedule'.tr),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        const SizedBox(width: 8),
        if (controller.appointmentStatus.value != 'completed')
          Expanded(
            child: OutlinedButton.icon(
              onPressed: controller.cancelAppointment,
              icon: const Icon(Icons.cancel),
              label: Text('cancel'.tr),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                foregroundColor: Colors.red,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: Colors.grey[700]),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(color: Colors.grey[700], fontSize: 12),
              ),
              Text(
                value,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPartyInfo(
    String title,
    String name,
    String address,
    IconData icon,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: Colors.grey[700]),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(color: Colors.grey[700], fontSize: 12),
              ),
              Text(
                name,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              if (address.isNotEmpty)
                Text(
                  address,
                  style: const TextStyle(fontSize: 12),
                ),
            ],
          ),
        ),
      ],
    );
  }

  // --- New Rating Section Widget ---
  Widget _buildRatingSection(BuildContext context) {
    // Don't show if user has already reviewed
    if (controller.hasUserReviewed.value) {
      return const Card(
        elevation: 2,
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Center(
            child: Text('Thank you for your feedback!',
                style: TextStyle(
                    fontStyle: FontStyle.italic, color: Colors.green)),
          ),
        ),
      );
    }

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'rate_pawnbroker'.trParams({'name': controller.shopName.value}),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            // Example using simple Icons, now interactive via controller:
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                return Obx(() => IconButton(
                      icon: Icon(
                        index < controller.selectedRating.value
                            ? Icons.star
                            : Icons.star_border,
                        color: Colors.amber,
                        size: 30, // Slightly larger stars
                      ),
                      onPressed: () => controller.updateRating(index + 1),
                    ));
              }),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller.reviewTextController, // Link to controller
              decoration: InputDecoration(
                labelText: 'add_review_optional'.tr,
                hintText: 'share_your_experience'.tr,
                border: const OutlineInputBorder(),
              ),
              maxLines: 3,
              enabled: !controller
                  .isSubmittingReview.value, // Disable while submitting
            ),
            const SizedBox(height: 16),
            Center(
              child: Obx(() => ElevatedButton.icon(
                    icon: controller.isSubmittingReview.value
                        ? const SizedBox(
                            height: 18,
                            width: 18,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white))
                        : const Icon(Icons.send),
                    label: Text(controller.isSubmittingReview.value
                        ? 'Submitting...'
                        : 'submit_review'.tr),
                    onPressed: controller.selectedRating.value == 0 ||
                            controller.isSubmittingReview.value
                        ? null // Disable if no rating or already submitting
                        : controller.submitReview,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 12),
                    ),
                  )),
            ),
          ],
        ),
      ),
    );
  }
}
