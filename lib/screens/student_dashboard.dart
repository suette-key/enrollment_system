import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../utils/mock_data.dart';
import '../models/student.dart';
import '../models/course.dart';
import '../models/enrollment.dart';
import '../controllers/enrollment_controller.dart';
import 'login_screen.dart';

class StudentDashboard extends StatefulWidget {
  final String studentId;

  const StudentDashboard({super.key, required this.studentId});

  @override
  State<StudentDashboard> createState() => _StudentDashboardState();
}

class _StudentDashboardState extends State<StudentDashboard> {
  int _selectedIndex = 0; 
  String? _curriculumYearFilter; 
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  Student get me => MockData.students.firstWhere((s) => s.id == widget.studentId);

  List<Enrollment> get myEnrollments => MockData.enrollments
      .where((e) => e.studentId == widget.studentId && e.status != EnrollmentStatus.dropped)
      .toList();

  List<Enrollment> get completedSubjects => MockData.enrollments
      .where((e) => e.studentId == widget.studentId && e.status == EnrollmentStatus.completed && e.grade != null)
      .toList();

  double get calculatedGpa {
    if (completedSubjects.isEmpty) return 0.0;
    double totalGradePoints = 0;
    int totalUnits = 0;
    for (var e in completedSubjects) {
      final course = MockData.courses.firstWhere((c) => c.id == e.courseId);
      totalGradePoints += (e.grade! * course.units);
      totalUnits += course.units;
    }
    return totalUnits == 0 ? 0.0 : (totalGradePoints / totalUnits);
  }

  int get totalUnitsEarned {
    int earned = 0;
    for (var e in completedSubjects) {
      if (e.grade! <= 3.0) {
        final course = MockData.courses.firstWhere((c) => c.id == e.courseId);
        earned += course.units;
      }
    }
    return earned;
  }

  String _getCourseYear(String code) {
    final exactFirstYear = ['ICT 102', 'CS 1', 'ICT 103', 'ICT 105', 'ICT 106', 'GE 4 MATH', 'GE 5 ENG', 'PE 1'];
    final exactSecondYear = ['ICT 104', 'ICT 107', 'ICT 113', 'MATH 12', 'ICT 110', 'ICT 111', 'ICT 112', 'ICT 114', 'ICT 122'];
    final exactThirdYear = ['ICT 108', 'ICT 115', 'ICT 109', 'ICT 117', 'ICT 118', 'ICT 116', 'ICT 119', 'ICT 120', 'ICT 121', 'CS 7'];
    final exactFourthYear = ['ICT 123', 'ICT 136', 'CS 8', 'ICT 124', 'ICT 125'];

    if (exactFirstYear.contains(code)) return '1st Year';
    if (exactSecondYear.contains(code)) return '2nd Year';
    if (exactThirdYear.contains(code)) return '3rd Year';
    if (exactFourthYear.contains(code)) return '4th Year';

    final match = RegExp(r'\b[1-4]').firstMatch(code);
    if (match != null) {
      final num = match.group(0);
      if (num == '1') return '1st Year';
      if (num == '2') return '2nd Year';
      if (num == '3') return '3rd Year';
      if (num == '4') return '4th Year';
    }
    return '1st Year'; 
  }

  void _handleEnroll(Course course) {
    String? validationError = EnrollmentController.canEnroll(me, course);
    
    if (validationError != null) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Row(
            children: [
              Icon(Icons.error_outline_rounded, color: AppTheme.danger, size: 28),
              SizedBox(width: 12),
              Text('Enrollment Blocked', style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
            ],
          ),
          content: Text(validationError, style: const TextStyle(fontSize: 14, height: 1.5, color: AppTheme.textSecondary)),
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Understood', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      );
      return;
    }

    setState(() => EnrollmentController.processEnrollment(me, course));
    _showMsg("Enrollment requested! Waitlisted status will be shown if course is full.");
  }

