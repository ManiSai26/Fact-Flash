import 'option.dart';

class Question {
  final String questionText;
  final List<Option> options;

  Question({required this.questionText, required this.options});

  factory Question.fromMap(Map<String, dynamic> map) {
    return Question(
      questionText: map['questionText'] ?? '',
      options:
          (map['options'] as List<dynamic>?)
              ?.map((x) => Option.fromMap(x))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'questionText': questionText,
      'options': options.map((x) => x.toMap()).toList(),
    };
  }
}
