// lib/models/clinic.dart

import 'dart:convert';
import 'dart:typed_data';

class Clinic {
  final int id;
  final String name;
  final String address;
  final List<String> services;
  final Map<String, dynamic> schedule;

  /// Si l’API renvoie un vrai URL, on le met ici ; sinon null
  final String? imageUrl;

  /// Le payload base64 retourné sous "image"
  final String? imageBase64;

  Clinic({
    required this.id,
    required this.name,
    required this.address,
    required this.services,
    required this.schedule,
    this.imageUrl,
    this.imageBase64,
  });

  factory Clinic.fromJson(Map<String, dynamic> json) {
    return Clinic(
      id: json['id'] as int,
      name: (json['name'] as String?) ?? 'Clinique sans nom',
      address: (json['address'] as String?) ?? 'Adresse non renseignée',
      services: json['services'] is List
          ? List<String>.from(json['services'] as List)
          : <String>[],
      schedule: json['schedule'] is Map
          ? Map<String, dynamic>.from(json['schedule'] as Map)
          : <String, dynamic>{},
      imageUrl: json['url'] is String ? json['url'] as String : null,
      imageBase64: json['image'] is String ? json['image'] as String : null,
    );
  }

  /// Retourne le contenu décodé en bytes pour Image.memory
  Uint8List? get imageBytes {
    if (imageBase64 == null) return null;
    try {
      return base64Decode(imageBase64!);
    } catch (_) {
      return null;
    }
  }
}
