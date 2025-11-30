import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/question.dart';
import '../services/quiz_service.dart';
import 'results_screen.dart';

class QuizScreen extends StatefulWidget {
  final int totalQuestions;
  final List<String>? categories;

  const QuizScreen({super.key, required this.totalQuestions, this.categories});

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
    final questions = await service.fetchQuiz(
      widget.totalQuestions,
      categories: widget.categories,
    );

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
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
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
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 16),
                    itemBuilder: (context, index) {
                      final option = question.options[index];
                      return GestureDetector(
                        onTap: () => _handleAnswer(index),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          padding: const EdgeInsets.symmetric(
                            vertical: 20,
                            horizontal: 16,
                          ),
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
                                backgroundColor: Theme.of(
                                  context,
                                ).primaryColor.withValues(alpha: 0.1),
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
                                const Icon(
                                  Icons.check_circle,
                                  color: Colors.green,
                                ),
                              if (_isAnswered &&
                                  _selectedOptionIndex == index &&
                                  !option.isCorrect)
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
                  color: _isCorrect!
                      ? Colors.green.shade50
                      : Colors.red.shade50,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(30),
                  ),
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
                            color: _isCorrect!
                                ? Colors.green.shade800
                                : Colors.red.shade800,
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
                        question.options
                            .firstWhere((o) => o.isCorrect)
                            .description,
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 10),
                    ],
                    if (question.options
                            .firstWhere((o) => o.isCorrect)
                            .explanation !=
                        null) ...[
                      const Text(
                        "Explanation:",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        question.options
                            .firstWhere((o) => o.isCorrect)
                            .explanation!,
                        style: const TextStyle(
                          fontSize: 14,
                          fontStyle: FontStyle.italic,
                        ),
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
