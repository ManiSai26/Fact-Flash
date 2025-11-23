import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/question.dart';
import '../models/option.dart';

/// Helper script to import mock questions into Firestore.
///
/// Usage: Call `importMockDataToFirestore()` from anywhere in your app
/// (e.g., from a button in admin screen or temporarily from main.dart)
class FirestoreDataImporter {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Mock questions to import
  final List<Question> _mockQuestions = [
    Question(
      questionText: "What is the capital of France?",
      options: [
        Option(description: "London", isCorrect: false),
        Option(description: "Berlin", isCorrect: false),
        Option(
          description: "Paris",
          isCorrect: true,
          explanation: "Paris is the capital and most populous city of France.",
        ),
        Option(description: "Madrid", isCorrect: false),
      ],
    ),
    Question(
      questionText: "Which planet is known as the Red Planet?",
      options: [
        Option(
          description: "Mars",
          isCorrect: true,
          explanation: "Mars appears red due to iron oxide on its surface.",
        ),
        Option(description: "Venus", isCorrect: false),
        Option(description: "Jupiter", isCorrect: false),
        Option(description: "Saturn", isCorrect: false),
      ],
    ),
    Question(
      questionText: "What is the largest mammal in the world?",
      options: [
        Option(description: "African Elephant", isCorrect: false),
        Option(
          description: "Blue Whale",
          isCorrect: true,
          explanation: "The Blue Whale can grow up to 100 feet long.",
        ),
        Option(description: "Giraffe", isCorrect: false),
        Option(description: "Hippopotamus", isCorrect: false),
      ],
    ),
    Question(
      questionText: "Who wrote 'Romeo and Juliet'?",
      options: [
        Option(description: "Charles Dickens", isCorrect: false),
        Option(
          description: "William Shakespeare",
          isCorrect: true,
          explanation: "Shakespeare wrote this tragedy early in his career.",
        ),
        Option(description: "Mark Twain", isCorrect: false),
        Option(description: "Jane Austen", isCorrect: false),
      ],
    ),
    Question(
      questionText: "What is the chemical symbol for Gold?",
      options: [
        Option(
          description: "Au",
          isCorrect: true,
          explanation: "Au comes from the Latin word for gold, 'Aurum'.",
        ),
        Option(description: "Ag", isCorrect: false),
        Option(description: "Fe", isCorrect: false),
        Option(description: "Pb", isCorrect: false),
      ],
    ),
    Question(
      questionText: "How many continents are there?",
      options: [
        Option(description: "5", isCorrect: false),
        Option(description: "6", isCorrect: false),
        Option(
          description: "7",
          isCorrect: true,
          explanation:
              "Asia, Africa, North America, South America, Antarctica, Europe, and Australia.",
        ),
        Option(description: "8", isCorrect: false),
      ],
    ),
  ];

  /// Import all mock questions to Firestore
  Future<void> importMockDataToFirestore() async {
    try {
      debugPrint('Starting import of ${_mockQuestions.length} questions...');

      final batch = _firestore.batch();

      for (var question in _mockQuestions) {
        final docRef = _firestore.collection('questions').doc();
        batch.set(docRef, question.toMap());
      }

      await batch.commit();

      debugPrint(
        '✅ Successfully imported ${_mockQuestions.length} questions to Firestore!',
      );
    } catch (e) {
      debugPrint('❌ Error importing questions: $e');
      rethrow;
    }
  }

  /// Check if questions collection is empty
  Future<bool> isQuestionsCollectionEmpty() async {
    try {
      final snapshot = await _firestore.collection('questions').limit(1).get();
      return snapshot.docs.isEmpty;
    } catch (e) {
      debugPrint('Error checking if collection is empty: $e');
      return false;
    }
  }

  /// Import only if collection is empty
  Future<void> importIfEmpty() async {
    final isEmpty = await isQuestionsCollectionEmpty();
    if (isEmpty) {
      debugPrint('Questions collection is empty. Importing mock data...');
      await importMockDataToFirestore();
    } else {
      debugPrint('Questions collection already has data. Skipping import.');
    }
  }
}

/// Convenience function to import data
///
/// Example usage in main.dart (temporary):
/// ```dart
/// void main() async {
///   WidgetsFlutterBinding.ensureInitialized();
///   await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
///
///   // Import mock data to Firestore if empty
///   await importMockDataToFirestore();
///
///   runApp(const FactFlashApp());
/// }
/// ```
Future<void> importMockDataToFirestore() async {
  final importer = FirestoreDataImporter();
  await importer.importIfEmpty();
}
