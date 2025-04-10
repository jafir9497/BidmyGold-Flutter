# Bid My Gold - Development Task Sheet

## Phase 1: Foundation & Setup (Est. 1-2 Weeks)

- [x] Setup Flutter project environment.
- [x] Integrate GetX for state management and navigation.
- [x] Setup Firebase project (Auth, Firestore, Storage, Cloud Messaging, Crashlytics, Analytics).
- [x] Add Firebase configuration files (`google-services.json`, `GoogleService-Info.plist`).
- [x] Implement basic UI shell: Splash Screen.
- [x] Implement basic UI shell: Language Selection Screen.
- [x] Implement basic UI shell: Onboarding Screens.
- [x] Integrate `get_storage` for flags (first_launch, language_selected, onboarding_complete).
- [x] Implement conditional navigation logic (Splash -> Lang/Onboard/AnonHome/Dashboard).
- [x] Setup basic GetX localization structure.
- [x] Implement core Authentication flow (Mobile OTP) & listener for navigation.
- [x] Define base app theme using Material UI components.

## Phase 2: Core User Features (Est. 2-3 Weeks)

- [x] Implement Anonymous Home Screen UI (App Info, Estimator Placeholder, Login CTA).
- [x] Develop the Gold Loan Calculator UI (within Anonymous Home and/or User Dashboard).
- [x] Integrate a Gold Rate API (e.g., Metal Price API) for real-time pricing in Calculator.
- [x] Implement the User Details screen (post-login for first-time users).
- [x] Implement KYC Upload screen (part of registration flow).
- [x] Implement Loan Request Form screen (Jewel details, photos/video, amount).
- [x] Implement Loan Request Review/Confirmation screen.
- [x] Connect Loan Request submission to Firebase Firestore.
- [x] Build the basic User Dashboard structure (to display status/requests).

## Phase 3: Core Pawnbroker Features (Est. 2 Weeks)

- [x] Implement the Pawnbroker Registration flow (collecting shop/individual info post-OTP).
- [x] Build the basic Pawnbroker Dashboard structure.
- [x] Implement the screen for Pawnbrokers to view incoming loan requests/bids.
- [x] Implement the bid submission functionality for Pawnbrokers.

## Phase 4: Bidding Interaction & Communication (Est. 2-3 Weeks)

- [x] Integrate Firebase Cloud Messaging (FCM) for push notifications.
  - [x] Notify Pawnbrokers of new requests in their area.
  - [x] Notify Users of new bids received.
  - [x] Notify Pawnbrokers when their bid is accepted.
  - [x] Appointment reminders.
- [x] Implement the User screen to view and compare received bids.
- [x] Implement the User flow to accept a specific bid.
- [x] Develop the Appointment Scheduling UI and logic for both users and pawnbrokers.
- [x] Implement basic in-app Chat functionality between a User and the accepted Pawnbroker using Firebase Firestore.

## Phase 5: KYC & Verification (Est. 2-3 Weeks)

- [x] Implement KYC document upload UI/logic for Users (ID, Address proof, Selfie capture) using Firebase Storage.
- [x] Implement KYC document upload UI/logic for Pawnbrokers (Shop Reg, ID proof) using Firebase Storage.
- [x] Develop a secure Master Admin interface:
  - [x] Create admin user authentication system (separate from regular users and pawnbrokers)
  - [x] Implement admin dashboard with navigation to various admin functions
  - [x] Build KYC verification interface (view documents, approve/reject with reason)
  - [x] Add pawnbroker verification interface (view shop documents, approve/reject)
  - [x] Create user management section (view/search users, disable accounts if needed)
  - [x] Implement loan request monitoring and statistics
  - [x] Add system settings and configuration options
  - [x] Implement activity logs and admin audit trails
- [x] Display KYC status (Pending, Verified, Rejected) in User and Pawnbroker profiles.
- [x] Implement QR Code generation for verified Users:
  - [x] Add QR code package dependency (e.g., qr_flutter)
  - [x] Create QR code generator service to encode user ID and verification status
  - [x] Design user profile screen with QR code display
  - [ ] Add security features to prevent QR code spoofing
- [x] Implement QR Code scanning functionality for Pawnbrokers:
  - [x] Add QR code scanner package dependency (e.g., mobile_scanner)
  - [x] Create scanner screen with camera integration
  - [x] Implement QR code validation against Firestore records
  - [x] Design verification results UI with user details display
  - [x] Add transaction logging for each scan

## Phase 6: Payments & Refinements (Est. 2 Weeks)

- [ ] Integrate Razorpay SDK for handling EMI payments:
  - [x] Add Razorpay Flutter SDK dependency
  - [ ] Set up Razorpay account and API keys
  - [x] Implement payment gateway integration service
  - [ ] Create secure payment flow with proper validation
- [ ] Implement the EMI payment section within the User Dashboard:
  - [x] Design EMI payment schedule UI
  - [x] Create payment history view
  - [ ] Implement payment reminder notifications
  - [x] Add receipt generation and download functionality
