class Quiz {
  final String quizId;
  final String title;
  final String description;
  final int difficultyOrder;
  final int totalQuestions;
  final bool isActive;
  final String createdByAdminId;

  Quiz({
    required this.quizId,
    required this.title,
    required this.description,
    required this.difficultyOrder,
    required this.totalQuestions,
    required this.isActive,
    required this.createdByAdminId,
  });

  factory Quiz.fromFirestore(Map<String, dynamic> data, String id) {
    return Quiz(
      quizId: id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      difficultyOrder: data['difficultyOrder'] ?? 999,
      totalQuestions: data['totalQuestions'] ?? 0,
      isActive: data['isActive'] ?? true,
      createdByAdminId: data['createdByAdminId'] ?? '',
    );
  }
}

class QuizQuestion {
  final String questionId;
  final String quizId;
  final String questionText;
  final String questionType;
  final String imagePath;
  final String? explanation;
  final String? sourceTitle;
  final String? sourceUrl;
  final String? sourceNote;
  final int questionOrder;
  final List<QuizOption> options;

  QuizQuestion({
    required this.questionId,
    required this.quizId,
    required this.questionText,
    required this.questionType,
    required this.imagePath,
    this.explanation,
    this.sourceTitle,
    this.sourceUrl,
    this.sourceNote,
    required this.questionOrder,
    required this.options,
  });

  factory QuizQuestion.fromFirestore(
    Map<String, dynamic> data,
    String id, {
    List<QuizOption> options = const [],
  }) {
    return QuizQuestion(
      questionId: id,
      quizId: data['quizId'] ?? '',
      questionText: data['questionText'] ?? '',
      questionType: data['questionType'] ?? 'text',
      imagePath: data['imagePath'] ?? '',
      explanation: data['explanation'],
      sourceTitle: data['sourceTitle'],
      sourceUrl: data['sourceUrl'],
      sourceNote: data['sourceNote'],
      questionOrder: data['questionOrder'] ?? 999,
      options: options,
    );
  }
}

class QuizOption {
  final String optionId;
  final String questionId;
  final String optionText;
  final bool isCorrect;
  final int optionOrder;

  QuizOption({
    required this.optionId,
    required this.questionId,
    required this.optionText,
    required this.isCorrect,
    required this.optionOrder,
  });

  factory QuizOption.fromFirestore(Map<String, dynamic> data, String id) {
    return QuizOption(
      optionId: id,
      questionId: data['questionId'] ?? '',
      optionText: data['optionText'] ?? '',
      isCorrect: data['isCorrect'] ?? false,
      optionOrder: data['optionOrder'] ?? 999,
    );
  }
}