  void _confirmDrop(Enrollment e, Course c) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Drop Course?'),
        content: Text('Are you sure you want to drop ${c.code} - ${c.title}? This will remove it from your current schedule.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.danger),
            onPressed: () {
              Navigator.pop(ctx);
              setState(() => EnrollmentController.processDrop(e));
              _showMsg("Course dropped successfully.");
            },
            child: const Text('Confirm Drop'),
          ),
        ],
      ),
    );
  }

  // --- NEW: MOCK PDF EXPORT LOGIC ---
  void _downloadTranscript() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => const AlertDialog(
        content: Row(
          children: [
            CircularProgressIndicator(),
            SizedBox(width: 24),
            Text("Generating PDF Transcript..."),
          ],
        ),
      ),
    );
    await Future.delayed(const Duration(milliseconds: 1500));
    if (mounted) {
      Navigator.pop(context); // Close dialog
      _showMsg("Transcript.pdf downloaded to your device.");
    }
  }

  // --- NEW: EDIT PROFILE MODAL ---
  void _showEditProfile() {
    final phoneCtrl = TextEditingController(text: me.phone);
    final passCtrl = TextEditingController(text: MockData.userCredentials[me.email] ?? '');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Edit Security Details', style: TextStyle(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Phone Number', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.textSecondary)),
            const SizedBox(height: 6),
            TextField(
              controller: phoneCtrl,
              decoration: InputDecoration(filled: true, fillColor: AppTheme.bgMain, border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none)),
            ),
            const SizedBox(height: 16),
            const Text('Account Password', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.textSecondary)),
            const SizedBox(height: 6),
            TextField(
              controller: passCtrl,
              obscureText: true,
              decoration: InputDecoration(filled: true, fillColor: AppTheme.bgMain, border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none)),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              setState(() {
                // Update specific fields safely
                final idx = MockData.students.indexWhere((s) => s.id == me.id);
                MockData.students[idx] = Student(
                  id: me.id, studentId: me.studentId, firstName: me.firstName, lastName: me.lastName,
                  email: me.email, phone: phoneCtrl.text.trim(), program: me.program, yearLevel: me.yearLevel, gpa: me.gpa
                );
                MockData.userCredentials[me.email] = passCtrl.text;
              });
              Navigator.pop(ctx);
              _showMsg("Profile updated successfully!");
            },
            child: const Text('Save Changes'),
          ),
        ],
      ),
    );
  }

  void _showMsg(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: isError ? AppTheme.danger : AppTheme.success,
      behavior: SnackBarBehavior.floating,
      margin: const EdgeInsets.all(20),
    ));
  }

  void _handleLogout() => Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LoginScreen()));

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
                Expanded(child: _buildMainContent()),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopBar() {
    final titles = ['Dashboard Overview', 'My Academic Schedule', 'CCI Curriculum', 'Academic Grades', 'My Profile'];
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 32),
      decoration: const BoxDecoration(color: AppTheme.bgCard, border: Border(bottom: BorderSide(color: AppTheme.border))),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(titles[_selectedIndex], style: GoogleFonts.plusJakartaSans(fontSize: 15, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
          Text('AY 2024-2025 • First Semester', style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.textSecondary)),
        ],
      ),
    );
  }

  Widget _buildMainContent() {
    switch (_selectedIndex) {
      case 0: return _buildDashboardTab();
      case 1: return _buildScheduleTab();
      case 2: return _buildCurriculumTab();
      case 3: return _buildGradesTab(); 
      case 4: return _buildProfileTab();
      default: return _buildDashboardTab();
    }
  }

  Widget _buildDashboardTab() {
    final filteredCourses = MockData.courses.where((c) => c.title.toLowerCase().contains(_searchQuery.toLowerCase()) || c.code.toLowerCase().contains(_searchQuery.toLowerCase())).toList();
    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStudentHeader(),
          const SizedBox(height: 40),
          Row(
            children: [
              const Text("Available Course Catalog", style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppTheme.textPrimary)),
              const Spacer(),
              SizedBox(
                width: 350, height: 45,
                child: TextField(
                  controller: _searchController,
                  onChanged: (v) => setState(() => _searchQuery = v),
                  decoration: InputDecoration(
                    hintText: 'Search course code or title...', prefixIcon: const Icon(Icons.search, size: 20),
                    filled: true, fillColor: Colors.white,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppTheme.border)),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          ListView.builder(
            shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
            itemCount: filteredCourses.length,
            itemBuilder: (ctx, i) => _courseRow(filteredCourses[i]),
          ),
        ],
      ),
    );
  }

  Widget _buildStudentHeader() {
    int activeUnits = 0;
    for (var e in myEnrollments) {
      if (e.status == EnrollmentStatus.enrolled || e.status == EnrollmentStatus.pending || e.status == EnrollmentStatus.waitlisted) {
        activeUnits += MockData.courses.firstWhere((c) => c.id == e.courseId).units;
      }
    }

    return Row(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Welcome, ${me.firstName}!', style: GoogleFonts.plusJakartaSans(fontSize: 28, fontWeight: FontWeight.w800, color: AppTheme.textPrimary)),
            const SizedBox(height: 4),
            Text('${me.studentId} • ${me.program}', style: const TextStyle(color: AppTheme.textSecondary, fontSize: 15, fontWeight: FontWeight.w500)),
          ],
        ),
        const Spacer(),
        _statBadge("Cumulative GPA", calculatedGpa > 0 ? calculatedGpa.toStringAsFixed(2) : "N/A", Icons.star_rounded),
        const SizedBox(width: 16),
        _statBadge("Active Units", "$activeUnits / 24", Icons.auto_stories_rounded),
      ],
    );
  }

  Widget _statBadge(String label, String val, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppTheme.border)),
      child: Row(
        children: [
          Icon(icon, size: 24, color: AppTheme.primaryLight),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary, fontWeight: FontWeight.bold)),
              Text(val, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: AppTheme.textPrimary)),
            ],
          )
        ],
      ),
    );
  }

  Widget _courseRow(Course c) {
    int currentOccupancy = EnrollmentController.getOccupancy(c.id);
    bool isFull = currentOccupancy >= c.maxCapacity;
    bool hasPrereqs = c.prerequisites.isNotEmpty;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppTheme.border)),
      child: Row(
        children: [
          Container(
            width: 90, padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(color: AppTheme.primary.withOpacity(0.05), borderRadius: BorderRadius.circular(8)),
            child: Center(child: Text(c.code, style: const TextStyle(color: AppTheme.primary, fontWeight: FontWeight.w900, fontSize: 13))),
          ),
          const SizedBox(width: 24),
          Expanded(
            flex: 4,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(c.title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: AppTheme.textPrimary)),
                const SizedBox(height: 4),
                if (hasPrereqs)
                  Row(
                    children: [
                      const Icon(Icons.lock_outline, size: 12, color: AppTheme.warning),
                      const SizedBox(width: 4),
                      Text("Prerequisites: ${c.prerequisites.join(', ')}", style: const TextStyle(fontSize: 11, color: AppTheme.warning, fontWeight: FontWeight.w700)),
                    ],
                  )
                else
                  const Text("Open Enrollment", style: TextStyle(fontSize: 11, color: AppTheme.success, fontWeight: FontWeight.w700)),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text("${c.units} Units", style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800)),
                const SizedBox(height: 4),
                Text("$currentOccupancy/${c.maxCapacity} Slots Filled", style: TextStyle(fontSize: 11, color: isFull ? AppTheme.danger : AppTheme.textSecondary, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
          const SizedBox(width: 40),
          SizedBox(
            width: 130, height: 42,
            child: ElevatedButton(
              onPressed: () => _handleEnroll(c),
              style: ElevatedButton.styleFrom(backgroundColor: isFull ? AppTheme.warning : AppTheme.primary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
              child: Text(isFull ? "Join Waitlist" : "Enroll Now", style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScheduleTab() {
    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];

    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Visual Timetable", style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: AppTheme.textPrimary)),
          const SizedBox(height: 8),
          const Text("Your active schedule for the week. Waitlisted classes appear in yellow.", style: TextStyle(color: AppTheme.textSecondary, fontSize: 14)),
          const SizedBox(height: 32),
          
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: days.map((day) => Expanded(child: _buildDayColumn(day))).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDayColumn(String day) {
    final todaysClasses = myEnrollments.where((e) {
      final c = MockData.courses.firstWhere((course) => course.id == e.courseId);
      if (c.schedule.trim().toUpperCase() == 'TBA') return false;
      final dayStringPart = c.schedule.split(' ')[0];
      final extractedDays = EnrollmentController.extractDays(dayStringPart);
      return extractedDays.contains(day);
    }).toList();

    todaysClasses.sort((a, b) {
      final cA = MockData.courses.firstWhere((c) => c.id == a.courseId);
      final cB = MockData.courses.firstWhere((c) => c.id == b.courseId);
      final tA = EnrollmentController.parseTimeRange(cA.schedule.replaceAll(RegExp(r'^[A-Z]+ '), '').trim());
      final tB = EnrollmentController.parseTimeRange(cB.schedule.replaceAll(RegExp(r'^[A-Z]+ '), '').trim());
      int startA = tA != null ? tA['start']! : 0;
      int startB = tB != null ? tB['start']! : 0;
      return startA.compareTo(startB);
    });

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(color: Colors.white, border: Border.all(color: AppTheme.border), borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          Container(
            width: double.infinity, padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: const BoxDecoration(color: AppTheme.bgCard, borderRadius: BorderRadius.vertical(top: Radius.circular(12))),
            child: Text(day, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.w900, color: AppTheme.textSecondary)),
          ),
          const Divider(height: 1, color: AppTheme.border),
          Expanded(
            child: todaysClasses.isEmpty 
              ? const Center(child: Text('-', style: TextStyle(color: AppTheme.textSecondary)))
              : ListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: todaysClasses.length,
                  itemBuilder: (ctx, i) {
                    final e = todaysClasses[i];
                    final c = MockData.courses.firstWhere((course) => course.id == e.courseId);
                    final isWaitlist = e.status == EnrollmentStatus.waitlisted;
                    
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8), padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isWaitlist ? AppTheme.warning.withOpacity(0.1) : AppTheme.primaryLight.withOpacity(0.1),
                        border: Border.all(color: isWaitlist ? AppTheme.warning.withOpacity(0.3) : AppTheme.primaryLight.withOpacity(0.3)),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(c.code, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 11, color: isWaitlist ? AppTheme.warning : AppTheme.primary)),
                              InkWell(onTap: () => _confirmDrop(e, c), child: Icon(Icons.close_rounded, size: 14, color: AppTheme.danger.withOpacity(0.7)))
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(c.schedule.replaceAll(RegExp(r'^[A-Z]+ '), ''), style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          Text(c.room, style: const TextStyle(fontSize: 10, color: AppTheme.textSecondary)),
                          if (isWaitlist) Padding(padding: const EdgeInsets.only(top: 4), child: Text('WAITLISTED', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: AppTheme.warning)))
                        ],
                      ),
                    );
                  },
                ),
          )
        ],
      ),
    );
  }

  Widget _buildCurriculumTab() {
    String prefix = '';
    if (me.program.contains('Computer Science')) prefix = 'CS';
    if (me.program.contains('Information Technology')) prefix = 'IT';
    if (me.program.contains('Information Systems')) prefix = 'IS';

    final programCourses = MockData.courses.where((c) {
      bool matchesProgram = c.code.startsWith(prefix) || c.code.startsWith('ICT') || c.code.startsWith('ANIM') || c.code.startsWith('MATH') || c.code.startsWith('GE') || c.code.startsWith('PE');
      bool matchesYear = _curriculumYearFilter == null || _curriculumYearFilter == 'All Years' || _getCourseYear(c.code) == _curriculumYearFilter; 
      return matchesProgram && matchesYear;
    }).toList();

    programCourses.sort((a, b) => _getCourseYear(a.code).compareTo(_getCourseYear(b.code)));

    // --- NEW: PROGRESS RING CALCULATIONS ---
    int totalProgramUnits = 0;
    for(var c in programCourses) totalProgramUnits += c.units;
    double progress = totalProgramUnits == 0 ? 0 : totalUnitsEarned / totalProgramUnits;

    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("CCI Curriculum Checklist", style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: AppTheme.textPrimary)),
                  const SizedBox(height: 4),
                  Text("Tracking requirements for ${me.program}", style: const TextStyle(color: AppTheme.textSecondary, fontSize: 14)),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(color: Colors.white, border: Border.all(color: AppTheme.border), borderRadius: BorderRadius.circular(12)),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _curriculumYearFilter ?? 'All Years',
                    items: ['All Years', '1st Year', '2nd Year', '3rd Year', '4th Year'].map((y) => DropdownMenuItem(value: y, child: Text(y, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800)))).toList(),
                    onChanged: (v) => setState(() => _curriculumYearFilter = v),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          
          // --- NEW: PROGRESS RING UI ---
          if (_curriculumYearFilter == null || _curriculumYearFilter == 'All Years')
            Container(
              margin: const EdgeInsets.only(bottom: 24),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppTheme.border)),
              child: Row(
                children: [
                  SizedBox(
                    width: 70, height: 70,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        CircularProgressIndicator(value: progress, strokeWidth: 8, backgroundColor: AppTheme.bgMain, color: AppTheme.primaryLight),
                        Center(child: Text('${(progress * 100).toInt()}%', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14))),
                      ],
                    ),
                  ),
                  const SizedBox(width: 24),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Overall Degree Progress", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(height: 4),
                      Text("You have completed $totalUnitsEarned out of $totalProgramUnits required units.", style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
                    ],
                  )
                ],
              ),
            ),

          Expanded(
            child: ListView.builder(
              itemCount: programCourses.length,
              itemBuilder: (ctx, i) => _curriculumListItem(programCourses[i]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _curriculumListItem(Course c) {
    bool hasPrereqs = c.prerequisites.isNotEmpty;
    bool isCompleted = MockData.enrollments.any((e) => e.studentId == me.id && e.courseId == c.id && e.status == EnrollmentStatus.completed);
    String yr = _getCourseYear(c.code);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: isCompleted ? AppTheme.success.withOpacity(0.4) : AppTheme.border)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
        leading: Icon(isCompleted ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded, color: isCompleted ? AppTheme.success : AppTheme.textSecondary.withOpacity(0.3), size: 28),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(color: AppTheme.primaryLight.withOpacity(0.08), borderRadius: BorderRadius.circular(4)),
              child: Text(yr, style: const TextStyle(fontSize: 10, color: AppTheme.primaryLight, fontWeight: FontWeight.w900)),
            ),
            const SizedBox(width: 12),
            Text(c.code, style: const TextStyle(fontWeight: FontWeight.w900, color: AppTheme.primary, fontSize: 13)),
            const SizedBox(width: 12),
            Expanded(child: Text(c.title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15))),
          ],
        ),
        subtitle: hasPrereqs 
          ? Padding(padding: const EdgeInsets.only(top: 4), child: Text("Requires: ${c.prerequisites.join(', ')}", style: const TextStyle(color: AppTheme.warning, fontSize: 11, fontWeight: FontWeight.w800)))
          : null,
        trailing: Text("${c.units} Units", style: const TextStyle(fontWeight: FontWeight.w800, color: AppTheme.textSecondary, fontSize: 13)),
      ),
    );
  }

  Widget _buildGradesTab() {
    final sortedSubjects = List<Enrollment>.from(completedSubjects)..sort((a, b) => b.dateRequested.compareTo(a.dateRequested));

    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Academic Records", style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: AppTheme.textPrimary)),
                  const SizedBox(height: 4),
                  const Text("View your historical grades and completed subjects.", style: TextStyle(color: AppTheme.textSecondary, fontSize: 14)),
                ],
              ),
              OutlinedButton.icon(
                onPressed: _downloadTranscript, // WIRED UP
                icon: const Icon(Icons.download_rounded, size: 18), label: const Text('Transcript'),
                style: OutlinedButton.styleFrom(foregroundColor: AppTheme.primary, side: const BorderSide(color: AppTheme.primary), padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12)),
              ),
            ],
          ),
          const SizedBox(height: 32),
          Row(
            children: [
              _statBadge("Cumulative GPA", calculatedGpa > 0 ? calculatedGpa.toStringAsFixed(2) : "N/A", Icons.star_rounded),
              const SizedBox(width: 16),
              _statBadge("Total Earned Units", "$totalUnitsEarned", Icons.workspace_premium_rounded),
            ],
          ),
          const SizedBox(height: 32),
          Expanded(
            child: sortedSubjects.isEmpty
              ? const Center(child: Text("No completed courses yet.", style: TextStyle(color: AppTheme.textSecondary, fontSize: 16)))
              : ListView.builder(
                  itemCount: sortedSubjects.length,
                  itemBuilder: (ctx, i) {
                    final e = sortedSubjects[i];
                    final c = MockData.courses.firstWhere((course) => course.id == e.courseId);
                    bool isPassed = e.grade! <= 3.0; 
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppTheme.border)),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        leading: Container(
                          width: 50, height: 50,
                          decoration: BoxDecoration(color: isPassed ? AppTheme.success.withOpacity(0.1) : AppTheme.danger.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                          child: Center(child: Text(e.grade!.toStringAsFixed(2), style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: isPassed ? AppTheme.success : AppTheme.danger))),
                        ),
                        title: Row(
                          children: [
                            Text(c.code, style: const TextStyle(fontWeight: FontWeight.w900, color: AppTheme.primary, fontSize: 14)),
                            const SizedBox(width: 12),
                            Expanded(child: Text(c.title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15))),
                          ],
                        ),
                        subtitle: Padding(padding: const EdgeInsets.only(top: 4), child: Text(e.semester, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12, fontWeight: FontWeight.w600))),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text("${c.units} Units", style: const TextStyle(fontWeight: FontWeight.w800, color: AppTheme.textSecondary, fontSize: 13)),
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(color: isPassed ? AppTheme.success : AppTheme.danger, borderRadius: BorderRadius.circular(4)),
                              child: Text(isPassed ? "PASSED" : "FAILED", style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.white)),
                            )
                          ],
                        ),
                      ),
                    );
                  },
                ),
          ),
        ],
      ),
    );
  }

