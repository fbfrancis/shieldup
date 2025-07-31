ShieldUp: Cybersecurity Learning App

ShieldUp is a mobile learning platform developed using Flutter and Firebase. The app is designed to teach users the fundamentals of cybersecurity through interactive modules, quizzes, real-time progress tracking, and an AI-powered tutoring system. ShieldUp integrates modern UI design, structured learning, and practical tools to enhance user engagement and retention.

-------------------------------------------------------------------------------

Features

- Dynamic Course Modules: Real-time content delivery from Firebase Firestore
- AI Tutor Chatbot: Gemini-powered chat with persistent memory and contextual answers
- Progress Tracking: Monitor user progress across lessons and quizzes
- Interactive Quizzes: Real-time feedback, retry options, and score analytics
- User Profile: Editable profile with image upload and persistent user data
- Concern Reporting: Report issues with optional image uploads
- Report History: View and manage previously submitted concerns
- Notification Center: Firestore-based in-app alerts (push notifications coming soon)
- Custom Themes: Light and dark themes using teal, black, and white colors
- Responsive UI: Optimized for all screen sizes and orientations

-------------------------------------------------------------------------------

Tech Stack

Frontend: Flutter and Dart  
Backend: Firebase (Firestore, Authentication, Storage, Functions)  
State Management: Provider  
Local Storage: Shared Preferences  
UI Tools: Google Fonts, Lottie, Image Picker

-------------------------------------------------------------------------------

Getting Started

Prerequisites

To set up and run this project, you must have the following installed:

- Flutter SDK
- Dart (included with Flutter)
- Git
- Android Studio or Visual Studio Code
- Firebase account with an active project

Optional:
- Android or iOS emulator
- Physical device for testing

Installation

1. Clone the repository

   git clone https://github.com/yourusername/shieldup.git  
   cd shieldup

2. Install Flutter dependencies

   flutter pub get

3. Configure Firebase

   - Add google-services.json to android/app/
   - Add GoogleService-Info.plist to ios/Runner/
   - Enable the following services in Firebase Console:
     - Firestore
     - Firebase Authentication (Email/Password)
     - Firebase Storage
     - Firebase Functions (if applicable)

4. (Optional) Configure AI API

   - Add your Gemini or Groq API key securely
   - You may use a .env file or secure key injection in ai_features.dart

5. Run the application

   flutter run

-------------------------------------------------------------------------------

Project Structure

lib/

├── main.dart                 Entry point of the app  
├── screens/                 Main app screens (Dashboard, Profile, etc.)  
├── providers/               App-wide state management (Theme, User)  
├── services/                Firebase and AI integration logic  
├── widgets/                 Reusable UI components  
├── models/                  Data structures (User, Report, etc.)

-------------------------------------------------------------------------------

Author

Name: Fosu Francis Boateng  
Project: ShieldUp – Cybersecurity Learning App  
Email: boatengfrancis881@gmail.com

-------------------------------------------------------------------------------

License

This project is intended for educational and academic use. For reuse or collaboration requests, please contact the author directly.

-------------------------------------------------------------------------------

Security

For details on how to report security vulnerabilities, please refer to the SECURITY.md file in this repository.
