import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mobile_app/core/services/id_generator_service.dart';
import 'package:mobile_app/features/map/models/recycling_point.dart';

class RecyclingPointService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<RecyclingPoint>> getRecyclingPoints() async {
    final snapshot = await _firestore.collection('recycling_points').get();

    final points = snapshot.docs.map((doc) {
      return RecyclingPoint.fromFirestore(doc.id, doc.data());
    }).toList();

    points.sort((a, b) {
      return a.pointCode.compareTo(b.pointCode);
    });

    return points;
  }

  Stream<List<RecyclingPoint>> getRecyclingPointsStream() {
    return _firestore.collection('recycling_points').snapshots().map((
      snapshot,
    ) {
      final points = snapshot.docs.map((doc) {
        return RecyclingPoint.fromFirestore(doc.id, doc.data());
      }).toList();

      points.sort((a, b) {
        return a.pointCode.compareTo(b.pointCode);
      });

      return points;
    });
  }

  Future<void> addRecyclingPoint({
    required String name,
    required String address,
    required double latitude,
    required double longitude,
    required String hours,
    required String status,
    required bool isOpen,
    String recyclingStatus = 'Accepting Items',
    required String contact,
    required String area,
    required Map<String, dynamic> openingHours,
  }) async {
    final pointCode = await IdGeneratorService().generateReadableCode(
      counterName: 'recycling_points',
      prefix: 'RP',
    );

    await _firestore.collection('recycling_points').add({
      'pointCode': pointCode,
      'name': name,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'hours': hours,
      'status': status,
      'is_open': isOpen,
      'recyclingStatus': recyclingStatus,
      'contact': contact,
      'area': area,
      'opening_hours': openingHours,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
}
