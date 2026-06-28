class RecyclingPoint {
  final String id;
  final String pointCode;
  final String name;
  final String address;
  final double latitude;
  final double longitude;
  final String hours;
  final String status;
  final bool isOpen;
  final String contact;
  final String area;
  final Map<String, dynamic> openingHours;

  RecyclingPoint({
    required this.id,
    required this.pointCode,
    required this.name,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.hours,
    required this.status,
    required this.isOpen,
    required this.contact,
    required this.area,
    required this.openingHours,
  });

  factory RecyclingPoint.fromFirestore(String id, Map<String, dynamic> data) {
    final Map<String, dynamic> openingHoursData =
        Map<String, dynamic>.from(data['opening_hours'] ?? {});

    final bool openNow = _checkOpenNow(
      data['status'] ?? 'Unknown',
      data['is_open'] ?? false,
      openingHoursData,
    );

    return RecyclingPoint(
      id: id,
      pointCode: data['pointCode'] ?? '',
      name: data['name'] ?? '',
      address: data['address'] ?? '',
      latitude: (data['latitude'] ?? 0).toDouble(),
      longitude: (data['longitude'] ?? 0).toDouble(),
      hours: data['hours'] ?? '',
      status: openNow ? 'Open' : 'Closed',
      isOpen: openNow,
      contact: data['contact'] ?? '',
      area: data['area'] ?? '',
      openingHours: openingHoursData,
    );
  }

  static bool _checkOpenNow(
    String firebaseStatus,
    bool firebaseIsOpen,
    Map<String, dynamic> openingHours,
  ) {
    if (firebaseStatus == 'Closed') {
      return false;
    }

    if (openingHours.isEmpty) {
      return firebaseIsOpen;
    }

    final String todayKey = _getTodayKey();
    final String todayHours = (openingHours[todayKey] ?? '').toString();

    if (todayHours.trim().isEmpty) {
      return firebaseIsOpen;
    }

    if (todayHours.toLowerCase().contains('closed')) {
      return false;
    }

    return _isCurrentTimeInside(todayHours);
  }

  static String _getTodayKey() {
    final int weekday = DateTime.now().weekday;

    if (weekday == DateTime.monday) return 'monday';
    if (weekday == DateTime.tuesday) return 'tuesday';
    if (weekday == DateTime.wednesday) return 'wednesday';
    if (weekday == DateTime.thursday) return 'thursday';
    if (weekday == DateTime.friday) return 'friday';
    if (weekday == DateTime.saturday) return 'saturday';

    return 'sunday';
  }

  static bool _isCurrentTimeInside(String hoursText) {
    final DateTime now = DateTime.now();
    final List<String> timeRanges = hoursText.split(',');

    for (String range in timeRanges) {
      final List<String> times = range.split('-');

      if (times.length != 2) {
        continue;
      }

      final DateTime? startTime = _convertToTodayTime(times[0].trim());
      DateTime? endTime = _convertToTodayTime(times[1].trim());

      if (startTime == null || endTime == null) {
        continue;
      }

      if (endTime.isBefore(startTime)) {
        endTime = endTime.add(const Duration(days: 1));
      }

      final bool afterStart =
          now.isAfter(startTime) || now.isAtSameMomentAs(startTime);
      final bool beforeEnd =
          now.isBefore(endTime) || now.isAtSameMomentAs(endTime);

      if (afterStart && beforeEnd) {
        return true;
      }
    }

    return false;
  }

  static DateTime? _convertToTodayTime(String timeText) {
    final RegExp regExp = RegExp(
      r'^(\d{1,2})(?::(\d{2}))?\s*(AM|PM)$',
      caseSensitive: false,
    );

    final Match? match = regExp.firstMatch(timeText.trim());

    if (match == null) {
      return null;
    }

    int hour = int.parse(match.group(1)!);
    int minute = int.parse(match.group(2) ?? '0');
    final String period = match.group(3)!.toUpperCase();

    if (period == 'PM' && hour != 12) {
      hour += 12;
    }

    if (period == 'AM' && hour == 12) {
      hour = 0;
    }

    final DateTime now = DateTime.now();

    return DateTime(
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );
  }
}