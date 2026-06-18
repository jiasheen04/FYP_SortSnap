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
      const Duration(seconds: 90),
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

    await _firestore.collection('image_scan_records').doc(userId).set({
      'userId': userId,
      'userNo': userData['userNo'] ?? '',
      'username': userData['username'] ?? '',
      'userName': '${userData['firstName'] ?? ''} ${userData['lastName'] ?? ''}'
          .trim(),
      'latestImageLocalPath': imageFile.path,
      'latestCategory': classification['category'] ?? 'Unknown',
      'latestConfidence': classification['confidence'] ?? 0,
      'latestConfidencePercentage': classification['confidencePercentage'] ?? 0,
      'latestGuidance': data['answer'] ?? '',
      'latestItemName': classification['itemName'] ?? '',
      'isRecyclable': classification['isRecyclable'] ?? false,
      'detectionMode': data['detectionMode'] ?? 'single',
      'classifications': classifications,
      'source': data['source'] ?? 'cnn + ilmu',
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

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
