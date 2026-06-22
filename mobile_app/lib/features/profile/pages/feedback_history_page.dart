import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class FeedbackHistoryPage extends StatefulWidget {
  const FeedbackHistoryPage({super.key});

  @override
  State<FeedbackHistoryPage> createState() => _FeedbackHistoryPageState();
}

class _FeedbackHistoryPageState extends State<FeedbackHistoryPage> {
  String formatDate(dynamic value) {
    if (value == null) return '-';

    if (value is Timestamp) {
      final date = value.toDate();
      final minute = date.minute.toString().padLeft(2, '0');
      return '${date.day}/${date.month}/${date.year} ${date.hour}:$minute';
    }

    return '-';
  }

  Color getStatusBgColor(String status) {
    if (status == 'Resolved') {
      return const Color(0xFFE5F8EE);
    }

    if (status == 'In Progress') {
      return const Color(0xFFEAF3FF);
    }

    return const Color(0xFFFFF6E8);
  }

  Color getStatusTextColor(String status) {
    if (status == 'Resolved') {
      return const Color(0xFF35A37A);
    }

    if (status == 'In Progress') {
      return const Color(0xFF1D5FD1);
    }

    return const Color(0xFFC26A00);
  }

  Widget buildStatusBadge(String status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      decoration: BoxDecoration(
        color: getStatusBgColor(status),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: getStatusTextColor(status),
          fontWeight: FontWeight.w800,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget buildFeedbackCard(Map<String, dynamic> data) {
    final subject = data['subject'] ?? 'No Subject';
    final category = data['category'] ?? 'No Category';
    final status = data['status'] ?? 'Open';
    final adminReply = (data['adminReply'] ?? '').toString().trim();

    return GestureDetector(
      onTap: () {
        showFeedbackDetails(data);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    category,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF1D1D1D),
                    ),
                  ),

                  const SizedBox(height: 7),

                  Text(
                    subject,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF808080),
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  const SizedBox(height: 7),

                  Text(
                    adminReply.isEmpty
                        ? 'No admin reply yet'
                        : 'Admin replied',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF35A37A),
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 10),

            buildStatusBadge(status),
          ],
        ),
      ),
    );
  }

  Widget buildDetailRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              title,
              style: const TextStyle(
                color: Color(0xFF808080),
                fontSize: 15,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),

          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: Color(0xFF1D1D1D),
                fontSize: 15,
                fontWeight: FontWeight.w800,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void showFeedbackDetails(Map<String, dynamic> data) {
    final subject = data['subject'] ?? 'No Subject';
    final category = data['category'] ?? 'No Category';
    final message = data['message'] ?? '-';
    final status = data['status'] ?? 'Open';
    final adminReply = (data['adminReply'] ?? '').toString().trim();
    final createdAt = formatDate(data['createdAt']);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.fromLTRB(28, 18, 28, 28),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(28),
            ),
          ),
          child: SafeArea(
            top: false,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 58,
                      height: 6,
                      margin: const EdgeInsets.only(bottom: 24),
                      decoration: BoxDecoration(
                        color: Color(0xFFE0E0E0),
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),

                  Text(
                    '$category Details',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF1D1D1D),
                    ),
                  ),

                  const SizedBox(height: 24),

                  buildDetailRow('Status', status),
                  buildDetailRow('Subject', subject),
                  buildDetailRow('Submitted', createdAt),
                  buildDetailRow('Message', message),
                  buildDetailRow(
                    'Admin Reply',
                    adminReply.isEmpty
                        ? 'No reply from admin yet.'
                        : adminReply,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget buildSection(String title, List<QueryDocumentSnapshot> docs) {
    if (docs.isEmpty) {
      return const SizedBox();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 15,
            color: Color(0xFF777777),
            fontWeight: FontWeight.w700,
          ),
        ),

        const SizedBox(height: 14),

        ...docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          return buildFeedbackCard(data);
        }),

        const SizedBox(height: 34),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFFD9EFE7),
      appBar: AppBar(
        backgroundColor: const Color(0xFF62C49D),
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'My Feedback',
          style: TextStyle(
            color: Colors.white,
            fontSize: 17,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: currentUser == null
          ? const Center(
              child: Text(
                'Please login first.',
                style: TextStyle(fontSize: 16),
              ),
            )
          : StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('feedback')
                  .where('userId', isEqualTo: currentUser.uid)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFF51BA90),
                    ),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Text(
                      'No feedback submitted yet.',
                      style: TextStyle(
                        fontSize: 15,
                        color: Color(0xFF777777),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  );
                }

                final allDocs = snapshot.data!.docs.toList();

                allDocs.sort((a, b) {
                  final aData = a.data() as Map<String, dynamic>;
                  final bData = b.data() as Map<String, dynamic>;

                  final aTime = aData['createdAt'];
                  final bTime = bData['createdAt'];

                  if (aTime == null && bTime == null) return 0;
                  if (aTime == null) return 1;
                  if (bTime == null) return -1;

                  return (bTime as Timestamp).compareTo(aTime as Timestamp);
                });

                final activeDocs = allDocs.where((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  final status = data['status'] ?? 'Open';

                  return status == 'Open' || status == 'In Progress';
                }).toList();

                final resolvedDocs = allDocs.where((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  final status = data['status'] ?? 'Open';

                  return status == 'Resolved';
                }).toList();

                return ListView(
                  padding: const EdgeInsets.fromLTRB(20, 34, 20, 30),
                  children: [
                    buildSection('Active Feedback', activeDocs),
                    buildSection('Resolved Feedback', resolvedDocs),
                  ],
                );
              },
            ),
    );
  }
}