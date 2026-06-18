import 'package:cloud_firestore/cloud_firestore.dart';

class FaqItem {
  final String faqId;
  final String question;
  final String answer;
  final String category;
  final int order;
  final bool isActive;

  FaqItem({
    required this.faqId,
    required this.question,
    required this.answer,
    required this.category,
    required this.order,
    required this.isActive,
  });

  factory FaqItem.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return FaqItem(
      faqId: doc.id,
      question: data['question'] ?? '',
      answer: data['answer'] ?? '',
      category: data['category'] ?? 'General',
      order: data['order'] ?? 0,
      isActive: data['isActive'] ?? true,
    );
  }
}