import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mobile_app/core/services/id_generator_service.dart';
import 'package:mobile_app/features/map/models/recycling_point.dart';

class LocationReportService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> submitLocationReport({
    required RecyclingPoint recyclingPoint,
    required String issueType,
    required String description,
  }) async {
    final currentUser = _auth.currentUser;

    if (currentUser == null) {
      throw Exception('User is not logged in.');
    }

    final userId = currentUser.uid;

    final userSnapshot = await _firestore.collection('users').doc(userId).get();

    if (!userSnapshot.exists) {
      throw Exception('User profile not found.');
    }

    final userData = userSnapshot.data() as Map<String, dynamic>;

    final userNo = userData['userNo'] ?? '';
    final username = userData['username'] ?? '';
    final firstName = userData['firstName'] ?? '';
    final lastName = userData['lastName'] ?? '';

    final userName = '$firstName $lastName'.trim().isEmpty
        ? username
        : '$firstName $lastName'.trim();

    final reportCode = await IdGeneratorService().generateReadableCode(
      counterName: 'location_reports',
      prefix: 'LR',
    );

    await _firestore.collection('location_reports').add({
      'reportCode': reportCode,
      'userId': userId,
      'userNo': userNo,
      'username': username,
      'userName': userName,
      'recyclingPointId': recyclingPoint.id,
      'recyclingPointCode': recyclingPoint.pointCode,
      'recyclingPointName': recyclingPoint.name,
      'issueType': issueType,
      'description': description,
      'status': 'Open',
      'createdAt': FieldValue.serverTimestamp(),
      'resolvedAt': null,
      'resolvedByAdminId': null,
    });
  }
}