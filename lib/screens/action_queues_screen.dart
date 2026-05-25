import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../utils/mock_data.dart';
import '../models/student.dart';
import '../models/enrollment.dart'; // Added the new model
import '../widgets/page_header.dart';

class ActionQueuesScreen extends StatefulWidget {
  const ActionQueuesScreen({super.key});

  @override
  State<ActionQueuesScreen> createState() => _ActionQueuesScreenState();
}

class _ActionQueuesScreenState extends State<ActionQueuesScreen> {
  // Logic: Connect to State
  // We now filter MockData.enrollments instead of students
  List<Enrollment> get _pendingEnrollments => MockData.enrollments
      .where((e) => e.status == EnrollmentStatus.pending)
      .toList();

  List<Enrollment> get _pendingDrops => MockData.enrollments
      .where((e) => e.status == EnrollmentStatus.dropped)
      .toList();

  void _handleApproval(Enrollment enrollment) {
    setState(() {
      // Find the enrollment in the mock database and update its status
      final index = MockData.enrollments.indexWhere((e) => e.id == enrollment.id);
      if (index != -1) {
        // Create a new updated Enrollment object (simulating a Firebase update)
        MockData.enrollments[index] = Enrollment(
          id: enrollment.id,
          studentId: enrollment.studentId,
          courseId: enrollment.courseId,
          semester: enrollment.semester,
          status: EnrollmentStatus.enrolled, // Status updated!
          dateRequested: enrollment.dateRequested,
          grade: enrollment.grade,
        );
      }
    });
    
    // Look up the student name just for the SnackBar message
    final student = MockData.students.firstWhere(
      (s) => s.id == enrollment.studentId,
      orElse: () => _fallbackStudent(),
    );
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Approved enrollment for ${student.fullName}')),
    );
  }

  void _handleRejection(Enrollment enrollment) {
    setState(() {
      MockData.enrollments.removeWhere((e) => e.id == enrollment.id);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Rejected request')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const PageHeader(
            title: 'Action Queues',
            subtitle: 'Review and approve enrollment or drop requests',
          ),
          const SizedBox(height: 20),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _buildQueueCard(
                    'Pending Enrollments',
                    _pendingEnrollments,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildQueueCard('Drop Requests', _pendingDrops),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQueueCard(String title, List<Enrollment> list) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.bgCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
          const Divider(height: 32),
          Expanded(
            child: list.isEmpty
                ? const Center(child: Text('All caught up!'))
                : ListView.separated(
                    itemCount: list.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
                    itemBuilder: (ctx, i) => _buildRequestItem(list[i]),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildRequestItem(Enrollment enrollment) {
    // We look up the student based on the enrollment's studentId
    final student = MockData.students.firstWhere(
      (s) => s.id == enrollment.studentId,
      orElse: () => _fallbackStudent(), // Prevents crashes if data is missing
    );

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.bgMain,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  student.fullName,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
                Text(
                  '${student.studentId} • ${student.program} • Course: ${enrollment.courseId}',
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(
              Icons.check_circle_rounded,
              color: AppTheme.success,
            ),
            onPressed: () => _handleApproval(enrollment),
            tooltip: 'Approve',
          ),
          IconButton(
            icon: const Icon(Icons.cancel_rounded, color: AppTheme.danger),
            onPressed: () => _handleRejection(enrollment),
            tooltip: 'Reject',
          ),
        ],
      ),
    );
  }

  // A safe fallback in case the mock data is mismatched
  Student _fallbackStudent() {
    return Student(
      id: 'error',
      studentId: 'Unknown',
      firstName: 'Unknown',
      lastName: 'Student',
      email: '',
      phone: '',
      program: 'Unknown',
      yearLevel: '',
    );
  }
}