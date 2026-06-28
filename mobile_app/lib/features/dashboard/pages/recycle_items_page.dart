import 'package:flutter/material.dart';
import 'package:mobile_app/features/dashboard/data/recycle_category_data.dart';
import 'package:mobile_app/features/dashboard/pages/recycle_item_detail_page.dart';

class RecycleItemsPage extends StatelessWidget {
  final RecycleCategory category;

  const RecycleItemsPage({super.key, required this.category});

  String getPageSubtitle() {
    if (category.isRecyclable) {
      return 'Press an item to view recycling guidance based on Trashpedia.';
    } else {
      return 'Press an item to view disposal guidance based on Trashpedia.';
    }
  }

  void openItemDetail(BuildContext context, String item) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => RecycleItemDetailPage(
          itemName: item,
          imagePath: category.getItemImagePath(item),
          icon: category.icon,
          isRecyclable: category.isRecyclable,
        ),
      ),
    );
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
        child: imagePath.isNotEmpty
            ? Image.asset(
                imagePath,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return Icon(
                    category.icon,
                    color: const Color(0xFF51BA90),
                    size: 32,
                  );
                },
              )
            : Icon(
                category.icon,
                color: const Color(0xFF51BA90),
                size: 32,
              ),
      ),
    );
  }

  Widget buildItemCard(BuildContext context, String item) {
    return GestureDetector(
      onTap: () {
        openItemDetail(context, item);
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.92),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
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
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFD5EDE4),
      appBar: AppBar(
        backgroundColor: const Color(0xFF51BA90),
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.white,
            size: 29,
          ),
        ),
        title: Text(
          category.name,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(28, 24, 28, 0),
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
                return buildItemCard(context, category.items[index]);
              },
            ),
          ),
        ],
      ),
    );
  }
}