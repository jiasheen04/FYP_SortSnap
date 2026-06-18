import 'package:flutter/material.dart';
import 'package:mobile_app/features/map/models/recycling_point.dart';
import 'package:mobile_app/features/map/pages/location_detail_page.dart';
import 'package:mobile_app/features/map/utils/location_utils.dart';
import 'package:mobile_app/features/map/widgets/location_filter_sheet.dart';
import 'package:mobile_app/features/map/widgets/location_list_card.dart';
import 'package:mobile_app/features/map/pages/location_report_page.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:geolocator/geolocator.dart';

class LocationListPage extends StatefulWidget {
  final List<RecyclingPoint> points;
  final Position? currentPosition;

  const LocationListPage({
    super.key,
    required this.points,
    required this.currentPosition,
  });

  @override
  State<LocationListPage> createState() => _LocationListPageState();
}

class _LocationListPageState extends State<LocationListPage> {
  final TextEditingController _searchController = TextEditingController();

  String _searchQuery = '';
  bool _showOpenOnly = false;
  double? _selectedDistanceKm;

  List<RecyclingPoint> get _filteredPoints {
    final filtered = widget.points.where((point) {
      final matchesSearch = LocationUtils.matchesSearch(point, _searchQuery);
      final matchesOpen = LocationUtils.matchesOpenFilter(point, _showOpenOnly);
      final matchesDistance = LocationUtils.matchesDistanceFilter(
        point,
        widget.currentPosition,
        _selectedDistanceKm,
      );

      return matchesSearch && matchesOpen && matchesDistance;
    }).toList();

    if (widget.currentPosition != null) {
      filtered.sort((a, b) {
        final distanceA = LocationUtils.calculateDistanceKm(
          widget.currentPosition!.latitude,
          widget.currentPosition!.longitude,
          a,
        );
        final distanceB = LocationUtils.calculateDistanceKm(
          widget.currentPosition!.latitude,
          widget.currentPosition!.longitude,
          b,
        );
        return distanceA.compareTo(distanceB);
      });
    }

    return filtered;
  }

  String? _getDistanceText(RecyclingPoint point) {
    if (widget.currentPosition == null) return null;

    final distanceKm = LocationUtils.calculateDistanceKm(
      widget.currentPosition!.latitude,
      widget.currentPosition!.longitude,
      point,
    );

    return LocationUtils.formatDistance(distanceKm);
  }

  Future<void> _launchPhoneCall(String contact) async {
    if (contact.isEmpty) return;

    final Uri phoneUri = Uri(scheme: 'tel', path: contact);

    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    }
  }

  Future<void> _launchNavigation(RecyclingPoint point) async {
    final Uri mapsUri = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=${point.latitude},${point.longitude}',
    );

    if (await canLaunchUrl(mapsUri)) {
      await launchUrl(mapsUri, mode: LaunchMode.externalApplication);
    }
  }

  void _openFilterSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return LocationFilterSheet(
          initialShowOpenOnly: _showOpenOnly,
          initialDistanceKm: _selectedDistanceKm,
          onOpenOnlyChanged: (value) {
            _showOpenOnly = value;
          },
          onDistanceChanged: (value) {
            _selectedDistanceKm = value;
          },
          onApply: () {
            setState(() {});
            Navigator.pop(context);
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFDDF2EA),
      body: Column(
        children: [
          Container(
            color: const Color(0xFF62C49D),
            padding: const EdgeInsets.fromLTRB(8, 8, 16, 12),
            child: SafeArea(
              bottom: false,
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                  ),
                  const Expanded(
                    child: Center(
                      child: Text(
                        'Location List',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    height: 42,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: TextField(
                      controller: _searchController,
                      onChanged: (value) {
                        setState(() {
                          _searchQuery = value.trim();
                        });
                      },
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        icon: Icon(Icons.search, color: Colors.grey),
                        hintText: 'Search',
                        hintStyle: TextStyle(color: Colors.grey),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                GestureDetector(
                  onTap: _openFilterSheet,
                  child: Container(
                    height: 42,
                    width: 42,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.tune, color: Colors.grey),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              itemCount: _filteredPoints.length,
              itemBuilder: (context, index) {
                final point = _filteredPoints[index];

                return LocationListCard(
                  point: point,
                  distanceText: _getDistanceText(point),
                  onReport: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            LocationReportPage(recyclingPoint: point),
                      ),
                    );
                  },
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => LocationDetailPage(point: point),
                      ),
                    );
                  },
                  onCall: () => _launchPhoneCall(point.contact),
                  onNavigate: () => _launchNavigation(point),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
