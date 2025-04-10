# Bid My Gold - Context Document

## Overview

Bid My Gold is a Platform-as-a-Service (PaaS) application for gold loans, connecting users with pawnbrokers through a bidding system. The app facilitates gold loan processing, KYC verification, and secure transactions between verified users and authorized pawnbrokers.

## User Types

1. **Master Admin**

   - Complete dashboard access
   - KYC verification authority
   - System monitoring and analytics
   - User and pawnbroker management

2. **User (Customer)**

   - Gold loan estimation
   - KYC submission
   - Bid management
   - Payment processing
   - Chat functionality
   - QR code for verification

3. **Pawn Brokers (Bidding Agents)**
   - Bid submission
   - User verification
   - Appointment management
   - Chat functionality
   - QR code scanning

## Core Features

### 1. Authentication & Registration

- Mobile number-based OTP authentication
- Separate registration flows for users and pawnbrokers
- KYC verification process
- Multi-language support (Tamil, Hindi, Malayalam, Kannada, Telugu, Marathi)

### 2. Gold Loan Calculator

- Real-time gold rate integration
- Loan amount estimation (up to 90% of gold value)
- EMI calculation
- Purity selection options
- Customizable loan amount

### 3. KYC Process

- Document upload system
- Selfie capture with liveness instructions (actual detection via SDK/service is optional)
  - Advanced selfie capture flow with step-by-step guidance
  - Visual prompts for different facial poses (turn left, turn right, smile)
  - Animated face outline guide with visual cues for each instruction
  - Preview and confirmation screen for captured selfies
- AI-powered document verification (Optional future enhancement)
- One-year validity period
- Verification status tracking
- Required documents:
  - For Users: ID proof, address proof, Selfie
  - For Pawnbrokers: Shop registration certificate, individual ID proof

### 4. Bidding System

- Jewel image/video upload (minimum 3 images)
- Location-based pawnbroker notification
- Bid submission and management
- Bid approval workflow
- Appointment scheduling

### 5. Payment Integration

- Razorpay integration for EMI payments
- Payment tracking
- Transaction history

### 6. Communication

- In-app chat between users and pawnbrokers
- Push notifications for bid updates
- Appointment notifications

### 7. Verification & Security

- QR code generation for user verification
- Pawnbroker scanning system
- Location tracking
- Secure document storage

### 8. Analytics & Reporting

- Loan performance tracking
- User engagement metrics
- Transaction analytics
- System performance monitoring

## Technical Stack

App Name : Bid My Gold
Bundle ID: com.bidmygold.app

### Frontend

