enum AppointmentStatus {
  pending,
  confirmed,
  completed,
  cancelled,
}

class Appointment {
  final String id;
  final String userId;
  final String clinicId;
  final DateTime date;
  final String time;
  final String service;
  final AppointmentStatus status;
  final bool isPaid;
  final double amount;
  final DateTime createdAt;

  Appointment({
    required this.id,
    required this.userId,
    required this.clinicId,
    required this.date,
    required this.time,
    required this.service,
    required this.status,
    required this.isPaid,
    required this.amount,
    required this.createdAt,
  });

  // Conversion depuis et vers JSON pour utilisation avec API
  factory Appointment.fromJson(Map<String, dynamic> json) {
    return Appointment(
      id: json['id'],
      userId: json['userId'],
      clinicId: json['clinicId'],
      date: DateTime.parse(json['date']),
      time: json['time'],
      service: json['service'],
      status: AppointmentStatus.values.firstWhere(
        (e) => e.toString() == 'AppointmentStatus.${json['status']}',
        orElse: () => AppointmentStatus.pending,
      ),
      isPaid: json['isPaid'],
      amount: json['amount'].toDouble(),
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'clinicId': clinicId,
      'date': date.toIso8601String(),
      'time': time,
      'service': service,
      'status': status.toString().split('.').last,
      'isPaid': isPaid,
      'amount': amount,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  // Copie avec modification
  Appointment copyWith({
    String? id,
    String? userId,
    String? clinicId,
    DateTime? date,
    String? time,
    String? service,
    AppointmentStatus? status,
    bool? isPaid,
    double? amount,
    DateTime? createdAt,
  }) {
    return Appointment(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      clinicId: clinicId ?? this.clinicId,
      date: date ?? this.date,
      time: time ?? this.time,
      service: service ?? this.service,
      status: status ?? this.status,
      isPaid: isPaid ?? this.isPaid,
      amount: amount ?? this.amount,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
