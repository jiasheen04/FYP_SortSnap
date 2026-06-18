import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mobile_app/features/profile/models/faq_item.dart';

class FaqService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<FaqItem>> getFaqs() async {
    final snapshot = await _firestore
        .collection('faqs')
        .where('isActive', isEqualTo: true)
        .get();

    final faqs = snapshot.docs.map((doc) {
      return FaqItem.fromFirestore(doc);
    }).toList();

    faqs.sort((a, b) => a.order.compareTo(b.order));

    return faqs;
  }

  Future<void> addFaq({
    required String question,
    required String answer,
    required String category,
    required int order,
  }) async {
    await _firestore.collection('faqs').add({
      'question': question,
      'answer': answer,
      'category': category,
      'order': order,
      'isActive': true,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateFaq({
    required String faqId,
    required String question,
    required String answer,
    required String category,
    required int order,
    required bool isActive,
  }) async {
    await _firestore.collection('faqs').doc(faqId).update({
      'question': question,
      'answer': answer,
      'category': category,
      'order': order,
      'isActive': isActive,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> deleteFaq(String faqId) async {
    await _firestore.collection('faqs').doc(faqId).delete();
  }
}