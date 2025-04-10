import 'dart:io';

import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:bidmygoldflutter/app/routes/app_pages.dart';
import 'package:get_storage/get_storage.dart';

class KycController extends GetxController {
  final _picker = ImagePicker();
  final _storage = FirebaseStorage.instance;
  final _auth = FirebaseAuth.instance;
  final _getStorage = GetStorage();

  // Observables for selected files
  var idProofFile = Rxn<XFile>();
  var addressProofFile = Rxn<XFile>();
  var selfieFile = Rxn<XFile>(); // New: Selfie file

  // Observables for upload progress
  var idProofUploading = false.obs;
  var addressProofUploading = false.obs;
  var selfieUploading = false.obs; // New: Selfie upload state
  var idProofProgress = 0.0.obs;
  var addressProofProgress = 0.0.obs;
  var selfieProgress = 0.0.obs; // New: Selfie progress

  var idProofUrl = RxnString(); // Store download URL after upload
  var addressProofUrl = RxnString();
  var selfieUrl = RxnString(); // New: Selfie URL

  var isUploading = false.obs; // Overall uploading state

  String? get userId => _auth.currentUser?.uid;

  // Pick Image Function
  Future<void> pickImage(ImageSource source, Rxn<XFile> fileVariable) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(source: source);
      if (pickedFile != null) {
        fileVariable.value = pickedFile;
        // Reset URL if a new file is picked
        if (fileVariable == idProofFile) idProofUrl.value = null;
        if (fileVariable == addressProofFile) addressProofUrl.value = null;
        if (fileVariable == selfieFile)
          selfieUrl.value = null; // New: Reset selfie URL
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to pick image: $e');
    }
  }

  // Upload File Function
  Future<String?> _uploadFile(XFile file, String path) async {
    try {
      final ref = _storage.ref().child(path);
      final uploadTask = ref.putFile(File(file.path));

      // Track progress (example using listeners)
      uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
        final progress = snapshot.bytesTransferred / snapshot.totalBytes;
        if (path.contains('id_proof')) {
          idProofProgress.value = progress;
        } else if (path.contains('address_proof')) {
          addressProofProgress.value = progress;
        } else if (path.contains('selfie')) {
          // New: Track selfie progress
          selfieProgress.value = progress;
        }
      });

      final snapshot = await uploadTask.whenComplete(() {});
      final downloadUrl = await snapshot.ref.getDownloadURL();

      // Reset progress after completion
      if (path.contains('id_proof')) idProofProgress.value = 0.0;
      if (path.contains('address_proof')) addressProofProgress.value = 0.0;
      if (path.contains('selfie'))
        selfieProgress.value = 0.0; // New: Reset selfie progress

      return downloadUrl;
    } catch (e) {
      Get.snackbar('Upload Error', 'Failed to upload ${file.name}: $e');
      return null;
    }
  }

  // Submit KYC Documents
  Future<void> submitKyc() async {
    if (userId == null) {
      Get.snackbar('Error', 'User not logged in!');
      return;
    }
    if (idProofFile.value == null) {
      Get.snackbar('Error', 'Please select ID proof document');
      return;
    }
    if (addressProofFile.value == null) {
      Get.snackbar('Error', 'Please select Address proof document');
      return;
    }
    if (selfieFile.value == null) {
      // New: Check for selfie
      Get.snackbar('Error', 'Please take a selfie');
      return;
    }

    isUploading.value = true;
    idProofUploading.value = true;
    addressProofUploading.value = true;
    selfieUploading.value =
        true; // New: Local var for selfie upload state within this method
    idProofUrl.value = null; // Clear previous URLs
    addressProofUrl.value = null;
    selfieUrl.value = null; // New: Clear selfie URL

    // Upload ID Proof
    final idPath =
        'users/$userId/kyc/id_proof_${DateTime.now().millisecondsSinceEpoch}';
    idProofUrl.value = await _uploadFile(idProofFile.value!, idPath);
    idProofUploading.value = false;

    if (idProofUrl.value == null) {
      isUploading.value = false; // Stop if first upload fails
      addressProofUploading.value = false; // Also stop second upload attempt
      selfieUploading.value = false; // New: Also stop selfie upload attempt
      return;
    }

    // Upload Address Proof
    final addressPath =
        'users/$userId/kyc/address_proof_${DateTime.now().millisecondsSinceEpoch}';
    addressProofUrl.value =
        await _uploadFile(addressProofFile.value!, addressPath);
    addressProofUploading.value = false;

    if (addressProofUrl.value == null) {
      isUploading.value = false; // Stop if second upload fails
      selfieUploading.value = false; // New: Also stop selfie upload attempt
      return;
    }

    // Upload Selfie (New)
    final selfiePath =
        'users/$userId/kyc/selfie_${DateTime.now().millisecondsSinceEpoch}';
    selfieUrl.value = await _uploadFile(selfieFile.value!, selfiePath);
    selfieUploading.value = false;

    isUploading.value = false;

    if (idProofUrl.value != null &&
        addressProofUrl.value != null &&
        selfieUrl.value != null) {
      // All uploads successful
      print('KYC Upload Success!');
      print('ID URL: ${idProofUrl.value}');
      print('Address URL: ${addressProofUrl.value}');
      print('Selfie URL: ${selfieUrl.value}');

      // --- TODO: Save URLs and update KYC status in Firestore --- (Requires firestore package)
      // Example:
      // try {
      //   await FirebaseFirestore.instance.collection('users').doc(userId).update({
      //     'kycDocuments': {
      //        'idProofUrl': idProofUrl.value,
      //        'addressProofUrl': addressProofUrl.value,
      //        'selfieUrl': selfieUrl.value, // New: Add selfie URL
      //        'submittedAt': FieldValue.serverTimestamp(),
      //      },
      //     'kycStatus': 'submitted', // Update status
      //   });
      // } catch (e) {
      //    Get.snackbar('Error', 'Database Error: Failed to update status: $e');
      //    return;
      // }
      // ---------------------------------------------------------

      // Mark KYC as submitted locally (optional, Firestore is source of truth)
      _getStorage.write('kyc_submitted_$userId', true);

      Get.snackbar('Success', 'KYC documents submitted successfully!');

      // Navigate to next step (Loan Request Form or Dashboard)
      // TODO: Determine correct next navigation target
      Get.offNamed(Routes.HOME); // For now, go home
    } else {
      Get.snackbar(
          'Error', 'One or more document uploads failed. Please try again.');
    }
  }
}
