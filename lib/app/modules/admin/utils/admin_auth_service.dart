import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../models/admin_user.dart';

class AdminAuthService extends GetxService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GetStorage _storage = GetStorage();

  // Observables for admin state
  final Rx<User?> firebaseUser = Rx<User?>(null);
  final Rx<AdminUser?> adminUser = Rx<AdminUser?>(null);

  // Session timeout duration (30 minutes)
  final sessionTimeout = const Duration(minutes: 30);
  DateTime? _lastActivity;

  // Storage keys
  static const String _adminSessionKey = 'admin_session_active';
  static const String _adminLastActivityKey = 'admin_last_activity';

  Future<AdminAuthService> init() async {
    firebaseUser.value = _auth.currentUser;
    _auth.authStateChanges().listen(_onAuthStateChanged);

    // Check if there's an existing session
    if (_storage.hasData(_adminSessionKey) &&
        _storage.read<bool>(_adminSessionKey) == true) {
      // Check session timeout
      final lastActivityStr = _storage.read<String>(_adminLastActivityKey);
      if (lastActivityStr != null) {
        _lastActivity = DateTime.parse(lastActivityStr);
        final now = DateTime.now();
        if (now.difference(_lastActivity!) <= sessionTimeout) {
          // Session still valid
          refreshSession();

          // Load admin user data
          if (firebaseUser.value != null) {
            await _loadAdminUser(firebaseUser.value!.uid);
          }
        } else {
          // Session expired
          await signOut();
        }
      }
    }

    return this;
  }

  // Handle auth state changes
  Future<void> _onAuthStateChanged(User? user) async {
    firebaseUser.value = user;

    if (user != null) {
      await _loadAdminUser(user.uid);
    } else {
      adminUser.value = null;
      await _storage.write(_adminSessionKey, false);
    }
  }

  // Load admin user data from Firestore
  Future<void> _loadAdminUser(String uid) async {
    try {
      final doc = await _firestore.collection('admins').doc(uid).get();
      if (doc.exists) {
        adminUser.value = AdminUser.fromFirestore(doc);

        // Update last login timestamp
        await _firestore.collection('admins').doc(uid).update({
          'lastLogin': FieldValue.serverTimestamp(),
        });
      } else {
        // User found in Firebase Auth but not in admin collection
        adminUser.value = null;
        await signOut();
      }
    } catch (e) {
      print('Error loading admin user: $e');
      adminUser.value = null;
    }
  }

  // Sign in with email and password
  Future<bool> signInWithEmailAndPassword(String email, String password) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
          email: email, password: password);

      // Verify this user is an admin in Firestore
      if (userCredential.user != null) {
        final doc = await _firestore
            .collection('admins')
            .doc(userCredential.user!.uid)
            .get();

        if (doc.exists) {
          final adminData = doc.data() as Map<String, dynamic>;

          // Check if admin account is active
          if (adminData['isActive'] == true) {
            refreshSession();
            return true;
          } else {
            // Admin account disabled
            await signOut();
            return false;
          }
        } else {
          // Not an admin, sign out
          await signOut();
          return false;
        }
      }
      return false;
    } catch (e) {
      print('Sign in error: $e');
      return false;
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _auth.signOut();
      adminUser.value = null;
      await _storage.write(_adminSessionKey, false);
      await _storage.remove(_adminLastActivityKey);
    } catch (e) {
      print('Sign out error: $e');
    }
  }

  // Refresh the session timeout
  void refreshSession() {
    _lastActivity = DateTime.now();
    _storage.write(_adminSessionKey, true);
    _storage.write(_adminLastActivityKey, _lastActivity!.toIso8601String());
  }

  // Check if session is active and refresh it
  bool checkAndRefreshSession() {
    if (_lastActivity == null) return false;

    final now = DateTime.now();
    if (now.difference(_lastActivity!) <= sessionTimeout) {
      refreshSession();
      return true;
    }

    return false;
  }

  // Check if user is a super admin
  bool isSuperAdmin() {
    return adminUser.value?.role == 'super_admin';
  }
}
