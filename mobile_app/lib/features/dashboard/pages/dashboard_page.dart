import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mobile_app/core/widgets/bottom_nav.dart';
import 'package:mobile_app/features/community/models/article.dart';
import 'package:mobile_app/features/community/pages/article_page.dart';
import 'package:mobile_app/features/community/pages/community_page.dart';
import 'package:mobile_app/features/community/services/community_service.dart';
import 'package:mobile_app/features/pickup/pages/pickup_page.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  String userDisplayName = '';
  bool isLoading = true;

  final CommunityService communityService = CommunityService();
  List<Article> articles = [];

  @override
  void initState() {
    super.initState();
    loadUserData();
    loadArticles();
  }

  Future<void> loadUserData() async {
    try {
      User? currentUser = FirebaseAuth.instance.currentUser;

      if (currentUser != null) {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser.uid)
            .get();

        if (userDoc.exists) {
          setState(() {
            userDisplayName = userDoc['firstName'] ?? 'User';
            isLoading = false;
          });
        } else {
          setState(() {
            userDisplayName = 'User';
            isLoading = false;
          });
        }
      } else {
        setState(() {
          userDisplayName = 'User';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        userDisplayName = 'User';
        isLoading = false;
      });
    }
  }

  Future<void> loadArticles() async {
    try {
      final articleList = await communityService.getActiveArticles();

      if (!mounted) return;

      setState(() {
        articles = articleList;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        articles = [];
      });
    }
  }

  void showQrDialog() {
    final currentUser = FirebaseAuth.instance.currentUser;

    String userId = 'N/A';

    if (currentUser != null) {
      if (currentUser.uid.length > 8) {
        userId = '${currentUser.uid.substring(0, 8)}...';
      } else {
        userId = currentUser.uid;
      }
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.qr_code_2, size: 120, color: Color(0xFF51BA90)),
              const SizedBox(height: 16),
              const Text(
                'Your SortSnap QR',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'User ID: $userId',
                style: const TextStyle(fontSize: 13, color: Colors.black54),
              ),
              const SizedBox(height: 8),
              const Text(
                'Show this QR at recycling points for quick check-in.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: Colors.black54),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text(
                'Close',
                style: TextStyle(color: Color(0xFF51BA90)),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget buildTopButton({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: ElevatedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, size: 20),
        label: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF96D8BE),
          foregroundColor: Colors.white,
          elevation: 2,
          padding: const EdgeInsets.symmetric(vertical: 17),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
    );
  }

  Widget buildSectionTitle({
    required String title,
    bool showSeeAll = false,
    VoidCallback? onSeeAll,
  }) {
    return Row(
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 21,
            fontWeight: FontWeight.w800,
            color: Colors.black,
          ),
        ),
        const Spacer(),
        if (showSeeAll)
          GestureDetector(
            onTap: onSeeAll,
            child: const Text(
              'See All  >',
              style: TextStyle(
                color: Colors.black26,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
      ],
    );
  }

  Widget buildArticleCard(Article article) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => ArticlePage(article: article)),
        );
      },
      child: Container(
        width: 270,
        margin: const EdgeInsets.only(right: 14),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.85),
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 7,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            buildArticleImage(article),
            const SizedBox(height: 8),
            Text(
              article.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Color(0xFF51BA90),
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              article.summary,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Colors.black38, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildArticleImage(Article article) {
    if (article.imagePath.isEmpty) {
      return buildArticlePlaceholder();
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Image.asset(
        article.imagePath,
        width: double.infinity,
        height: 105,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return buildArticlePlaceholder();
        },
      ),
    );
  }

  Widget buildArticlePlaceholder() {
    return Container(
      width: double.infinity,
      height: 105,
      decoration: BoxDecoration(
        color: const Color(0xFFE8F8F0),
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Icon(
        Icons.article_outlined,
        color: Color(0xFF51BA90),
        size: 42,
      ),
    );
  }

  Widget buildArticlesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildSectionTitle(
          title: 'Articles',
          showSeeAll: true,
          onSeeAll: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const CommunityPage(initialTabIndex: 2),
              ),
            );
          },
        ),
        const SizedBox(height: 14),

        if (articles.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.85),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Text(
              'No articles available yet.',
              style: TextStyle(color: Colors.black54, fontSize: 14),
            ),
          )
        else
          SizedBox(
            height: 175,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: articles.length,
              itemBuilder: (context, index) {
                return buildArticleCard(articles[index]);
              },
            ),
          ),
      ],
    );
  }

  Widget buildTipCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.85),
        borderRadius: BorderRadius.circular(14),
      ),
      child: const Row(
        children: [
          Icon(Icons.lightbulb_outline, color: Color(0xFF51BA90), size: 30),
          SizedBox(width: 14),
          Expanded(
            child: Text(
              'Rinse food containers before recycling them.',
              style: TextStyle(
                fontSize: 14,
                color: Colors.black54,
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFD5EDE4),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF51BA90)),
            )
          : SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(22, 18, 22, 100),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Welcome back,',
                      style: TextStyle(
                        fontSize: 23,
                        fontWeight: FontWeight.w500,
                        color: Colors.black,
                      ),
                    ),
                    Text(
                      userDisplayName,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF51BA90),
                      ),
                    ),
                    const SizedBox(height: 22),

                    Row(
                      children: [
                        buildTopButton(
                          icon: Icons.local_shipping_outlined,
                          title: 'Pickup',
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const PickupPage(),
                              ),
                            );
                          },
                        ),
                        const SizedBox(width: 18),
                        buildTopButton(
                          icon: Icons.qr_code_scanner,
                          title: 'Show QR',
                          onTap: showQrDialog,
                        ),
                      ],
                    ),

                    const SizedBox(height: 30),

                    buildArticlesSection(),

                    const SizedBox(height: 30),

                    const Text(
                      'Tips of the day 🌱',
                      style: TextStyle(
                        fontSize: 21,
                        fontWeight: FontWeight.w800,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 14),

                    buildTipCard(),
                  ],
                ),
              ),
            ),
      bottomNavigationBar: const BottomNav(selectedIndex: 2),
    );
  }
}
