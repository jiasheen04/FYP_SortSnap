import 'package:flutter/material.dart';
import 'package:mobile_app/app/routes.dart';

class BottomNav extends StatelessWidget {
  final int selectedIndex;

  const BottomNav({super.key, required this.selectedIndex});

  void goToPage(BuildContext context, int index) {
    if (index == selectedIndex) return;

    if (index == 0) {
      Navigator.pushReplacementNamed(context, AppRoutes.community);
    } else if (index == 1) {
      Navigator.pushReplacementNamed(context, AppRoutes.map);
    } else if (index == 2) {
      Navigator.pushReplacementNamed(context, AppRoutes.dashboard);
    } else if (index == 3) {
      Navigator.pushReplacementNamed(context, AppRoutes.chatbot);
    } else if (index == 4) {
      Navigator.pushReplacementNamed(context, AppRoutes.profile);
    }
  }

  Widget buildNavItem({
    required BuildContext context,
    required IconData icon,
    required int index,
  }) {
    final bool isSelected = selectedIndex == index;

    return GestureDetector(
      onTap: () {
        goToPage(context, index);
      },
      child: Container(
        width: 55,
        height: 55,
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF7ECFB0).withValues(alpha: 0.35)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Icon(icon, color: Colors.white, size: 27),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: SizedBox(
        height: 68,
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.bottomCenter,
          children: [
            Positioned(
              bottom: 0,
              left: 10,
              right: 10,
              child: Container(
                height: 62,
                decoration: BoxDecoration(
                  color: const Color(0xFF51BA90),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.10),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    buildNavItem(
                      context: context,
                      icon: Icons.groups_outlined,
                      index: 0,
                    ),
                    buildNavItem(
                      context: context,
                      icon: Icons.map_outlined,
                      index: 1,
                    ),

                    // Empty space for center home circle
                    const SizedBox(width: 72),

                    buildNavItem(
                      context: context,
                      icon: Icons.smart_toy_outlined,
                      index: 3,
                    ),
                    buildNavItem(
                      context: context,
                      icon: Icons.person_outline,
                      index: 4,
                    ),
                  ],
                ),
              ),
            ),

            // Center Home Button
            Positioned(
              bottom: 4,
              child: GestureDetector(
                onTap: () {
                  goToPage(context, 2);
                },
                child: Container(
                  width: 58,
                  height: 58,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.12),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Container(
                    margin: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFF51BA90),
                      border: Border.all(
                        color: const Color(0xFF7ECFB0),
                        width: 1.5,
                      ),
                    ),
                    child: const Icon(
                      Icons.home_outlined,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
