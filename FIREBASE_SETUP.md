# Fact Flash - Firebase Setup Guide

To run the **Fact Flash** application with real Firebase integration, follow these steps:

## 1. Create a Firebase Project
1. Go to the [Firebase Console](https://console.firebase.google.com/).
2. Click **"Add project"**.
3. Name your project (e.g., `fact-flash-quiz`).
4. Disable Google Analytics (optional, simplifies setup) and create the project.

## 2. Add Apps to Firebase

### For Web ✅ (ALREADY CONFIGURED)
The web platform is already configured! Firebase credentials are in `lib/firebase_options.dart`.

If you need to update or add a new web app:
1. In the Firebase Console, click the **Web** icon (`</>`).
2. Register your app with a nickname (e.g., "Fact Flash Web").
3. Copy the configuration values.
4. Update `lib/firebase_options.dart` with the new values.

### For Android
1. In the Firebase Console, click the **Android** icon.
2. Enter the package name: `com.example.fact_flash` (or check `android/app/build.gradle` for `applicationId`).
3. Click **Register app**.
4. Download `google-services.json`.
5. Place the file in: `android/app/google-services.json`.
6. Update the Android credentials in `lib/firebase_options.dart`.

### For iOS (Mac only)
1. In the Firebase Console, click the **iOS** icon.
2. Enter the Bundle ID: `com.example.factFlash` (or check `ios/Runner.xcodeproj`).
3. Click **Register app**.
4. Download `GoogleService-Info.plist`.
5. Open `ios/Runner.xcworkspace` in Xcode.
6. Drag and drop the file into the `Runner` folder in Xcode.
7. Update the iOS credentials in `lib/firebase_options.dart`.

## 3. Setup Firestore
1. In the Firebase Console, go to **Build** > **Firestore Database**.
2. Click **Create database**.
3. Choose a location and start in **Test mode** (for development).
4. The app includes a mock service that works without this, but to use real data:

### Option A: Import Mock Data Programmatically (Recommended)
Use the built-in importer to quickly populate your database:

```dart
// In main.dart, add this import:
import 'utils/firestore_importer.dart';

// Then call this after Firebase.initializeApp():
await importMockDataToFirestore();
```

The importer will check if the `questions` collection is empty and import all mock questions automatically.

### Option B: Add Questions Manually
- **Collection Name**: `questions`
- **Document Fields**:
  - `questionText` (string)
  - `options` (array of maps):
    - `description` (string)
    - `isCorrect` (boolean)
    - `explanation` (string) - *Optional*

## 4. Run the App
Run `flutter run -d chrome` (for web) or `flutter run` (for mobile) in your terminal.

## 5. Verify Firebase Connection
When the app starts, check the debug console for:
```
Firebase initialized successfully!
```

If you see this message, Firebase is working correctly! If you see "Running with Mock Data only", check your Firestore setup.
