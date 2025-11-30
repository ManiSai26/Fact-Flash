import 'option.dart';

class Question {
  final String? id;
  final String questionText;
  final List<Option> options;
  final String category; // Category field

  Question({
    this.id,
    required this.questionText,
    required this.options,
    this.category = 'General', // Default category
  });

  factory Question.fromMap(Map<String, dynamic> data, String id) {
    return Question(
      id: id,
      questionText: data['questionText'] ?? '',
      category:
          data['category'] ?? 'General', // Default to 'General' if not present
      options:
          (data['options'] as List<dynamic>?)
              ?.map((opt) => Option.fromMap(opt as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'questionText': questionText,
      'category': category,
      'options': options.map((opt) => opt.toMap()).toList(),
    };
  }
}
