import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../../../data/models/pawnbroker_model.dart';
import '../utils/admin_auth_service.dart';

class PawnbrokerVerificationController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseFunctions _functions = FirebaseFunctions.instance;
  final AdminAuthService _authService = Get.find<AdminAuthService>();

  // Observables for pending verifications
  final RxList<PawnbrokerModel> allPawnbrokers = <PawnbrokerModel>[].obs;
  final RxBool isLoading = false.obs;
  final Rxn<PawnbrokerModel> selectedPawnbroker = Rxn<PawnbrokerModel>();
  final RxString searchQuery = ''.obs;

  // Observables for detailed view
  final TextEditingController rejectionReasonController =
      TextEditingController();
  var isSubmitting = false.obs;
  var currentImageIndex = 0.obs;
  final RxnString shopLicenseUrl = RxnString();
  final RxnString idProofUrl = RxnString();
  final RxList<String> shopPhotoUrls = <String>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchPendingPawnbrokers();
  }

  List<PawnbrokerModel> get filteredPendingPawnbrokers {
    return allPawnbrokers.where((p) {
      final query = searchQuery.value.toLowerCase();
      if (query.isEmpty) return true;

      final shopNameMatch = p.shopName.toLowerCase().contains(query);
      final ownerNameMatch = p.ownerName.toLowerCase().contains(query);
      final phoneMatch = p.phone.contains(query);
      final cityMatch = p.city.toLowerCase().contains(query);
      final idMatch = p.id.toLowerCase().contains(query);

      return shopNameMatch ||
          ownerNameMatch ||
          phoneMatch ||
          cityMatch ||
          idMatch;
    }).toList();
  }

  Future<void> fetchPendingPawnbrokers() async {
    isLoading.value = true;
    selectedPawnbroker.value = null;
    try {
      final QuerySnapshot snapshot = await _firestore
          .collection('pawnbrokers')
          .where('status', isEqualTo: 'pending')
          .orderBy('createdAt', descending: true)
          .get();

      allPawnbrokers.value = snapshot.docs
          .map((doc) => PawnbrokerModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      print('Error fetching pending pawnbrokers: $e');
      Get.snackbar('Error', 'Failed to load pending pawnbrokers');
    } finally {
      isLoading.value = false;
    }
  }

  void selectPawnbroker(PawnbrokerModel pawnbroker) {
    selectedPawnbroker.value = pawnbroker;
    rejectionReasonController.clear();
    currentImageIndex.value = 0;
    _fetchDocumentUrls(pawnbroker);
  }

  Future<void> _fetchDocumentUrls(PawnbrokerModel pawnbroker) async {
    shopLicenseUrl.value = null;
    idProofUrl.value = null;
    shopPhotoUrls.clear();
    isLoading.value = true;
    try {
      if (pawnbroker.shopLicenseUrl.isNotEmpty) {
        try {
          shopLicenseUrl.value = await _storage
              .refFromURL(pawnbroker.shopLicenseUrl)
              .getDownloadURL();
        } catch (e) {
          print('Error fetching shop license URL: $e');
        }
      }

      if (pawnbroker.idProofUrl.isNotEmpty) {
        try {
          idProofUrl.value =
              await _storage.refFromURL(pawnbroker.idProofUrl).getDownloadURL();
        } catch (e) {
          print('Error fetching ID proof URL: $e');
        }
      }

      final shopPhotosRef =
          _storage.ref('pawnbrokers/${pawnbroker.id}/shop_photos');
      final ListResult result = await shopPhotosRef.listAll();

      final urls = <String>[];
      for (final ref in result.items) {
        try {
          final url = await ref.getDownloadURL();
          urls.add(url);
        } catch (e) {
          print('Error fetching shop photo URL for ${ref.fullPath}: $e');
        }
      }
      shopPhotoUrls.assignAll(urls);
    } catch (e) {
      print('Error fetching document URLs for pawnbroker ${pawnbroker.id}: $e');
      Get.snackbar('Error', 'Could not load document previews.');
    } finally {
      isLoading.value = false;
    }
  }

  void clearSelectedPawnbroker() {
    selectedPawnbroker.value = null;
    shopLicenseUrl.value = null;
    idProofUrl.value = null;
    shopPhotoUrls.clear();
  }

  void setSearchQuery(String query) {
    searchQuery.value = query;
  }

  void nextImage() {
    if (shopPhotoUrls.isNotEmpty &&
        currentImageIndex.value < shopPhotoUrls.length - 1) {
      currentImageIndex.value++;
    }
  }

  void prevImage() {
    if (shopPhotoUrls.isNotEmpty && currentImageIndex.value > 0) {
      currentImageIndex.value--;
    }
  }

  Future<void> approveRequest() async {
    if (selectedPawnbroker.value == null) return;
    final pawnbroker = selectedPawnbroker.value!;

    isSubmitting.value = true;
    try {
      final callable = _functions.httpsCallable('updatePawnbrokerStatus');
      await callable.call({
        'pawnbrokerId': pawnbroker.id,
        'status': 'verified',
        'rejectionReason': null,
      });

      Get.snackbar('Success', 'Pawnbroker approved successfully');
      clearSelectedPawnbroker();

      await fetchPendingPawnbrokers();
    } catch (e) {
      print('Error approving pawnbroker: $e');
      Get.snackbar('Error', 'Failed to approve pawnbroker. Please try again.');
    } finally {
      isSubmitting.value = false;
    }
  }

  Future<void> rejectRequest() async {
    if (selectedPawnbroker.value == null) return;

    final rejectionReason = rejectionReasonController.text.trim();
    if (rejectionReason.isEmpty) {
      Get.snackbar('Error', 'Please provide a reason for rejection');
      return;
    }

    final pawnbroker = selectedPawnbroker.value!;

    isSubmitting.value = true;
    try {
      final callable = _functions.httpsCallable('updatePawnbrokerStatus');
      await callable.call({
        'pawnbrokerId': pawnbroker.id,
        'status': 'rejected',
        'rejectionReason': rejectionReason,
      });

      Get.snackbar('Success', 'Pawnbroker rejected successfully');
      clearSelectedPawnbroker();

      await fetchPendingPawnbrokers();
    } catch (e) {
      print('Error rejecting pawnbroker: $e');
      Get.snackbar('Error', 'Failed to reject pawnbroker. Please try again.');
    } finally {
      isSubmitting.value = false;
    }
  }

  @override
  void onClose() {
    rejectionReasonController.dispose();
    super.onClose();
  }
}
