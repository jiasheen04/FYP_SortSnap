import 'package:cloud_firestore/cloud_firestore.dart';

class LocationReport {
  final String id;
  final String reportCode;
  final String userId;
  final String userNo;
  final String username;
  final String userName;
  final String recyclingPointId;
  final String recyclingPointCode;
  final String recyclingPointName;
  final String issueType;
  final String description;
  final String status;
  final Timestamp? createdAt;
  final Timestamp? resolvedAt;
  final String? resolvedByAdminId;

  LocationReport({
    required this.id,
    required this.reportCode,
    required this.userId,
    required this.userNo,
    required this.username,
    required this.userName,
    required this.recyclingPointId,
    required this.recyclingPointCode,
    required this.recyclingPointName,
    required this.issueType,
    required this.description,
    required this.status,
    this.createdAt,
    this.resolvedAt,
    this.resolvedByAdminId,
  });

  factory LocationReport.fromFirestore(
    String id,
    Map<String, dynamic> data,
  ) {
    return LocationReport(
      id: id,
      reportCode: data['reportCode'] ?? '',
      userId: data['userId'] ?? '',
      userNo: data['userNo'] ?? '',
      username: data['username'] ?? '',
      userName: data['userName'] ?? '',
      recyclingPointId: data['recyclingPointId'] ?? '',
      recyclingPointCode: data['recyclingPointCode'] ?? '',
      recyclingPointName: data['recyclingPointName'] ?? '',
      issueType: data['issueType'] ?? '',
      description: data['description'] ?? '',
      status: data['status'] ?? 'Open',
      createdAt: data['createdAt'],
      resolvedAt: data['resolvedAt'],
      resolvedByAdminId: data['resolvedByAdminId'],
    );
  }
}