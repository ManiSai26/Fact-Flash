import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'quiz_screen.dart';
import 'admin_screen.dart';
import 'profile_screen.dart';
import 'package:fact_flash/services/auth_service.dart';
import 'package:fact_flash/services/user_service.dart';
import 'package:fact_flash/services/quiz_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class StartScreen extends StatefulWidget {
  const StartScreen({super.key});

  @override
  State<StartScreen> createState() => _StartScreenState();
}

class _StartScreenState extends State<StartScreen> {
  double _questionCount = 5;
  String? _userRole;
  bool _isLoadingRole = true;
  List<String> _availableCategories = [];
  Set<String> _selectedCategories = {};
  bool _isLoadingCategories = true;
  late QuizService _quizService;

  @override
  void initState() {
    super.initState();
    _quizService = QuizService(
      firestore: Firebase.apps.isNotEmpty ? FirebaseFirestore.instance : null,
    );
    _loadUserRole();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    final categories = await _quizService.getCategories();
    setState(() {
      _availableCategories = categories;
      _isLoadingCategories = false;
    });
  }

  Future<void> _loadUserRole() async {
    final authService = AuthService();
    final userService = UserService();
    final user = authService.currentUser;

    if (user != null) {
      final userProfile = await userService.getUserProfile(user.uid);
      setState(() {
        _userRole = userProfile?.role ?? 'user';
        _isLoadingRole = false;
      });
    } else {
      setState(() {
        _isLoadingRole = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.person, color: Color(0xFF4A148C)),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProfileScreen()),
              );
            },
          ),
        ],
      ),
      backgroundColor: const Color(0xFFF3E5F5), // Light purple background
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset('assets/icon.png', width: 120, height: 120),
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
                  style: GoogleFonts.outfit(
                    fontSize: 20,
                    color: Colors.grey[700],
                  ),
                ),
                const SizedBox(height: 60),
                Text(
                  'Number of Questions: ${_questionCount.round()}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
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
                const SizedBox(height: 30),
                if (!_isLoadingCategories &&
                    _availableCategories.isNotEmpty) ...[
                  const Text(
                    'Select Categories:',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    alignment: WrapAlignment.center,
                    children: _availableCategories.map((category) {
                      final isSelected = _selectedCategories.contains(category);
                      return FilterChip(
                        label: Text(category),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() {
                            if (selected) {
                              _selectedCategories.add(category);
                            } else {
                              _selectedCategories.remove(category);
                            }
                          });
                        },
                        selectedColor: Theme.of(
                          context,
                        ).primaryColor.withOpacity(0.3),
                        checkmarkColor: Theme.of(context).primaryColor,
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 10),
                ],
                const SizedBox(height: 40),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => QuizScreen(
                          totalQuestions: _questionCount.round(),
                          categories: _selectedCategories.isEmpty
                              ? null
                              : _selectedCategories.toList(),
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 50,
                      vertical: 15,
                    ),
                    textStyle: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 5,
                  ),
                  child: Text(
                    _selectedCategories.isEmpty
                        ? 'Start Flash Quiz (All Categories)'
                        : 'Start Flash Quiz (${_selectedCategories.length} ${_selectedCategories.length == 1 ? 'Category' : 'Categories'})',
                  ),
                ),
                const SizedBox(height: 20),
                if (!_isLoadingRole && _userRole == 'admin')
                  TextButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AdminScreen(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.admin_panel_settings),
                    label: const Text('Admin Panel'),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.grey[700],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
