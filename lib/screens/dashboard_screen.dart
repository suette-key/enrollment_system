import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../utils/mock_data.dart';
import '../models/student.dart';
import '../models/enrollment.dart';
import '../controllers/enrollment_controller.dart'; // Needed for bulk approval
import '../widgets/stat_card.dart';
import '../widgets/status_badge.dart';

// CHANGED TO STATEFUL WIDGET TO FIX CONTEXT ERROR AND ALLOW UI UPDATES
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 24),
          _buildStatCards(),
          const SizedBox(height: 24),
          _buildMasterEnrollmentList(), 
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Dashboard',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            color: AppTheme.textPrimary,
          ),
        ),
        Text(
          'Welcome back, Admin · AY 2024–2025, 1st Semester',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 13,
            color: AppTheme.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCards() {
    return GridView.count(
      crossAxisCount: 4,
      crossAxisSpacing: 14,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1.5,
      children: const [
        StatCard(
          title: 'Total Students',
          value: '1,405',
          icon: Icons.school_rounded,
          iconColor: AppTheme.primaryLight,
          iconBg: Color(0xFFEFF6FF),
        ),
        StatCard(
          title: 'Enrolled',
          value: '1,248',
          icon: Icons.check_circle_rounded,
          iconColor: AppTheme.success,
          iconBg: Color(0xFFECFDF5),
        ),
        StatCard(
          title: 'Pending',
          value: '89',
          icon: Icons.pending_rounded,
          iconColor: AppTheme.warning,
          iconBg: Color(0xFFFFFBEB),
        ),
        StatCard(
          title: 'Courses Offered',
          value: '78',
          icon: Icons.menu_book_rounded,
          iconColor: Color(0xFF7C3AED),
          iconBg: Color(0xFFF5F3FF),
        ),
      ],
    );
  }

  Widget _buildMasterEnrollmentList() {
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Master Enrollment List', style: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.w800)),
              
              // --- THE WORKING ADMIN POWER TOOL ---
              ElevatedButton.icon(
                onPressed: () {
                  // Wrapped in setState to refresh the list instantly
                  setState(() {
                    int approvedCount = EnrollmentController.approveAllPending();
                    
                    // Context works perfectly here now!
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Success! $approvedCount pending enrollments approved.'),
                        backgroundColor: AppTheme.success,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  });
                },
                icon: const Icon(Icons.check_circle_outline_rounded, size: 18),
                label: const Text('Approve All Pending'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.success,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          const Row(
            children: [
              Expanded(flex: 2, child: Text('STUDENT', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: AppTheme.textSecondary))),
              Expanded(child: Text('COURSE', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: AppTheme.textSecondary))),
              Expanded(child: Text('STATUS', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: AppTheme.textSecondary))),
            ],
          ),
          const Divider(height: 24),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: MockData.enrollments.length,
            separatorBuilder: (_, __) => const Divider(height: 20),
            itemBuilder: (ctx, i) {
              final e = MockData.enrollments[i];
              final s = MockData.students.firstWhere(
                (student) => student.id == e.studentId,
                orElse: () => _fallbackStudent(),
              );
              return Row(
                children: [
                  Expanded(flex: 2, child: Text(s.fullName, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600))),
                  Expanded(child: Text(e.courseId, style: const TextStyle(fontSize: 13))),
                  Expanded(child: StatusBadge(status: e.status)),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Student _fallbackStudent() => Student(
        id: '',
        studentId: '',
        firstName: 'Unknown',
        lastName: '',
        email: '',
        phone: '',
        program: '',
        yearLevel: '',
        gpa: 0.0,
      );
}