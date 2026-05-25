import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import 'dashboard_screen.dart';
import 'students_screen.dart';
import 'courses_screen.dart';
import 'grading_screen.dart'; // The new Grading Portal
import 'profile_screen.dart'; 
import 'settings_screen.dart';
import 'login_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  // FIX: Removed 'const' from the list itself, added to individual items to prevent errors
  final List<_NavItem> _navItems = [
    const _NavItem(icon: Icons.dashboard_rounded, label: 'Dashboard', activeIcon: Icons.dashboard_rounded),
    const _NavItem(icon: Icons.school_outlined, label: 'Students', activeIcon: Icons.school_rounded),
    const _NavItem(icon: Icons.menu_book_outlined, label: 'Courses', activeIcon: Icons.menu_book_rounded),
    const _NavItem(icon: Icons.rule_rounded, label: 'Grading Portal', activeIcon: Icons.rule_rounded), 
    const _NavItem(icon: Icons.person_outline_rounded, label: 'Profile', activeIcon: Icons.person_rounded),
  ];

  // The 6 main screens mapped to the navigation indices
  final List<Widget> _screens = [
    const DashboardScreen(),
    const StudentsScreen(),
    const CoursesScreen(),
    const GradingScreen(), // Index 3
    const ProfileScreen(), // Index 4
    const SettingsScreen(), // Index 5
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgMain,
      body: Row(
        children: [
          _buildSidebar(),
          Expanded(
            child: Column(
              children: [
                _buildTopBar(),
                Expanded(child: _screens[_selectedIndex]),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopBar() {
    final titles = [
      'Admin Dashboard', 
      'Student Records', 
      'Course Management', 
      'Faculty Grading Portal', 
      'Administrator Profile', 
      'System Settings'
    ];
    
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 32),
      decoration: const BoxDecoration(
        color: AppTheme.bgCard, 
        border: Border(bottom: BorderSide(color: AppTheme.border))
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            titles[_selectedIndex], 
            style: GoogleFonts.plusJakartaSans(fontSize: 15, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)
          ),
          Text(
            'AY 2024-2025 • First Semester', 
            style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.textSecondary)
          ),
        ],
      ),
    );
  }

  // --- UNIFIED SIDEBAR DESIGN ---
  Widget _buildSidebar() {
    return Container(
      width: 260,
      color: AppTheme.sidebarBg,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLogo(),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              'MAIN MENU',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11, 
                fontWeight: FontWeight.w900, 
                color: AppTheme.sidebarText.withOpacity(0.3), 
                letterSpacing: 1.5
              ),
            ),
          ),
          const SizedBox(height: 12),
          ...List.generate(_navItems.length, (i) => _buildNavItem(i)),
          const Spacer(),
          // Settings is locked to index 5 at the bottom
          _buildNavItemCustom(
            icon: Icons.settings_outlined,
            activeIcon: Icons.settings_rounded,
            label: 'Settings',
            index: 5, 
          ),
          const SizedBox(height: 8),
          _buildSidebarUser(),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildNavItem(int index) => _buildNavItemCustom(
        icon: _navItems[index].icon,
        activeIcon: _navItems[index].activeIcon,
        label: _navItems[index].label,
        index: index,
      );

  Widget _buildNavItemCustom({required IconData icon, required IconData activeIcon, required String label, required int index}) {
    final isActive = _selectedIndex == index;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: InkWell(
        onTap: () => setState(() => _selectedIndex = index),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: isActive ? AppTheme.primaryLight.withOpacity(0.15) : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(
                isActive ? activeIcon : icon, 
                size: 20, 
                color: isActive ? Colors.white : AppTheme.sidebarText.withOpacity(0.5)
              ),
              const SizedBox(width: 14),
              Text(
                label,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  fontWeight: isActive ? FontWeight.w800 : FontWeight.w600,
                  color: isActive ? Colors.white : AppTheme.sidebarText.withOpacity(0.6),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.asset(
              'assets/logo.jpg',
              width: 40, height: 40,
              fit: BoxFit.cover,
              errorBuilder: (ctx, err, stack) => Container(
                width: 40, height: 40,
                decoration: BoxDecoration(
                  color: AppTheme.primaryLight, 
                  borderRadius: BorderRadius.circular(10)
                ),
                child: const Icon(Icons.school_rounded, color: Colors.white, size: 22),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Text(
            'ISATU Admin', 
            style: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.w900, color: Colors.white)
          ),
        ],
      ),
    );
  }

  Widget _buildSidebarUser() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.04), 
          borderRadius: BorderRadius.circular(16)
        ),
        child: Row(
          children: [
            Container(
              width: 38, height: 38,
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [AppTheme.primaryLight, AppTheme.accent]), 
                borderRadius: BorderRadius.circular(10)
              ),
              child: const Center(
                child: Text('AD', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w900))
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Administrator', 
                    style: GoogleFonts.plusJakartaSans(fontSize: 13, color: Colors.white, fontWeight: FontWeight.w800), 
                    overflow: TextOverflow.ellipsis
                  ),
                  Text(
                    'admin@isatu.edu', 
                    style: GoogleFonts.plusJakartaSans(fontSize: 11, color: AppTheme.sidebarText.withOpacity(0.4)), 
                    overflow: TextOverflow.ellipsis
                  ),
                ],
              ),
            ),
            IconButton(
              icon: Icon(Icons.power_settings_new_rounded, size: 20, color: AppTheme.sidebarText.withOpacity(0.4)),
              onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LoginScreen())),
            ),
          ],
        ),
      ),
    );
  }
}

// Ensure this has the 'const' keyword!
class _NavItem {
  final IconData icon, activeIcon;
  final String label;
  const _NavItem({
    required this.icon, 
    required this.activeIcon, 
    required this.label
  });
}