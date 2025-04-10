I am building a mobile app. I need a detailed and structured explanation of the app's flow and features, written as a Markdown file, so that it is easy for an app developer to understand and implement. Use the Context over to write this

Project Name : Bid My Gold

below is the concept

PaaS platform for Gold loan where the main concept of the app will be

The user will open the app and it will have a splash screen followed by language screen and followed by onboarding screen and a homescreen where the app will explain the process of bidmygold and it will show the gold loan calculator based on interest rate on paisa and rupees for 100 rupees based on todays gold rate we will provide upto 90% of the rate as mortage once the user fills the data the user will enter the required amount of loan or the gram of gold they have and the select the purity of gold if they don't know they select don't know option and they will enter the required loan amount so they will get estimate amount with emi if they know purity they will get loan amount upto 90% per gram they can customize the amount lets say i am eligible to get loan upto 1lak but i need only 10k i will change the required amount to 10k and submit

on home screen after onboarding they have 2 options either they can fill the data in gold loan estimator and proceed to login / register or they can straight away goto login / register page

on register page it should be for user and there will be a option to join as pawn broker for pawnbroker

3 types of users in app

- Master Admin
- User (customer)
- Pawn Brokers (Bidding agent)

The app should have registration with mobile number and otp for User and Pawn Broker and i need a master admin account details with a complete dashboard

The User need to upload the KYC for approving the bid which master admin will validate and approve it the KYC will be valid for a year and the user will be entitled as verified user which will be shown for pawn brokers know the user will be authentic as verified user

KYC Process: Requires ID Proof, Address Proof, and a Selfie with instructions (turn left, right, smile). Master Admin verifies.

On pawn broker registration once mobile authentication completed and they need to enter Name, Shop name, address, email (optional) once they submit they need to Upload Shop registration certificate and individual id proof for KYC then Master admin validate and approve it

Until the admin approve the user will be shown with a screen KYC in Progress

if the user is happy then we need to upload minimum 3 picture of the jewel and if possible need to upload a short video of the jewel once they submitted we will ask the user to enter their phone number which we will use to register the user into our portal and it will be authenticated using OTP and then we will ask the name of the user and email as optional and then we will show the user the details they submitted along with their location address which is fetched automatically and user can validate and submit the request

Once request submitted the nearby pawn brokers will get notified and they view the request with photos and details and can enter the bid amount they can offer once they enter the user will get the notification and they can view all the offered bid and they can check and approve the bid once bid approved the pawn broker will be notified the user can schedule appoinment for the next process the next process where the user can upload the KYC documents and visit the pawn broker to get the gold pledged.

In addition we need to add emi payment via dashboard from user via razorpay. and add chat feature to chat between user and pawnbrokers regarding their bid

this is app is purely for India need multi language support for indian local languages like tamil, hindi, malayalam, kannada, telegu, marati etc create translation file for each language with strings i will create new if i need to add new language

create a strings files i will add languages in future

Add gold rate API integration for real-time pricing

Implement advanced analytics for loan performance

Add document verification AI to streamline KYC process

Create pawnbroker rating and review system

On user dashboard add a QR image so the pawn broker can scan it from their dashboard app to validate the user is geniune and so we can track the process weather user went to pawn shop and on booking appoinment they will be generated with the instructions to display qr on pawn shop

## Tech Stack

- **Framework**: Flutter
- **Statemanagement and Navigation**: Getx
- **UI**: Material UI
- **Backend/Auth**: Firebase (auth, storage, real-time, database, cloud messaging and crashanalytics)

## App Workflow Clarification

The app follows different flows based on the user's status:

**1. First-Time User Flow:**

- Splash Screen shows briefly.
- Language Selection screen appears.
- User selects a language.
- Onboarding screens explain the app process.
- User lands on the **Anonymous Home Screen** which shows:
  - App process explanation.
  - Gold Loan Estimator.
  - Login/Register options / "Get Started" CTA.
- If the user uses the estimator or clicks "Get Started":
  - They are prompted to Login/Register (Mobile OTP).
  - After successful authentication, they proceed to User Details/KYC upload (ID, Address, Selfie).
  - Then, they can fill the Loan Request form (uploading jewel photos/video).
  - A validation/review screen shows the submitted details.
  - Finally, they land on their personalized User Dashboard.

**2. Returning User (Logged Out) Flow:**

- Splash Screen shows briefly.
- App checks storage (language selected, onboarding done).
- App checks auth state (user is logged out).
- User lands directly on the **Anonymous Home Screen**.
- Flow continues as step 1 (from Login/Register prompt) if they choose to proceed.

**3. Returning User (Logged In) Flow:**

- Splash Screen shows briefly.
- App checks storage (language selected, onboarding done).
- App checks auth state (user is logged in).
- User lands directly on their personalized **User Dashboard Screen**.

**Home Screen Note:** The concept mentions a home screen after onboarding _before_ login/register, containing the estimator. This is the **Anonymous Home Screen**. The **User Dashboard Screen** is what logged-in users see.
