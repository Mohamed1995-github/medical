class User {
  final String id;
  final String name;
  final String phoneNumber;
  final String cniNumber;

  User({
    required this.id,
    required this.name,
    required this.phoneNumber,
    required this.cniNumber,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      name: json['name'] as String,
      phoneNumber: json['phoneNumber'] as String,
      cniNumber: json['cniNumber'] as String,
    );
  }
}
