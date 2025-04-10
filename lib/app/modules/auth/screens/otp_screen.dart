import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:bidmygoldflutter/app/modules/auth/controllers/auth_controller.dart';

class OtpScreen extends GetView<AuthController> {
  const OtpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('verify_otp'.tr),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Obx(() => Text(
                  'enter_otp'.trArgs([
                    controller.mobileNumber.value.replaceFirst('+91', '')
                  ]), // Display number
                  style: Get.textTheme.titleMedium,
                  textAlign: TextAlign.center,
                )),
            const SizedBox(height: 30),
            TextField(
              controller: controller.otpController,
              keyboardType: TextInputType.number,
              maxLength: 6,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  letterSpacing: 10.0,
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold), // Style for OTP look
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: const InputDecoration(
                labelText: 'OTP',
                border: OutlineInputBorder(),
                counterText: '', // Hide the counter
              ),
            ),
            const SizedBox(height: 20),
            Obx(() => ElevatedButton(
                  onPressed:
                      controller.isLoading.value ? null : controller.verifyOtp,
                  child: controller.isLoading.value
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white),
                        )
                      : Text('verify_otp'.tr),
                )),
            const SizedBox(height: 20),
            Obx(() {
              final canResend = controller.countdown.value == 0;
              final text = canResend
                  ? 'resend_otp'.tr
                  : 'resend_otp_in'
                      .trArgs([controller.countdown.value.toString()]);
              return TextButton(
                onPressed: canResend && !controller.isLoading.value
                    ? controller.resendOtp
                    : null,
                child: Text(text),
              );
            })
          ],
        ),
      ),
    );
  }
}
