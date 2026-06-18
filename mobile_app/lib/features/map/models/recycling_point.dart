class RecyclingPoint {
  final String id; // Firestore document ID
  final String pointCode; // Readable ID, e.g. RP001
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
    return RecyclingPoint(
      id: id,
      pointCode: data['pointCode'] ?? '',
      name: data['name'] ?? '',
      address: data['address'] ?? '',
      latitude: (data['latitude'] ?? 0).toDouble(),
      longitude: (data['longitude'] ?? 0).toDouble(),
      hours: data['hours'] ?? '',
      status: data['status'] ?? 'Unknown',
      isOpen: data['is_open'] ?? false,
      contact: data['contact'] ?? '',
      area: data['area'] ?? '',
      openingHours: Map<String, dynamic>.from(data['opening_hours'] ?? {}),
    );
  }
}