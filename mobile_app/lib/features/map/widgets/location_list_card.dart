import 'package:flutter/material.dart';
import 'package:mobile_app/features/map/models/recycling_point.dart';

class LocationListCard extends StatelessWidget {
  final RecyclingPoint point;
  final String? distanceText;
  final VoidCallback onTap;
  final VoidCallback onCall;
  final VoidCallback onNavigate;
  final VoidCallback? onReport;

  const LocationListCard({
    super.key,
    required this.point,
    required this.onTap,
    required this.onCall,
    required this.onNavigate,
    this.distanceText,
    this.onReport,
  });

  @override
  Widget build(BuildContext context) {
    final bool isNotAccepting = point.recyclingStatus == 'Not Accepting Items';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: point.isOpen
                              ? const Color(0xFFA7E1C8)
                              : const Color(0xFFD9D9D9),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'Status: ${point.status}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.black87,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: isNotAccepting
                              ? const Color(0xFFFFD6C9)
                              : const Color(0xFFA7E1C8),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'Recycling: ${point.recyclingStatus}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.black87,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                if (distanceText != null)
                  Text(
                    distanceText!,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF62C49D),
                    ),
                  ),
                const SizedBox(width: 8),
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_horiz, color: Color(0xFF8FD3BB)),
                  onSelected: (value) {
                    if (value == 'report') {
                      onReport?.call();
                    }
                  },
                  itemBuilder: (context) => const [
                    PopupMenuItem(value: 'report', child: Text('Report issue')),
                  ],
                ),
              ],
            ),

            if (isNotAccepting) ...[
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF0E8),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: const Color(0xFFFFB99F)),
                ),
                child: const Text(
                  'This recycling point is currently not accepting items. Please call before going.',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.black87,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],

            const SizedBox(height: 10),
            Text(
              point.name,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFA7DCC8),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      point.address,
                      style: const TextStyle(
                        fontSize: 11,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFA7DCC8),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'Operation hour: ${point.hours}',
                      style: const TextStyle(
                        fontSize: 11,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: onCall,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFA7E1C8),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.call, color: Colors.black87, size: 16),
                          SizedBox(width: 6),
                          Text('Call', style: TextStyle(color: Colors.black87)),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: GestureDetector(
                    onTap: onNavigate,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFA7E1C8),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.navigation,
                            color: Colors.black87,
                            size: 16,
                          ),
                          SizedBox(width: 6),
                          Text(
                            'Go Now',
                            style: TextStyle(color: Colors.black87),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
