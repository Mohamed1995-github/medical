class Physician {
  final int id;
  final String name;
  final String specialty;
  Physician({required this.id, required this.name, required this.specialty});
  factory Physician.fromJson(Map<String, dynamic> json) => Physician(
        id: json['id'] as int,
        name: json['name'] as String,
        specialty: json['specialty'] as String,
      );
}
