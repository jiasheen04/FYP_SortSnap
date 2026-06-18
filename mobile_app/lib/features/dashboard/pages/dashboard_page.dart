import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mobile_app/core/widgets/bottom_nav.dart';
import 'package:mobile_app/features/pickup/pages/pickup_page.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  String userDisplayName = '';
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadUserData();
  }

  Future<void> loadUserData() async {
    try {
      User? currentUser = FirebaseAuth.instance.currentUser;

      if (currentUser != null) {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser.uid)
            .get();

        if (userDoc.exists) {
          setState(() {
            userDisplayName = userDoc['firstName'] ?? 'User';
            isLoading = false;
          });
        } else {
          setState(() {
            userDisplayName = 'User';
            isLoading = false;
          });
        }
      } else {
        setState(() {
          userDisplayName = 'User';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        userDisplayName = 'User';
        isLoading = false;
      });
    }
  }

  Widget _buildFeatureCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Color? iconColor,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: const Color(0xFFE8F8F0),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: iconColor ?? const Color(0xFF51BA90), size: 24),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.black54,
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
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Welcome back,',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    Text(
                      userDisplayName,
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF51BA90),
                      ),
                    ),
                    const SizedBox(height: 25),

                    // Quick action buttons
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const PickupPage(),
                                ),
                              );
                            },
                            icon: const Icon(Icons.local_shipping_outlined, size: 20),
                            label: const Text('Pickup'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF96D8BE),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 18),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              _showQrDialog();
                            },
                            icon: const Icon(Icons.qr_code, size: 20),
                            label: const Text('Show QR'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF96D8BE),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 18),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 28),

                    // Features section
                    const Text(
                      'Explore Features',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 14),

                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      mainAxisSpacing: 14,
                      crossAxisSpacing: 14,
                      childAspectRatio: 1.1,
                      children: [
                        _buildFeatureCard(
                          icon: Icons.map_outlined,
                          title: 'Find Locations',
                          subtitle: 'Nearby recycling points',
                          onTap: () {
                            Navigator.pushReplacementNamed(context, '/map');
                          },
                        ),
                        _buildFeatureCard(
                          icon: Icons.smart_toy_outlined,
                          title: 'Ask Chatbot',
                          subtitle: 'Recycling guidance',
                          onTap: () {
                            Navigator.pushReplacementNamed(context, '/chatbot');
                          },
                        ),
                        _buildFeatureCard(
                          icon: Icons.quiz_outlined,
                          title: 'Challenges',
                          subtitle: 'Quiz & Flashcards',
                          onTap: () {
                            Navigator.pushReplacementNamed(context, '/community');
                          },
                        ),
                        _buildFeatureCard(
                          icon: Icons.camera_alt_outlined,
                          title: 'Scan Item',
                          subtitle: 'Image classification',
                          onTap: () {
                            Navigator.pushReplacementNamed(context, '/chatbot');
                          },
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Tips section
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF62C49D), Color(0xFF51BA90)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Recycling Tip',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Rinse food containers before recycling them. Clean items have a better chance of being recycled properly!',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
      bottomNavigationBar: const BottomNav(selectedIndex: 2),
    );
  }

  void _showQrDialog() {
    final currentUser = FirebaseAuth.instance.currentUser;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.qr_code_2, size: 120, color: Color(0xFF51BA90)),
            const SizedBox(height: 16),
            const Text(
              'Your SortSnap QR',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'User ID: ${currentUser?.uid.substring(0, 8) ?? 'N/A'}...',
              style: const TextStyle(fontSize: 13, color: Colors.black54),
            ),
            const SizedBox(height: 8),
            const Text(
              'Show this QR at recycling points for quick check-in.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: Colors.black54),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close', style: TextStyle(color: Color(0xFF51BA90))),
          ),
        ],
      ),
    );
  }
}
