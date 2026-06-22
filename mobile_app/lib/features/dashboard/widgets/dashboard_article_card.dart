import 'package:flutter/material.dart';
import 'package:mobile_app/features/community/models/article.dart';

class DashboardArticleCard extends StatelessWidget {
  final Article article;
  final VoidCallback onTap;

  const DashboardArticleCard({
    super.key,
    required this.article,
    required this.onTap,
  });

  Widget _buildImage() {
    if (article.imagePath.isEmpty) {
      return Container(
        height: 110,
        width: double.infinity,
        color: const Color(0xFFE8F8F0),
        child: const Icon(
          Icons.article_outlined,
          color: Color(0xFF51BA90),
          size: 40,
        ),
      );
    }

    return Image.asset(
      article.imagePath,
      width: double.infinity,
      height: 110,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          height: 110,
          width: double.infinity,
          color: const Color(0xFFE8F8F0),
          child: const Icon(
            Icons.article_outlined,
            color: Color(0xFF51BA90),
            size: 40,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
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
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: _buildImage(),
            ),
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
          ],
        ),
      ),
    );
  }
}
