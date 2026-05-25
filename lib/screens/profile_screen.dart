import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../widgets/page_header.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // Static variables simulate a backend database so data persists across tabs!
  static String _fullName = 'Administrator';
  static String _email = 'admin@isatu.edu';
  static String _role = 'System Administrator';

  late TextEditingController _nameCtrl;
  late TextEditingController _emailCtrl;
  late TextEditingController _roleCtrl;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: _fullName);
    _emailCtrl = TextEditingController(text: _email);
    _roleCtrl = TextEditingController(text: _role);
  }

  void _saveProfile() {
    setState(() {
      _fullName = _nameCtrl.text;
      _email = _emailCtrl.text;
      _role = _roleCtrl.text;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profile updated successfully!'), backgroundColor: AppTheme.success),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const PageHeader(
            title: 'My Profile',
            subtitle: 'Manage your administrator credentials and personal info',
          ),
          const SizedBox(height: 24),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar & Quick Actions Card
              Expanded(
                flex: 2,
                child: _buildAvatarCard(),
              ),
              const SizedBox(width: 24),
              // Main Info Edit Form
              Expanded(
                flex: 3,
                child: _buildDetailsCard(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAvatarCard() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AppTheme.bgCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: AppTheme.primaryLight.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Icon(Icons.person, size: 60, color: AppTheme.primary),
            ),
          ),
          const SizedBox(height: 20),
          Text(_fullName, style: GoogleFonts.plusJakartaSans(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
          Text(_role, style: GoogleFonts.plusJakartaSans(color: AppTheme.textSecondary)),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              icon: const Icon(Icons.upload_rounded, size: 18),
              label: const Text('Upload New Photo'),
              onPressed: () {},
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsCard() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AppTheme.bgCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Personal Information', style: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
          const Divider(height: 32),
          _profileField('Full Name', _nameCtrl),
          const SizedBox(height: 16),
          _profileField('Email Address', _emailCtrl),
          const SizedBox(height: 16),
          _profileField('Assigned Role', _roleCtrl),
          const SizedBox(height: 32),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: _saveProfile,
                  style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                  child: const Text('Save Changes'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Password reset email sent!')));
                  },
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    foregroundColor: AppTheme.danger,
                    side: const BorderSide(color: AppTheme.danger),
                  ),
                  child: const Text('Reset Password'),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _profileField(String label, TextEditingController ctrl) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
        const SizedBox(height: 8),
        TextField(
          controller: ctrl,
          decoration: const InputDecoration(filled: true, fillColor: AppTheme.bgMain),
        ),
      ],
    );
  }
}