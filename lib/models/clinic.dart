class Clinic {
  final String id;
  final String name;
  final String address;
  final String phoneNumber;
  final String? imageUrl;
  final double rating;
  final List<String> services;
  final Map<String, dynamic> schedule;

  Clinic({
    required this.id,
    required this.name,
    required this.address,
    required this.phoneNumber,
    this.imageUrl,
    required this.rating,
    required this.services,
    required this.schedule,
  });

  // Conversion depuis et vers JSON pour utilisation avec API
  factory Clinic.fromJson(Map<String, dynamic> json) {
    return Clinic(
      id: json['id'],
      name: json['name'],
      address: json['address'],
      phoneNumber: json['phoneNumber'],
      imageUrl: json['imageUrl'],
      rating: json['rating'].toDouble(),
      services: List<String>.from(json['services']),
      schedule: Map<String, dynamic>.from(json['schedule']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'phoneNumber': phoneNumber,
      'imageUrl': imageUrl,
      'rating': rating,
      'services': services,
      'schedule': schedule,
    };
  }
}
