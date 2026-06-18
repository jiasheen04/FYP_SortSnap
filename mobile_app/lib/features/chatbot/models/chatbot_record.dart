import 'package:cloud_firestore/cloud_firestore.dart';

class ChatbotRecord {
  final String userId;
  final String userNo;
  final String username;
  final String userName;
  final String latestQuestion;
  final String latestAnswer;
  final bool isRecyclingRelated;
  final String source;
  final Timestamp? updatedAt;

  ChatbotRecord({
    required this.userId,
    required this.userNo,
    required this.username,
    required this.userName,
    required this.latestQuestion,
    required this.latestAnswer,
    required this.isRecyclingRelated,
    required this.source,
    this.updatedAt,
  });

  factory ChatbotRecord.fromFirestore(Map<String, dynamic> data) {
    return ChatbotRecord(
      userId: data['userId'] ?? '',
      userNo: data['userNo'] ?? '',
      username: data['username'] ?? '',
      userName: data['userName'] ?? '',
      latestQuestion: data['latestQuestion'] ?? '',
      latestAnswer: data['latestAnswer'] ?? '',
      isRecyclingRelated: data['isRecyclingRelated'] ?? false,
      source: data['source'] ?? 'rule_based',
      updatedAt: data['updatedAt'],
    );
  }
}