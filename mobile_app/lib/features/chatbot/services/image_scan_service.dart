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

  String _safeDocPart(String value) {
    final cleaned = value.trim().isEmpty ? 'user' : value.trim();
    return cleaned.replaceAll(RegExp(r'[^A-Za-z0-9_-]'), '_');
  }

  String _buildImageScanDisplayText(Map<String, dynamic> data) {
    final detectionMode = (data['detectionMode'] ?? 'single').toString();
    final classification =
        data['classification'] as Map<String, dynamic>? ?? {};
    final classificationsRaw = data['classifications'] as List? ?? [];
    final answer = (data['answer'] ?? 'No guidance returned.').toString();

    if (detectionMode == 'possible_mixed' && classificationsRaw.length > 1) {
      String itemListText = '';

      for (int i = 0; i < classificationsRaw.length; i++) {
        final item = Map<String, dynamic>.from(classificationsRaw[i] as Map);

        final category = (item['category'] ?? 'Unknown').toString();
        final isRecyclable = item['isRecyclable'] == true;

        itemListText +=
            '${i + 1}. $category\n'
            'Recyclable: ${isRecyclable ? "Yes" : "No"}\n\n';
      }

      return 'Possible mixed materials:\n\n'
          '$itemListText'
          '$answer';
    }

    final category = (classification['category'] ?? 'Unknown').toString();
    final itemName = (classification['itemName'] ?? category).toString();
    final isRecyclable = classification['isRecyclable'] == true;

    return 'Item: $itemName\n'
        'Category: $category\n'
        'Recyclable: ${isRecyclable ? "Yes" : "No"}\n\n'
        '$answer';
  }

  String _buildImageContextText(Map<String, dynamic> data) {
    final detectionMode = (data['detectionMode'] ?? 'single').toString();
    final classification =
        data['classification'] as Map<String, dynamic>? ?? {};
    final classificationsRaw = data['classifications'] as List? ?? [];

    if (detectionMode == 'possible_mixed' && classificationsRaw.length > 1) {
      final possibleItems = classificationsRaw
          .map((rawItem) {
            final item = Map<String, dynamic>.from(rawItem as Map);
            final category = (item['category'] ?? 'Unknown').toString();
            final itemName = (item['itemName'] ?? category).toString();
            final isRecyclable = item['isRecyclable'] == true;

            return '$itemName ($category, recyclable: ${isRecyclable ? "Yes" : "No"})';
          })
          .join(', ');

      return 'Previous image scan result: The uploaded image might contain mixed waste materials: $possibleItems. Use this as the item context when the user asks about "it", "this item", "that item", "the image", or asks for more details. If the user corrects the item, trust the user correction.';
    }

    final category = (classification['category'] ?? 'Unknown').toString();
    final itemName = (classification['itemName'] ?? category).toString();
    final isRecyclable = classification['isRecyclable'] == true;

    return 'Previous image scan result: The uploaded image was classified as $itemName. Category: $category. Recyclable: ${isRecyclable ? "Yes" : "No"}. Use this as the item context when the user asks about "it", "this item", "that item", "the image", or asks for more details. If the user corrects the item, trust the user correction.';
  }

  Future<Map<String, dynamic>> classifyImage({
    required File imageFile,
    List<Map<String, dynamic>> chatHistory = const [],
  }) async {
    final currentUser = _auth.currentUser;

    if (currentUser == null) {
      throw Exception('User is not logged in.');
    }

    final url = Uri.parse('$_baseUrl/api/chatbot/classify-image');

    final request = http.MultipartRequest('POST', url);

    request.files.add(
      await http.MultipartFile.fromPath('image', imageFile.path),
    );

    request.fields['chatHistory'] = jsonEncode(chatHistory);

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

    final chatDisplayText = _buildImageScanDisplayText(data);
    final imageContextText = _buildImageContextText(data);

    data['chatDisplayText'] = chatDisplayText;
    data['imageContextText'] = imageContextText;

    final chatbotDoc = _firestore.collection('chatbot_records').doc(userId);
    final messagesCollection = chatbotDoc.collection('messages');

    await _firestore.runTransaction((transaction) async {
      final chatbotSnapshot = await transaction.get(chatbotDoc);

      final currentMessageCount =
          (chatbotSnapshot.data()?['messageCount'] ?? 0) as int;

      final currentScanCount =
          (chatbotSnapshot.data()?['imageScanCount'] ?? 0) as int;

      final scanNo = currentScanCount + 1;

      final userMessageNo = currentMessageCount + 1;
      final botMessageNo = currentMessageCount + 2;

      final safeUserNo = _safeDocPart(userNo.isNotEmpty ? userNo : userId);

      final scanDocId =
          '${safeUserNo}_scan_${scanNo.toString().padLeft(6, '0')}';

      final userMessageId =
          '${userMessageNo.toString().padLeft(6, '0')}_image_user';

      final botMessageId =
          '${botMessageNo.toString().padLeft(6, '0')}_image_bot';

      final imageScanDoc = _firestore
          .collection('image_scan_records')
          .doc(scanDocId);

      transaction.set(imageScanDoc, {
        'scanId': scanDocId,
        'scanNo': scanNo,
        'displayOrder': scanNo,
        'userId': userId,
        'userNo': userNo,
        'username': username,
        'userName': userName,
        'imageLocalPath': imageFile.path,
        'category': mainCategory,
        'itemName': mainItemName,
        'isRecyclable': isRecyclable,
        'confidence': confidence,
        'confidencePercentage': confidencePercentage,
        'detectionMode': detectionMode,
        'classifications': classifications,
        'possibleCategories': possibleCategories,
        'guidance': answer,
        'chatDisplayText': chatDisplayText,
        'imageContextText': imageContextText,
        'source': source,
        'createdAt': FieldValue.serverTimestamp(),
      });

      transaction.set(chatbotDoc, {
        'userId': userId,
        'userNo': userNo,
        'username': username,
        'userName': userName,
        'latestQuestion': 'Image scan',
        'latestAnswer': chatDisplayText,
        'latestImageContextText': imageContextText,
        'isRecyclingRelated': true,
        'source': source,
        'messageCount': botMessageNo,
        'imageScanCount': scanNo,
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
        'text': chatDisplayText,
        'imageContextText': imageContextText,
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

  Future<bool> warmUpImageScanner() async {
    final url = Uri.parse('https://sortsnap-cnn.onrender.com/health');

    for (int attempt = 1; attempt <= 6; attempt++) {
      try {
        final response = await http
            .get(url)
            .timeout(const Duration(seconds: 20));

        if (response.statusCode == 200) {
          final body = response.body.trim();

          if (body.startsWith('{')) {
            final data = jsonDecode(body) as Map<String, dynamic>;

            if (data['success'] == true) {
              return true;
            }
          }
        }
      } catch (e) {
        print('CNN warm up attempt $attempt failed: $e');
      }

      await Future.delayed(const Duration(seconds: 10));
    }

    return false;
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
