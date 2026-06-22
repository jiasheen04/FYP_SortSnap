import 'package:flutter/material.dart';
import 'package:mobile_app/features/dashboard/data/recycle_category_data.dart';
import 'package:mobile_app/features/dashboard/pages/recycle_items_page.dart';

class RecycleCategoriesPage extends StatefulWidget {
  final int initialTabIndex;

  const RecycleCategoriesPage({super.key, this.initialTabIndex = 0});

  @override
  State<RecycleCategoriesPage> createState() => _RecycleCategoriesPageState();
}

class _RecycleCategoriesPageState extends State<RecycleCategoriesPage> {
  late int selectedTabIndex;

  @override
  void initState() {
    super.initState();
    selectedTabIndex = widget.initialTabIndex;
  }

  List<RecycleCategory> get currentCategories {
    if (selectedTabIndex == 0) {
      return RecycleCategoryData.recyclableCategories;
    } else {
      return RecycleCategoryData.nonRecyclableCategories;
    }
  }

  void openCategoryItems(RecycleCategory category) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => RecycleItemsPage(category: category)),
    );
  }

  Widget buildTabButton({required String title, required int index}) {
    bool isSelected = selectedTabIndex == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedTabIndex = index;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ]
              : [],
        ),
        child: Column(
          children: [
            Text(
              title,
              style: TextStyle(
                color: isSelected ? const Color(0xFF51BA90) : Colors.black38,
                fontSize: 15,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
            const SizedBox(height: 5),
            Container(
              width: 28,
              height: 3,
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFF51BA90)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildCategoryCard(RecycleCategory category) {
    return GestureDetector(
      onTap: () {
        openCategoryItems(category);
      },
      child: Column(
        children: [
          Container(
            width: 82,
            height: 82,
            decoration: BoxDecoration(
              color: const Color(0xFF96D8BE),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 7,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: ClipOval(
              child: Image.asset(
                category.imagePath,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Icon(category.icon, color: Colors.white, size: 38);
                },
              ),
            ),
          ),
          const SizedBox(height: 9),
          Text(
            category.name,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 13,
              color: Colors.black54,
              fontWeight: FontWeight.w500,
              height: 1.2,
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
                  const Text(
                    'Recycle Categories',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Color.fromARGB(221, 254, 254, 254),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 22),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 22),
              child: Row(
                children: [
                  Expanded(
                    child: buildTabButton(title: 'Recyclable', index: 0),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: buildTabButton(title: 'Special Handling', index: 1),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
                itemCount: currentCategories.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisSpacing: 26,
                  crossAxisSpacing: 18,
                  childAspectRatio: 0.78,
                ),
                itemBuilder: (context, index) {
                  return buildCategoryCard(currentCategories[index]);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
