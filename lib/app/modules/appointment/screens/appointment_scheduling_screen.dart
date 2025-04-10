import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:bidmygoldflutter/app/modules/appointment/controllers/appointment_scheduling_controller.dart';
import 'package:intl/intl.dart';

class AppointmentSchedulingScreen
    extends GetView<AppointmentSchedulingController> {
  const AppointmentSchedulingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('schedule_appointment'.tr),
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
              // Loan Request and Bid Details Card
              _buildDetailsCard(),
              const SizedBox(height: 24),

              // Date Selection
              _buildDateSelection(context),
              const SizedBox(height: 24),

              // Time Selection
              _buildTimeSelection(),
              const SizedBox(height: 32),

              // Additional Notes
              _buildNotesField(),
              const SizedBox(height: 32),

              // Schedule Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: controller.isFormValid.value
                      ? controller.scheduleAppointment
                      : null,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: controller.isSubmitting.value
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text('confirm_appointment'.tr),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildDetailsCard() {
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

            // Loan Request Details
            Row(
              children: [
                const Icon(Icons.account_balance_wallet, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'loan_amount'.tr,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                      Text(
                        controller.formattedLoanAmount,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                const Icon(Icons.diamond_outlined, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'jewel_type'.tr,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                      Text(
                        controller.jewelType.value,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Parties Information
            _buildPartyInfo(
              title: controller.isPawnbroker.value
                  ? 'customer'.tr
                  : 'pawnbroker'.tr,
              name: controller.isPawnbroker.value
                  ? controller.userName.value
                  : controller.shopName.value,
              address: controller.isPawnbroker.value
                  ? ''
                  : controller.shopAddress.value,
              iconData:
                  controller.isPawnbroker.value ? Icons.person : Icons.store,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPartyInfo({
    required String title,
    required String name,
    required String address,
    required IconData iconData,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(iconData, size: 18),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
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

  Widget _buildDateSelection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'appointment_date'.tr,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: () => controller.selectDate(context),
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                const Icon(Icons.calendar_today),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    controller.selectedDate.value != null
                        ? DateFormat('EEEE, MMMM d, yyyy')
                            .format(controller.selectedDate.value!)
                        : 'select_date'.tr,
                    style: TextStyle(
                      color: controller.selectedDate.value != null
                          ? Colors.black
                          : Colors.grey,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        if (controller.dateError.value.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              controller.dateError.value,
              style: const TextStyle(color: Colors.red, fontSize: 12),
            ),
          ),
      ],
    );
  }

  Widget _buildTimeSelection() {
    final timeSlots = controller.availableTimeSlots;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'appointment_time'.tr,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: timeSlots.map((time) {
            final isSelected = controller.selectedTime.value == time;

            return ChoiceChip(
              selected: isSelected,
              label: Text(time),
              backgroundColor: Colors.grey.shade200,
              selectedColor: Get.theme.primaryColor.withOpacity(0.2),
              onSelected: (selected) {
                if (selected) controller.selectedTime.value = time;
              },
            );
          }).toList(),
        ),
        if (controller.timeError.value.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              controller.timeError.value,
              style: const TextStyle(color: Colors.red, fontSize: 12),
            ),
          ),
      ],
    );
  }

  Widget _buildNotesField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${'notes'.tr} (${'optional'.tr})',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: controller.notesController,
          maxLines: 3,
          decoration: InputDecoration(
            hintText: 'appointment_notes_hint'.tr,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ],
    );
  }
}
