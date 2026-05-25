import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../widgets/page_header.dart';
import '../controllers/enrollment_controller.dart'; // REQUIRED FOR GLOBAL SETTINGS

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // STATIC VARIABLES: These simulate a backend database! 
  // Changes here will persist even when you change tabs.
  static bool _emailNotifications = true;
  static bool _enrollmentAlerts = true;
  static bool _pendingApprovals = false;
  static String _semester = '1st Semester';
  static String _academicYear = '2024–2025';
  static String _schoolName = 'Iloilo Science and Technology University';
  static String _maxStudents = '40';
  static String _enrollmentDeadline = 'June 30, 2025';
  static String _lateFee = '500';
  static String _minUnits = '15';

  void _saveSettings(String section) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$section saved successfully!'), 
        backgroundColor: AppTheme.success,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const PageHeader(
              title: 'System Settings',
              subtitle: 'Manage system preferences and configurations',
            ),
            const SizedBox(height: 24),
            // TWO-COLUMN DASHBOARD LAYOUT FOR PERFECT SIZING
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // LEFT COLUMN
                Expanded(
                  child: Column(
                    children: [
                      _buildAcademicSettings(),
                      const SizedBox(height: 24),
                      _buildNotificationSettings(),
                    ],
                  ),
                ),
                const SizedBox(width: 24),
                // RIGHT COLUMN
                Expanded(
                  child: Column(
                    children: [
                      _buildEnrollmentSettings(),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAcademicSettings() {
    return _settingsCard(
      title: 'Academic Configuration',
      icon: Icons.school_rounded,
      iconColor: AppTheme.primaryLight,
      child: Column(
        children: [
          _settingsDropdownField('Academic Year', _academicYear, [
            '2023–2024',
            '2024–2025',
            '2025–2026',
          ], (v) => setState(() => _academicYear = v!)),
          const SizedBox(height: 14),
          _settingsDropdownField('Current Semester', _semester, [
            '1st Semester',
            '2nd Semester',
            'Summer',
          ], (v) => setState(() => _semester = v!)),
          const SizedBox(height: 14),
          _settingsTextField('School Name', _schoolName, (v) => _schoolName = v),
          const SizedBox(height: 14),
          _settingsTextField('Max Students Per Section', _maxStudents, (v) => _maxStudents = v),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => _saveSettings('Academic Configuration'),
              child: const Text('Save Academic Settings'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationSettings() {
    return _settingsCard(
      title: 'Notifications',
      icon: Icons.notifications_rounded,
      iconColor: AppTheme.warning,
      child: Column(
        children: [
          _toggleRow(
            'Email Notifications',
            'Receive enrollment updates via email',
            _emailNotifications,
            (v) => setState(() => _emailNotifications = v),
          ),
          const Divider(color: AppTheme.border, height: 24),
          _toggleRow(
            'Enrollment Alerts',
            'Get notified when new students enroll',
            _enrollmentAlerts,
            (v) => setState(() => _enrollmentAlerts = v),
          ),
          const Divider(color: AppTheme.border, height: 24),
          _toggleRow(
            'Pending Approvals',
            'Reminders for unprocessed applications',
            _pendingApprovals,
            (v) => setState(() => _pendingApprovals = v),
          ),
        ],
      ),
    );
  }

  Widget _buildEnrollmentSettings() {
    return _settingsCard(
      title: 'Enrollment Policies',
      icon: Icons.policy_rounded,
      iconColor: AppTheme.success,
      child: Column(
        children: [
          // WIRED TO GLOBAL SETTINGS
          _toggleRow(
            'Auto-Approve Enrollments',
            'Automatically approve new enrollment requests without manual review',
            SystemSettings.autoApprove,
            (v) => setState(() => SystemSettings.autoApprove = v),
          ),
          const Divider(color: AppTheme.border, height: 24),
          _settingsTextField('Enrollment Deadline', _enrollmentDeadline, (v) => _enrollmentDeadline = v),
          const SizedBox(height: 14),
          _settingsTextField('Late Enrollment Fee (PHP)', _lateFee, (v) => _lateFee = v),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _settingsTextField('Min Units per Semester', _minUnits, (v) => _minUnits = v),
              ),
              const SizedBox(width: 12),
              // WIRED TO GLOBAL SETTINGS
              Expanded(
                child: _settingsTextField('Max Units per Semester', SystemSettings.maxUnits.toString(), (v) {
                  if (int.tryParse(v) != null) SystemSettings.maxUnits = int.parse(v);
                }),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => _saveSettings('Enrollment Policies'),
              child: const Text('Save Enrollment Policies'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _settingsCard({
    required String title,
    required IconData icon,
    required Color iconColor,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.bgCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: iconColor, size: 18),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          child,
        ],
      ),
    );
  }

  Widget _toggleRow(
    String title,
    String subtitle,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11,
                  color: AppTheme.textSecondary,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        Switch(
          value: value,
          onChanged: onChanged,
          activeColor: AppTheme.primary,
        ),
      ],
    );
  }

  Widget _settingsTextField(String label, String initialValue, Function(String) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          initialValue: initialValue,
          onChanged: onChanged,
          style: GoogleFonts.plusJakartaSans(fontSize: 13),
          decoration: InputDecoration(
            filled: true,
            fillColor: AppTheme.bgMain,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppTheme.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppTheme.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(
                color: AppTheme.primaryLight,
                width: 2,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 12,
            ),
          ),
        ),
      ],
    );
  }

  Widget _settingsDropdownField(
    String label,
    String value,
    List<String> items,
    ValueChanged<String?> onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
          decoration: BoxDecoration(
            color: AppTheme.bgMain,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppTheme.border),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              items: items
                  .map(
                    (item) => DropdownMenuItem<String>(
                      value: item,
                      child: Text(
                        item,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                    ),
                  )
                  .toList(),
              onChanged: onChanged,
              icon: const Icon(
                Icons.keyboard_arrow_down_rounded,
                size: 20,
                color: AppTheme.textSecondary,
              ),
            ),
          ),
        ),
      ],
    );
  }
}