class User {
  final String id;
  final String username;
  final String phoneNumber;
  final String cni;
  final String? profileImage;

  User({
    required this.id,
    required this.username,
    required this.phoneNumber,
    required this.cni,
    this.profileImage,
  });

  // Conversion depuis et vers JSON pour utilisation avec API
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      username: json['username'],
      phoneNumber: json['phoneNumber'],
      cni: json['cni'],
      profileImage: json['profileImage'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'phoneNumber': phoneNumber,
      'cni': cni,
      'profileImage': profileImage,
    };
  }

  // Copie avec modification
  User copyWith({
    String? username,
    String? phoneNumber,
    String? cni,
    String? profileImage,
  }) {
    return User(
      id: this.id,
      username: username ?? this.username,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      cni: cni ?? this.cni,
      profileImage: profileImage ?? this.profileImage,
    );
  }
}
