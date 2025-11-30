import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/question.dart';
import '../models/option.dart';

class QuizService {
  final FirebaseFirestore? _firestore;

  QuizService({FirebaseFirestore? firestore}) : _firestore = firestore;

  // Mock Data
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

  Future<List<Question>> fetchQuiz(
    int count, {
    List<String>? categories,
  }) async {
    List<Question> questions = [];

    // Try fetching from Firestore first
    try {
      if (_firestore != null) {
        // final snapshot = await _firestore
        //     .collection('questions')
        //     .limit(count)
        //     .get();
        // if (snapshot.docs.isNotEmpty) {
        //   questions = snapshot.docs
        //       .map((doc) => Question.fromMap(doc.data(), id: doc.id))
        //       .toList();
        // }
        final QuerySnapshot allQuestionsSnapshot = await _firestore
            .collection('questions')
            .get();
        if (allQuestionsSnapshot.docs.isNotEmpty) {
          List<Question> allQuestions = allQuestionsSnapshot.docs
              .map(
                (doc) => Question.fromMap(
                  doc.data() as Map<String, dynamic>,
                  doc.id,
                ),
              )
              .toList();

          // Filter by categories if provided
          if (categories != null && categories.isNotEmpty) {
            allQuestions = allQuestions
                .where((q) => categories.contains(q.category))
                .toList();
          }

          allQuestions.shuffle();
          questions = allQuestions.take(count).toList();
        }
      }
    } catch (e) {
      debugPrint("Error fetching from Firestore: $e. Using mock data.");
    }

    // Fallback to mock data if Firestore fails or returns empty
    if (questions.isEmpty) {
      questions = List.from(_mockQuestions);

      // Filter by categories if provided
      if (categories != null && categories.isNotEmpty) {
        questions = questions
            .where((q) => categories.contains(q.category))
            .toList();
      }

      questions.shuffle(); // Randomize mock data
    }

    // Ensure we return exactly 'count' or fewer if not enough exist
    return questions.take(count).toList();
  }

  // Get all unique categories from Firestore
  Future<List<String>> getCategories() async {
    if (_firestore == null) {
      return ['General']; // Default category
    }

    try {
      final QuerySnapshot snapshot = await _firestore
          .collection('questions')
          .get();

      final Set<String> categories = {};
      for (var doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final category = data['category'] as String? ?? 'General';
        categories.add(category);
      }

      return categories.toList()..sort();
    } catch (e) {
      debugPrint("Error fetching categories: $e");
      return ['General'];
    }
  }

  Future<void> addQuestion(Question question) async {
    if (_firestore == null) {
      debugPrint("Firestore not initialized. Cannot add question.");
      return;
    }
    try {
      await _firestore.collection('questions').add(question.toMap());
    } catch (e) {
      debugPrint("Error adding question: $e");
      rethrow;
    }
  }

  Future<void> batchAddQuestions(List<Question> questions) async {
    if (_firestore == null) {
      debugPrint("Firestore not initialized. Cannot batch add.");
      return;
    }
    final batch = _firestore.batch();
    for (var q in questions) {
      final docRef = _firestore.collection('questions').doc();
      batch.set(docRef, q.toMap());
    }
    try {
      await batch.commit();
    } catch (e) {
      debugPrint("Error batch adding questions: $e");
      rethrow;
    }
  }

  Stream<List<Question>> getQuestions() {
    if (_firestore == null) {
      return Stream.value([]);
    }
    return _firestore.collection('questions').snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => Question.fromMap(doc.data(), doc.id))
          .toList();
    });
  }

  Future<void> updateQuestion(String id, Question question) async {
    if (_firestore == null) return;
    try {
      await _firestore.collection('questions').doc(id).update(question.toMap());
    } catch (e) {
      debugPrint("Error updating question: $e");
      rethrow;
    }
  }

  Future<void> deleteQuestion(String id) async {
    if (_firestore == null) return;
    try {
      await _firestore.collection('questions').doc(id).delete();
    } catch (e) {
      debugPrint("Error deleting question: $e");
      rethrow;
    }
  }
}