- [ ] Develop a Pawnbroker rating and review system:
  - [x] Design rating UI for users to rate pawnbrokers
  - [x] Create review submission form with text feedback
  - [ ] Implement rating calculation and display on pawnbroker profiles
  - [ ] Add admin moderation interface for inappropriate reviews
  <!-- - [ ] (Optional) Integrate a third-party AI Document Verification service:
  - [ ] Research and select appropriate AI verification provider
  - [ ] Implement API integration for document validation
  - [ ] Create pre-verification flow before manual admin review
  - [ ] Add fraud detection capabilities -->
- [x] Implement Firebase Analytics to track key events:
  - [x] Configure analytics for user journey tracking
  - [x] Add custom event tracking for critical app actions
  - [x] Implement conversion tracking for important flows
  - [x] Create dashboard for analytics data visualization

## Phase 7: Testing, Optimization & Deployment (Est. 2-3 Weeks)

<!-- - [ ] Write Unit, Widget, and Integration tests:
  - [ ] Develop unit tests for business logic and service layers
  - [ ] Create widget tests for UI components
  - [ ] Implement integration tests for critical user flows
  - [ ] Set up continuous integration for automated testing
- [ ] Conduct thorough manual testing:
  - [ ] Create comprehensive test plan for all app features
  - [ ] Perform cross-device compatibility testing
  - [ ] Test network conditions and offline functionality
  - [ ] Conduct user acceptance testing with sample users -->

<!-- - [ ] Conduct thorough manual testing:

  - [ ] Test Admin Module Functionality (Login, Dashboard, Navigation, KYC/Pawn Verify, User/Admin Mgmt, Settings, Logs)
  - [ ] Create comprehensive test plan for all app features
  - [ ] Perform cross-device compatibility testing
  - [ ] Test network conditions and offline functionality
  - [ ] Conduct user acceptance testing with sample users -->

- [x] Optimize app performance:
  - [x] Implement lazy loading for large data sets
  - [x] Optimize Firebase queries with proper indexing
  - [x] Reduce app size with appropriate image compression
  - [x] Implement caching strategies for frequently accessed data
  <!-- - [ ] Perform security checks:
  - [ ] Conduct security audit of authentication processes
  - [ ] Test for data leakage and proper access controls
  - [ ] Verify secure storage of sensitive information
  - [ ] Implement additional security measures as needed -->
  <!-- - [ ] Prepare builds for Beta testing:
  - [ ] Configure Firebase App Distribution
  - [ ] Set up TestFlight for iOS testing
  - [ ] Create beta tester onboarding documentation
  - [ ] Implement crash reporting and beta feedback collection -->
  <!-- - [ ] Finalize app store listings:
  - [ ] Create compelling app descriptions
  - [ ] Design app store screenshots and promotional graphics
  - [ ] Record app preview videos
  - [ ] Prepare marketing materials and press kit -->
  <!-- - [ ] Deploy to Google Play Store and Apple App Store:
  - [ ] Complete app store review requirements
  - [ ] Configure in-app purchase products if applicable
  - [ ] Implement proper versioning strategy
  - [ ] Create post-launch monitoring plan -->

## Phase 8: Additional Features (Post-Initial Release)

- [x] Multiple language support (English, Tamil, Hindi):
  - [x] Implement localization architecture
  - [x] Create translation files for all app strings
  - [x] Design language selection UI
  - [x] Test text fitting and layout in all languages
- [x] Enhanced chat functionality:
  - [x] Implement real-time messaging
  - [x] Add message read receipts
  - [x] Create typing indicators
  - [x] Support image sharing in chats
- [x] In-app notifications center:
  - [x] Create dedicated notifications screen
  - [ ] Implement notification preference settings
  - [ ] Support rich notification content
  - [ ] Add notification grouping and categorization
- [x] User feedback system:
  - [x] Design feedback submission form
  - [ ] Implement satisfaction surveys
  - [ ] Create feedback management dashboard for admins
  - [ ] Add auto-categorization of feedback topics
- [ ] Performance analytics dashboard for pawnbrokers:
  - [ ] Visualize bid acceptance rates
  - [ ] Show conversion metrics and performance trends
  - [ ] Create competition analysis (anonymized)
  <!-- - [ ] Implement business growth suggestions -->
- [ ] Scheduled payment reminders:
  - [ ] Design reminder creation interface
  - [ ] Implement recurring notification system
  - [ ] Add custom reminder messages
  - [ ] Create calendar integration
- [ ] Transaction history and reporting:
  - [ ] Implement detailed transaction logs
  - [ ] Create financial reporting tools
  - [ ] Design exportable reports (PDF, Excel)
  - [ ] Add transaction search and filtering capabilities

## Localization Progress:

- [x] PawnbrokerVerificationScreen
- [x] KycVerificationScreen
- [x] AdminManagementScreen
- [x] AdminDashboardScreen
- [x] AdminLoginScreen
- [x] LoanRequestListScreen (Admin)
- [x] SystemSettingsScreen (Admin)
- [x] AdminLogsScreen (Admin)
