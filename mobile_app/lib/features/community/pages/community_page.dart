import 'package:flutter/material.dart';
import 'package:mobile_app/core/widgets/bottom_nav.dart';
import 'package:mobile_app/features/community/models/quiz.dart';
import 'package:mobile_app/features/community/models/flashcard.dart';
import 'package:mobile_app/features/community/models/article.dart';
import 'package:mobile_app/features/community/services/community_service.dart';
import 'package:mobile_app/features/community/pages/quiz_page.dart';
import 'package:mobile_app/features/community/pages/flashcard_page.dart';
import 'package:mobile_app/features/community/pages/article_page.dart';

class CommunityPage extends StatefulWidget {
  const CommunityPage({super.key});

  @override
  State<CommunityPage> createState() => _CommunityPageState();
}

class _CommunityPageState extends State<CommunityPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final CommunityService _communityService = CommunityService();

  List<Quiz> _quizzes = [];
  List<FlashcardSet> _flashcardSets = [];
  List<Article> _articles = [];

  bool _isLoading = true;

  static const Color mainGreen = Color(0xFF62C49D);
  static const Color iconGreen = Color(0xFF51BA90);
  static const Color pageBg = Color(0xFFD5EDE4);
  static const Color lightGreen = Color(0xFFE8F8F0);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    try {
      final quizzes = await _communityService.getActiveQuizzes();
      final flashcardSets = await _communityService.getActiveFlashcardSets();
      final articles = await _communityService.getActiveArticles();

      if (!mounted) return;

      setState(() {
        _quizzes = quizzes;
        _flashcardSets = flashcardSets;
        _articles = articles;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load community data: $e')),
      );
    }
  }

  Widget _buildEmptyMessage(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 16, color: Colors.black54),
        ),
      ),
    );
  }

  Widget _buildCommunityCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
    required VoidCallback onTap,
    Widget? customSubtitle,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 10,
        ),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: iconBgColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: iconColor,
            size: 26,
          ),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
        subtitle: customSubtitle ??
            Padding(
              padding: const EdgeInsets.only(top: 3),
              child: Text(
                subtitle,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: Colors.grey,
        ),
        onTap: onTap,
      ),
    );
  }

  Widget _buildQuizList() {
    if (_quizzes.isEmpty) {
      return _buildEmptyMessage(
        'No quizzes available yet.\nCheck back later!',
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _quizzes.length,
      itemBuilder: (context, index) {
        final quiz = _quizzes[index];

        return _buildCommunityCard(
          title: quiz.title,
          subtitle: 'Tap to start quiz',
          icon: Icons.quiz_outlined,
          iconColor: iconGreen,
          iconBgColor: lightGreen,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => QuizPage(quiz: quiz),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildFlashcardList() {
    if (_flashcardSets.isEmpty) {
      return _buildEmptyMessage(
        'No flashcard sets available yet.\nCheck back later!',
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _flashcardSets.length,
      itemBuilder: (context, index) {
        final set = _flashcardSets[index];

        final levelStyle = _getLevelStyle(set.level);
        final levelText = _formatLevelText(set.level);

        return _buildCommunityCard(
          title: set.title,
          subtitle: '',
          icon: levelStyle.icon,
          iconColor: levelStyle.color,
          iconBgColor: levelStyle.backgroundColor,
          customSubtitle: Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Align(
              alignment: Alignment.centerLeft,
              widthFactor: 1,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: levelStyle.backgroundColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  levelText,
                  style: TextStyle(
                    color: levelStyle.color,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => FlashcardPage(flashcardSet: set),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildArticleList() {
    if (_articles.isEmpty) {
      return _buildEmptyMessage(
        'No articles available yet.\nCheck back later!',
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _articles.length,
      itemBuilder: (context, index) {
        final article = _articles[index];

        return _buildCommunityCard(
          title: article.title,
          subtitle: article.summary,
          icon: Icons.article_outlined,
          iconColor: iconGreen,
          iconBgColor: lightGreen,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ArticlePage(article: article),
              ),
            );
          },
        );
      },
    );
  }

  _LevelStyle _getLevelStyle(String level) {
    switch (level.toLowerCase()) {
      case 'intermediate':
        return _LevelStyle(
          color: Colors.orange,
          backgroundColor: Colors.orange.withValues(alpha: 0.12),
          icon: Icons.menu_book_outlined,
        );

      case 'advanced':
        return _LevelStyle(
          color: Colors.redAccent,
          backgroundColor: Colors.redAccent.withValues(alpha: 0.12),
          icon: Icons.auto_stories_outlined,
        );

      default:
        return _LevelStyle(
          color: iconGreen,
          backgroundColor: iconGreen.withValues(alpha: 0.12),
          icon: Icons.style_outlined,
        );
    }
  }

  String _formatLevelText(String level) {
    if (level.isEmpty) return 'Beginner';

    return '${level[0].toUpperCase()}${level.substring(1).toLowerCase()}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: pageBg,
      appBar: AppBar(
        backgroundColor: mainGreen,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Community',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          labelStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
          tabs: const [
            Tab(text: 'Quiz'),
            Tab(text: 'Flashcards'),
            Tab(text: 'Articles'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: iconGreen),
            )
          : TabBarView(
              controller: _tabController,
              children: [
                SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: _buildQuizList(),
                ),
                SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: _buildFlashcardList(),
                ),
                SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: _buildArticleList(),
                ),
              ],
            ),
      bottomNavigationBar: const BottomNav(selectedIndex: 0),
    );
  }
}

class _LevelStyle {
  final Color color;
  final Color backgroundColor;
  final IconData icon;

  _LevelStyle({
    required this.color,
    required this.backgroundColor,
    required this.icon,
  });
}