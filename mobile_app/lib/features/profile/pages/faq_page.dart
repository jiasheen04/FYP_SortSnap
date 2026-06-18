import 'package:flutter/material.dart';
import 'package:mobile_app/features/profile/models/faq_item.dart';
import 'package:mobile_app/features/profile/services/faq_service.dart';

class FaqPage extends StatefulWidget {
  const FaqPage({super.key});

  @override
  State<FaqPage> createState() => _FaqPageState();
}

class _FaqPageState extends State<FaqPage> {
  final FaqService _faqService = FaqService();

  bool _isLoading = true;
  String selectedCategory = 'All';
  String searchText = '';

  List<FaqItem> _faqList = [];

  @override
  void initState() {
    super.initState();
    _loadFaqs();
  }

  Future<void> _loadFaqs() async {
    try {
      final faqs = await _faqService.getFaqs();

      if (!mounted) return;

      setState(() {
        _faqList = faqs;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });
    }
  }

  List<String> get categories {
    final faqCategories = _faqList.map((faq) => faq.category).toSet().toList();
    faqCategories.sort();

    return ['All', ...faqCategories];
  }

  List<FaqItem> get filteredFaq {
    return _faqList.where((faq) {
      final matchCategory =
          selectedCategory == 'All' || faq.category == selectedCategory;

      final question = faq.question.toLowerCase();
      final answer = faq.answer.toLowerCase();
      final search = searchText.toLowerCase();

      final matchSearch =
          search.isEmpty ||
          question.contains(search) ||
          answer.contains(search);

      return matchCategory && matchSearch;
    }).toList();
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'General':
        return Icons.info_outline;
      case 'Chatbot':
        return Icons.smart_toy_outlined;
      case 'Image':
        return Icons.image_outlined;
      case 'Map':
        return Icons.location_on_outlined;
      case 'Education':
        return Icons.school_outlined;
      case 'Pickup':
        return Icons.local_shipping_outlined;
      case 'Privacy':
        return Icons.lock_outline;
      default:
        return Icons.help_outline;
    }
  }

  Widget _buildSearchBox() {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 18, 20, 12),
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFB9E5D2)),
      ),
      child: TextField(
        onChanged: (value) {
          setState(() {
            searchText = value;
          });
        },
        decoration: const InputDecoration(
          icon: Icon(Icons.search, color: Color(0xFF51BA90)),
          hintText: 'Search FAQ',
          hintStyle: TextStyle(color: Colors.black38, fontSize: 14),
          border: InputBorder.none,
        ),
      ),
    );
  }

  Widget _buildCategoryChips() {
    return SizedBox(
      height: 42,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          final isSelected = selectedCategory == category;

          return GestureDetector(
            onTap: () {
              setState(() {
                selectedCategory = category;
              });
            },
            child: Container(
              margin: const EdgeInsets.only(right: 10),
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 9),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFF51BA90) : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFF51BA90)),
              ),
              child: Text(
                category,
                style: TextStyle(
                  color: isSelected ? Colors.white : const Color(0xFF51BA90),
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFaqCard(FaqItem faq) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFB9E5D2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Theme(
        data: ThemeData().copyWith(
          dividerColor: Colors.transparent,
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
        ),
        child: ExpansionTile(
          shape: const Border(),
          collapsedShape: const Border(),
          tilePadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
          childrenPadding: const EdgeInsets.fromLTRB(18, 0, 18, 18),

          trailing: const Icon(
            Icons.keyboard_arrow_down_rounded,
            color: Color(0xFF3F7D5A),
          ),

          title: Text(
            faq.question,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Color(0xFF222222),
            ),
          ),

          iconColor: const Color(0xFF3F7D5A),
          collapsedIconColor: const Color(0xFF3F7D5A),

          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                faq.answer,
                style: const TextStyle(
                  fontSize: 15,
                  height: 1.45,
                  color: Color(0xFF333333),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyResult() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.only(top: 70),
        child: Column(
          children: [
            Icon(Icons.search_off, size: 48, color: Color(0xFF51BA90)),
            SizedBox(height: 10),
            Text(
              'No FAQ found',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
            SizedBox(height: 5),
            Text(
              'Try searching another keyword.',
              style: TextStyle(fontSize: 13, color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final faqs = filteredFaq;

    return Scaffold(
      backgroundColor: const Color(0xFFD5EDE4),
      appBar: AppBar(
        backgroundColor: const Color(0xFF62C49D),
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'FAQ',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 16,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF51BA90)),
            )
          : Column(
              children: [
                _buildSearchBox(),
                _buildCategoryChips(),
                const SizedBox(height: 14),
                Expanded(
                  child: faqs.isEmpty
                      ? _buildEmptyResult()
                      : RefreshIndicator(
                          color: const Color(0xFF51BA90),
                          onRefresh: _loadFaqs,
                          child: ListView.builder(
                            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                            itemCount: faqs.length,
                            itemBuilder: (context, index) {
                              return _buildFaqCard(faqs[index]);
                            },
                          ),
                        ),
                ),
              ],
            ),
    );
  }
}
