import 'package:flutter/material.dart';
import 'package:mobile_app/features/map/models/recycling_point.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:mobile_app/features/map/pages/location_report_page.dart';

class LocationDetailPage extends StatelessWidget {
  final RecyclingPoint point;

  const LocationDetailPage({super.key, required this.point});

  Future<void> _launchPhoneCall(BuildContext context) async {
    if (point.contact.isEmpty) return;

    final Uri phoneUri = Uri(scheme: 'tel', path: point.contact);

    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    }
  }

  Future<void> _launchNavigation(BuildContext context) async {
    final Uri mapsUri = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=${point.latitude},${point.longitude}',
    );

    if (await canLaunchUrl(mapsUri)) {
      await launchUrl(mapsUri, mode: LaunchMode.externalApplication);
    }
  }

  Widget _buildInfoBox(String title, String value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: const Color(0xFFA7DCC8),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 11, color: Colors.white),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(fontSize: 11, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool openNow = point.isOpen;

    return Scaffold(
      backgroundColor: const Color(0xFFDDF2EA),
      appBar: AppBar(
        backgroundColor: const Color(0xFF62C49D),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Location Detail',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: openNow
                      ? const Color(0xFFA7E1C8)
                      : const Color(0xFFD9D9D9),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Status: ${point.status}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                point.name,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInfoBox('Address', point.address),
                  const SizedBox(width: 10),
                  _buildInfoBox('Operation hour', point.hours),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () => _launchPhoneCall(context),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFA7E1C8),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.call, color: Colors.white, size: 18),
                            SizedBox(width: 6),
                            Text(
                              'Call',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: InkWell(
                      onTap: () => _launchNavigation(context),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFA7E1C8),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.navigation,
                              color: Colors.white,
                              size: 18,
                            ),
                            SizedBox(width: 6),
                            Text(
                              'Go Now',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const Text(
                'Weekly Opening Hours',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 12),
              ...point.openingHours.entries.map(
                (entry) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 90,
                        child: Text(
                          entry.key[0].toUpperCase() + entry.key.substring(1),
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                      Expanded(child: Text(entry.value.toString())),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              if (point.contact.isNotEmpty)
                Text(
                  'Contact: ${point.contact}',
                  style: const TextStyle(fontSize: 14),
                ),
              const SizedBox(height: 8),
              Text('Area: ${point.area}', style: const TextStyle(fontSize: 14)),

              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 46,
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            LocationReportPage(recyclingPoint: point),
                      ),
                    );
                  },
                  icon: const Icon(Icons.report_problem_outlined),
                  label: const Text('Report Location Issue'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF62C49D),
                    side: const BorderSide(color: Color(0xFF62C49D)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
