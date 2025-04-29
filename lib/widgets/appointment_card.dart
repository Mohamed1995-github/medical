import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/appointment.dart';
import '../config/theme.dart';

class AppointmentCard extends StatelessWidget {
  final Appointment appointment;
  final String clinicName;
  final VoidCallback? onTap;
  final VoidCallback? onPayment;
  final VoidCallback? onCancel;

  const AppointmentCard({
    Key? key,
    required this.appointment,
    required this.clinicName,
    this.onTap,
    this.onPayment,
    this.onCancel,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    clinicName,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  _buildStatusChip(context),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(Icons.calendar_today,
                      size: 16, color: lightTextColor),
                  const SizedBox(width: 8),
                  Text(
                    DateFormat('dd MMMM yyyy').format(appointment.date),
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(width: 16),
                  const Icon(Icons.access_time,
                      size: 16, color: lightTextColor),
                  const SizedBox(width: 8),
                  Text(
                    appointment.time,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.medical_services_outlined,
                      size: 16, color: lightTextColor),
                  const SizedBox(width: 8),
                  Text(
                    appointment.service,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.payment, size: 16, color: lightTextColor),
                  const SizedBox(width: 8),
                  Text(
                    appointment.isPaid ? 'Payé' : 'Non payé',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: appointment.isPaid ? successColor : errorColor,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${appointment.amount.toStringAsFixed(2)} €',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
              if (_showActions())
                Padding(
                  padding: const EdgeInsets.only(top: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: _buildActionButtons(context),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(BuildContext context) {
    Color chipColor;
    String statusText;

    switch (appointment.status) {
      case AppointmentStatus.pending:
        chipColor = Colors.orange;
        statusText = 'En attente';
        break;
      case AppointmentStatus.confirmed:
        chipColor = Colors.blue;
        statusText = 'Confirmé';
        break;
      case AppointmentStatus.completed:
        chipColor = successColor;
        statusText = 'Terminé';
        break;
      case AppointmentStatus.cancelled:
        chipColor = errorColor;
        statusText = 'Annulé';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: chipColor.withOpacity(0.2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: chipColor, width: 1),
      ),
      child: Text(
        statusText,
        style: TextStyle(
          color: chipColor,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  bool _showActions() {
    return appointment.status == AppointmentStatus.pending ||
        appointment.status == AppointmentStatus.confirmed ||
        (!appointment.isPaid &&
            appointment.status != AppointmentStatus.cancelled);
  }

  List<Widget> _buildActionButtons(BuildContext context) {
    final List<Widget> buttons = [];

    // Bouton de paiement
    if (!appointment.isPaid &&
        appointment.status != AppointmentStatus.cancelled &&
        onPayment != null) {
      buttons.add(
        TextButton.icon(
          onPressed: onPayment,
          icon: const Icon(Icons.payment, size: 16),
          label: const Text('Payer'),
          style: TextButton.styleFrom(
            foregroundColor: primaryColor,
          ),
        ),
      );
    }

    // Bouton d'annulation
    if ((appointment.status == AppointmentStatus.pending ||
            appointment.status == AppointmentStatus.confirmed) &&
        onCancel != null) {
      buttons.add(
        TextButton.icon(
          onPressed: onCancel,
          icon: const Icon(Icons.cancel_outlined, size: 16),
          label: const Text('Annuler'),
          style: TextButton.styleFrom(
            foregroundColor: errorColor,
          ),
        ),
      );
    }

    return buttons;
  }
}
