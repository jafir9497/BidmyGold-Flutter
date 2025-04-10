import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:bidmygoldflutter/app/modules/user/details/controllers/user_details_controller.dart';

class UserDetailsScreen extends GetView<UserDetailsController> {
  const UserDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('enter_your_details'.tr),
        centerTitle: true,
        automaticallyImplyLeading: false, // No back button
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: controller.formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'welcome_complete_profile'.tr,
                style: Get.textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),
              // Name Field
              TextFormField(
                controller: controller.nameController,
                decoration: InputDecoration(
                  labelText: 'full_name'.tr,
                  border: const OutlineInputBorder(),
                ),
                validator: controller.validateName,
                textCapitalization: TextCapitalization.words,
              ),
              const SizedBox(height: 20),
              // Email Field (Optional)
              TextFormField(
                controller: controller.emailController,
                decoration: InputDecoration(
                  labelText: 'email_optional'.tr,
                  border: const OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: controller.validateEmail, // Validates if not empty
              ),
              const SizedBox(height: 30),
              // Save Button
              Obx(() => ElevatedButton(
                    onPressed: controller.isLoading.value
                        ? null
                        : controller.saveUserDetails,
                    child: controller.isLoading.value
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white))
                        : Text('save_and_continue'.tr),
                  )),
            ],
          ),
        ),
      ),
    );
  }
}
