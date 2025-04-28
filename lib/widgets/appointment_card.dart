import 'package:flutter/material.dart';
import '../models/appointment.dart';

class AppointmentCard extends StatelessWidget {
  final Appointment appointment;
  final VoidCallback onTap;

  const AppointmentCard({
    super.key,
    required this.appointment,
    required this.onTap,
  });

  String _getStatusText(AppointmentStatus status) {
    switch (status) {
      case AppointmentStatus.pending:
        return 'Pending';
      case AppointmentStatus.confirmed:
        return 'Confirmed';
      case AppointmentStatus.cancelled:
        return 'Cancelled';
      case AppointmentStatus.completed:
        return 'Completed';
    }
  }

  Color _getStatusColor(AppointmentStatus status) {
    switch (status) {
      case AppointmentStatus.pending:
        return Colors.orange;
      case AppointmentStatus.confirmed:
        return Colors.green;
      case AppointmentStatus.cancelled:
        return Colors.red;
      case AppointmentStatus.completed:
        return Colors.blue;
    }
  }

  String _formatDateTime(DateTime dateTime) {
    final day = dateTime.day.toString().padLeft(2, '0');
    final month = dateTime.month.toString().padLeft(2, '0');
    final year = dateTime.year;
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');

    return '$day/$month/$year at $hour:$minute';
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title and Status Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // In a real app, we would fetch doctor and clinic names
                  const Text(
                    'Medical Appointment',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color:
                          _getStatusColor(appointment.status).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: _getStatusColor(appointment.status),
                      ),
                    ),
                    child: Text(
                      _getStatusText(appointment.status),
                      style: TextStyle(
                        color: _getStatusColor(appointment.status),
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Date Time Row
              Row(
                children: [
                  const Icon(Icons.access_time, size: 16, color: Colors.grey),
                  const SizedBox(width: 8),
                  Text(
                    _formatDateTime(appointment.scheduledTime),
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // ID Row
              Row(
                children: [
                  const Icon(Icons.tag, size: 16, color: Colors.grey),
                  const SizedBox(width: 8),
                  Text(
                    'ID: ${appointment.id}',
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ),

              // Notes - if any
              if (appointment.notes.isNotEmpty) ...[
                const SizedBox(height: 12),
                const Divider(),
                const SizedBox(height: 4),
                Text(
                  'Notes: ${appointment.notes}',
                  style: const TextStyle(
                    fontStyle: FontStyle.italic,
                    fontSize: 14,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],

              // Action Buttons
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // Show different buttons based on status
                  if (appointment.status == AppointmentStatus.pending ||
                      appointment.status == AppointmentStatus.confirmed) ...[
                    TextButton.icon(
                      onPressed: () {
                        // This would be implemented in a real app
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Reschedule coming soon!')),
                        );
                      },
                      icon: const Icon(Icons.calendar_today, size: 16),
                      label: const Text('Reschedule'),
                    ),
                    const SizedBox(width: 8),
                    TextButton.icon(
                      onPressed: () {
                        // This would be implemented in a real app
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Cancel coming soon!')),
                        );
                      },
                      icon: const Icon(Icons.cancel_outlined,
                          size: 16, color: Colors.red),
                      label: const Text('Cancel',
                          style: TextStyle(color: Colors.red)),
                    ),
                  ],

                  if (appointment.status == AppointmentStatus.completed) ...[
                    TextButton.icon(
                      onPressed: () {
                        // This would be implemented in a real app
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Review coming soon!')),
                        );
                      },
                      icon: const Icon(Icons.rate_review_outlined, size: 16),
                      label: const Text('Review'),
                    ),
                  ],

                  if (appointment.status == AppointmentStatus.cancelled) ...[
                    TextButton.icon(
                      onPressed: () {
                        // This would be implemented in a real app
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Rebook coming soon!')),
                        );
                      },
                      icon: const Icon(Icons.refresh, size: 16),
                      label: const Text('Rebook'),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
