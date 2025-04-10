import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:bidmygoldflutter/app/routes/app_pages.dart';

class PawnbrokerRegistrationController extends GetxController {
  // Form controllers
  final formKey = GlobalKey<FormState>();
  final shopNameController = TextEditingController();
  final ownerNameController = TextEditingController();
  final addressController = TextEditingController();
  final cityController = TextEditingController();
  final stateController = TextEditingController();
  final pinCodeController = TextEditingController();
  final emailController = TextEditingController();
  final gstNumberController = TextEditingController();
  final licenseNumberController = TextEditingController();
  final experienceController = TextEditingController();

  // Firebase instances
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  final _storage = FirebaseStorage.instance;

  // Observables
  var isLoading = false.obs;
  var currentStep = 0.obs;
  var selectedExperience = '1-5 years'.obs;

  // Document files
  var shopLicenseFile = Rxn<XFile>();
  var idProofFile = Rxn<XFile>();
  var shopPhotoFile = Rxn<XFile>();

  // Upload URLs
  var shopLicenseUrl = RxnString();
  var idProofUrl = RxnString();
  var shopPhotoUrl = RxnString();

  // Upload progress
  var uploadingShopLicense = false.obs;
  var uploadingIdProof = false.obs;
  var uploadingShopPhoto = false.obs;

  // Experience options
  final List<String> experienceOptions = [
    'Less than 1 year',
    '1-5 years',
    '5-10 years',
    'More than 10 years'
  ];

  @override
  void onInit() {
    super.onInit();
    // Pre-fill mobile number if available
    final user = _auth.currentUser;
    if (user != null && user.phoneNumber != null) {
      // Mobile number is already captured during OTP verification
    }
  }

  @override
  void onClose() {
    // Dispose controllers
    shopNameController.dispose();
    ownerNameController.dispose();
    addressController.dispose();
    cityController.dispose();
    stateController.dispose();
    pinCodeController.dispose();
    emailController.dispose();
    gstNumberController.dispose();
    licenseNumberController.dispose();
    experienceController.dispose();
    super.onClose();
  }