Widget _buildProfileTab() {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Account Settings", style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: AppTheme.textPrimary)),
              // --- FIXED: ADDED FOREGROUND COLOR & TEXT STYLE FOR VISIBILITY ---
              ElevatedButton.icon(
                onPressed: _showEditProfile,
                icon: const Icon(Icons.edit_rounded, size: 16),
                label: const Text('Edit Profile', style: TextStyle(fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary, // Deepened for better contrast
                  foregroundColor: Colors.white,     // Forces icon and text to be stark white
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              )
            ],
          ),
          const SizedBox(height: 32),
          Container(
            padding: const EdgeInsets.all(40),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: AppTheme.border)),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  children: [
                    Container(
                      width: 120, height: 120, 
                      decoration: BoxDecoration(color: AppTheme.primaryLight.withOpacity(0.1), shape: BoxShape.circle), 
                      child: Center(child: Text(me.initials, style: const TextStyle(fontSize: 40, fontWeight: FontWeight.w900, color: AppTheme.primary)))
                    ),
                    const SizedBox(height: 20),
                    const Text("Active Student", style: TextStyle(color: AppTheme.success, fontWeight: FontWeight.bold, fontSize: 12)),
                  ],
                ),
                const SizedBox(width: 48),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Academic Identity", style: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.w800, color: AppTheme.primary)),
                      const Divider(height: 32),
                      _profileInfoRow("Full Name", me.fullName),
                      _profileInfoRow("Student ID", me.studentId),
                      _profileInfoRow("Email", me.email),
                      _profileInfoRow("Phone", me.phone),
                      _profileInfoRow("Degree Program", me.program),
                      _profileInfoRow("Classification", me.yearLevel),
                    ],
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _profileInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          SizedBox(width: 140, child: Text(label, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13, fontWeight: FontWeight.bold))),
          Expanded(child: Text(value, style: const TextStyle(color: AppTheme.textPrimary, fontSize: 15, fontWeight: FontWeight.w800))),
        ],
      ),
    );
  }

  Widget _buildSidebar() {
    return Container(
      width: 260, color: AppTheme.sidebarBg,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLogo(),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text('STUDENT ACCESS', style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w900, color: AppTheme.sidebarText.withOpacity(0.3), letterSpacing: 1.5)),
          ),
          const SizedBox(height: 12),
          _buildNavItem(icon: Icons.grid_view_rounded, label: 'Dashboard', index: 0),
          _buildNavItem(icon: Icons.calendar_today_rounded, label: 'My Schedule', index: 1),
          _buildNavItem(icon: Icons.assignment_rounded, label: 'Curriculum', index: 2),
          _buildNavItem(icon: Icons.grading_rounded, label: 'Academic Grades', index: 3),
          _buildNavItem(icon: Icons.person_pin_rounded, label: 'Profile', index: 4),
          const Spacer(),
          _buildSidebarUser(),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildNavItem({required IconData icon, required String label, required int index}) {
    final isActive = _selectedIndex == index;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4), 
      child: InkWell(
        onTap: () => setState(() => _selectedIndex = index),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14), 
          decoration: BoxDecoration(color: isActive ? AppTheme.primaryLight.withOpacity(0.15) : Colors.transparent, borderRadius: BorderRadius.circular(12)),
          child: Row(
            children: [
              Icon(icon, size: 20, color: isActive ? Colors.white : AppTheme.sidebarText.withOpacity(0.5)),
              const SizedBox(width: 14),
              Text(label, style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: isActive ? FontWeight.w800 : FontWeight.w600, color: isActive ? Colors.white : AppTheme.sidebarText.withOpacity(0.6))), 
              if (index == 1 && myEnrollments.isNotEmpty) ...[
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(color: AppTheme.warning, borderRadius: BorderRadius.circular(6)),
                  child: Text('${myEnrollments.length}', style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w900)),
                )
              ]
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
              'assets/logo.jpg', width: 40, height: 40, fit: BoxFit.cover,
              errorBuilder: (ctx, err, stack) => Container(width: 40, height: 40, decoration: BoxDecoration(color: AppTheme.primaryLight, borderRadius: BorderRadius.circular(10)), child: const Icon(Icons.school_rounded, color: Colors.white, size: 22)),
            ),
          ),
          const SizedBox(width: 14),
          Text('ISATU Portal', style: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.w900, color: Colors.white)),
        ],
      ),
    );
  }

  Widget _buildSidebarUser() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16), 
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: Colors.white.withOpacity(0.04), borderRadius: BorderRadius.circular(16)),
        child: Row(
          children: [
            Container(width: 38, height: 38, decoration: BoxDecoration(color: AppTheme.primaryLight, borderRadius: BorderRadius.circular(10)), child: Center(child: Text(me.initials, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w900)))),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${me.firstName} ${me.lastName}', style: GoogleFonts.plusJakartaSans(fontSize: 13, color: Colors.white, fontWeight: FontWeight.w800), overflow: TextOverflow.ellipsis),
                  Text(me.email, style: GoogleFonts.plusJakartaSans(fontSize: 11, color: AppTheme.sidebarText.withOpacity(0.4)), overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
            IconButton(icon: Icon(Icons.power_settings_new_rounded, size: 20, color: AppTheme.sidebarText.withOpacity(0.4)), onPressed: _handleLogout),
          ],
        ),
      ),
    );
  }
}