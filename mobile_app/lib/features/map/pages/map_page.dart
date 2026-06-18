import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mobile_app/core/widgets/bottom_nav.dart';
import 'package:mobile_app/features/map/models/recycling_point.dart';
import 'package:mobile_app/features/map/pages/location_detail_page.dart';
import 'package:mobile_app/features/map/pages/location_list_page.dart';
import 'package:mobile_app/features/map/services/recycling_point_service.dart';
import 'package:mobile_app/features/map/widgets/map_location_card.dart';
import 'package:mobile_app/features/map/pages/location_report_page.dart';
import 'package:url_launcher/url_launcher.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  static const LatLng defaultCenter = LatLng(2.9213, 101.6559);

  final RecyclingPointService _recyclingPointService = RecyclingPointService();

  GoogleMapController? mapController;
  final Set<Marker> _markers = {};

  bool _isLoading = true;
  List<RecyclingPoint> _points = [];
  RecyclingPoint? _selectedPoint;
  Position? _currentPosition;

  @override
  void initState() {
    super.initState();
    _initializePage();
  }

  Future<void> _initializePage() async {
    await _getCurrentLocation();
    await _loadRecyclingPoints();
  }

  Future<void> _getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return;

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      setState(() {
        _currentPosition = position;
      });
    } catch (e) {
      debugPrint('Location error: $e');
    }
  }

  Future<void> _loadRecyclingPoints() async {
    try {
      final points = await _recyclingPointService.getRecyclingPoints();

      final markers = points.map((point) {
        return Marker(
          markerId: MarkerId(point.id),
          position: LatLng(point.latitude, point.longitude),
          infoWindow: InfoWindow(title: point.name, snippet: point.address),
          onTap: () {
            setState(() {
              _selectedPoint = point;
            });
          },
        );
      }).toSet();

      setState(() {
        _points = points;
        _markers
          ..clear()
          ..addAll(markers);
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading recycling points: $e');
      setState(() {
        _isLoading = false;
      });
    }
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

  Future<void> _openMapSearchDialog() async {
    final TextEditingController controller = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Search Location'),
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration: const InputDecoration(
              hintText: 'Search by name, address, or area',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final query = controller.text.trim().toLowerCase();

                final results = _points.where((point) {
                  return point.name.toLowerCase().contains(query) ||
                      point.address.toLowerCase().contains(query) ||
                      point.area.toLowerCase().contains(query);
                }).toList();

                if (results.isNotEmpty && mapController != null) {
                  mapController!.animateCamera(
                    CameraUpdate.newLatLngZoom(
                      LatLng(results.first.latitude, results.first.longitude),
                      13,
                    ),
                  );

                  setState(() {
                    _selectedPoint = results.first;
                  });
                }

                Navigator.pop(context);
              },
              child: const Text('Search'),
            ),
          ],
        );
      },
    );
  }

  void _openListPage() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => LocationListPage(
          points: _points,
          currentPosition: _currentPosition,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF62C49D),
      appBar: AppBar(
        backgroundColor: const Color(0xFF62C49D),
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Map View',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.white))
          : Stack(
              children: [
                GoogleMap(
                  initialCameraPosition: const CameraPosition(
                    target: defaultCenter,
                    zoom: 11.8,
                  ),
                  onMapCreated: (controller) {
                    mapController = controller;
                  },
                  markers: _markers,
                  myLocationEnabled: _currentPosition != null,
                  myLocationButtonEnabled: true,
                  onTap: (_) {
                    setState(() {
                      _selectedPoint = null;
                    });
                  },
                ),
                Positioned(
                  top: 14,
                  left: 16,
                  child: GestureDetector(
                    onTap: _openListPage,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF62C49D),
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 4,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Row(
                        children: [
                          Icon(
                            Icons.format_list_bulleted,
                            color: Colors.white,
                            size: 18,
                          ),
                          SizedBox(width: 6),
                          Text(
                            'List View',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  right: 16,
                  bottom: 120,
                  child: FloatingActionButton(
                    heroTag: 'map_search_btn',
                    backgroundColor: const Color(0xFF62C49D),
                    onPressed: _openMapSearchDialog,
                    child: const Icon(Icons.search, color: Colors.white),
                  ),
                ),
                if (_selectedPoint != null)
                  Positioned(
                    left: 16,
                    right: 16,
                    bottom: 16,
                    child: MapLocationCard(
                      point: _selectedPoint!,
                      onReport: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => LocationReportPage(
                              recyclingPoint: _selectedPoint!,
                            ),
                          ),
                        );
                      },
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                LocationDetailPage(point: _selectedPoint!),
                          ),
                        );
                      },
                      onCall: () => _launchPhoneCall(_selectedPoint!.contact),
                      onNavigate: () => _launchNavigation(_selectedPoint!),
                    ),
                  ),
              ],
            ),
      bottomNavigationBar: const BottomNav(selectedIndex: 1),
    );
  }
}
