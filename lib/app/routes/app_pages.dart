import 'package:get/get.dart';
// Remove Placeholder import if no longer needed
// import 'package:flutter/material.dart';

// Import screen and binding
import 'package:bidmygoldflutter/app/modules/onboarding/bindings/splash_binding.dart';
import 'package:bidmygoldflutter/app/modules/onboarding/screens/splash_screen.dart';
import 'package:bidmygoldflutter/app/modules/onboarding/bindings/language_binding.dart'; // Import language binding
import 'package:bidmygoldflutter/app/modules/onboarding/screens/language_screen.dart'; // Import language screen
import 'package:bidmygoldflutter/app/modules/onboarding/bindings/onboarding_binding.dart'; // Import onboarding binding
import 'package:bidmygoldflutter/app/modules/onboarding/screens/onboarding_screen.dart'; // Import onboarding screen

// Import Auth screens & bindings
import 'package:bidmygoldflutter/app/modules/auth/bindings/auth_binding.dart';
import 'package:bidmygoldflutter/app/modules/auth/screens/login_screen.dart';
import 'package:bidmygoldflutter/app/modules/auth/screens/otp_screen.dart';

// Import Home screens & bindings
import 'package:bidmygoldflutter/app/modules/home/bindings/anonymous_home_binding.dart';
import 'package:bidmygoldflutter/app/modules/home/screens/anonymous_home_screen.dart';
// TODO: Import user dashboard screen/binding later
import 'package:bidmygoldflutter/app/modules/user/details/bindings/user_details_binding.dart'; // Import User Details Binding
import 'package:bidmygoldflutter/app/modules/user/details/screens/user_details_screen.dart'; // Import User Details Screen
import 'package:bidmygoldflutter/app/modules/user/kyc/bindings/kyc_binding.dart'; // Import KYC Binding
import 'package:bidmygoldflutter/app/modules/user/kyc/screens/kyc_screen.dart'; // Import KYC Screen
import 'package:bidmygoldflutter/app/modules/user/loan_request/bindings/loan_request_binding.dart'; // Import Loan Request Binding
import 'package:bidmygoldflutter/app/modules/user/loan_request/screens/loan_request_screen.dart'; // Import Loan Request Screen
import 'package:bidmygoldflutter/app/modules/user/loan_request/screens/loan_request_review_screen.dart'; // Import Loan Request Review Screen
import 'package:bidmygoldflutter/app/modules/user/dashboard/screens/dashboard_screen.dart'; // Import Dashboard Screen
import 'package:bidmygoldflutter/app/modules/user/dashboard/bindings/dashboard_binding.dart'; // Import Dashboard Binding
import 'package:bidmygoldflutter/app/modules/pawnbroker/registration/screens/pawnbroker_registration_screen.dart'; // Import Pawnbroker Registration Screen
import 'package:bidmygoldflutter/app/modules/pawnbroker/registration/bindings/pawnbroker_registration_binding.dart'; // Import Pawnbroker Registration Binding
import 'package:bidmygoldflutter/app/modules/pawnbroker/dashboard/screens/pawnbroker_dashboard_screen.dart'; // Import Pawnbroker Dashboard Screen
import 'package:bidmygoldflutter/app/modules/pawnbroker/dashboard/bindings/pawnbroker_dashboard_binding.dart'; // Import Pawnbroker Dashboard Binding
import 'package:bidmygoldflutter/app/modules/pawnbroker/place_bid/screens/pawnbroker_place_bid_screen.dart'; // Import Pawnbroker Place Bid Screen
import 'package:bidmygoldflutter/app/modules/pawnbroker/place_bid/bindings/pawnbroker_place_bid_binding.dart'; // Import Pawnbroker Place Bid Binding
import 'package:bidmygoldflutter/app/modules/pawnbroker/loan_request_details/screens/pawnbroker_loan_request_details_screen.dart'; // Import Pawnbroker Loan Request Details Screen
import 'package:bidmygoldflutter/app/modules/pawnbroker/loan_request_details/bindings/pawnbroker_loan_request_details_binding.dart'; // Import Pawnbroker Loan Request Details Binding

