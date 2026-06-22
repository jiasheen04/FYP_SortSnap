import 'package:flutter/material.dart';

class DashboardSectionTitle extends StatelessWidget {
  final String title;
  final bool showSeeAll;
  final VoidCallback? onSeeAll;

  const DashboardSectionTitle({
    super.key,
    required this.title,
    this.showSeeAll = false,
    this.onSeeAll,
  });

  @override
  Widget build(BuildContext context) {
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
}
