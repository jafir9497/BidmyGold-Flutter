import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LoanRequestController extends GetxController {
  // Form key for validation
  final formKey = GlobalKey<FormState>();

  // Text controllers
  final jewelTypeController = TextEditingController();
  final jewelWeightController = TextEditingController();
  final loanAmountController = TextEditingController();
  final loanPurposeController = TextEditingController();

  // Observables
  var isLoading = false.obs;
  var jewelPurity = '22K'.obs;
  var loanTenure = 6.obs; // Default 6 months

  // Jewel photos
  var jewelPhotos = <XFile>[].obs;
  var jewelPhotoUrls = <String>[].obs;
  var photoUploading = false.obs;

  // Jewel video
  var jewelVideo = Rxn<XFile>();
  var jewelVideoUrl = RxnString();
  var videoUploading = false.obs;

  // Maximum loan amount based on weight and purity
  var maxLoanAmount = 0.0.obs;

  // Estimated monthly payment
  var estimatedMonthlyPayment = 0.0.obs;

  // Purity options
  final List<String> purityOptions = ['18K', '22K', '24K'];

  // Tenure options
  final List<int> tenureOptions = [3, 6, 9, 12, 24];

  @override
  void onInit() {
    super.onInit();
    // Add listener to weight input to calculate max loan amount
    jewelWeightController.addListener(_calculateMaxLoanAmount);
    // Add listener to loan amount input to calculate EMI
    loanAmountController.addListener(_calculateEMI);
  }

  @override
  void onClose() {
    // Dispose controllers
    jewelTypeController.dispose();
    jewelWeightController.dispose();
    loanAmountController.dispose();
    loanPurposeController.dispose();
    super.onClose();
  }

  // Calculate maximum loan amount based on weight and purity
  void _calculateMaxLoanAmount() {
    if (jewelWeightController.text.isNotEmpty) {
      try {
        double weight = double.parse(jewelWeightController.text);
        double rate = _getGoldRateForPurity(jewelPurity.value);

        // Calculate max loan (90% of gold value)
        maxLoanAmount.value = weight * rate * 0.9;

        // Recalculate EMI if loan amount is entered
        _calculateEMI();
      } catch (e) {
        maxLoanAmount.value = 0.0;
      }
    } else {
      maxLoanAmount.value = 0.0;
    }
  }

  // Get gold rate based on purity (simplified for now)
  double _getGoldRateForPurity(String purity) {
    // These are placeholder rates
    switch (purity) {
      case '24K':
        return 6000.0; // Price per gram for 24K
      case '22K':
        return 5500.0; // Price per gram for 22K
      case '18K':
        return 4500.0; // Price per gram for 18K
      default:
        return 5500.0;
    }
    // In a real app, you would get this from an API or Firestore
  }

  // Calculate EMI based on loan amount and tenure
  void _calculateEMI() {
    if (loanAmountController.text.isNotEmpty) {
      try {
        double principal = double.parse(loanAmountController.text);
        int months = loanTenure.value;
        double ratePerMonth = 0.01; // 1% per month (simplified)

        // EMI formula: P × r × (1 + r)ⁿ / ((1 + r)ⁿ - 1)
        double emi =
            (principal * ratePerMonth * (pow(1 + ratePerMonth, months))) /
                (pow(1 + ratePerMonth, months) - 1);

        estimatedMonthlyPayment.value = emi;
      } catch (e) {
        estimatedMonthlyPayment.value = 0.0;
      }
    } else {
      estimatedMonthlyPayment.value = 0.0;
    }
  }

  // Helper for math.pow function
  double pow(double x, int y) {
    double result = 1.0;
    for (int i = 0; i < y; i++) {
      result *= x;
    }
    return result;
  }

  // Update purity and recalculate max loan amount
  void updatePurity(String purity) {
    jewelPurity.value = purity;
    _calculateMaxLoanAmount();
  }

  // Update tenure and recalculate EMI
  void updateTenure(int tenure) {
    loanTenure.value = tenure;
    _calculateEMI();
  }

  // Pick jewel photo
  Future<void> pickJewelPhoto() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
      );

      if (image != null) {
        jewelPhotos.add(image);
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to pick image: $e');
    }
  }

  // Pick jewel photo from gallery
  Future<void> pickJewelPhotoFromGallery() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );

      if (image != null) {
        jewelPhotos.add(image);
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to pick image: $e');
    }
  }

  // Record jewel video
  Future<void> recordJewelVideo() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? video = await picker.pickVideo(
        source: ImageSource.camera,
        maxDuration: const Duration(seconds: 30), // Limit to 30 seconds
      );

      if (video != null) {
        jewelVideo.value = video;
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to record video: $e');
    }
  }

  // Remove a photo at a specific index
  void removePhotoAt(int index) {
    if (index >= 0 && index < jewelPhotos.length) {
      jewelPhotos.removeAt(index);
    }
  }

  // Remove the video
  void removeVideo() {
    jewelVideo.value = null;
  }

  // Submit the loan request
  Future<void> submitLoanRequest() async {
    if (formKey.currentState!.validate()) {
      // Check if at least 3 photos are added
      if (jewelPhotos.length < 3) {
        Get.snackbar('Error', 'min_3_photos_required'.tr);
        return;
      }

      try {
        isLoading.value = true;

        // 1. Upload images and video
        await _uploadJewelPhotos();
        if (jewelVideo.value != null) {
          await _uploadJewelVideo();
        }

        // Navigate to review screen instead of direct submission
        isLoading.value = false;
        Get.toNamed('/loan-request-review');
      } catch (e) {
        isLoading.value = false;
        Get.snackbar('Error', 'Failed to prepare request: $e');
      }
    }
  }

  // Final submission to Firestore after review
  Future<void> submitFinalLoanRequest() async {
    try {
      isLoading.value = true;

      // Save loan request data to Firestore
      await _saveLoanRequestToFirestore();

      // Show success message
      isLoading.value = false;
      Get.snackbar('Success', 'request_submitted'.tr);
    } catch (e) {
      isLoading.value = false;
      Get.snackbar('Error', 'Failed to submit request: $e');
      rethrow; // Rethrow to handle in the review screen
    }
  }

  // Upload jewel photos to Firebase Storage
  Future<void> _uploadJewelPhotos() async {
    photoUploading.value = true;
    jewelPhotoUrls.clear();

    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) throw Exception('User not logged in');

    for (int i = 0; i < jewelPhotos.length; i++) {
      final photo = jewelPhotos[i];
      final fileName =
          'jewel_photo_${DateTime.now().millisecondsSinceEpoch}_$i.jpg';
      final path = 'users/$userId/loan_requests/$fileName';

      // Upload file
      final ref = FirebaseStorage.instance.ref().child(path);
      final uploadTask = ref.putFile(File(photo.path));

      // Wait for upload to complete
      final snapshot = await uploadTask;

      // Get download URL
      final downloadUrl = await snapshot.ref.getDownloadURL();
      jewelPhotoUrls.add(downloadUrl);
    }

    photoUploading.value = false;
  }

  // Upload jewel video to Firebase Storage
  Future<void> _uploadJewelVideo() async {
    if (jewelVideo.value == null) return;

    videoUploading.value = true;

    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) throw Exception('User not logged in');

    final fileName = 'jewel_video_${DateTime.now().millisecondsSinceEpoch}.mp4';
    final path = 'users/$userId/loan_requests/$fileName';

    // Upload file
    final ref = FirebaseStorage.instance.ref().child(path);
    final uploadTask = ref.putFile(File(jewelVideo.value!.path));

    // Wait for upload to complete
    final snapshot = await uploadTask;

    // Get download URL
    jewelVideoUrl.value = await snapshot.ref.getDownloadURL();

    videoUploading.value = false;
  }

  // Save loan request data to Firestore
  Future<void> _saveLoanRequestToFirestore() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) throw Exception('User not logged in');

    // Create loan request document
    await FirebaseFirestore.instance.collection('loan_requests').add({
      'userId': userId,
      'jewelType': jewelTypeController.text,
      'jewelWeight': double.parse(jewelWeightController.text),
      'jewelPurity': jewelPurity.value,
      'loanAmount': double.parse(loanAmountController.text),
      'loanPurpose': loanPurposeController.text,
      'loanTenure': loanTenure.value,
      'estimatedMonthlyPayment': estimatedMonthlyPayment.value,
      'jewelPhotoUrls': jewelPhotoUrls,
      'jewelVideoUrl': jewelVideoUrl.value,
      'status': 'pending',
      'createdAt': FieldValue.serverTimestamp(),
      'location': const GeoPoint(0, 0), // Placeholder, would be actual user location
    });

    // Also update user's data to track loan requests
    await FirebaseFirestore.instance.collection('users').doc(userId).update({
      'hasActiveLoanRequest': true,
      'lastLoanRequestDate': FieldValue.serverTimestamp(),
    });
  }
}
