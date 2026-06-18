import 'package:cloud_firestore/cloud_firestore.dart';

class ImageScanRecord {
  final String userId;
  final String userNo;
  final String username;
  final String userName;
  final String latestImageUrl;
  final String latestImagePath;
  final String latestCategory;
  final double latestConfidence;
  final String latestGuidance;
  final String source;
  final Timestamp? updatedAt;

  ImageScanRecord({
    required this.userId,
    required this.userNo,
    required this.username,
    required this.userName,
    required this.latestImageUrl,
    required this.latestImagePath,
    required this.latestCategory,
    required this.latestConfidence,
    required this.latestGuidance,
    required this.source,
    this.updatedAt,
  });

  factory ImageScanRecord.fromFirestore(Map<String, dynamic> data) {
    return ImageScanRecord(
      userId: data['userId'] ?? '',
      userNo: data['userNo'] ?? '',
      username: data['username'] ?? '',
      userName: data['userName'] ?? '',
      latestImageUrl: data['latestImageUrl'] ?? '',
      latestImagePath: data['latestImagePath'] ?? '',
      latestCategory: data['latestCategory'] ?? 'Pending',
      latestConfidence: (data['latestConfidence'] ?? 0).toDouble(),
      latestGuidance: data['latestGuidance'] ?? '',
      source: data['source'] ?? 'image_upload',
      updatedAt: data['updatedAt'],
    );
  }
}