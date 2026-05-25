import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/mock_data.dart';
import '../models/course.dart';
import '../models/enrollment.dart';
import '../controllers/enrollment_controller.dart';
import '../widgets/page_header.dart';
import '../theme/app_theme.dart';

class GradingScreen extends StatefulWidget {
  const GradingScreen({super.key});

  @override
  State<GradingScreen> createState() => _GradingScreenState();
}

class _GradingScreenState extends State<GradingScreen> {
  String? _selectedCourseId;
  String _searchQuery = '';
  String _gradingStatusFilter = 'All'; // NEW STATUS FILTER

  @override
  Widget build(BuildContext context) {
    List<Enrollment> classList = [];
    
    if (_selectedCourseId != null) {
      classList = MockData.enrollments.where((e) => 
        e.courseId == _selectedCourseId && 
        (e.status == EnrollmentStatus.enrolled || e.status == EnrollmentStatus.completed)
      ).toList();
      
      // Apply Search Filter
      if (_searchQuery.isNotEmpty) {
        classList = classList.where((e) {
          final s = MockData.students.firstWhere((student) => student.id == e.studentId);
          return s.fullName.toLowerCase().contains(_searchQuery.toLowerCase()) || 
                 s.studentId.toLowerCase().contains(_searchQuery.toLowerCase());
        }).toList();
      }

      // --- NEW: APPLY STATUS FILTER ---
      if (_gradingStatusFilter == 'Graded') {
        classList = classList.where((e) => e.grade != null).toList();
      } else if (_gradingStatusFilter == 'Pending') {
        classList = classList.where((e) => e.grade == null).toList();
      }
    }

    int totalInCourse = _selectedCourseId != null ? MockData.enrollments.where((e) => e.courseId == _selectedCourseId && (e.status == EnrollmentStatus.enrolled || e.status == EnrollmentStatus.completed)).length : 0;
    int gradedCount = _selectedCourseId != null ? MockData.enrollments.where((e) => e.courseId == _selectedCourseId && e.grade != null).length : 0;

    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const PageHeader(
            title: 'Grading Portal',
            subtitle: 'End-of-semester faculty grade entry and verification',
          ),
          const SizedBox(height: 32),
          
          Row(
            children: [
              // Course Selector
              Expanded(
                flex: 2,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  decoration: BoxDecoration(color: Colors.white, border: Border.all(color: AppTheme.border), borderRadius: BorderRadius.circular(10)),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String?>(
                      isExpanded: true,
                      value: _selectedCourseId,
                      hint: const Text('Select a Course to Grade', style: TextStyle(fontWeight: FontWeight.bold)),
                      items: MockData.courses.map((c) => DropdownMenuItem(
                        value: c.id, 
                        child: Text('${c.code} - ${c.title}', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14))
                      )).toList(),
                      onChanged: (val) {
                        setState(() {
                          _selectedCourseId = val;
                          _gradingStatusFilter = 'All'; // Reset filter when changing courses
                        });
                      },
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              
              // --- NEW: STATUS FILTER DROPDOWN ---
              Expanded(
                flex: 1,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  decoration: BoxDecoration(
                    color: _selectedCourseId == null ? AppTheme.bgMain : Colors.white, 
                    border: Border.all(color: AppTheme.border), 
                    borderRadius: BorderRadius.circular(10)
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      isExpanded: true,
                      value: _gradingStatusFilter,
                      icon: const Icon(Icons.filter_list_rounded, size: 20),
                      items: ['All', 'Pending', 'Graded'].map((s) => DropdownMenuItem(
                        value: s, 
                        child: Text('Status: $s', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13))
                      )).toList(),
                      onChanged: _selectedCourseId == null ? null : (val) => setState(() => _gradingStatusFilter = val!),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              
              // Student Search
              Expanded(
                flex: 1,
                child: TextField(
                  onChanged: (v) => setState(() => _searchQuery = v),
                  enabled: _selectedCourseId != null,
                  decoration: InputDecoration(
                    hintText: 'Search student...', prefixIcon: const Icon(Icons.search, size: 20),
                    filled: true, fillColor: _selectedCourseId == null ? AppTheme.bgMain : Colors.white,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppTheme.border)),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          Expanded(
            child: _selectedCourseId == null
              ? _buildEmptyState()
              : Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppTheme.border)),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(color: AppTheme.primaryLight.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                            child: const Icon(Icons.analytics_rounded, color: AppTheme.primaryLight),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Overall Grading Progress', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold)),
                                const SizedBox(height: 8),
                                LinearProgressIndicator(
                                  value: totalInCourse == 0 ? 0 : gradedCount / totalInCourse,
                                  backgroundColor: AppTheme.bgMain,
                                  color: gradedCount == totalInCourse && totalInCourse > 0 ? AppTheme.success : AppTheme.primaryLight,
                                  minHeight: 8,
                                  borderRadius: BorderRadius.circular(4),
                                )
                              ],
                            ),
                          ),
                          const SizedBox(width: 24),
                          Text('$gradedCount / $totalInCourse', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: AppTheme.primary)),
                          const SizedBox(width: 8),
                          const Text('Graded', style: TextStyle(color: AppTheme.textSecondary, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                      child: Row(
                        children: [
                          Expanded(flex: 3, child: Text('STUDENT NAME & ID', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.textSecondary))),
                          SizedBox(width: 100, child: Text('FINAL GRADE', textAlign: TextAlign.center, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.textSecondary))),
                          SizedBox(width: 60),
                        ],
                      ),
                    ),
                    const Divider(height: 1),
                    
                    Expanded(
                      child: classList.isEmpty 
                        ? Center(child: Text("No students match this filter.", style: TextStyle(color: AppTheme.textSecondary.withOpacity(0.7), fontSize: 16)))
                        : ListView.builder(
                            itemCount: classList.length,
                            itemBuilder: (ctx, i) {
                              final e = classList[i];
                              final student = MockData.students.firstWhere((s) => s.id == e.studentId);
                              return _GradeInputRow(
                                enrollment: e,
                                studentName: student.fullName,
                                studentId: student.studentId,
                                onGradeSubmitted: () => setState(() {}),
                              );
                            },
                          ),
                    ),
                  ],
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.drive_file_rename_outline_rounded, size: 64, color: AppTheme.border.withOpacity(0.8)),
          const SizedBox(height: 16),
          const Text('Select a course from the dropdown above to begin grading.', style: TextStyle(color: AppTheme.textSecondary, fontSize: 16)),
        ],
      ),
    );
  }
}