  // Validate shop name
  String? validateShopName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'shop_name_required'.tr;
    }
    return null;
  }

  // Validate owner name
  String? validateOwnerName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'owner_name_required'.tr;
    }
    return null;
  }

  // Validate address
  String? validateAddress(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'address_required'.tr;
    }
    return null;
  }

  // Validate city
  String? validateCity(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'city_required'.tr;
    }
    return null;
  }

  // Validate state
  String? validateState(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'state_required'.tr;
    }
    return null;
  }

  // Validate pin code
  String? validatePinCode(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'pin_code_required'.tr;
    }
    // Check if pin code is 6 digits
    if (!RegExp(r'^\d{6}$').hasMatch(value)) {
      return 'invalid_pin_code'.tr;
    }
    return null;
  }

  // Validate email (optional)
  String? validateEmail(String? value) {
    if (value != null && value.isNotEmpty && !GetUtils.isEmail(value)) {
      return 'invalid_email'.tr;
    }
    return null;
  }

  // Validate GST number (optional)
  String? validateGstNumber(String? value) {
    if (value != null && value.isNotEmpty) {
      // Basic GST format validation (15 characters)
      if (!RegExp(r'^[0-9A-Z]{15}$').hasMatch(value)) {
        return 'invalid_gst_number'.tr;
      }
    }
    return null;
  }

  // Validate license number
  String? validateLicenseNumber(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'license_number_required'.tr;
    }
    return null;
  }

  // Validate shop license file
  bool validateShopLicenseFile() {
    if (shopLicenseFile.value == null && shopLicenseUrl.value == null) {
      Get.snackbar(
        'error'.tr,
        'shop_license_required'.tr,
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }
    return true;
  }

  // Validate ID proof file
  bool validateIdProofFile() {
    if (idProofFile.value == null && idProofUrl.value == null) {
      Get.snackbar(
        'error'.tr,
        'id_proof_required'.tr,
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }
    return true;
  }

  // Select experience
  void selectExperience(String experience) {
    selectedExperience.value = experience;
  }

  // Go to next step
  void nextStep() {
    if (currentStep.value == 0) {
      // Validate basic info step
      if (formKey.currentState?.validate() ?? false) {
        currentStep.value++;
      }
    } else if (currentStep.value == 1) {
      // Validate document upload step
      if (validateShopLicenseFile() && validateIdProofFile()) {
        currentStep.value++;
      }
    }
  }

  // Go to previous step
  void previousStep() {
    if (currentStep.value > 0) {
      currentStep.value--;
    }
  }

  // Pick image from camera or gallery
  Future<void> pickImage(ImageSource source, Rxn<XFile> fileVariable) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: source);

      if (image != null) {
        fileVariable.value = image;
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to pick image: $e');
    }
  }

  // Upload shop license
  Future<void> uploadShopLicense() async {
    if (shopLicenseFile.value == null) return;

    try {
      uploadingShopLicense.value = true;

      final userId = _auth.currentUser?.uid;
      if (userId == null) throw Exception('User not logged in');

      final fileName =
          'shop_license_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final path = 'pawnbrokers/$userId/documents/$fileName';

      // Upload file
      final ref = _storage.ref().child(path);
      final uploadTask = ref.putFile(File(shopLicenseFile.value!.path));

      // Wait for upload to complete
      final snapshot = await uploadTask;

      // Get download URL
      shopLicenseUrl.value = await snapshot.ref.getDownloadURL();

      uploadingShopLicense.value = false;
    } catch (e) {
      uploadingShopLicense.value = false;
      Get.snackbar('Error', 'Failed to upload shop license: $e');
    }
  }

  // Upload ID proof
  Future<void> uploadIdProof() async {
    if (idProofFile.value == null) return;

    try {
      uploadingIdProof.value = true;

      final userId = _auth.currentUser?.uid;
      if (userId == null) throw Exception('User not logged in');

      final fileName = 'id_proof_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final path = 'pawnbrokers/$userId/documents/$fileName';

      // Upload file
      final ref = _storage.ref().child(path);
      final uploadTask = ref.putFile(File(idProofFile.value!.path));

      // Wait for upload to complete
      final snapshot = await uploadTask;

      // Get download URL
      idProofUrl.value = await snapshot.ref.getDownloadURL();

      uploadingIdProof.value = false;
    } catch (e) {
      uploadingIdProof.value = false;
      Get.snackbar('Error', 'Failed to upload ID proof: $e');
    }
  }

  // Upload shop photo
  Future<void> uploadShopPhoto() async {
    if (shopPhotoFile.value == null) return;

    try {
      uploadingShopPhoto.value = true;

      final userId = _auth.currentUser?.uid;
      if (userId == null) throw Exception('User not logged in');

      final fileName =
          'shop_photo_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final path = 'pawnbrokers/$userId/documents/$fileName';

      // Upload file
      final ref = _storage.ref().child(path);
      final uploadTask = ref.putFile(File(shopPhotoFile.value!.path));

      // Wait for upload to complete
      final snapshot = await uploadTask;

      // Get download URL
      shopPhotoUrl.value = await snapshot.ref.getDownloadURL();

      uploadingShopPhoto.value = false;
    } catch (e) {
      uploadingShopPhoto.value = false;
      Get.snackbar('Error', 'Failed to upload shop photo: $e');
    }
  }

  // Submit pawnbroker registration
  Future<void> submitRegistration() async {
    try {
      isLoading.value = true;

      // Upload any remaining documents
      if (shopLicenseFile.value != null && shopLicenseUrl.value == null) {
        await uploadShopLicense();
      }

      if (idProofFile.value != null && idProofUrl.value == null) {
        await uploadIdProof();
      }

      if (shopPhotoFile.value != null && shopPhotoUrl.value == null) {
        await uploadShopPhoto();
      }

      final userId = _auth.currentUser?.uid;
      if (userId == null) throw Exception('User not logged in');

      // Create pawnbroker document in Firestore
      await _firestore.collection('pawnbrokers').doc(userId).set({
        'userId': userId,
        'shopName': shopNameController.text.trim(),
        'ownerName': ownerNameController.text.trim(),
        'address': addressController.text.trim(),
        'city': cityController.text.trim(),
        'state': stateController.text.trim(),
        'pinCode': pinCodeController.text.trim(),
        'email': emailController.text.trim(),
        'mobileNumber': _auth.currentUser?.phoneNumber,
        'gstNumber': gstNumberController.text.trim(),
        'licenseNumber': licenseNumberController.text.trim(),
        'experience': selectedExperience.value,
        'documents': {
          'shopLicenseUrl': shopLicenseUrl.value,
          'idProofUrl': idProofUrl.value,
          'shopPhotoUrl': shopPhotoUrl.value,
        },
        'isVerified': false,
        'verificationStatus': 'pending',
        'registeredAt': FieldValue.serverTimestamp(),
      });

      // Update user record to mark as pawnbroker
      await _firestore.collection('users').doc(userId).set({
        'isPawnbroker': true,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      isLoading.value = false;

      // Show success message
      Get.snackbar(
        'success'.tr,
        'pawnbroker_registration_successful'.tr,
        snackPosition: SnackPosition.BOTTOM,
      );

      // Navigate to pawnbroker dashboard
      Get.offAllNamed(Routes.PAWNBROKER_DASHBOARD);
    } catch (e) {
      isLoading.value = false;
      Get.snackbar('Error', 'Failed to submit registration: $e');
    }
  }
}
