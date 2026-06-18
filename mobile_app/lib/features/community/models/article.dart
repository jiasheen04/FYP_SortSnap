import 'package:cloud_firestore/cloud_firestore.dart';

class Article {
  final String articleId;
  final String title;
  final String summary;
  final String content;
  final String category;
  final String sourceName;
  final String sourceUrl;
  final String imagePath;
  final int articleOrder;
  final bool isActive;
  final String createdByAdminId;
  final DateTime? createdAt;

  Article({
    required this.articleId,
    required this.title,
    required this.summary,
    required this.content,
    required this.category,
    required this.sourceName,
    required this.sourceUrl,
    required this.imagePath,
    required this.articleOrder,
    required this.isActive,
    required this.createdByAdminId,
    this.createdAt,
  });

  factory Article.fromFirestore(Map<String, dynamic> data, String id) {
    return Article(
      articleId: id,
      title: data['title'] ?? '',
      summary: data['summary'] ?? '',
      content: data['content'] ?? '',
      category: data['category'] ?? '',
      sourceName: data['sourceName'] ?? '',
      sourceUrl: data['sourceUrl'] ?? '',
      imagePath: data['imagePath'] ?? '',
      articleOrder: data['articleOrder'] ?? 999,
      isActive: data['isActive'] ?? true,
      createdByAdminId: data['createdByAdminId'] ?? '',
      createdAt: data['createdAt'] is Timestamp
          ? (data['createdAt'] as Timestamp).toDate()
          : null,
    );
  }
}