import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mobile_app/features/profile/models/quiz_history.dart';

class ProfileService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<List<QuizHistory>> getQuizHistory() async {
    final currentUser = _auth.currentUser;

    if (currentUser == null) return [];

    final snapshot = await _firestore
        .collection('quiz_attempts')
        .where('userId', isEqualTo: currentUser.uid)
        .get();

    final history = snapshot.docs.map((doc) {
      return QuizHistory.fromFirestore(doc.data(), doc.id);
    }).toList();

    history.sort((a, b) {
      final aTime = a.completedAt;
      final bTime = b.completedAt;

      if (aTime == null && bTime == null) return 0;
      if (aTime == null) return 1;
      if (bTime == null) return -1;

      return bTime.compareTo(aTime);
    });

    return history;
  }
}