// Phase 4 imports
import 'package:bidmygoldflutter/app/modules/user/loan_request/screens/loan_request_bids_screen.dart'; // Import Loan Request Bids Screen
import 'package:bidmygoldflutter/app/modules/user/loan_request/bindings/loan_request_bids_binding.dart'; // Import Loan Request Bids Binding
import 'package:bidmygoldflutter/app/modules/user/bid_details/screens/bid_details_screen.dart'; // Import Bid Details Screen
import 'package:bidmygoldflutter/app/modules/user/bid_details/bindings/bid_details_binding.dart'; // Import Bid Details Binding
import 'package:bidmygoldflutter/app/modules/appointment/screens/appointment_scheduling_screen.dart'; // Import Appointment Scheduling Screen
import 'package:bidmygoldflutter/app/modules/appointment/bindings/appointment_scheduling_binding.dart'; // Import Appointment Scheduling Binding
import 'package:bidmygoldflutter/app/modules/appointment/screens/appointment_details_screen.dart'; // Import Appointment Details Screen
import 'package:bidmygoldflutter/app/modules/appointment/bindings/appointment_details_binding.dart'; // Import Appointment Details Binding
import 'package:bidmygoldflutter/app/modules/chat/screens/chat_screen.dart'; // Import Chat Screen
import 'package:bidmygoldflutter/app/modules/chat/bindings/chat_binding.dart'; // Import Chat Binding

// Import placeholder screens for now if needed, or remove

// Admin imports
import '../modules/admin/bindings/admin_login_binding.dart';
import '../modules/admin/screens/admin_login_screen.dart';
import '../modules/admin/bindings/admin_dashboard_binding.dart';
import '../modules/admin/screens/admin_dashboard_screen.dart';
import '../modules/admin/bindings/kyc_verification_binding.dart';
import '../modules/admin/screens/kyc_verification_screen.dart';
import '../modules/admin/bindings/pawnbroker_verification_binding.dart';
import '../modules/admin/screens/pawnbroker_verification_screen.dart';
import '../modules/admin/bindings/user_management_binding.dart';
import '../modules/admin/screens/user_management_screen.dart';
import '../modules/admin/bindings/loan_monitoring_binding.dart';
import '../modules/admin/screens/loan_monitoring_screen.dart';
import '../modules/admin/bindings/system_settings_binding.dart';
import '../modules/admin/screens/system_settings_screen.dart';
import '../modules/admin/bindings/admin_logs_binding.dart';
import '../modules/admin/screens/admin_logs_screen.dart';
import '../modules/user/profile/bindings/user_qr_binding.dart';
import '../modules/user/profile/screens/user_qr_screen.dart';
// Import Pawnbroker QR Scanner components
import '../modules/pawnbroker/qr_scanner/screens/pawnbroker_qr_scanner_screen.dart';
import '../modules/pawnbroker/qr_scanner/bindings/pawnbroker_qr_scanner_binding.dart';
// Import User Profile Detail components
import '../modules/admin/screens/user_profile_detail_screen.dart';
import '../modules/admin/bindings/user_profile_detail_binding.dart';
// Import Loan Request Detail components
import '../modules/admin/screens/loan_request_detail_screen.dart';
import '../modules/admin/bindings/loan_request_detail_binding.dart';
// Import Admin Management components
import '../modules/admin/screens/admin_management_screen.dart';
import '../modules/admin/bindings/admin_management_binding.dart';

// Import EMI Payment components
import '../modules/user/emi_payment/bindings/emi_payment_binding.dart';
import '../modules/user/emi_payment/screens/emi_payment_screen.dart';

// Import Payment History components
import '../modules/user/payment_history/bindings/payment_history_binding.dart';
import '../modules/user/payment_history/screens/payment_history_screen.dart';

// Import Notifications components
import '../modules/notifications/bindings/notifications_binding.dart';
import '../modules/notifications/screens/notifications_screen.dart';

