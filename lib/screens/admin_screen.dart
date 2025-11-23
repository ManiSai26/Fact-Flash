import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/question.dart';
import '../models/option.dart';
import '../services/quiz_service.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _formKey = GlobalKey<FormState>();
  final QuizService _quizService = QuizService(
    firestore: Firebase.apps.isNotEmpty ? FirebaseFirestore.instance : null,
  );

  // Manual Entry Controllers
  final TextEditingController _questionController = TextEditingController();
  final List<TextEditingController> _optionControllers = List.generate(
    4,
    (_) => TextEditingController(),
  );
  final List<TextEditingController> _explanationControllers = List.generate(
    4,
    (_) => TextEditingController(),
  );
  int _correctOptionIndex = 0;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _questionController.dispose();
    for (var c in _optionControllers) {
      c.dispose();
    }
    for (var c in _explanationControllers) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _saveManualQuestion() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final options = List.generate(4, (index) {
        return Option(
          description: _optionControllers[index].text.trim(),
          isCorrect: index == _correctOptionIndex,
          explanation: _explanationControllers[index].text.trim().isNotEmpty
              ? _explanationControllers[index].text.trim()
              : null,
        );
      });

      final question = Question(
        questionText: _questionController.text.trim(),
        options: options,
      );

      await _quizService.addQuestion(question);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Question added successfully!')),
        );
        _clearForm();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error adding question: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _clearForm() {
    _questionController.clear();
    for (var c in _optionControllers) {
      c.clear();
    }
    for (var c in _explanationControllers) {
      c.clear();
    }
    setState(() => _correctOptionIndex = 0);
  }

  Future<void> _pickAndUploadExcel() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['xlsx'],
      );

      if (result != null) {
        setState(() => _isLoading = true);

        // On Windows, result.files.single.path is available
        final fileBytes = result.files.single.bytes;
        final filePath = result.files.single.path;

        var bytes = fileBytes;
        if (bytes == null && filePath != null) {
          bytes = File(filePath).readAsBytesSync();
        }

        if (bytes == null) {
          throw Exception("Could not read file data");
        }

        var excel = Excel.decodeBytes(bytes);
        List<Question> questions = [];

        for (var table in excel.tables.keys) {
          // Assuming first row is header, start from index 1
          // Format: Question | Opt1 | Opt2 | Opt3 | Opt4 | CorrectIndex (1-4) | Explanation
          for (var row in excel.tables[table]!.rows.skip(1)) {
            if (row.length < 6) continue;

            final qText = row[0]?.value.toString() ?? '';
            if (qText.isEmpty) continue;

            final opts = [
              row[1]?.value.toString() ?? '',
              row[2]?.value.toString() ?? '',
              row[3]?.value.toString() ?? '',
              row[4]?.value.toString() ?? '',
            ];

            final correctIdxVal = row[5]?.value;
            int correctIdx = 0;
            if (correctIdxVal != null) {
              correctIdx = int.tryParse(correctIdxVal.toString()) ?? 1;
              correctIdx -= 1; // Convert 1-based to 0-based
            }
            if (correctIdx < 0 || correctIdx > 3) correctIdx = 0;

            final explanation = row.length > 6
                ? row[6]?.value.toString()
                : null;

            List<Option> optionsList = [];
            for (int i = 0; i < 4; i++) {
              optionsList.add(
                Option(
                  description: opts[i],
                  isCorrect: i == correctIdx,
                  explanation: (i == correctIdx) ? explanation : null,
                ),
              );
            }

            questions.add(Question(questionText: qText, options: optionsList));
          }
        }

        if (questions.isNotEmpty) {
          await _quizService.batchAddQuestions(questions);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Successfully imported ${questions.length} questions!',
                ),
              ),
            );
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('No valid questions found in Excel.'),
              ),
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error importing Excel: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Panel'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Manual Entry'),
            Tab(text: 'Bulk Import (Excel)'),
            Tab(text: 'Manage Questions'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildManualEntryTab(),
                _buildBulkImportTab(),
                _buildManageQuestionsTab(),
              ],
            ),
    );
  }

  Widget _buildManualEntryTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              controller: _questionController,
              decoration: const InputDecoration(
                labelText: 'Question Text',
                border: OutlineInputBorder(),
              ),
              validator: (value) =>
                  value == null || value.isEmpty ? 'Required' : null,
              maxLines: 2,
            ),
            const SizedBox(height: 20),
            const Text(
              "Options",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            ...List.generate(4, (index) {
              return Card(
                margin: const EdgeInsets.only(bottom: 10),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Radio<int>(
                            value: index,
                            groupValue: _correctOptionIndex,
                            onChanged: (val) =>
                                setState(() => _correctOptionIndex = val!),
                          ),
                          Expanded(
                            child: TextFormField(
                              controller: _optionControllers[index],
                              decoration: InputDecoration(
                                labelText: 'Option ${index + 1}',
                                border: const OutlineInputBorder(),
                              ),
                              validator: (value) =>
                                  value == null || value.isEmpty
                                  ? 'Required'
                                  : null,
                            ),
                          ),
                        ],
                      ),
                      if (index == _correctOptionIndex)
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0, left: 48),
                          child: TextFormField(
                            controller: _explanationControllers[index],
                            decoration: const InputDecoration(
                              labelText: 'Explanation (Optional)',
                              border: OutlineInputBorder(),
                              isDense: true,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            }),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saveManualQuestion,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.white,
              ),
              child: const Text('Save Question'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBulkImportTab() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.table_view, size: 80, color: Colors.green),
            const SizedBox(height: 20),
            Text(
              'Bulk Import from Excel',
              style: GoogleFonts.outfit(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Excel Format:\nCol 1: Question Text\nCol 2-5: Options 1-4\nCol 6: Correct Option Number (1-4)\nCol 7: Explanation (Optional)',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, height: 1.5),
            ),
            const SizedBox(height: 40),
            ElevatedButton.icon(
              onPressed: _pickAndUploadExcel,
              icon: const Icon(Icons.upload_file),
              label: const Text('Pick Excel File'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 30,
                  vertical: 15,
                ),
                textStyle: const TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Manage Questions Tab Logic
  String _searchQuery = '';

  Widget _buildManageQuestionsTab() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: TextField(
            decoration: const InputDecoration(
              labelText: 'Search Questions',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(),
            ),
            onChanged: (value) {
              setState(() {
                _searchQuery = value.toLowerCase();
              });
            },
          ),
        ),
        Expanded(
          child: StreamBuilder<List<Question>>(
            stream: _quizService.getQuestions(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              final questions = snapshot.data ?? [];
              final filteredQuestions = questions.where((q) {
                return q.questionText.toLowerCase().contains(_searchQuery);
              }).toList();

              if (filteredQuestions.isEmpty) {
                return const Center(child: Text('No questions found.'));
              }

              return ListView.builder(
                itemCount: filteredQuestions.length,
                itemBuilder: (context, index) {
                  final question = filteredQuestions[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: ListTile(
                      title: Text(
                        question.questionText,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: Text('${question.options.length} options'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.blue),
                            onPressed: () => _showEditDialog(question),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _deleteQuestion(question),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Future<void> _deleteQuestion(Question question) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Question'),
        content: const Text('Are you sure you want to delete this question?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true && question.id != null) {
      await _quizService.deleteQuestion(question.id!);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Question deleted.')));
      }
    }
  }

  void _showEditDialog(Question question) {
    // Pre-fill controllers
    final qController = TextEditingController(text: question.questionText);
    final optControllers = List.generate(
      4,
      (i) => TextEditingController(
        text: i < question.options.length
            ? question.options[i].description
            : '',
      ),
    );
    final expControllers = List.generate(
      4,
      (i) => TextEditingController(
        text: i < question.options.length
            ? (question.options[i].explanation ?? '')
            : '',
      ),
    );
    int correctIdx = 0;
    for (int i = 0; i < question.options.length; i++) {
      if (question.options[i].isCorrect) {
        correctIdx = i;
        break;
      }
    }

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) {
          return AlertDialog(
            title: const Text('Edit Question'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: qController,
                    decoration: const InputDecoration(
                      labelText: 'Question Text',
                    ),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 10),
                  ...List.generate(4, (index) {
                    return Column(
                      children: [
                        Row(
                          children: [
                            Radio<int>(
                              value: index,
                              groupValue: correctIdx,
                              onChanged: (val) {
                                setStateDialog(() => correctIdx = val!);
                              },
                            ),
                            Expanded(
                              child: TextField(
                                controller: optControllers[index],
                                decoration: InputDecoration(
                                  labelText: 'Option ${index + 1}',
                                ),
                              ),
                            ),
                          ],
                        ),
                        if (index == correctIdx)
                          Padding(
                            padding: const EdgeInsets.only(left: 48),
                            child: TextField(
                              controller: expControllers[index],
                              decoration: const InputDecoration(
                                labelText: 'Explanation',
                              ),
                            ),
                          ),
                      ],
                    );
                  }),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () async {
                  final options = List.generate(4, (index) {
                    return Option(
                      description: optControllers[index].text.trim(),
                      isCorrect: index == correctIdx,
                      explanation: expControllers[index].text.trim().isNotEmpty
                          ? expControllers[index].text.trim()
                          : null,
                    );
                  });

                  final updatedQuestion = Question(
                    id: question.id,
                    questionText: qController.text.trim(),
                    options: options,
                  );

                  if (question.id != null) {
                    await _quizService.updateQuestion(
                      question.id!,
                      updatedQuestion,
                    );
                    if (context.mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Question updated.')),
                      );
                    }
                  }
                },
                child: const Text('Update'),
              ),
            ],
          );
        },
      ),
    );
  }
}
