import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:bidmygoldflutter/app/theme/app_theme.dart';
import '../controllers/auth_controller.dart';

class LoginScreen extends GetView<AuthController> {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(),
      body: SafeArea(
        child: Padding(
          padding: AppTheme.screenPadding,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 24),
                Text(
                  'Welcome Back',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  'Enter your mobile number to continue',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
                ),
                const SizedBox(height: 48),
                Obx(() => !controller.isOtpSent.value
                    ? _buildMobileInput()
                    : _buildOtpInput()),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMobileInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Mobile Number',
          style: Get.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller.mobileController,
          keyboardType: TextInputType.phone,
          maxLength: 10,
          style: Get.textTheme.bodyLarge,
          decoration: InputDecoration(
            hintText: 'Enter your mobile number',
            prefixIcon: Container(
              padding: const EdgeInsets.all(16),
              child: Text(
                '+91',
                style: Get.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            counterText: '',
          ),
        ),
        const SizedBox(height: 24),
        Obx(() => ElevatedButton(
              onPressed: controller.isLoading.value ? null : controller.sendOtp,
              child: controller.isLoading.value
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Text('Continue'),
            )),
      ],
    );
  }

  Widget _buildOtpInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Enter OTP',
          style: Get.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'We\'ve sent a verification code to ${controller.mobileNumber}',
          style: Get.textTheme.bodyMedium?.copyWith(
            color: AppTheme.textSecondary,
          ),
        ),
        const SizedBox(height: 24),
        TextFormField(
          controller: controller.otpController,
          keyboardType: TextInputType.number,
          maxLength: 6,
          style: Get.textTheme.headlineMedium?.copyWith(
            letterSpacing: 8,
            fontWeight: FontWeight.w600,
          ),
          decoration: const InputDecoration(
            hintText: '• • • • • •',
            counterText: '',
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        Obx(() => ElevatedButton(
              onPressed: controller.isLoading.value ? null : controller.verifyOtp,
              child: controller.isLoading.value
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Text('Verify OTP'),
            )),
        const SizedBox(height: 24),
        Center(
          child: Obx(() => controller.countdown.value > 0
              ? Text(
                  'Resend OTP in ${controller.countdown.value}s',
                  style: Get.textTheme.bodyMedium?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
                )
              : TextButton(
                  onPressed: controller.resendOtp,
                  child: Text(
                    'Resend OTP',
                    style: Get.textTheme.bodyLarge?.copyWith(
                      color: AppTheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                )),
        ),
      ],
    );
  }
}
