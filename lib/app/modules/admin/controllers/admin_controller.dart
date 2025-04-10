import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/admin.dart';

class AdminController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final Rxn<Admin> currentAdmin = Rxn<Admin>();
  final RxBool isLoading = false.obs;
  final RxList<Admin> adminList = <Admin>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchCurrentAdminDetails();
  }

  Future<void> fetchCurrentAdminDetails() async {
    isLoading.value = true;
    try {
      // Get the current admin ID from Firebase Auth
      final User? user = _auth.currentUser;
      final String adminId = user?.uid ?? '';

      if (adminId.isNotEmpty) {
        final DocumentSnapshot doc =
            await _firestore.collection('admins').doc(adminId).get();

        if (doc.exists) {
          currentAdmin.value = Admin.fromFirestore(doc);
        }
      }
    } catch (e) {
      print('Error fetching admin details: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchAllAdmins() async {
    isLoading.value = true;
    try {
      final QuerySnapshot snapshot =
          await _firestore.collection('admins').get();

      final List<Admin> admins =
          snapshot.docs.map((doc) => Admin.fromFirestore(doc)).toList();

      adminList.assignAll(admins);
    } catch (e) {
      print('Error fetching admins: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> createAdmin(
      String name, String email, String password, String role) async {
    isLoading.value = true;
    try {
      // Create user in Firebase Auth
      final UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final String adminId = userCredential.user!.uid;

      // Create admin in Firestore
      final Admin newAdmin = Admin(
        id: adminId,
        name: name,
        email: email,
        role: role,
        createdAt: DateTime.now(),
      );

      await _firestore.collection('admins').doc(adminId).set(newAdmin.toMap());
      return true;
    } catch (e) {
      print('Error creating admin: $e');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> updateAdmin(Admin admin) async {
    isLoading.value = true;
    try {
      await _firestore.collection('admins').doc(admin.id).update(admin.toMap());
      return true;
    } catch (e) {
      print('Error updating admin: $e');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> deleteAdmin(String adminId) async {
    isLoading.value = true;
    try {
      await _firestore.collection('admins').doc(adminId).delete();
      return true;
    } catch (e) {
      print('Error deleting admin: $e');
      return false;
    } finally {
      isLoading.value = false;
    }
  }
}
