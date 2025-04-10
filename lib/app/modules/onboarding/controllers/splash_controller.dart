import 'package:get/get.dart';
import 'package:bidmygoldflutter/app/routes/app_pages.dart'; // Import routes
import 'package:get_storage/get_storage.dart'; // Import GetStorage
import 'package:firebase_auth/firebase_auth.dart'; // Import FirebaseAuth

class SplashController extends GetxController {
  final _getStorage = GetStorage();
  final _auth = FirebaseAuth.instance;

  @override
  void onReady() {
    super.onReady();
    _checkStatusAndNavigate();
  }

  Future<void> _checkStatusAndNavigate() async {
    // Simulate loading time
    await Future.delayed(const Duration(seconds: 2)); // Reduced delay

    // Read flags from storage
    final languageSelected =
        _getStorage.read<bool>('language_selected') ?? false;
    final onboardingComplete =
        _getStorage.read<bool>('onboarding_complete') ?? false;
    final isLoggedIn = _auth.currentUser != null;

    // Determine initial route
    String initialRoute;
    if (!languageSelected) {
      initialRoute = Routes.LANGUAGE_SELECTION;
    } else if (!onboardingComplete) {
      initialRoute = Routes.ONBOARDING;
    } else if (isLoggedIn) {
      initialRoute = Routes.HOME; // User Dashboard
    } else {
      initialRoute = Routes.ANONYMOUS_HOME;
    }

    Get.offNamed(initialRoute); // Navigate using offNamed to replace splash
  }
}