// Import Feedback components
import '../modules/feedback/bindings/feedback_binding.dart';
import '../modules/feedback/screens/feedback_screen.dart';

part 'app_routes.dart';

class AppPages {
  AppPages._();

  static const INITIAL = Routes.SPLASH; // Set initial route to Splash

  static final routes = [
    GetPage(
      name: _Paths.SPLASH,
      page: () => const SplashScreen(), // Use actual Splash Screen
      binding: SplashBinding(), // Add Splash Binding
    ),
    GetPage(
      name: _Paths.LANGUAGE_SELECTION,
      page: () => const LanguageScreen(),
      binding: LanguageBinding(),
    ),
    GetPage(
      name: _Paths.ONBOARDING, // Add Onboarding route
      page: () => const OnboardingScreen(),
      binding: OnboardingBinding(),
    ),
    GetPage(
      name: _Paths.ANONYMOUS_HOME,
      page: () => const AnonymousHomeScreen(),
      binding: AnonymousHomeBinding(),
    ),
    GetPage(
      name: _Paths.LOGIN,
      page: () => const LoginScreen(), // Use actual Login Screen
      binding: AuthBinding(), // Use Auth Binding
    ),
    GetPage(
      name: _Paths.OTP,
      page: () => const OtpScreen(), // Use actual OTP Screen
      binding: AuthBinding(), // Use Auth Binding
    ),
    GetPage(
      name: _Paths.USER_DETAILS, // Add User Details route
      page: () => const UserDetailsScreen(),
      binding: UserDetailsBinding(),
    ),
    GetPage(
      name: _Paths.KYC_UPLOAD, // Add KYC Upload route
      page: () => const KycScreen(),
      binding: KycBinding(),
    ),
    GetPage(
      name: _Paths.LOAN_REQUEST, // Add Loan Request route
      page: () => const LoanRequestScreen(),
      binding: LoanRequestBinding(),
    ),
    GetPage(
      name: _Paths.LOAN_REQUEST_REVIEW, // Add Loan Request Review route
      page: () => const LoanRequestReviewScreen(),
      binding: LoanRequestBinding(), // Reuse the same binding
    ),
    GetPage(
      name: _Paths.PAWNBROKER_REGISTRATION, // Add Pawnbroker Registration route
      page: () => const PawnbrokerRegistrationScreen(),
      binding: PawnbrokerRegistrationBinding(),
    ),
    GetPage(
      name: _Paths.PAWNBROKER_DASHBOARD, // Add Pawnbroker Dashboard route
      page: () => const PawnbrokerDashboardScreen(),
      binding: PawnbrokerDashboardBinding(),
    ),
    GetPage(
      name: _Paths
          .PAWNBROKER_LOAN_REQUEST_DETAILS, // Add Pawnbroker Loan Request Details route
      page: () => const PawnbrokerLoanRequestDetailsScreen(),
      binding: PawnbrokerLoanRequestDetailsBinding(),
    ),
    GetPage(
      name: _Paths.PAWNBROKER_PLACE_BID, // Add Pawnbroker Place Bid route
      page: () => const PawnbrokerPlaceBidScreen(),
      binding: PawnbrokerPlaceBidBinding(),
    ),

    // Phase 4 routes
    GetPage(
      name: _Paths.LOAN_REQUEST_BIDS, // Add Loan Request Bids route
      page: () => const LoanRequestBidsScreen(),
      binding: LoanRequestBidsBinding(),
    ),
    GetPage(
      name: _Paths.BID_DETAILS, // Add Bid Details route
      page: () => const BidDetailsScreen(),
      binding: BidDetailsBinding(),
    ),
    GetPage(
      name: _Paths.APPOINTMENT_SCHEDULING, // Add Appointment Scheduling route
      page: () => const AppointmentSchedulingScreen(),
      binding: AppointmentSchedulingBinding(),
    ),
    GetPage(
      name: _Paths.APPOINTMENT_DETAILS, // Add Appointment Details route
      page: () => const AppointmentDetailsScreen(),
      binding: AppointmentDetailsBinding(),
    ),
    GetPage(
      name: _Paths.CHAT, // Add Chat route
      page: () => const ChatScreen(),
      binding: ChatBinding(),
    ),

    // Add other pages here
    GetPage(
      name: _Paths.HOME,
      page: () => const DashboardScreen(), // Use actual Dashboard Screen
      binding: DashboardBinding(), // Use Dashboard Binding
    ),

    // Admin Routes
    GetPage(
      name: Routes.ADMIN_LOGIN,
      page: () => const AdminLoginScreen(),
      binding: AdminLoginBinding(),
    ),
    GetPage(
      name: Routes.ADMIN_DASHBOARD,
      page: () => const AdminDashboardScreen(),
      binding: AdminDashboardBinding(),
    ),
    GetPage(
      name: Routes.KYC_VERIFICATION,
      page: () => const KycVerificationScreen(),
      binding: KycVerificationBinding(),
    ),
    GetPage(
      name: Routes.PAWNBROKER_VERIFICATION,
      page: () => const PawnbrokerVerificationScreen(),
      binding: PawnbrokerVerificationBinding(),
    ),
    GetPage(
      name: Routes.USER_MANAGEMENT,
      page: () => const UserManagementScreen(),
      binding: UserManagementBinding(),
    ),
    GetPage(
      name: Routes.LOAN_MONITORING,
      page: () => const LoanMonitoringScreen(),
      binding: LoanMonitoringBinding(),
    ),
    GetPage(
      name: Routes.SYSTEM_SETTINGS,
      page: () => const SystemSettingsScreen(),
      binding: SystemSettingsBinding(),
    ),
    GetPage(
      name: Routes.ADMIN_LOGS,
      page: () => const AdminLogsScreen(),
      binding: AdminLogsBinding(),
    ),
    GetPage(
      name: Routes.USER_QR,
      page: () => const UserQrScreen(),
      binding: UserQrBinding(),
    ),
    // Pawnbroker QR Scanner Route
    GetPage(
      name: Routes.PAWNBROKER_QR_SCANNER,
      page: () => const PawnbrokerQrScannerScreen(),
      binding: PawnbrokerQrScannerBinding(),
    ),
    // User Profile Detail Route (Admin)
    GetPage(
      name: Routes.USER_PROFILE_DETAIL,
      page: () => const UserProfileDetailScreen(),
      binding: UserProfileDetailBinding(),
    ),
    // Loan Request Detail Route (Admin)
    GetPage(
      name: Routes.LOAN_REQUEST_DETAIL,
      page: () => const LoanRequestDetailScreen(),
      binding: LoanRequestDetailBinding(),
    ),
    // Admin Management Route
    GetPage(
      name: Routes.ADMIN_MANAGEMENT,
      page: () => const AdminManagementScreen(),
      binding: AdminManagementBinding(),
    ),
    // EMI Payment Route
    GetPage(
      name: _Paths.EMI_PAYMENT,
      page: () => const EmiPaymentScreen(),
      binding: EmiPaymentBinding(),
      // Add middleware if needed (e.g., ensure user is logged in)
      // middlewares: [AuthMiddleware()],
    ),
    // Payment History Route
    GetPage(
      name: _Paths.PAYMENT_HISTORY,
      page: () => const PaymentHistoryScreen(),
      binding: PaymentHistoryBinding(),
      // middlewares: [AuthMiddleware()],
    ),
    // Notifications Route
    GetPage(
      name: _Paths.NOTIFICATIONS,
      page: () => const NotificationsScreen(),
      binding: NotificationsBinding(),
      // middlewares: [AuthMiddleware()],
    ),
    // Feedback Route
    GetPage(
      name: _Paths.FEEDBACK,
      page: () => const FeedbackScreen(),
      binding: FeedbackBinding(),
      // middlewares: [AuthMiddleware()],
    ),
  ];
}
