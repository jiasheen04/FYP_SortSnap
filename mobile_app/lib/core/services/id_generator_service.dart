import 'package:cloud_firestore/cloud_firestore.dart';

class IdGeneratorService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<String> generateReadableCode({
    required String counterName,
    required String prefix,
  }) async {
    final counterRef = _firestore.collection('counters').doc(counterName);

    return _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(counterRef);

      int nextNumber = 1;

      if (snapshot.exists) {
        final data = snapshot.data() as Map<String, dynamic>;
        nextNumber = data['nextNumber'] ?? 1;
      }

      final readableCode = '$prefix${nextNumber.toString().padLeft(3, '0')}';

      transaction.set(
        counterRef,
        {'nextNumber': nextNumber + 1},
        SetOptions(merge: true),
      );

      return readableCode;
    });
  }
}