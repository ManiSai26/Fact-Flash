# Fact Flash 🎯

A beautiful, cross-platform quiz application built with Flutter and Firebase. Test your knowledge with randomized questions, get instant feedback with explanations, and manage your question database with an intuitive admin panel.

![Flutter](https://img.shields.io/badge/Flutter-v3.9.2-02569B?logo=flutter)
![Firebase](https://img.shields.io/badge/Firebase-Integrated-FFCA28?logo=firebase)
![Platform](https://img.shields.io/badge/Platform-Web%20%7C%20Android%20%7C%20iOS%20%7C%20Windows%20%7C%20macOS%20%7C%20Linux-brightgreen)

---

## 📋 Table of Contents

- [Features](#-features)
- [Screenshots & Demo](#-screenshots--demo)
- [Tech Stack](#-tech-stack)
- [Project Architecture](#-project-architecture)
- [Getting Started](#-getting-started)
- [Firebase Setup](#-firebase-setup)
- [Running the App](#-running-the-app)
- [Admin Panel Guide](#-admin-panel-guide)
- [Project Structure](#-project-structure)
- [Contributing](#-contributing)
- [License](#-license)

---

## ✨ Features

### 🎮 Quiz Experience
- **Customizable Quiz Length**: Select anywhere from 1 to 10 questions per quiz session
- **Randomized Questions**: Questions are shuffled for a fresh experience every time
- **Interactive UI**: Clean, modern interface with smooth animations and transitions
- **Instant Feedback**: Get immediate visual feedback (green for correct, red for incorrect)
- **Detailed Explanations**: Learn from your mistakes with explanations for correct answers
- **Auto-Progression**: Questions automatically advance after 3 seconds
- **Score Tracking**: Real-time score display and comprehensive results screen
- **Percentage Calculation**: View your performance as both score and percentage

### 🛠️ Admin Panel
- **Manual Question Entry**: Add individual questions with 4 options and explanations
- **Bulk Import from Excel**: Upload multiple questions at once using Excel files (.xlsx)
- **Question Management**: View, search, edit, and delete existing questions
- **Real-time Sync**: All changes are instantly synchronized with Firebase Firestore
- **Input Validation**: Form validation to ensure data integrity
- **Visual Feedback**: Success/error messages for all operations

### 📱 Cross-Platform Support
- **Web** ✅ (Fully configured and deployed to Firebase Hosting)
- **Android** ✅
- **iOS** ✅
- **Windows** ✅
- **macOS** ✅
- **Linux** ✅

### 🎨 UI/UX Features
- **Material 3 Design**: Modern, beautiful UI following Material Design 3 guidelines
- **Google Fonts**: Custom typography using Outfit font family
- **Responsive Layout**: Adapts to different screen sizes
- **Color-Coded Feedback**: Visual indicators for correct/incorrect answers
- **Loading States**: Smooth loading indicators during data fetch
- **Glassmorphism**: Modern design aesthetics with shadows and rounded corners

### 🔥 Firebase Integration
- **Cloud Firestore**: Real-time NoSQL database for storing questions
- **Fallback to Mock Data**: Works offline with built-in mock questions
- **Multi-platform Configuration**: Firebase configured for Web, Android, and iOS
- **Error Handling**: Graceful fallback when Firebase is unavailable

---

## 📸 Screenshots & Demo

> **Note**: The app features a clean purple theme with intuitive navigation and smooth animations.

### Key Screens:
1. **Start Screen**: Select number of questions and start quiz
2. **Quiz Screen**: Interactive question-answer interface with real-time feedback
3. **Results Screen**: Comprehensive score summary with percentage
4. **Admin Panel**: Three-tab interface for managing questions

---

## 🛠️ Tech Stack

### Frontend Framework
- **Flutter** `3.9.2+` - Cross-platform UI framework
- **Dart** `^3.9.2` - Programming language

### Backend & Database
- **Firebase Core** `^4.2.1` - Firebase SDK initialization
- **Cloud Firestore** `^6.1.0` - NoSQL cloud database

### UI & Design
- **Google Fonts** `^6.3.2` - Custom typography (Outfit font)
- **Material 3** - Modern design system

### File Handling
- **File Picker** `^10.3.7` - File selection for Excel import
- **Excel** `^4.0.6` - Excel file parsing for bulk import

### App Configuration
- **Flutter Launcher Icons** `^0.14.1` - Custom app icons
- **Flutter Native Splash** `^2.4.1` - Custom splash screens

---

## 🏗️ Project Architecture

### Design Pattern
The app follows a **Service-based Architecture** with clear separation of concerns:

```
lib/
├── models/          # Data models (Question, Option)
├── screens/         # UI screens (Start, Quiz, Results, Admin)
├── services/        # Business logic (QuizService)
└── utils/           # Utilities (Firestore importer)
```

### Data Flow
1. **User Interaction** → Screen (UI Layer)
2. **Screen** → Service (Business Logic Layer)
3. **Service** → Firebase/Mock Data (Data Layer)
4. **Data** → Service → Screen (Response Flow)

### Key Components

#### 📦 Models
- **`Option`**: Represents a quiz option with description, correctness flag, and optional explanation
- **`Question`**: Contains question text and a list of options

#### 🖼️ Screens
- **`StartScreen`**: Entry point with quiz customization (question count selection)
- **`QuizScreen`**: Main quiz interface with question display and answer handling
- **`ResultsScreen`**: Score summary and restart functionality
- **`AdminScreen`**: Three-tab admin panel for question management

#### ⚙️ Services
- **`QuizService`**: Handles all quiz-related operations
  - Fetch questions from Firestore or mock data
  - CRUD operations (Create, Read, Update, Delete)
  - Batch operations for bulk imports
  - Real-time streaming of questions

#### 🔧 Utils
- **`FirestoreDataImporter`**: Utility for importing mock data to Firestore
  - Check if database is empty
  - Import initial question set
  - Programmatic data seeding

---

## 🚀 Getting Started

### Prerequisites
- **Flutter SDK** `3.9.2` or higher
- **Dart SDK** `3.9.2` or higher
- **Firebase Account** (for cloud features)
- **Code Editor** (VS Code, Android Studio, or IntelliJ IDEA)

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/ManiSai26/Fact-Flash.git
   cd Fact-Flash
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Check Flutter setup**
   ```bash
   flutter doctor
   ```

4. **Generate app icons (optional)**
   ```bash
   flutter pub run flutter_launcher_icons
   ```

5. **Generate splash screens (optional)**
   ```bash
   flutter pub run flutter_native_splash:create
   ```

---

## 🔥 Firebase Setup

For detailed Firebase configuration instructions, see **[FIREBASE_SETUP.md](FIREBASE_SETUP.md)**.

### Quick Setup Summary:

1. **Create Firebase Project**
   - Go to [Firebase Console](https://console.firebase.google.com/)
   - Create a new project

2. **Enable Firestore**
   - Navigate to Firestore Database
   - Create database in test mode (for development)

3. **Configure Platforms**
   - **Web**: Already configured in `lib/firebase_options.dart`
   - **Android**: Add `google-services.json` to `android/app/`
   - **iOS**: Add `GoogleService-Info.plist` to `ios/Runner/`

4. **Import Initial Data** (Optional)
   ```dart
   // In lib/main.dart, after Firebase.initializeApp()
   import 'utils/firestore_importer.dart';
   await importMockDataToFirestore();
   ```

### Working Without Firebase
The app includes built-in mock data and will work perfectly without Firebase configuration. You'll see this message in the console:
```
Firebase initialization failed: ...
Running with Mock Data only.
```

---

## 💻 Running the App

### Web (Chrome)
```bash
flutter run -d chrome
```

### Android
```bash
flutter run -d android
```

### iOS (requires macOS)
```bash
flutter run -d ios
```

### Windows
```bash
flutter run -d windows
```

### macOS
```bash
flutter run -d macos
```

### Linux
```bash
flutter run -d linux
```

### Build for Production

**Web (deployed to Firebase Hosting)**
```bash
flutter build web
firebase deploy
```

**Android APK**
```bash
flutter build apk --release
```

**iOS (requires macOS)**
```bash
flutter build ios --release
```

---

## 👨‍💼 Admin Panel Guide

### Accessing Admin Panel
From the start screen, click the **"Admin Panel"** button below the "Start Flash Quiz" button.

### Tab 1: Manual Entry
1. Enter the question text
2. Fill in all 4 options
3. Select the correct answer using radio buttons
4. (Optional) Add an explanation for the correct answer
5. Click **"Save Question"**

### Tab 2: Bulk Import (Excel)
1. Prepare an Excel file (.xlsx) with this format:

   | Column 1 | Column 2 | Column 3 | Column 4 | Column 5 | Column 6 | Column 7 |
   |----------|----------|----------|----------|----------|----------|----------|
   | Question Text | Option 1 | Option 2 | Option 3 | Option 4 | Correct (1-4) | Explanation |

   **Example:**
   | Question | Opt1 | Opt2 | Opt3 | Opt4 | Correct | Explanation |
   |----------|------|------|------|------|---------|-------------|
   | What is 2+2? | 3 | 4 | 5 | 6 | 2 | Basic addition |

2. Click **"Pick Excel File"**
3. Select your .xlsx file
4. Questions will be automatically imported

### Tab 3: Manage Questions
- **Search**: Use the search bar to filter questions
- **Edit**: Click the blue edit icon to modify a question
- **Delete**: Click the red delete icon (with confirmation)
- **Real-time Updates**: All changes sync instantly

---

## 📁 Project Structure

```
fact_flash/
├── android/                 # Android-specific files
├── ios/                     # iOS-specific files
├── web/                     # Web-specific files
├── windows/                 # Windows-specific files
├── macos/                   # macOS-specific files
├── linux/                   # Linux-specific files
├── lib/                     # Main application code
│   ├── models/              # Data models
│   │   ├── option.dart      # Option model
│   │   └── question.dart    # Question model
│   ├── screens/             # UI screens
│   │   ├── start_screen.dart    # Home/start screen
│   │   ├── quiz_screen.dart     # Quiz gameplay screen
│   │   ├── results_screen.dart  # Results summary screen
│   │   └── admin_screen.dart    # Admin panel
│   ├── services/            # Business logic
│   │   └── quiz_service.dart    # Quiz operations service
│   ├── utils/               # Utilities
│   │   └── firestore_importer.dart  # Data import utility
│   ├── firebase_options.dart    # Firebase configuration
│   └── main.dart            # App entry point
├── assets/                  # Images, icons, etc.
│   └── icon.png             # App icon
├── test/                    # Unit and widget tests
├── .github/                 # GitHub workflows
├── pubspec.yaml             # Dependencies and metadata
├── README.md                # This file
├── FIREBASE_SETUP.md        # Firebase setup guide
└── firebase.json            # Firebase hosting config
```

---

## 🤝 Contributing

Contributions are welcome! Please follow these steps:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## 👨‍💻 Author

**Mani Sai**
- GitHub: [@ManiSai26](https://github.com/ManiSai26)

---

## 🙏 Acknowledgments

- Flutter team for the amazing framework
- Firebase for backend infrastructure
- Google Fonts for beautiful typography
- Material Design team for design guidelines

---

## 📞 Support

If you encounter any issues or have questions:
1. Check the [FIREBASE_SETUP.md](FIREBASE_SETUP.md) guide
2. Review the debug console for error messages
3. Open an issue on GitHub with details

---

**Built with ❤️ using Flutter and Firebase**
