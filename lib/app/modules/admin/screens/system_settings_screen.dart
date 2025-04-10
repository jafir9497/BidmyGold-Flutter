import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/system_settings_controller.dart';
import '../widgets/admin_drawer.dart';

class SystemSettingsScreen extends StatefulWidget {
  const SystemSettingsScreen({super.key});

  @override
  _SystemSettingsScreenState createState() => _SystemSettingsScreenState();
}

class _SystemSettingsScreenState extends State<SystemSettingsScreen> {
  // Add GlobalKey for Form validation
  final _formKey = GlobalKey<FormState>();

  // State for the admin note input (Remove if not needed)
  // late final TextEditingController _noteController;
  // Use SystemSettingsController
  final SystemSettingsController controller = Get.find();
  // Remove LoanRequestModel if not needed
  // late final LoanRequestModel request;

  @override
  void initState() {
    super.initState();
    // Remove argument loading if not needed
    // request = Get.arguments as LoanRequestModel;
    // Remove note controller if not needed
    // _noteController = TextEditingController();
  }

  @override
  void dispose() {
    // Remove note controller disposal if not needed
    // _noteController.dispose();
    // Form key doesn't need disposal
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('system_settings_title'.tr),
      ),
      drawer: const AdminDrawer(),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildMaintenanceCard(context),
                const SizedBox(height: 24),
                _buildSectionTitle(context, 'api_keys_section_title'.tr),
                _buildTextField(
                  controller: controller.goldApiKeyController,
                  label: 'gold_api_key_label'.tr,
                  hint: 'gold_api_key_hint'.tr,
                ),
                const SizedBox(height: 24),

                _buildSectionTitle(context, 'gold_rate_section_title'.tr),
                _buildGoldRateSection(context),
                const SizedBox(height: 24),

