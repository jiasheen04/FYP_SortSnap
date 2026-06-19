import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

class ImageScanService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  static const String _baseUrl = 'https://sortsnap-ilmu.onrender.com';

  Future<File> saveImageToLocalAppFolder({
    required File imageFile,
    required String sourceType,
  }) async {
    final appDirectory = await getApplicationDocumentsDirectory();

    final folderPath = '${appDirectory.path}/sortsnap_images/$sourceType';
    final folder = Directory(folderPath);

    if (!await folder.exists()) {
      await folder.create(recursive: true);
    }

    final fileName = sourceType == 'camera'
        ? 'latest_camera_scan.jpg'
        : 'latest_gallery_scan.jpg';

    final savedImagePath = '$folderPath/$fileName';

    final savedImage = await imageFile.copy(savedImagePath);

    return savedImage;
  }

  Future<Map<String, dynamic>> classifyImage({required File imageFile}) async {
    final currentUser = _auth.currentUser;

    if (currentUser == null) {
      throw Exception('User is not logged in.');
    }

    final url = Uri.parse('$_baseUrl/api/chatbot/classify-image');

    final request = http.MultipartRequest('POST', url);

    request.files.add(
      await http.MultipartFile.fromPath('image', imageFile.path),
    );

    final streamedResponse = await request.send().timeout(
      const Duration(seconds: 240),
    );

    final response = await http.Response.fromStream(streamedResponse);
    final data = jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode != 200 || data['success'] != true) {
      throw Exception(data['message'] ?? 'Failed to classify image.');
    }

    final classification =
        data['classification'] as Map<String, dynamic>? ?? {};
    final classifications = data['classifications'] as List? ?? [];

    final userId = currentUser.uid;
    final userSnapshot = await _firestore.collection('users').doc(userId).get();
    final userData = userSnapshot.data() ?? {};

    final userNo = userData['userNo'] ?? '';
    final username = userData['username'] ?? '';
    final userName =
        '${userData['firstName'] ?? ''} ${userData['lastName'] ?? ''}'.trim();

    final answer = data['answer'] ?? '';
    final source = data['source'] ?? 'cnn + ilmu';
    final detectionMode = data['detectionMode'] ?? 'single';

    final mainCategory = classification['category'] ?? 'Unknown';
    final mainItemName = classification['itemName'] ?? '';
    final confidence = classification['confidence'] ?? 0;
    final confidencePercentage = classification['confidencePercentage'] ?? 0;
    final isRecyclable = classification['isRecyclable'] ?? false;

    final possibleCategories = classifications.map((item) {
      final mapItem = item as Map<String, dynamic>;
      return {
        'category': mapItem['category'] ?? 'Unknown',
        'itemName': mapItem['itemName'] ?? '',
        'isRecyclable': mapItem['isRecyclable'] ?? false,
        'confidence': mapItem['confidence'] ?? 0,
        'confidencePercentage': mapItem['confidencePercentage'] ?? 0,
      };
    }).toList();

    final imageScanDoc = _firestore
        .collection('image_scan_records')
        .doc(userId);

    final chatbotDoc = _firestore.collection('chatbot_records').doc(userId);
    final messagesCollection = chatbotDoc.collection('messages');

    await _firestore.runTransaction((transaction) async {
      final chatbotSnapshot = await transaction.get(chatbotDoc);
      final currentCount =
          (chatbotSnapshot.data()?['messageCount'] ?? 0) as int;

      final userMessageNo = currentCount + 1;
      final botMessageNo = currentCount + 2;

      final userMessageId =
          '${userMessageNo.toString().padLeft(5, '0')}_image_user';
      final botMessageId =
          '${botMessageNo.toString().padLeft(5, '0')}_image_bot';

      transaction.set(imageScanDoc, {
        'userId': userId,
        'userNo': userNo,
        'username': username,
        'userName': userName,
        'latestImageLocalPath': imageFile.path,
        'latestCategory': mainCategory,
        'latestConfidence': confidence,
        'latestConfidencePercentage': confidencePercentage,
        'latestGuidance': answer,
        'latestItemName': mainItemName,
        'isRecyclable': isRecyclable,
        'detectionMode': detectionMode,
        'classifications': classifications,
        'source': source,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      transaction.set(chatbotDoc, {
        'userId': userId,
        'userNo': userNo,
        'username': username,
        'userName': userName,
        'latestQuestion': 'Image scan',
        'latestAnswer': answer,
        'isRecyclingRelated': true,
        'source': source,
        'messageCount': botMessageNo,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      transaction.set(messagesCollection.doc(userMessageId), {
        'messageNo': userMessageNo,
        'displayOrder': userMessageNo,
        'userId': userId,
        'userNo': userNo,
        'username': username,
        'userName': userName,
        'role': 'user',
        'messageType': 'image_scan',
        'text': 'Image uploaded for scanning.',
        'imageLocalPath': imageFile.path,
        'source': 'user',
        'createdAt': FieldValue.serverTimestamp(),
      });

      transaction.set(messagesCollection.doc(botMessageId), {
        'messageNo': botMessageNo,
        'displayOrder': botMessageNo,
        'userId': userId,
        'userNo': userNo,
        'username': username,
        'userName': userName,
        'role': 'bot',
        'messageType': 'image_scan_result',
        'text': answer,
        'imageLocalPath': imageFile.path,
        'detectionMode': detectionMode,
        'mainCategory': mainCategory,
        'mainItemName': mainItemName,
        'isRecyclable': isRecyclable,
        'confidence': confidence,
        'confidencePercentage': confidencePercentage,
        'possibleCategories': possibleCategories,
        'source': source,
        'createdAt': FieldValue.serverTimestamp(),
      });
    });

    return data;
  }

  Future<void> saveLatestImageScanLocal({
    required File imageFile,
    required String sourceType,
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

    final savedImage = await saveImageToLocalAppFolder(
      imageFile: imageFile,
      sourceType: sourceType,
    );

    await _firestore.collection('image_scan_records').doc(userId).set({
      'userId': userId,
      'userNo': userNo,
      'username': username,
      'userName': userName,
      'latestImageLocalPath': savedImage.path,
      'latestImageSource': sourceType,
      'latestCategory': 'Pending',
      'latestConfidence': 0,
      'latestGuidance': 'Image saved. Classifying...',
      'source': 'local_image',
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }
}
