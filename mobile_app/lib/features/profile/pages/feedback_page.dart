import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mobile_app/features/profile/pages/feedback_history_page.dart';

class FeedbackPage extends StatefulWidget {
  const FeedbackPage({super.key});

  @override
  State<FeedbackPage> createState() => _FeedbackPageState();
}

class _FeedbackPageState extends State<FeedbackPage> {
  final TextEditingController _subjectController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();
  bool _isSubmitting = false;
  String _selectedCategory = 'Bug Report';

  final List<String> _categories = [
    'Bug Report',
    'Feature Request',
    'General Feedback',
    'Other',
  ];

  Future<void> _submitFeedback() async {
    if (_subjectController.text.trim().isEmpty ||
        _messageController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields')),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        throw Exception('Not logged in');
      }

      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .get();

      String username = 'Unknown User';
      String userNo = '-';

      if (userDoc.exists) {
        final userData = userDoc.data();

        if (userData != null) {
          username = userData['username'] ?? 'Unknown User';
          userNo = userData['userNo'] ?? '-';
        }
      }

      await FirebaseFirestore.instance.collection('feedback').add({
        'userId': currentUser.uid,
        'username': username,
        'userNo': userNo,
        'category': _selectedCategory,
        'subject': _subjectController.text.trim(),
        'message': _messageController.text.trim(),
        'status': 'Open',
        'adminReply': '',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Feedback submitted successfully!')),
      );

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to submit: $e')));
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _subjectController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFD5EDE4),
      appBar: AppBar(
        backgroundColor: const Color(0xFF62C49D),
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Colors.white,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Help Centre',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 17,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Submit Feedback',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            const Text(
              'Let us know how we can improve SortSnap.',
              style: TextStyle(fontSize: 14, color: Colors.black54),
            ),
            const SizedBox(height: 24),

            Align(
              alignment: Alignment.centerRight,
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFF35A37A), width: 1.6),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 14,
                  ),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const FeedbackHistoryPage(),
                    ),
                  );
                },
                icon: const Icon(
                  Icons.history,
                  color: Color(0xFF35A37A),
                  size: 18,
                ),
                label: const Text(
                  'My Feedback',
                  style: TextStyle(
                    color: Color(0xFF35A37A),
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),

            const Text(
              'Category',
              style: TextStyle(fontSize: 16, color: Colors.black54),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedCategory,
                  isExpanded: true,
                  items: _categories.map((cat) {
                    return DropdownMenuItem(value: cat, child: Text(cat));
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _selectedCategory = value;
                      });
                    }
                  },
                ),
              ),
            ),
            const SizedBox(height: 20),

            const Text(
              'Subject',
              style: TextStyle(fontSize: 16, color: Colors.black54),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _subjectController,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                hintText: 'Brief description of your issue',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 20),

            const Text(
              'Message',
              style: TextStyle(fontSize: 16, color: Colors.black54),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _messageController,
              maxLines: 6,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                hintText: 'Describe in detail...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submitFeedback,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF51BA90),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isSubmitting
                    ? const SizedBox(
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        'Submit Feedback',
                        style: TextStyle(fontSize: 16),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
