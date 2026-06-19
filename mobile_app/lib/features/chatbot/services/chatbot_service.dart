import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'package:mobile_app/features/chatbot/models/chatbot_record.dart';

class ChatbotService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  static const String _baseUrl = 'https://sortsnap-ilmu.onrender.com';

  Future<ChatbotRecord?> getLatestChatbotRecord() async {
    final currentUser = _auth.currentUser;

    if (currentUser == null) {
      return null;
    }

    final snapshot = await _firestore
        .collection('chatbot_records')
        .doc(currentUser.uid)
        .get();

    if (!snapshot.exists || snapshot.data() == null) {
      return null;
    }

    return ChatbotRecord.fromFirestore(snapshot.data()!);
  }

  Future<String> askQuestion(
    String question, {
    List<Map<String, dynamic>> chatHistory = const [],
  }) async {
    final currentUser = _auth.currentUser;

    if (currentUser == null) {
      throw Exception('User is not logged in.');
    }

    final userId = currentUser.uid;

    final userSnapshot = await _firestore.collection('users').doc(userId).get();

    if (!userSnapshot.exists || userSnapshot.data() == null) {
      throw Exception('User profile not found.');
    }

    final userData = userSnapshot.data()!;

    final userNo = userData['userNo'] ?? '';
    final username = userData['username'] ?? '';
    final firstName = userData['firstName'] ?? '';
    final lastName = userData['lastName'] ?? '';

    final fullName = '$firstName $lastName'.trim();
    final userName = fullName.isEmpty ? username : fullName;

    final aiResult = await _askIlmuBackend(
      question: question,
      chatHistory: chatHistory,
    );

    final answer = aiResult['answer'] ?? 'Sorry, I could not generate an answer.';
    final isRecyclingRelated = aiResult['isRecyclingRelated'] ?? true;
    final source = aiResult['source'] ?? 'ilmu';

    await _firestore.collection('chatbot_records').doc(userId).set({
      'userId': userId,
      'userNo': userNo,
      'username': username,
      'userName': userName,
      'latestQuestion': question,
      'latestAnswer': answer,
      'isRecyclingRelated': isRecyclingRelated,
      'source': source,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    return answer;
  }

  Future<Map<String, dynamic>> _askIlmuBackend({
    required String question,
    required List<Map<String, dynamic>> chatHistory,
  }) async {
    final url = Uri.parse('$_baseUrl/api/chatbot/text');

    final response = await http
        .post(
          url,
          headers: {
            'Content-Type': 'application/json',
          },
          body: jsonEncode({
            'question': question,
            'chatHistory': chatHistory,
          }),
        )
        .timeout(const Duration(seconds: 60));

    final data = jsonDecode(response.body);

    if (response.statusCode != 200 || data['success'] != true) {
      throw Exception(data['message'] ?? 'Failed to get AI response.');
    }

    return {
      'answer': data['answer'],
      'isRecyclingRelated': data['isRecyclingRelated'] ?? true,
      'source': data['source'] ?? 'ilmu',
    };
  }
}