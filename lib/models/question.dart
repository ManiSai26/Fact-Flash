import 'option.dart';

class Question {
  final String? id;
  final String questionText;
  final List<Option> options;

  Question({this.id, required this.questionText, required this.options});

  factory Question.fromMap(Map<String, dynamic> map, {String? id}) {
    return Question(
      id: id,
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
