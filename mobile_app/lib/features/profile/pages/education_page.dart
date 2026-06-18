import 'package:flutter/material.dart';
import 'package:mobile_app/features/profile/models/quiz_history.dart';
import 'package:mobile_app/features/profile/services/profile_service.dart';

class EducationPage extends StatefulWidget {
  const EducationPage({super.key});

  @override
  State<EducationPage> createState() => _EducationPageState();
}

class _EducationPageState extends State<EducationPage> {
  final ProfileService _profileService = ProfileService();

  bool _isLoading = true;
  List<QuizHistory> _quizHistory = [];

  @override
  void initState() {
    super.initState();
    _loadQuizHistory();
  }

  Future<void> _loadQuizHistory() async {
    try {
      final history = await _profileService.getQuizHistory();

      if (!mounted) return;

      setState(() {
        _quizHistory = history;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });
    }
  }

  Widget _buildHistoryCard(QuizHistory history) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: const Color(0xFFE8F8F0),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.school_outlined,
              color: Color(0xFF51BA90),
              size: 23,
            ),
          ),
          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  history.quizTitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  history.completedTimeText,
                  style: const TextStyle(
                    fontSize: 12.5,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 10),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            decoration: BoxDecoration(
              color: const Color(0xFFE8F8F0),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '${history.score}/${history.totalQuestions}',
              style: const TextStyle(
                color: Color(0xFF51BA90),
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyHistory() {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(20),
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.school_outlined,
              color: Color(0xFF51BA90),
              size: 42,
            ),
            SizedBox(height: 12),
            Text(
              'No education record yet',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: 6),
            Text(
              'Complete a quiz and your result will appear here.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: Colors.black54,
              ),
            ),
          ],
        ),
      ),
    );
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
          'Education',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 17,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: Color(0xFF51BA90),
              ),
            )
          : _quizHistory.isEmpty
              ? _buildEmptyHistory()
              : RefreshIndicator(
                  color: const Color(0xFF51BA90),
                  onRefresh: _loadQuizHistory,
                  child: ListView(
                    padding: const EdgeInsets.all(20),
                    children: _quizHistory.map((history) {
                      return _buildHistoryCard(history);
                    }).toList(),
                  ),
                ),
    );
  }
}
