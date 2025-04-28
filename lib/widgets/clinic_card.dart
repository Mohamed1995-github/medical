import 'package:flutter/material.dart';
import '../models/clinic.dart';

class ClinicCard extends StatelessWidget {
  final Clinic clinic;
  final VoidCallback onTap;

  const ClinicCard({
    super.key,
    required this.clinic,
    required this.onTap,
  });

  String _formatSpecialties(List<String> specialties) {
    if (specialties.isEmpty) {
      return 'General Services';
    }

    if (specialties.length <= 2) {
      return specialties.join(', ');
    }

    return '${specialties.take(2).join(', ')} +${specialties.length - 2} more';
  }

  String _formatOperatingHours(Map<String, dynamic> operatingHours) {
    final now = DateTime.now();
    final dayName = _getDayName(now.weekday);

    final hours = operatingHours[dayName];
    if (hours == null || hours['open'] == null || hours['open'].isEmpty) {
      return 'Closed Today';
    }

    return 'Today: ${hours['open']} - ${hours['close']}';
  }

  String _getDayName(int day) {
    const days = [
      'monday',
      'tuesday',
      'wednesday',
      'thursday',
      'friday',
      'saturday',
      'sunday'
    ];
    return days[day - 1];
  }

  bool _isOpenNow(Map<String, dynamic> operatingHours) {
    final now = DateTime.now();
    final dayName = _getDayName(now.weekday);

    final hours = operatingHours[dayName];
    if (hours == null || hours['open'] == null || hours['open'].isEmpty) {
      return false;
    }

    final openTime =
        TimeOfDay.fromDateTime(DateTime.parse('2023-01-01 ${hours['open']}'));
    final closeTime =
        TimeOfDay.fromDateTime(DateTime.parse('2023-01-01 ${hours['close']}'));

    return now.isAfter(DateTime(
            now.year, now.month, now.day, openTime.hour, openTime.minute)) &&
        now.isBefore(DateTime(
            now.year, now.month, now.day, closeTime.hour, closeTime.minute));
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        onTap: onTap,
        title: Text(clinic.name),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(_formatSpecialties(
                clinic.specialties.map((s) => s.toString()).toList())),
            Text(_formatOperatingHours(clinic.operatingHours)),
          ],
        ),
        trailing: _isOpenNow(clinic.operatingHours)
            ? const Chip(label: Text('Open'))
            : const Chip(label: Text('Closed')),
      ),
    );
  }
}
