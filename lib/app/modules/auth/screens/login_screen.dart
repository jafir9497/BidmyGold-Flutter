import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:bidmygoldflutter/app/modules/auth/controllers/auth_controller.dart';
import 'package:bidmygoldflutter/app/routes/app_pages.dart';

class LoginScreen extends GetView<AuthController> {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('login_register'.tr),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'enter_mobile'.tr,
              style: Get.textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            TextField(
              controller: controller.mobileController,
              keyboardType: TextInputType.phone,
              maxLength: 10,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(10),
              ],
              decoration: InputDecoration(
                prefixIcon: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '+91',
                        style: TextStyle(
                          fontSize: 16,
                          color: Theme.of(context).textTheme.bodyLarge?.color,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        height: 24,
                        width: 1,
                        color: Theme.of(context).dividerColor,
                      ),
                    ],
                  ),
                ),
                labelText: 'mobile_number'.tr,
                border: const OutlineInputBorder(),
                counterText: '', // Hide the counter
                hintText: '10-digit mobile number',
              ),
              onChanged: (value) {
                // Clear any previous error messages when user types
                if (value.length == 10) {
                  // Hide keyboard when 10 digits are entered
                  FocusScope.of(context).unfocus();
                }
              },
            ),
            const SizedBox(height: 20),
            Obx(() => ElevatedButton(
                  onPressed:
                      controller.isLoading.value ? null : controller.sendOtp,
                  child: controller.isLoading.value
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ))
                      : Text('continue'.tr),
                )),
            // TODO: Add option for Pawnbroker login/registration toggle
            const SizedBox(height: 20),
            TextButton(
              onPressed: () {
                // Navigate to Pawnbroker registration
                Get.toNamed(Routes.PAWNBROKER_REGISTRATION);
              },
              child: Text('register_as_pawnbroker'.tr),
            )
          ],
        ),
      ),
    );
  }
}