                _buildSectionTitle(context, 'loan_config_section_title'.tr),
                _buildTextField(
                  controller: controller.defaultLoanRateController,
                  label: 'default_loan_rate_label'.tr,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'validation_rate_empty'.tr;
                    }
                    if (double.tryParse(value) == null) {
                      return 'validation_invalid_number'.tr;
                    }
                    if (double.parse(value) <= 0) {
                      return 'validation_rate_positive'.tr;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: controller.maxLoanTenureController,
                  label: 'max_loan_tenure_label'.tr,
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'validation_tenure_empty'.tr;
                    }
                    if (int.tryParse(value) == null) {
                      return 'validation_invalid_number'.tr;
                    }
                    if (int.parse(value) <= 0) {
                      return 'validation_tenure_positive'.tr;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: controller.maxLoanPercentageController,
                  label: 'max_loan_percentage_label'.tr,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'validation_percentage_empty'.tr;
                    }
                    if (double.tryParse(value) == null) {
                      return 'validation_invalid_number'.tr;
                    }
                    final percent = double.parse(value);
                    if (percent <= 0 || percent > 100) {
                      return 'validation_percentage_range'.tr;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildTextField(
                        controller: controller.minLoanAmountController,
                        label: 'min_loan_amount_label'.tr,
                        keyboardType:
                            const TextInputType.numberWithOptions(decimal: true),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'validation_amount_empty'.tr;
                          }
                          if (double.tryParse(value) == null) {
                            return 'validation_invalid_number'.tr;
                          }
                          if (double.parse(value) < 0) {
                            return 'validation_amount_negative'.tr;
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildTextField(
                        controller: controller.maxLoanAmountController,
                        label: 'max_loan_amount_label'.tr,
                        keyboardType:
                            const TextInputType.numberWithOptions(decimal: true),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'validation_amount_empty'.tr;
                          }
                          if (double.tryParse(value) == null) {
                            return 'validation_invalid_number'.tr;
                          }
                          if (double.parse(value) <= 0) {
                            return 'validation_amount_positive'.tr;
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                _buildSectionTitle(context, 'service_fee_section_title'.tr),
                _buildTextField(
                  controller: controller.serviceChargeController,
                  label: 'service_charge_label'.tr,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'validation_amount_empty'.tr;
                    }
                    if (double.tryParse(value) == null) {
                      return 'validation_invalid_number'.tr;
                    }
                    if (double.parse(value) < 0) {
                      return 'validation_amount_negative'.tr;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),

                _buildSectionTitle(context, 'notifications_section_title'.tr),
                SwitchListTile(
                  title: Text('enable_push_notifications_label'.tr),
                  value: controller.pushNotificationsEnabled.value,
                  onChanged: (bool value) {
                    controller.pushNotificationsEnabled.value = value;
                  },
                  activeColor: Theme.of(context).primaryColor,
                ),
                Obx(() => RadioListTile<String>(
                      title: Text('notification_option_all'.tr),
                      value: 'all',
                      groupValue: controller.notificationSettings.value,
                      onChanged: (value) =>
                          controller.setNotificationSettings(value!),
                      dense: true,
                    )),
                Obx(() => RadioListTile<String>(
                      title: Text('notification_option_important'.tr),
                      value: 'important',
                      groupValue: controller.notificationSettings.value,
                      onChanged: (value) =>
                          controller.setNotificationSettings(value!),
                      dense: true,
                    )),
                Obx(() => RadioListTile<String>(
                      title: Text('notification_option_none'.tr),
                      value: 'none',
                      groupValue: controller.notificationSettings.value,
                      onChanged: (value) =>
                          controller.setNotificationSettings(value!),
                      dense: true,
                    )),
                const SizedBox(height: 32),

                // Save Button
                Center(
                  child: Obx(() => ElevatedButton.icon(
                        icon: controller.isSaving.value
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2, color: Colors.white))
                            : const Icon(Icons.save),
                        label: Text(controller.isSaving.value
                            ? 'saving_button_loading'.tr
                            : 'save_settings_button'.tr),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 40, vertical: 15),
                          backgroundColor: Theme.of(context).primaryColor,
                          foregroundColor: Colors.white,
                        ),
                        onPressed: controller.isSaving.value
                            ? null
                            : () {
                                if (_formKey.currentState!.validate()) {
                                  controller.saveSettings();
                                }
                              },
                      )),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Theme.of(context).primaryColor,
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? hint,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        obscureText: obscureText,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          isDense: true,
        ),
        validator: validator,
      ),
    );
  }

  Widget _buildMaintenanceCard(BuildContext context) {
    return Card(
      color: controller.maintenanceMode.value ? Colors.orange.shade50 : null,
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('maintenance_mode_title'.tr,
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(
                    'maintenance_mode_description'.tr,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            Obx(() => Switch(
                  value: controller.maintenanceMode.value,
                  onChanged: (value) => controller.toggleMaintenanceMode(),
                  activeColor: Theme.of(context).colorScheme.error,
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildGoldRateSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Obx(() => SwitchListTile(
              title: Text('manual_gold_rate_label'.tr),
              subtitle: Text('manual_gold_rate_subtitle'.tr),
              value: controller.goldRateManualEntry.value,
              onChanged: (value) => controller.toggleGoldRateManualEntry(),
              activeColor: Theme.of(context).primaryColor,
            )),
        const SizedBox(height: 8),
        Obx(() => controller.goldRateManualEntry.value
            ? _buildTextField(
                controller: controller.goldRateController,
                label: 'manual_gold_rate_input_label'.tr,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: (value) {
                  if (controller.goldRateManualEntry.value) {
                    if (value == null || value.isEmpty) {
                      return 'validation_rate_empty'.tr;
                    }
                    if (double.tryParse(value) == null) {
                      return 'validation_invalid_number'.tr;
                    }
                    if (double.parse(value) <= 0) {
                      return 'validation_rate_positive'.tr;
                    }
                  }
                  return null;
                },
              )
            : Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Text(
                  '${'last_api_update_label'.tr}: ${controller.lastGoldRateUpdate.value.isEmpty ? 'never'.tr : controller.lastGoldRateUpdate.value}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              )),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            children: [
              Text('display_currency_label'.tr),
              const Spacer(),
              Obx(() => DropdownButton<String>(
                    value: controller.selectedCurrency.value,
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        controller.setCurrency(newValue);
                      }
                    },
                    items: <String>['INR', 'USD']
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    underline: Container(),
                  )),
            ],
          ),
        ),
      ],
    );
  }
}
