import 'package:cloud_firestore/cloud_firestore.dart';

class QuizHistory {
  final String attemptId;
  final String quizTitle;
  final int score;
  final int totalQuestions;
  final Timestamp? completedAt;

  QuizHistory({
    required this.attemptId,
    required this.quizTitle,
    required this.score,
    required this.totalQuestions,
    required this.completedAt,
  });

  factory QuizHistory.fromFirestore(Map<String, dynamic> data, String id) {
    return QuizHistory(
      attemptId: id,
      quizTitle: data['quizTitle'] ?? 'Quiz Challenge',
      score: data['score'] ?? 0,
      totalQuestions: data['totalQuestions'] ?? 0,
      completedAt: data['completedAt'] is Timestamp ? data['completedAt'] : null,
    );
  }

  String get completedTimeText {
    if (completedAt == null) return 'Just now';

    final date = completedAt!.toDate();
    final minute = date.minute.toString().padLeft(2, '0');

    return '${date.day}/${date.month}/${date.year} • ${date.hour}:$minute';
  }
}
