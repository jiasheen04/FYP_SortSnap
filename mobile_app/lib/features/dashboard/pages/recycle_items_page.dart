import 'package:flutter/material.dart';
import 'package:mobile_app/features/dashboard/data/recycle_category_data.dart';

class RecycleCategoryItemsPage extends StatelessWidget {
  final RecycleCategory category;

  const RecycleCategoryItemsPage({
    super.key,
    required this.category,
  });

  Widget buildItemCard(String item) {
    return Column(
      children: [
        Container(
          width: 92,
          height: 92,
          decoration: const BoxDecoration(
            color: Color(0xFFE3EA74),
            shape: BoxShape.circle,
          ),
          child: Icon(
            category.icon,
            color: const Color(0xFF51BA90),
            size: 42,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          item,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.black45,
            fontSize: 15,
            fontWeight: FontWeight.w500,
            height: 1.25,
          ),
        ),
      ],
    );
  }

  String getPageSubtitle() {
    if (category.isRecyclable) {
      return 'Clean and dry items before recycling.';
    } else {
      return 'These items need separate handling or general disposal.';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: const Icon(
                      Icons.arrow_back,
                      color: Colors.black,
                      size: 30,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      category.name,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(28, 8, 28, 0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  getPageSubtitle(),
                  style: const TextStyle(
                    color: Colors.black38,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 28),
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 22),
                itemCount: category.items.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisSpacing: 32,
                  crossAxisSpacing: 14,
                  childAspectRatio: 0.70,
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