class _GradeInputRow extends StatefulWidget {
  final Enrollment enrollment;
  final String studentName;
  final String studentId;
  final VoidCallback onGradeSubmitted;

  const _GradeInputRow({required this.enrollment, required this.studentName, required this.studentId, required this.onGradeSubmitted});

  @override
  State<_GradeInputRow> createState() => _GradeInputRowState();
}

class _GradeInputRowState extends State<_GradeInputRow> {
  late TextEditingController _ctrl;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.enrollment.grade?.toString() ?? '');
  }

  @override
  void didUpdateWidget(covariant _GradeInputRow oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.enrollment.id != widget.enrollment.id) {
      _ctrl.text = widget.enrollment.grade?.toString() ?? '';
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _saveGrade() {
    if (_ctrl.text.trim().isEmpty) return;
    double? parsedGrade = double.tryParse(_ctrl.text.trim());
    
    if (parsedGrade == null || parsedGrade < 1.0) {
      setState(() => _hasError = true);
      return;
    }

    setState(() => _hasError = false);
    if (parsedGrade > 3.0) parsedGrade = 5.0;

    EnrollmentController.submitGrade(widget.enrollment.id, parsedGrade);
    widget.onGradeSubmitted();
  }

  @override
  Widget build(BuildContext context) {
    bool isLocked = widget.enrollment.grade != null;

    return Container(
      decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: AppTheme.border))),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.studentName, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: AppTheme.textPrimary)),
                const SizedBox(height: 2),
                Text(widget.studentId, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          
          if (isLocked)
            TextButton.icon(
              onPressed: () {
                final idx = MockData.enrollments.indexWhere((en) => en.id == widget.enrollment.id);
                MockData.enrollments[idx] = Enrollment(
                  id: widget.enrollment.id, studentId: widget.enrollment.studentId, courseId: widget.enrollment.courseId, semester: widget.enrollment.semester,
                  status: EnrollmentStatus.enrolled, dateRequested: widget.enrollment.dateRequested, grade: null
                );
                _ctrl.clear();
                widget.onGradeSubmitted();
              },
              icon: const Icon(Icons.lock_rounded, size: 14, color: AppTheme.warning),
              label: const Text("Unlock", style: TextStyle(color: AppTheme.warning, fontSize: 12, fontWeight: FontWeight.bold)),
            ),
            
          const SizedBox(width: 16),
          
          SizedBox(
            width: 100,
            child: TextField(
              controller: _ctrl,
              enabled: !isLocked,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*'))],
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: isLocked ? AppTheme.textSecondary : AppTheme.textPrimary),
              onSubmitted: (_) => _saveGrade(),
              decoration: InputDecoration(
                hintText: 'e.g. 1.5',
                filled: true,
                fillColor: isLocked ? AppTheme.success.withOpacity(0.1) : AppTheme.bgMain,
                contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
                errorText: _hasError ? 'Invalid' : null,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: isLocked ? AppTheme.success.withOpacity(0.5) : AppTheme.border)),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppTheme.border)),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppTheme.primary, width: 2)),
              ),
            ),
          ),
          
          SizedBox(
            width: 60,
            child: !isLocked
              ? IconButton(icon: const Icon(Icons.keyboard_return_rounded, color: AppTheme.primaryLight), onPressed: _saveGrade, tooltip: 'Save Grade (Enter)')
              : const Icon(Icons.check_circle_rounded, color: AppTheme.success),
          )
        ],
      ),
    );
  }
}