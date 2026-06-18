import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mobile_app/features/community/models/quiz.dart';
import 'package:mobile_app/features/community/models/flashcard.dart';
import 'package:mobile_app/features/community/models/article.dart';

class CommunityService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // =========================
  // Quiz methods
  // =========================

  Future<List<Quiz>> getActiveQuizzes() async {
    final snapshot = await _firestore
        .collection('quizzes')
        .where('isActive', isEqualTo: true)
        .get();

    final quizzes = snapshot.docs
        .map((doc) => Quiz.fromFirestore(doc.data(), doc.id))
        .toList();

    quizzes.sort((a, b) => a.difficultyOrder.compareTo(b.difficultyOrder));

    return quizzes;
  }

  Future<List<QuizQuestion>> getQuizQuestions(String quizId) async {
    final snapshot = await _firestore
        .collection('quiz_questions')
        .where('quizId', isEqualTo: quizId)
        .where('isActive', isEqualTo: true)
        .get();

    final questionDocs = snapshot.docs.toList()
      ..sort((a, b) {
        final aOrder = a.data()['questionOrder'] ?? 999;
        final bOrder = b.data()['questionOrder'] ?? 999;
        return aOrder.compareTo(bOrder);
      });

    List<QuizQuestion> questions = [];

    for (final doc in questionDocs) {
      final optionsSnapshot = await _firestore
          .collection('quiz_options')
          .where('questionId', isEqualTo: doc.id)
          .get();

      final optionDocs = optionsSnapshot.docs.toList()
        ..sort((a, b) {
          final aOrder = a.data()['optionOrder'] ?? 999;
          final bOrder = b.data()['optionOrder'] ?? 999;
          return aOrder.compareTo(bOrder);
        });

      final options = optionDocs
          .map((optDoc) => QuizOption.fromFirestore(optDoc.data(), optDoc.id))
          .toList();

      final question = QuizQuestion.fromFirestore(
        doc.data(),
        doc.id,
        options: options,
      );

      questions.add(question);
    }

    return questions;
  }

  Future<void> saveQuizAttempt({
    required String quizId,
    required String quizTitle,
    required int score,
    required int totalQuestions,
    required List<Map<String, dynamic>> answers,
  }) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) return;

    String userNo = '';
    String username = '';

    final userDoc = await _firestore
        .collection('users')
        .doc(currentUser.uid)
        .get();

    if (userDoc.exists) {
      final userData = userDoc.data() ?? {};
      userNo = userData['userNo'] ?? '';
      username =
          userData['username'] ??
          userData['name'] ??
          currentUser.displayName ??
          currentUser.email ??
          '';
    }

    await _firestore.collection('quiz_attempts').add({
      'userId': currentUser.uid,
      'userNo': userNo,
      'username': username,
      'quizId': quizId,
      'quizTitle': quizTitle,
      'score': score,
      'totalQuestions': totalQuestions,
      'answers': answers,
      'startedAt': FieldValue.serverTimestamp(),
      'completedAt': FieldValue.serverTimestamp(),
    });
  }

  // =========================
  // Flashcard methods
  // =========================

  Future<List<FlashcardSet>> getActiveFlashcardSets() async {
    final snapshot = await _firestore
        .collection('flashcard_sets')
        .where('isActive', isEqualTo: true)
        .get();

    final sets = snapshot.docs
        .map((doc) => FlashcardSet.fromFirestore(doc.data(), doc.id))
        .toList();

    sets.sort((a, b) => a.difficultyOrder.compareTo(b.difficultyOrder));

    return sets;
  }

  Future<List<Flashcard>> getFlashcards(String setId) async {
    final snapshot = await _firestore
        .collection('flashcards')
        .where('setId', isEqualTo: setId)
        .where('isActive', isEqualTo: true)
        .get();

    final cards = snapshot.docs
        .map((doc) => Flashcard.fromFirestore(doc.data(), doc.id))
        .toList();

    cards.sort((a, b) => a.cardOrder.compareTo(b.cardOrder));

    return cards;
  }

  // =========================
  // Article methods
  // =========================

  Future<List<Article>> getActiveArticles() async {
    final snapshot = await _firestore
        .collection('articles')
        .where('isActive', isEqualTo: true)
        .get();

    final articles = snapshot.docs
        .map((doc) => Article.fromFirestore(doc.data(), doc.id))
        .toList();

    articles.sort((a, b) => a.articleOrder.compareTo(b.articleOrder));

    return articles;
  }
}
