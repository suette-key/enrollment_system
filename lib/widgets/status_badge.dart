import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/enrollment.dart'; // Updated to the correct model
import '../theme/app_theme.dart';

class StatusBadge extends StatelessWidget {
  final EnrollmentStatus status;

  const StatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final config = _getConfig(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: config['bg'] as Color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: config['dot'] as Color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 5),
          Text(
            config['label'] as String,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: config['text'] as Color,
            ),
          ),
        ],
      ),
    );
  }

  Map<String, dynamic> _getConfig(EnrollmentStatus status) {
    switch (status) {
      case EnrollmentStatus.enrolled:
        return {
          'label': 'Enrolled',
          'bg': AppTheme.success.withOpacity(0.12),
          'dot': AppTheme.success,
          'text': AppTheme.success,
        };
      case EnrollmentStatus.pending:
        return {
          'label': 'Pending',
          'bg': AppTheme.warning.withOpacity(0.12),
          'dot': AppTheme.warning,
          'text': AppTheme.warning,
        };
      case EnrollmentStatus.waitlisted: // Added new status
        return {
          'label': 'Waitlisted',
          'bg': Colors.orange.withOpacity(0.12), // Using standard orange for waitlist
          'dot': Colors.orange,
          'text': Colors.orange,
        };
      case EnrollmentStatus.dropped:
        return {
          'label': 'Dropped',
          'bg': AppTheme.danger.withOpacity(0.12),
          'dot': AppTheme.danger,
          'text': AppTheme.danger,
        };
      case EnrollmentStatus.completed: // Updated from graduated to completed
        return {
          'label': 'Completed',
          'bg': AppTheme.primaryLight.withOpacity(0.12),
          'dot': AppTheme.primaryLight,
          'text': AppTheme.primaryLight,
        };
    }
  }
}