import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../routes/app_pages.dart';
import 'package:get_storage/get_storage.dart';

class AuthService extends GetxService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GetStorage _storage = GetStorage();

  // Observable user state
  final Rx<User?> user = Rx<User?>(null);

  // User type (user, pawnbroker)
  final RxString userType = RxString('');

  // User data
  final Rx<Map<String, dynamic>> userData = Rx<Map<String, dynamic>>({});

  // Loading state
  final RxBool isLoading = RxBool(false);

  // Initialize the service
  Future<AuthService> init() async {
    // Set up auth state listener
    _auth.authStateChanges().listen(_onAuthStateChanged);

    // Check if user is already logged in
    final currentUser = _auth.currentUser;
    if (currentUser != null) {
      user.value = currentUser;
      await _fetchUserData(currentUser.uid);
    }

    return this;
  }

  // Auth state change handler
  void _onAuthStateChanged(User? firebaseUser) async {
    if (firebaseUser == null) {
      // User signed out
      user.value = null;
      userType.value = '';
      userData.value = {};

      // Navigate to appropriate screen based on login status
      if (GetPlatform.isWeb) {
        Get.offAllNamed(Routes.LOGIN);
      } else {
        // Check if onboarding is completed
        final onboardingComplete =
            _storage.read('onboarding_complete') ?? false;
        if (onboardingComplete) {
          Get.offAllNamed(Routes.ANONYMOUS_HOME);
        } else {
          Get.offAllNamed(Routes.ONBOARDING);
        }
      }
    } else {
      // User signed in
      user.value = firebaseUser;
      await _fetchUserData(firebaseUser.uid);
    }
  }

  // Fetch user data from Firestore
  Future<void> _fetchUserData(String uid) async {
    try {
      isLoading.value = true;

      // Check user collection first
      final userDoc = await _firestore.collection('users').doc(uid).get();

      if (userDoc.exists) {
        userData.value = userDoc.data() ?? {};
        userType.value = 'user';

        // Navigate based on profile completion
        _navigateBasedOnUserProfile();
        return;
      }

      // Check pawnbroker collection
      final pawnbrokerDoc =
          await _firestore.collection('pawnbrokers').doc(uid).get();

      if (pawnbrokerDoc.exists) {
        userData.value = pawnbrokerDoc.data() ?? {};
        userType.value = 'pawnbroker';

        // Navigate based on profile completion
        _navigateBasedOnPawnbrokerProfile();
        return;
      }

      // No profile exists - could be a new user
      userData.value = {};
      userType.value = '';
    } catch (e) {
      print('Error fetching user data: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Navigate based on user profile completion
  void _navigateBasedOnUserProfile() {
    // Get current route
    final currentRoute = Get.currentRoute;

    // If user data is empty or missing required fields
    if (userData.value.isEmpty ||
        !userData.value.containsKey('name') ||
        !userData.value.containsKey('phone')) {
      // User needs to complete profile
      if (currentRoute != Routes.USER_DETAILS) {
        Get.offAllNamed(Routes.USER_DETAILS);
      }
      return;
    }

    // Check if KYC is completed
    final kycSubmitted = userData.value['kycSubmitted'] ?? false;
    if (!kycSubmitted) {
      // User needs to complete KYC
      if (currentRoute != Routes.KYC_UPLOAD) {
        Get.offAllNamed(Routes.KYC_UPLOAD);
      }
      return;
    }

    // User profile is complete, go to dashboard
    if (currentRoute != Routes.HOME) {
      Get.offAllNamed(Routes.HOME);
    }
  }

  // Navigate based on pawnbroker profile completion
  void _navigateBasedOnPawnbrokerProfile() {
    // Get current route
    final currentRoute = Get.currentRoute;

    // If pawnbroker data is empty or missing required fields
    if (userData.value.isEmpty ||
        !userData.value.containsKey('shopName') ||
        !userData.value.containsKey('ownerName')) {
      // Pawnbroker needs to complete profile
      if (currentRoute != Routes.PAWNBROKER_REGISTRATION) {
        Get.offAllNamed(Routes.PAWNBROKER_REGISTRATION);
      }
      return;
    }

    // Check if verification is in progress
    final isVerified = userData.value['isVerified'] ?? false;
    if (!isVerified) {
      // Show verification pending screen (to be implemented)
      return;
    }

    // Pawnbroker profile is complete, go to dashboard
    if (currentRoute != Routes.PAWNBROKER_DASHBOARD) {
      Get.offAllNamed(Routes.PAWNBROKER_DASHBOARD);
    }
  }

  // Sign in with mobile number - Step 1: Send OTP
  Future<void> signInWithMobile(String phoneNumber) async {
    try {
      isLoading.value = true;
      await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) async {
          // Auto-verification (Android only)
          await _auth.signInWithCredential(credential);
        },
        verificationFailed: (FirebaseAuthException e) {
          throw e;
        },
        codeSent: (String verificationId, int? resendToken) {
          // Store verification ID for OTP verification
          _storage.write('phone_verification_id', verificationId);

          // Navigate to OTP screen
          Get.toNamed(Routes.OTP, arguments: {'phoneNumber': phoneNumber});
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          // Auto-retrieval timeout
        },
      );
    } catch (e) {
      throw e;
    } finally {
      isLoading.value = false;
    }
  }

  // Sign in with mobile number - Step 2: Verify OTP
  Future<void> verifyOtp(String otp) async {
    try {
      isLoading.value = true;

      // Get verification ID from storage
      final verificationId = _storage.read('phone_verification_id');
      if (verificationId == null) {
        throw Exception('Verification ID not found. Please try again.');
      }

      // Create credential
      final credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: otp,
      );

      // Sign in
      await _auth.signInWithCredential(credential);

      // Remove verification ID from storage
      _storage.remove('phone_verification_id');
    } catch (e) {
      throw e;
    } finally {
      isLoading.value = false;
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      throw e;
    }
  }

  // Check if user is authenticated
  bool get isAuthenticated => user.value != null;

  // Get current user ID
  String? get currentUserId => user.value?.uid;

  // Check if user is a pawnbroker
  bool get isPawnbroker => userType.value == 'pawnbroker';

  // Check if user is a regular user
  bool get isRegularUser => userType.value == 'user';
}
