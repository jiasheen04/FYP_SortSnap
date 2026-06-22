import 'package:flutter/material.dart';
import 'package:mobile_app/features/dashboard/data/recycle_category_data.dart';

class RecycleItemsPage extends StatelessWidget {
  final RecycleCategory category;

  const RecycleItemsPage({super.key, required this.category});

  String getPageSubtitle() {
    if (category.isRecyclable) {
      return 'Items listed based on Trashpedia 101 Trash. Clean and dry items before recycling when applicable.';
    } else {
      return 'Items listed based on Trashpedia 101 Trash. These items need special disposal guidance.';
    }
  }

  Widget buildImageBox(String item) {
    String imagePath = category.getItemImagePath(item);

    return Container(
      width: 76,
      height: 76,
      decoration: BoxDecoration(
        color: const Color(0xFFE8F8F0),
        borderRadius: BorderRadius.circular(14),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Image.asset(
          imagePath,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Icon(
              category.icon,
              color: const Color(0xFF51BA90),
              size: 30,
            );
          },
        ),
      ),
    );
  }

  Widget buildItemCard(String item) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 7,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          buildImageBox(item),
          const SizedBox(height: 12),
          Text(
            item,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.black54,
              fontSize: 13,
              fontWeight: FontWeight.w500,
              height: 1.25,
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
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 14, 18, 0),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: const Icon(
                      Icons.arrow_back,
                      color: Colors.black87,
                      size: 29,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      category.name,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(28, 10, 28, 0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  getPageSubtitle(),
                  style: const TextStyle(
                    color: Colors.black45,
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                    height: 1.35,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.fromLTRB(22, 0, 22, 22),
                itemCount: category.items.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 1.02,
                ),
                itemBuilder: (context, index) {
                  return buildItemCard(category.items[index]);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
