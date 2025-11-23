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
