import 'package:cloud_firestore/cloud_firestore.dart';

class PickupRequest {
  final String pickupId;
  final String userId;
  final String? userNo;
  final String? username;
  final String pickupAddress;
  final String? unitNo;
  final String? postalCode;
  final String? remarks;
  final String status;
  final List<String> itemTypes;
  final DateTime? createdAt;

  PickupRequest({
    required this.pickupId,
    required this.userId,
    this.userNo,
    this.username,
    required this.pickupAddress,
    this.unitNo,
    this.postalCode,
    this.remarks,
    required this.status,
    required this.itemTypes,
    this.createdAt,
  });

  factory PickupRequest.fromFirestore(Map<String, dynamic> data, String id) {
    return PickupRequest(
      pickupId: data['pickupId'] ?? id,
      userId: data['userId'] ?? '',
      userNo: data['userNo'],
      username: data['username'],
      pickupAddress: data['pickupAddress'] ?? '',
      unitNo: data['unitNo'],
      postalCode: data['postalCode'],
      remarks: data['remarks'],
      status: data['status'] ?? 'Pending',
      itemTypes: List<String>.from(data['itemTypes'] ?? []),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
    );
  }
}