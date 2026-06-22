import 'package:flutter/material.dart';
import 'package:mobile_app/features/dashboard/data/recycle_category_data.dart';
import 'package:mobile_app/features/dashboard/pages/recycle_items_page.dart';

class RecycleCategoriesPage extends StatefulWidget {
  final int initialTabIndex;

  const RecycleCategoriesPage({
    super.key,
    this.initialTabIndex = 0,
  });

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
      MaterialPageRoute(
        builder: (_) => RecycleCategoryItemsPage(
          category: category,
        ),
      ),
    );
  }

  Widget buildTabButton({
    required String title,
    required int index,
  }) {
    bool isSelected = selectedTabIndex == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedTabIndex = index;
        });
      },
      child: Column(
        children: [
          Text(
            title,
            style: TextStyle(
              color: isSelected ? const Color(0xFF51BA90) : Colors.black38,
              fontSize: 20,
              fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
            ),
          ),
          const SizedBox(height: 7),
          Container(
            width: 42,
            height: 4,
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFF51BA90) : Colors.transparent,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ],
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
            width: 104,
            height: 104,
            decoration: const BoxDecoration(
              color: Color(0xFFE3EA74),
              shape: BoxShape.circle,
            ),
            child: Icon(
              category.icon,
              color: const Color(0xFF51BA90),
              size: 50,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            category.name,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.black45,
              fontWeight: FontWeight.w600,
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
      backgroundColor: const Color(0xFFF7F7F7),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 18, 16, 0),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: const Icon(
                      Icons.arrow_back,
                      color: Colors.black,
                      size: 32,
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    'Recycle Categories',
                    style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.w800,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 34),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 34),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  buildTabButton(
                    title: 'Recyclable',
                    index: 0,
                  ),
                  buildTabButton(
                    title: 'Non-Recyclable',
                    index: 1,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 34),
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 22),
                itemCount: currentCategories.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisSpacing: 36,
                  crossAxisSpacing: 14,
                  childAspectRatio: 0.74,
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