- **Framework**: Flutter
- **State Management & Navigation**: GetX
- **UI Components**: Material UI (Flutter's built-in Material library)
- **Localization**: GetX Localization

### Backend & Services

- **Authentication**: Firebase Auth
- **Database**: Firebase Realtime Database
- **Storage**: Firebase Storage
- **Messaging**: Firebase Cloud Messaging
- **Analytics**: Firebase Analytics
- **Crash Reporting**: Firebase Crashlytics

### Third-Party Integrations

- Razorpay Payment Gateway
- Gold Rate API
- AI Document Verification Service
- Maps API for location services

## App Flow

This describes the high-level navigation flow based on user state.

### State Check (Post-Splash)

1.  Check local storage for `language_selected` flag.
2.  Check local storage for `onboarding_complete` flag.
3.  Check Firebase `authStateChanges` stream for logged-in user.

### Flow Logic

1.  **IF** `language_selected` is `false` -> Go to **Language Selection Screen**.
    - On completion, set flag, proceed to check onboarding.
2.  **ELSE IF** `onboarding_complete` is `false` -> Go to **Onboarding Screen**.
    - On completion, set flag, proceed to check auth state.
3.  **ELSE IF** `authStateChanges` indicates **logged out** -> Go to **Anonymous Home Screen**.
    - Contains estimator, app info, Login/Register CTA.
    - CTA leads to Login Screen.
4.  **ELSE IF** `authStateChanges` indicates **logged in** -> Go to **User Dashboard Screen**.

### User Action Flows

- **Login/Registration (from Anonymous Home):**
  1.  Login Screen (Enter Mobile)
  2.  OTP Screen (Verify OTP)
  3.  _On Success:_ Firebase Auth state changes, listener navigates to User Dashboard (or further registration steps if needed).
- **Submitting First Loan Request (Post-Login/Registration):**
  1.  (From Dashboard or prompted) User Details Screen (Name, Email etc.)
  2.  KYC Upload Screen (ID, Address, Selfie)
  3.  Loan Request Form (Jewel Details, Photos/Video, Amount)
  4.  Review/Confirmation Screen
  5.  Submission -> Back to User Dashboard (showing pending request)

## Security Considerations

- End-to-end encryption for sensitive data
- Secure document storage
- Regular security audits
- Compliance with Indian financial regulations
- Data privacy protection

## Future Enhancements

- Additional language support
- Advanced AI features
- Enhanced analytics
- Additional payment gateways
- Integration with banking systems

## Development Checklist

- [ ] Core authentication system
- [ ] Multi-language support
- [ ] Gold rate API integration
- [x] KYC verification system (including selfie capture)
- [ ] Document upload functionality
- [ ] Bidding system
- [ ] Chat implementation
- [ ] Payment integration
- [ ] QR code system
- [ ] Analytics dashboard
- [ ] Push notifications
- [ ] Location services
- [ ] Admin dashboard
- [ ] Testing and QA
- [ ] Security implementation
- [ ] Performance optimization

## Firebase Configuration

- Project created in Firebase Console
- Configuration files location: docs/configs/
  - Android: google-services.json
  - iOS: GoogleService-Info.plist
- Bundle ID: com.bidmygold.app

## Firebase Setup

1. Create Firebase project
2. Add Android & iOS apps
3. Download and place configuration files:
   - Android: `android/app/google-services.json`
   - iOS: `ios/Runner/GoogleService-Info.plist`

## Getting Started

## API Configuration

- Metal Price API for real-time gold rates
  - Base URL: https://api.metalpriceapi.com/v1
  - API Key: 9a3d8c0dd64594a0d616dff03e7594da
  - Features:
    - Real-time gold rates
    - Historical data
    - Multi-currency support
    - Automatic purity calculations

## Development Plan (Phased Approach)

### Phase 1: Foundation & Setup (Est. 1-2 Weeks)

- Setup Flutter project environment.
- Integrate GetX for state management and navigation.
- Setup Firebase project (Auth, Firestore, Storage, Cloud Messaging, Crashlytics, Analytics).
- Add Firebase configuration files (`google-services.json`, `GoogleService-Info.plist`).
- Implement basic UI shell: Splash Screen, Language Selection Screen, Onboarding Screens.
- Implement core Authentication flow (Mobile OTP) for both User and Pawnbroker roles using Firebase Auth.
- Setup basic GetX localization structure with initial language files (e.g., English, Tamil).
- Define base app theme using Material UI components.

### Phase 2: Core User Features (Est. 2-3 Weeks)

- Develop the Gold Loan Calculator UI.
- Integrate a Gold Rate API (e.g., Metal Price API) for real-time pricing.
- Implement the User Registration flow (collecting basic info post-OTP).
- Build the basic User Dashboard structure.
- Implement jewel image/video upload functionality using Firebase Storage.
- Create the "Submit Loan Request/Bid" form and connect it to Firebase Firestore.

### Phase 3: Core Pawnbroker Features (Est. 2 Weeks)

- Implement the Pawnbroker Registration flow (collecting shop/individual info post-OTP).
- Build the basic Pawnbroker Dashboard structure.
- Implement the screen for Pawnbrokers to view incoming loan requests/bids.
- Implement the bid submission functionality for Pawnbrokers.

### Phase 4: Bidding Interaction & Communication (Est. 2-3 Weeks)

- Integrate Firebase Cloud Messaging (FCM) for push notifications:
  - Notify Pawnbrokers of new requests in their area.
  - Notify Users of new bids received.
  - Notify Pawnbrokers when their bid is accepted.
  - Appointment reminders.
- Implement the User screen to view and compare received bids.
- Implement the User flow to accept a specific bid.
- Develop the Appointment Scheduling UI and logic for both users and pawnbrokers.
- Implement basic in-app Chat functionality between a User and the accepted Pawnbroker using Firebase Firestore.

### Phase 5: KYC & Verification (Est. 2-3 Weeks)

- Implement KYC document upload UI/logic for Users (ID, Address proof, Selfie capture) using Firebase Storage.
  - Completed the user KYC upload module with ID and Address proof document capture
  - Implemented advanced guided selfie capture with facial pose instructions
  - Added interactive face guide overlay that changes based on instructions
  - Created review screen for confirming the captured selfie
  - Used animations for smooth transitions between instructions
- Implement KYC document upload UI/logic for Pawnbrokers (Shop Reg, ID proof) using Firebase Storage.
- Develop a secure Master Admin interface (potentially a simple web app or separate Flutter app module) for reviewing and approving/rejecting KYC submissions. Update Firestore records accordingly.
- Display KYC status (Pending, Verified, Rejected) in User and Pawnbroker profiles.
- Implement QR Code generation for verified Users within their app.
- Implement QR Code scanning functionality for Pawnbrokers to verify users during appointments.

### Phase 6: Payments & Refinements (Est. 2 Weeks)

- Integrate Razorpay SDK for handling EMI payments.
- Implement the EMI payment section within the User Dashboard.
- Develop a Pawnbroker rating and review system.
- (Optional) Integrate a third-party AI Document Verification service if chosen.
- Implement Firebase Analytics to track key events (registrations, bids, payments, etc.).

### Phase 7: Testing, Optimization & Deployment (Est. 2-3 Weeks)

- Write Unit, Widget, and Integration tests.
- Conduct thorough manual testing across different devices and scenarios.
- Optimize app performance (startup time, UI smoothness, network usage).
- Perform security checks and address potential vulnerabilities.
- Prepare builds for Beta testing (e.g., Firebase App Distribution).
- Finalize app store listings (graphics, descriptions).
- Deploy to Google Play Store and Apple App Store.

## Proposed Folder Structure (Flutter with GetX)

```
bidmygoldflutter/
├── android/                 # Android specific code
├── ios/                     # iOS specific code
├── lib/                     # Dart code
│   ├── app/                 # Application-level configuration and modules
│   │   ├── data/            # Data layer: models, providers, repositories
│   │   │   ├── models/      # Data models (User, PawnBroker, Bid, KYC, LoanRequest, etc.)
│   │   │   ├── providers/   # API clients, DB access (Firebase Services, Gold API Client, Razorpay Client)
│   │   │   └── repositories/ # Abstracts data sources (AuthRepo, BidRepo, UserRepo, PaymentRepo)
│   │   ├── modules/         # Feature modules (organized by feature/screen)
│   │   │   ├── auth/        # Authentication (Login, Register, OTP)
│   │   │   │   ├── bindings/
│   │   │   │   ├── controllers/
│   │   │   │   ├── screens/
│   │   │   │   └── widgets/
│   │   │   ├── onboarding/  # Splash, Language Select, Onboarding Slides
│   │   │   │   ├── bindings/
│   │   │   │   ├── controllers/
│   │   │   │   ├── screens/
│   │   │   │   └── widgets/
│   │   │   ├── calculator/  # Gold Loan Calculator
│   │   │   │   ├── controllers/
│   │   │   │   ├── screens/
│   │   │   │   └── widgets/
│   │   │   ├── user/        # User specific features
│   │   │   │   ├── dashboard/
│   │   │   │   ├── kyc/
│   │   │   │   ├── loan_request/ # Creating new loan requests
│   │   │   │   ├── bids/       # Viewing bids
│   │   │   │   ├── payments/
│   │   │   │   ├── appointments/
│   │   │   │   └── profile/    # Includes QR code display
│   │   │   ├── pawnbroker/  # Pawnbroker specific features
│   │   │   │   ├── dashboard/
│   │   │   │   ├── kyc/
│   │   │   │   ├── requests/   # Viewing loan requests
│   │   │   │   ├── bidding/    # Submitting bids
│   │   │   │   ├── appointments/
│   │   │   │   └── profile/    # Includes QR code scanner
│   │   │   ├── chat/        # Chat feature
│   │   │   │   ├── bindings/
│   │   │   │   ├── controllers/
│   │   │   │   ├── models/
│   │   │   │   ├── screens/
│   │   │   │   └── widgets/
│   │   │   ├── admin/       # Optional: Admin functionalities if built into the same app
│   │   ├── routes/          # GetX Navigation Routes
│   │   │   ├── app_pages.dart # Defines GetPages
│   │   │   └── app_routes.dart # Defines route names (constants)
│   │   ├── services/        # Background/Core services (Firebase Push Notifications, Location)
│   │   ├── translations/    # Localization strings (e.g., AppTranslations.dart or JSON files)
│   │   ├── utils/           # Utility functions, constants, extensions, theme
│   │   │   ├── constants.dart # App-wide constants
│   │   │   ├── helpers/     # Helper functions
│   │   │   ├── theme/       # Theme data (colors, typography)
│   │   │   └── validators.dart # Input validators
│   │   └── widgets/         # Common UI widgets shared across multiple modules
│   ├── main.dart            # Application entry point (initializes GetX, Firebase)
├── assets/                  # Static assets
│   ├── fonts/
│   ├── images/
│   └── translations/      # Location for JSON translation files if preferred
├── test/                    # Unit, widget, and integration tests
├── docs/                    # Project documentation
│   ├── configs/             # Firebase config files (copied here for reference, actual location varies)
│   └── context.md           # This file
├── .gitignore
├── pubspec.yaml             # Flutter project dependencies
└── README.md                # Project overview, setup instructions
```
