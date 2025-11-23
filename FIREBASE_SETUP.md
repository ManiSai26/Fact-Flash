# Fact Flash - Firebase Setup Guide

To run the **Fact Flash** application with real Firebase integration, follow these steps:

## 1. Create a Firebase Project
1. Go to the [Firebase Console](https://console.firebase.google.com/).
2. Click **"Add project"**.
3. Name your project (e.g., `fact-flash-quiz`).
4. Disable Google Analytics (optional, simplifies setup) and create the project.

## 2. Add Apps to Firebase

### For Android
1. In the Firebase Console, click the **Android** icon.
2. Enter the package name: `com.example.fact_flash` (or check `android/app/build.gradle` for `applicationId`).
3. Click **Register app**.
4. Download `google-services.json`.
5. Place the file in: `android/app/google-services.json`.

### For iOS (Mac only)
1. In the Firebase Console, click the **iOS** icon.
2. Enter the Bundle ID: `com.example.factFlash` (or check `ios/Runner.xcodeproj`).
3. Click **Register app**.
4. Download `GoogleService-Info.plist`.
5. Open `ios/Runner.xcworkspace` in Xcode.
6. Drag and drop the file into the `Runner` folder in Xcode.

## 3. Setup Firestore
1. In the Firebase Console, go to **Build** > **Firestore Database**.
2. Click **Create database**.
3. Choose a location and start in **Test mode** (for development).
4. **Important**: The app includes a mock service that works without this, but to use real data, you would need to populate the `questions` collection.
   - **Collection Name**: `questions`
   - **Document Fields**:
     - `questionText` (string)
     - `options` (array of maps):
       - `description` (string)
       - `isCorrect` (boolean)
       - `explanation` (string) - *Optional*

## 4. Run the App
Run `flutter run` in your terminal.
