import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mobile_app/features/pickup/models/pickup_request.dart';

class PickupService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<String> _generatePickupRequestId() async {
    final counterRef = _firestore.collection('counters').doc('pickup_requests');

    return _firestore.runTransaction((transaction) async {
      final counterSnapshot = await transaction.get(counterRef);

      int lastNumber = 0;

      if (counterSnapshot.exists) {
        final data = counterSnapshot.data();
        lastNumber = data?['lastNumber'] ?? 0;
      }

      final int nextNumber = lastNumber + 1;
      final String pickupId = 'PR${nextNumber.toString().padLeft(3, '0')}';

      transaction.set(
        counterRef,
        {
          'lastNumber': nextNumber,
          'updatedAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );

      return pickupId;
    });
  }

  Future<void> submitPickupRequest({
    required String pickupAddress,
    String? unitNo,
    String? postalCode,
    String? remarks,
    required List<String> itemTypes,
  }) async {
    final currentUser = _auth.currentUser;

    if (currentUser == null) {
      throw Exception('User is not logged in.');
    }

    if (pickupAddress.trim().isEmpty) {
      throw Exception('Pickup address is required.');
    }

    if (itemTypes.isEmpty) {
      throw Exception('Please select at least one item type.');
    }

    final userDoc =
        await _firestore.collection('users').doc(currentUser.uid).get();

    final userData = userDoc.data();

    final String userNo = userData?['userNo']?.toString() ?? '';
    final String username =
        userData?['username']?.toString() ??
        userData?['name']?.toString() ??
        currentUser.displayName ??
        'Unknown User';

    final String pickupId = await _generatePickupRequestId();

    await _firestore.collection('pickup_requests').doc(pickupId).set({
      'pickupId': pickupId,
      'userId': currentUser.uid,
      'userNo': userNo,
      'username': username,
      'pickupAddress': pickupAddress.trim(),
      'unitNo': unitNo?.trim(),
      'postalCode': postalCode?.trim(),
      'remarks': remarks?.trim(),
      'status': 'Pending',
      'itemTypes': itemTypes,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': null,
      'forwardedByAdminId': null,
      'forwardedToPointId': null,
      'forwardedAt': null,
    });
  }

  Stream<List<PickupRequest>> getUserPickupRequestsStream() {
    final currentUser = _auth.currentUser;

    if (currentUser == null) {
      return Stream.value([]);
    }

    return _firestore
        .collection('pickup_requests')
        .where('userId', isEqualTo: currentUser.uid)
        .snapshots()
        .map((snapshot) {
      final requests = snapshot.docs.map((doc) {
        return PickupRequest.fromFirestore(doc.data(), doc.id);
      }).toList();

      requests.sort((a, b) {
        final aDate = a.createdAt ?? DateTime(2000);
        final bDate = b.createdAt ?? DateTime(2000);
        return bDate.compareTo(aDate);
      });

      return requests;
    });
  }
}