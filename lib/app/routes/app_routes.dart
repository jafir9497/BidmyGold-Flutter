part of 'app_pages.dart';
// DO NOT EDIT. This is code generated via package:get_cli/get_cli.dart

abstract class Routes {
  Routes._();
  static const SPLASH = _Paths.SPLASH; // Example initial route
  static const LANGUAGE_SELECTION =
      _Paths.LANGUAGE_SELECTION; // Add language route
  static const ONBOARDING = _Paths.ONBOARDING; // Add onboarding route
  // Add other routes here as needed
  static const HOME = _Paths.HOME;
  static const ANONYMOUS_HOME =
      _Paths.ANONYMOUS_HOME; // Add anonymous home route
  static const LOGIN = _Paths.LOGIN;
  static const OTP = _Paths.OTP; // Add OTP route
  static const USER_DETAILS = _Paths.USER_DETAILS; // Add user details route
  static const KYC_UPLOAD = _Paths.KYC_UPLOAD; // Add KYC upload route
  static const LOAN_REQUEST = _Paths.LOAN_REQUEST; // Add loan request route
  static const LOAN_REQUEST_REVIEW =
      _Paths.LOAN_REQUEST_REVIEW; // Add loan request review route
  static const PAWNBROKER_REGISTRATION =
      _Paths.PAWNBROKER_REGISTRATION; // Add pawnbroker registration route
  static const PAWNBROKER_DASHBOARD =
      _Paths.PAWNBROKER_DASHBOARD; // Add pawnbroker dashboard route
  static const PAWNBROKER_LOAN_REQUEST_DETAILS = _Paths
      .PAWNBROKER_LOAN_REQUEST_DETAILS; // Add pawnbroker loan request details route
  static const PAWNBROKER_PLACE_BID =
      _Paths.PAWNBROKER_PLACE_BID; // Add pawnbroker place bid route

  // Phase 4 routes
  static const LOAN_REQUEST_BIDS =
      _Paths.LOAN_REQUEST_BIDS; // Add loan request bids route
  static const BID_DETAILS = _Paths.BID_DETAILS; // Add bid details route
  static const APPOINTMENT_SCHEDULING =
      _Paths.APPOINTMENT_SCHEDULING; // Add appointment scheduling route
  static const APPOINTMENT_DETAILS =
      _Paths.APPOINTMENT_DETAILS; // Add appointment details route
  static const CHAT = _Paths.CHAT; // Add chat route

  // Admin routes
  static const ADMIN_LOGIN = _Paths.ADMIN_LOGIN;
  static const ADMIN_DASHBOARD = _Paths.ADMIN_DASHBOARD;
  static const KYC_VERIFICATION = _Paths.KYC_VERIFICATION;
  static const PAWNBROKER_VERIFICATION = _Paths.PAWNBROKER_VERIFICATION;
  static const USER_MANAGEMENT = _Paths.USER_MANAGEMENT;
  static const LOAN_MONITORING = _Paths.LOAN_MONITORING;
  static const SYSTEM_SETTINGS = _Paths.SYSTEM_SETTINGS;
  static const ADMIN_LOGS = _Paths.ADMIN_LOGS;
  static const USER_QR = _Paths.USER_QR; // Add User QR Route Name
  static const PAWNBROKER_QR_SCANNER =
      _Paths.PAWNBROKER_QR_SCANNER; // Add Pawnbroker QR Scanner Route Name
  static const USER_PROFILE_DETAIL =
      _Paths.USER_PROFILE_DETAIL; // Add User Profile Detail Route Name (Admin)
  static const LOAN_REQUEST_DETAIL =
      _Paths.LOAN_REQUEST_DETAIL; // Add Loan Request Detail Route Name (Admin)
  static const ADMIN_MANAGEMENT =
      _Paths.ADMIN_MANAGEMENT; // Add Admin Management Route Name

  // User specific routes (post-login)
  static const EMI_PAYMENT = _Paths.EMI_PAYMENT; // Add EMI Payment route
  static const PAYMENT_HISTORY =
      _Paths.PAYMENT_HISTORY; // Add Payment History route
  static const NOTIFICATIONS = _Paths.NOTIFICATIONS; // Add Notifications route
  static const FEEDBACK = _Paths.FEEDBACK; // Add Feedback route
}

abstract class _Paths {
  _Paths._();
  static const SPLASH = '/splash';
  static const LANGUAGE_SELECTION = '/language-selection'; // Add language path
  static const ONBOARDING = '/onboarding'; // Add onboarding path
  static const HOME = '/home'; // Example home route (User Dashboard)
  static const ANONYMOUS_HOME = '/anonymous-home'; // Add anonymous home path
  static const LOGIN = '/login'; // Example login route
  static const OTP = '/otp'; // Add OTP path
  static const USER_DETAILS = '/user-details'; // Add user details path
  static const KYC_UPLOAD = '/kyc-upload'; // Add KYC upload path
  static const LOAN_REQUEST = '/loan-request'; // Add loan request path
  static const LOAN_REQUEST_REVIEW =
      '/loan-request-review'; // Add loan request review path
  static const PAWNBROKER_REGISTRATION =
      '/pawnbroker-registration'; // Add pawnbroker registration path
  static const PAWNBROKER_DASHBOARD =
      '/pawnbroker-dashboard'; // Add pawnbroker dashboard path
  static const PAWNBROKER_LOAN_REQUEST_DETAILS =
      '/pawnbroker-loan-request-details'; // Add pawnbroker loan request details path
  static const PAWNBROKER_PLACE_BID =
      '/pawnbroker-place-bid'; // Add pawnbroker place bid path

  // Phase 4 paths
  static const LOAN_REQUEST_BIDS =
      '/loan-request-bids'; // Add loan request bids path
  static const BID_DETAILS = '/bid-details'; // Add bid details path
  static const APPOINTMENT_SCHEDULING =
      '/appointment-scheduling'; // Add appointment scheduling path
  static const APPOINTMENT_DETAILS =
      '/appointment-details'; // Add appointment details path
  static const CHAT = '/chat'; // Add chat path

  // Admin paths
  static const ADMIN_LOGIN = '/admin/login';
  static const ADMIN_DASHBOARD = '/admin/dashboard';
  static const KYC_VERIFICATION = '/admin/kyc-verification';
  static const PAWNBROKER_VERIFICATION = '/admin/pawnbroker-verification';
  static const USER_MANAGEMENT = '/admin/user-management';
  static const LOAN_MONITORING = '/admin/loan-monitoring';
  static const SYSTEM_SETTINGS = '/admin/system-settings';
  static const ADMIN_LOGS = '/admin/logs';
  static const USER_QR = '/user/qr'; // Add User QR Path
  static const PAWNBROKER_QR_SCANNER =
      '/pawnbroker/qr-scanner'; // Add Pawnbroker QR Scanner Path
  static const USER_PROFILE_DETAIL =
      '/admin/user-profile-detail'; // Add User Profile Detail Path (Admin)
  static const LOAN_REQUEST_DETAIL =
      '/admin/loan-request-detail'; // Add Loan Request Detail Path (Admin)
  static const ADMIN_MANAGEMENT =
      '/admin/admin-management'; // Add Admin Management Path

  // User specific paths
  static const EMI_PAYMENT = '/user/emi-payment'; // Add EMI Payment path
  static const PAYMENT_HISTORY =
      '/user/payment-history'; // Add Payment History path
  static const NOTIFICATIONS = '/user/notifications'; // Add Notifications path
  static const FEEDBACK = '/user/feedback'; // Add Feedback path
}
