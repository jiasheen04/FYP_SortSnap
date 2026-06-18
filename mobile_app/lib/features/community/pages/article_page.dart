import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:mobile_app/features/community/models/article.dart';

class ArticlePage extends StatelessWidget {
  final Article article;

  const ArticlePage({super.key, required this.article});

  Future<void> _openSource(BuildContext context) async {
    if (article.sourceUrl.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Source website is not available.')),
      );
      return;
    }

    try {
      final Uri url = Uri.parse(article.sourceUrl.trim());

      final bool launched = await launchUrl(
        url,
        mode: LaunchMode.externalApplication,
      );

      if (!launched) {
        if (!context.mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cannot open source website.')),
        );
      }
    } catch (e) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to open website: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFD5EDE4),
      appBar: AppBar(
        backgroundColor: const Color(0xFF62C49D),
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Article',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(18),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildArticleImage(),

              const SizedBox(height: 18),

              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F8F0),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  article.category,
                  style: const TextStyle(
                    color: Color(0xFF51BA90),
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ),

              const SizedBox(height: 14),

              Text(
                article.title,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1F1F1F),
                ),
              ),

              const SizedBox(height: 10),

              Text(
                article.summary,
                style: const TextStyle(
                  fontSize: 15,
                  height: 1.5,
                  color: Colors.black54,
                  fontWeight: FontWeight.w500,
                ),
              ),

              const SizedBox(height: 18),

              Text(
                article.content,
                style: const TextStyle(
                  fontSize: 15,
                  height: 1.6,
                  color: Color(0xFF2F2F2F),
                ),
              ),

              const SizedBox(height: 24),

              const Text(
                'Source',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1F1F1F),
                ),
              ),

              const SizedBox(height: 8),

              Text(
                article.sourceName,
                style: const TextStyle(
                  fontSize: 13,
                  height: 1.4,
                  color: Colors.black54,
                ),
              ),

              const SizedBox(height: 14),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _openSource(context),
                  icon: const Icon(Icons.open_in_new),
                  label: const Text('View Source Website'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF62C49D),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildArticleImage() {
    if (article.imagePath.isEmpty) {
      return _buildImagePlaceholder();
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: Image.asset(
        article.imagePath,
        width: double.infinity,
        height: 170,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return _buildImagePlaceholder();
        },
      ),
    );
  }

  Widget _buildImagePlaceholder() {
    return Container(
      width: double.infinity,
      height: 170,
      decoration: BoxDecoration(
        color: const Color(0xFFE8F8F0),
        borderRadius: BorderRadius.circular(14),
      ),
      child: const Icon(
        Icons.article_outlined,
        color: Color(0xFF51BA90),
        size: 58,
      ),
    );
  }
}
