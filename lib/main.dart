import 'dart:async';


import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Initialize Firebase.
  // Note: For a real app, you must configure your platform-specific options.
  // If no config is present, we try to initialize with default options if possible,
  // or catch the error to allow the mock service to run.
  try {
    await Firebase.initializeApp();
  } catch (e) {
    debugPrint('Firebase initialization failed or not configured: $e');
    debugPrint('Running with Mock Data only.');
  }
  runApp(const FactFlashApp());
}

class FactFlashApp extends StatelessWidget {
  const FactFlashApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fact Flash',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6200EA), // Deep Purple
          brightness: Brightness.light,
        ),
        textTheme: GoogleFonts.outfitTextTheme(),
      ),
      home: const StartScreen(),
    );
  }
}

// --- Data Models ---

class Option {
  final String description;
  final bool isCorrect;
  final String? explanation;

  Option({
    required this.description,
    required this.isCorrect,
    this.explanation,
  });

  factory Option.fromMap(Map<String, dynamic> map) {
    return Option(
      description: map['description'] ?? '',
      isCorrect: map['isCorrect'] ?? false,
      explanation: map['explanation'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'description': description,
      'isCorrect': isCorrect,
      'explanation': explanation,
    };
  }
}

class Question {
  final String questionText;
  final List<Option> options;

  Question({
    required this.questionText,
    required this.options,
  });

  factory Question.fromMap(Map<String, dynamic> map) {
    return Question(
      questionText: map['questionText'] ?? '',
      options: (map['options'] as List<dynamic>?)
              ?.map((x) => Option.fromMap(x))
              .toList() ??
          [],
    );
  }
}

// --- Quiz Service ---

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
        Option(description: "Paris", isCorrect: true, explanation: "Paris is the capital and most populous city of France."),
        Option(description: "Madrid", isCorrect: false),
      ],
    ),
    Question(
      questionText: "Which planet is known as the Red Planet?",
      options: [
        Option(description: "Mars", isCorrect: true, explanation: "Mars appears red due to iron oxide on its surface."),
        Option(description: "Venus", isCorrect: false),
        Option(description: "Jupiter", isCorrect: false),
        Option(description: "Saturn", isCorrect: false),
      ],
    ),
    Question(
      questionText: "What is the largest mammal in the world?",
      options: [
        Option(description: "African Elephant", isCorrect: false),
        Option(description: "Blue Whale", isCorrect: true, explanation: "The Blue Whale can grow up to 100 feet long."),
        Option(description: "Giraffe", isCorrect: false),
        Option(description: "Hippopotamus", isCorrect: false),
      ],
    ),
    Question(
      questionText: "Who wrote 'Romeo and Juliet'?",
      options: [
        Option(description: "Charles Dickens", isCorrect: false),
        Option(description: "William Shakespeare", isCorrect: true, explanation: "Shakespeare wrote this tragedy early in his career."),
        Option(description: "Mark Twain", isCorrect: false),
        Option(description: "Jane Austen", isCorrect: false),
      ],
    ),
    Question(
      questionText: "What is the chemical symbol for Gold?",
      options: [
        Option(description: "Au", isCorrect: true, explanation: "Au comes from the Latin word for gold, 'Aurum'."),
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
        Option(description: "7", isCorrect: true, explanation: "Asia, Africa, North America, South America, Antarctica, Europe, and Australia."),
        Option(description: "8", isCorrect: false),
      ],
    ),
  ];

  Future<List<Question>> fetchQuiz(int count) async {
    List<Question> questions = [];

    // Try fetching from Firestore first
    try {
      if (_firestore != null) {
        final snapshot = await _firestore.collection('questions').limit(count).get();
        if (snapshot.docs.isNotEmpty) {
          questions = snapshot.docs.map((doc) => Question.fromMap(doc.data())).toList();
        }
      }
    } catch (e) {
      debugPrint("Error fetching from Firestore: $e. Using mock data.");
    }

    // Fallback to mock data if Firestore fails or returns empty
    if (questions.isEmpty) {
      questions = List.from(_mockQuestions);
      questions.shuffle(); // Randomize mock data
    }

    // Ensure we return exactly 'count' or fewer if not enough exist
    return questions.take(count).toList();
  }
}

