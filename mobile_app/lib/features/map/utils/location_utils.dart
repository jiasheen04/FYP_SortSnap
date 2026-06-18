import 'package:geolocator/geolocator.dart';
import 'package:mobile_app/features/map/models/recycling_point.dart';

class LocationUtils {
  static double calculateDistanceKm(
    double userLat,
    double userLng,
    RecyclingPoint point,
  ) {
    final meters = Geolocator.distanceBetween(
      userLat,
      userLng,
      point.latitude,
      point.longitude,
    );

    return meters / 1000;
  }

  static String formatDistance(double distanceKm) {
    if (distanceKm < 1) {
      final meters = (distanceKm * 1000).round();
      return '$meters m away';
    }
    return '${distanceKm.toStringAsFixed(1)} km away';
  }

  static bool matchesSearch(RecyclingPoint point, String query) {
    if (query.trim().isEmpty) return true;

    final lower = query.toLowerCase();

    return point.name.toLowerCase().contains(lower) ||
        point.address.toLowerCase().contains(lower) ||
        point.area.toLowerCase().contains(lower);
  }

  static bool matchesOpenFilter(RecyclingPoint point, bool openOnly) {
    if (!openOnly) return true;
    return point.isOpen;
  }

  static bool matchesDistanceFilter(
    RecyclingPoint point,
    Position? currentPosition,
    double? selectedDistanceKm,
  ) {
    if (currentPosition == null || selectedDistanceKm == null) {
      return true;
    }

    final distanceKm = calculateDistanceKm(
      currentPosition.latitude,
      currentPosition.longitude,
      point,
    );

    return distanceKm <= selectedDistanceKm;
  }
}