// --- Screens ---

// 1. Start Screen
class StartScreen extends StatefulWidget {
  const StartScreen({super.key});

  @override
  State<StartScreen> createState() => _StartScreenState();
}

class _StartScreenState extends State<StartScreen> {
  double _questionCount = 5;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3E5F5), // Light purple background
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.flash_on_rounded, size: 80, color: Theme.of(context).primaryColor),
              const SizedBox(height: 20),
              Text(
                'Fact Flash',
                style: GoogleFonts.outfit(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF4A148C),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Test your knowledge!',
                style: GoogleFonts.outfit(fontSize: 20, color: Colors.grey[700]),
              ),
              const SizedBox(height: 60),
              Text(
                'Number of Questions: ${_questionCount.round()}',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              Slider(
                value: _questionCount,
                min: 1,
                max: 10,
                divisions: 9,
                label: _questionCount.round().toString(),
                onChanged: (double value) {
                  setState(() {
                    _questionCount = value;
                  });
                },
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => QuizScreen(totalQuestions: _questionCount.round()),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                  textStyle: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  elevation: 5,
                ),
                child: const Text('Start Flash Quiz'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// 2. Quiz Screen
class QuizScreen extends StatefulWidget {
  final int totalQuestions;

  const QuizScreen({super.key, required this.totalQuestions});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {

  List<Question> _questions = [];
  int _currentIndex = 0;
  int _score = 0;
  bool _isLoading = true;
  
  // State for answer handling
  bool _isAnswered = false;
  int? _selectedOptionIndex;
  bool? _isCorrect;

  @override
  void initState() {
    super.initState();
    _loadQuiz();
  }

  Future<void> _loadQuiz() async {
    // Try to get Firestore instance if initialized, else null
    FirebaseFirestore? firestore;
    try {
      if (Firebase.apps.isNotEmpty) {
        firestore = FirebaseFirestore.instance;
      }
    } catch (_) {}

    final service = QuizService(firestore: firestore);
    final questions = await service.fetchQuiz(widget.totalQuestions);
    
    if (mounted) {
      setState(() {
        _questions = questions;
        _isLoading = false;
      });
    }
  }

  void _handleAnswer(int optionIndex) {
    if (_isAnswered) return;

    final currentQuestion = _questions[_currentIndex];
    final isCorrect = currentQuestion.options[optionIndex].isCorrect;

    setState(() {
      _isAnswered = true;
      _selectedOptionIndex = optionIndex;
      _isCorrect = isCorrect;
      if (isCorrect) _score++;
    });

    // Auto advance after delay
    Timer(const Duration(seconds: 3), () {
      if (mounted) {
        if (_currentIndex < _questions.length - 1) {
          setState(() {
            _currentIndex++;
            _isAnswered = false;
            _selectedOptionIndex = null;
            _isCorrect = null;
          });
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => ResultsScreen(
                score: _score,
                totalQuestions: _questions.length,
              ),
            ),
          );
        }
      }
    });
  }

  Color _getButtonColor(int index) {
    if (!_isAnswered) return Colors.white;

    final currentQuestion = _questions[_currentIndex];
    final isOptionCorrect = currentQuestion.options[index].isCorrect;

    if (isOptionCorrect) {
      return Colors.green.shade100; // Highlight correct answer
    }
    
    if (_selectedOptionIndex == index && !isOptionCorrect) {
      return Colors.red.shade100; // Highlight wrong selection
    }

    return Colors.grey.shade200; // Dim others
  }

  Color _getBorderColor(int index) {
    if (!_isAnswered) return Colors.transparent;
    
    final currentQuestion = _questions[_currentIndex];
    final isOptionCorrect = currentQuestion.options[index].isCorrect;

    if (isOptionCorrect) return Colors.green;
    if (_selectedOptionIndex == index && !isOptionCorrect) return Colors.red;
    
    return Colors.transparent;
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_questions.isEmpty) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text("No questions found.")),
      );
    }

    final question = _questions[_currentIndex];

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text('Question ${_currentIndex + 1}/${_questions.length}'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Question Card
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Text(
                    question.questionText,
                    style: GoogleFonts.outfit(
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF212121),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 30),
                // Options Grid
                Expanded(
                  child: ListView.separated(
                    itemCount: question.options.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 16),
                    itemBuilder: (context, index) {
                      final option = question.options[index];
                      return GestureDetector(
                        onTap: () => _handleAnswer(index),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                          decoration: BoxDecoration(
                            color: _getButtonColor(index),
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(
                              color: _getBorderColor(index),
                              width: 2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.05),
                                blurRadius: 5,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 15,
                                backgroundColor: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                                child: Text(
                                  String.fromCharCode(65 + index), // A, B, C, D
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(context).primaryColor,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Text(
                                  option.description,
                                  style: const TextStyle(fontSize: 18),
                                ),
                              ),
                              if (_isAnswered && option.isCorrect)
                                const Icon(Icons.check_circle, color: Colors.green),
                              if (_isAnswered && _selectedOptionIndex == index && !option.isCorrect)
                                const Icon(Icons.cancel, color: Colors.red),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          
          // Feedback Overlay
          if (_isAnswered)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: _isCorrect! ? Colors.green.shade50 : Colors.red.shade50,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 20,
                      offset: const Offset(0, -5),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          _isCorrect! ? Icons.check_circle : Icons.error,
                          color: _isCorrect! ? Colors.green : Colors.red,
                          size: 30,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          _isCorrect! ? "Correct!" : "Incorrect",
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: _isCorrect! ? Colors.green.shade800 : Colors.red.shade800,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    if (!_isCorrect!) ...[
                      const Text(
                        "Correct Answer:",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        question.options.firstWhere((o) => o.isCorrect).description,
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 10),
                    ],
                    if (question.options.firstWhere((o) => o.isCorrect).explanation != null) ...[
                       const Text(
                        "Explanation:",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        question.options.firstWhere((o) => o.isCorrect).explanation!,
                        style: const TextStyle(fontSize: 14, fontStyle: FontStyle.italic),
                      ),
                    ],
                    const SizedBox(height: 10),
                    LinearProgressIndicator(
                      backgroundColor: Colors.grey[300],
                      valueColor: AlwaysStoppedAnimation<Color>(
                        _isCorrect! ? Colors.green : Colors.red,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// 3. Results Screen
class ResultsScreen extends StatelessWidget {
  final int score;
  final int totalQuestions;

  const ResultsScreen({
    super.key,
    required this.score,
    required this.totalQuestions,
  });

  @override
  Widget build(BuildContext context) {
    final percentage = (score / totalQuestions) * 100;
    
    return Scaffold(
      backgroundColor: const Color(0xFFF3E5F5),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Quiz Complete!',
                style: GoogleFonts.outfit(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF4A148C),
                ),
              ),
              const SizedBox(height: 40),
              Container(
                padding: const EdgeInsets.all(40),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Text(
                      '$score / $totalQuestions',
                      style: GoogleFonts.outfit(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                    Text(
                      'Score',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Text(
                '${percentage.toStringAsFixed(0)}%',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: percentage >= 70 ? Colors.green : Colors.orange,
                ),
              ),
              const SizedBox(height: 60),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => const StartScreen()),
                    (route) => false,
                  );
                },
                icon: const Icon(Icons.refresh),
                label: const Text('Restart Quiz'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
