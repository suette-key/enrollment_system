import 'package:flutter/material.dart';
import '../utils/mock_data.dart';
import '../models/student.dart';
import '../models/enrollment.dart';
import '../widgets/page_header.dart';
import '../theme/app_theme.dart';

class StudentsScreen extends StatefulWidget {
  const StudentsScreen({super.key});
  @override
  State<StudentsScreen> createState() => _StudentsScreenState();
}

class _StudentsScreenState extends State<StudentsScreen> {
  String _search = '';
  String? _filterProgram;
  String? _filterYear;
  String? _filterSection;

  final Map<String, List<String>> _sectionMapping = {
    'BS Computer Science': ['CS-A', 'CS-B'],
    'BS Information Technology': ['IT-A', 'IT-B', 'IT-C', 'IT-D'],
    'BS Information Systems': ['IS-A'],
  };

  // --- NEW: STUDENT DETAILS MODAL ---
  void _showStudentDetails(Student student) {
    // Calculate Active Units
    final activeEnrolls = MockData.enrollments.where((e) => e.studentId == student.id && (e.status == EnrollmentStatus.enrolled || e.status == EnrollmentStatus.pending));
    int activeUnits = 0;
    for (var e in activeEnrolls) {
      activeUnits += MockData.courses.firstWhere((c) => c.id == e.courseId).units;
    }

    // Calculate GPA
    final completed = MockData.enrollments.where((e) => e.studentId == student.id && e.status == EnrollmentStatus.completed && e.grade != null).toList();
    double gpa = 0.0;
    if (completed.isNotEmpty) {
      double points = 0; int units = 0;
      for (var e in completed) {
        final c = MockData.courses.firstWhere((c) => c.id == e.courseId);
        points += (e.grade! * c.units);
        units += c.units;
      }
      gpa = units > 0 ? (points / units) : 0.0;
    }

    // All records for timeline
    final allRecords = MockData.enrollments.where((e) => e.studentId == student.id).toList()..sort((a,b) => b.dateRequested.compareTo(a.dateRequested));

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        contentPadding: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: SizedBox(
          width: 500,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // HEADER
              Container(
                padding: const EdgeInsets.all(24),
                decoration: const BoxDecoration(color: AppTheme.bgCard, borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
                child: Row(
                  children: [
                    CircleAvatar(radius: 30, backgroundColor: AppTheme.primaryLight, child: Text(student.initials, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold))),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(student.fullName, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
                          Text('${student.studentId} • ${student.email}', style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                        ],
                      ),
                    ),
                    IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(ctx)),
                  ],
                ),
              ),
              // STATS
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(child: _detailStat('Program', student.program)),
                        Expanded(child: _detailStat('Year Level', student.yearLevel)),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(child: _detailStat('Cum. GPA', gpa > 0 ? gpa.toStringAsFixed(2) : 'N/A')),
                        Expanded(child: _detailStat('Active Units', '$activeUnits / 24')),
                      ],
                    ),
                    const Divider(height: 32),
                    const Align(alignment: Alignment.centerLeft, child: Text('Enrollment History', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14))),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 300, // Scrollable area for records
                      child: allRecords.isEmpty 
                        ? const Center(child: Text("No records found."))
                        : ListView.builder(
                            itemCount: allRecords.length,
                            itemBuilder: (context, index) {
                              final e = allRecords[index];
                              final c = MockData.courses.firstWhere((course) => course.id == e.courseId);
                              return ListTile(
                                dense: true,
                                contentPadding: EdgeInsets.zero,
                                title: Text(c.code, style: const TextStyle(fontWeight: FontWeight.bold)),
                                subtitle: Text(c.title, maxLines: 1, overflow: TextOverflow.ellipsis),
                                trailing: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(e.status.name.toUpperCase(), style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: e.status == EnrollmentStatus.completed ? AppTheme.success : AppTheme.warning)),
                                    if (e.grade != null) Text('Grade: ${e.grade}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                                  ],
                                ),
                              );
                            },
                          ),
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _detailStat(String label, String val) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary, fontWeight: FontWeight.w600)),
        const SizedBox(height: 2),
        Text(val, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final filtered = MockData.students.where((s) {
      final matchSearch = s.fullName.toLowerCase().contains(_search.toLowerCase());
      final matchProgram = _filterProgram == null || s.program == _filterProgram;
      final matchYear = _filterYear == null || s.yearLevel == _filterYear;
      return matchSearch && matchProgram && matchYear;
    }).toList();

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          PageHeader(
            title: 'Students', subtitle: 'CCI Enrollment Records',
            actions: [
              ElevatedButton.icon(
                onPressed: () => _showStudentForm(context, null),
                icon: const Icon(Icons.add_rounded), label: const Text('Add Student'),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildFilters(),
          const SizedBox(height: 16),
          Expanded(child: _buildStudentList(filtered)),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: TextField(
            onChanged: (v) => setState(() => _search = v),
            decoration: InputDecoration(
              hintText: 'Search by name...', prefixIcon: const Icon(Icons.search, size: 18),
              filled: true, fillColor: Colors.white,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppTheme.border)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          flex: 2,
          child: _dropdownFilter('All Programs', _filterProgram, _sectionMapping.keys.toList(), (v) {
            setState(() { _filterProgram = v; _filterSection = null; });
          }),
        ),
        const SizedBox(width: 10),
        Expanded(child: _dropdownFilter('All Years', _filterYear, ['1st Year', '2nd Year', '3rd Year', '4th Year'], (v) => setState(() => _filterYear = v))),
        const SizedBox(width: 10),
        Expanded(
          child: _dropdownFilter('All Sections', _filterSection, _filterProgram != null ? _sectionMapping[_filterProgram]! : _sectionMapping.values.expand((x) => x).toList(), (v) => setState(() => _filterSection = v)),
        ),
      ],
    );
  }

  Widget _dropdownFilter(String hint, String? value, List<String> items, ValueChanged<String?> onChanged) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10), border: Border.all(color: AppTheme.border)),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String?>(
          isExpanded: true, value: value,
          hint: Text(hint, style: const TextStyle(fontSize: 13, overflow: TextOverflow.ellipsis)),
          items: [null, ...items].map((i) => DropdownMenuItem(value: i, child: Text(i ?? hint, style: const TextStyle(fontSize: 13)))).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  void _showStudentForm(BuildContext context, Student? existing) {
    final firstCtrl = TextEditingController(text: existing?.firstName ?? '');
    final lastCtrl = TextEditingController(text: existing?.lastName ?? '');
    final emailCtrl = TextEditingController(text: existing?.email ?? '');
    final passCtrl = TextEditingController();
    String selectedProgram = existing?.program ?? 'BS Computer Science';
    String selectedYear = existing?.yearLevel ?? '1st Year';
    String selectedSection = _sectionMapping[selectedProgram]!.first;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: Text(existing == null ? 'Add New Student' : 'Edit Student', style: const TextStyle(fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: SizedBox(
              width: 400,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _formField('First Name', firstCtrl),
                  _formField('Last Name', lastCtrl),
                  Row(
                    children: [
                      Expanded(child: _formField('Email', emailCtrl)),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: TextField(controller: passCtrl, obscureText: true, decoration: const InputDecoration(labelText: 'Password', filled: true, border: InputBorder.none)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  _formDropdown('Program', selectedProgram, _sectionMapping.keys.toList(), (v) {
                    setDialogState(() { selectedProgram = v!; selectedSection = _sectionMapping[selectedProgram]!.first; });
                  }),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(child: _formDropdown('Year Level', selectedYear, ['1st Year', '2nd Year', '3rd Year', '4th Year'], (v) => setDialogState(() => selectedYear = v!))),
                      const SizedBox(width: 10),
                      Expanded(child: _formDropdown('Section', selectedSection, _sectionMapping[selectedProgram]!, (v) => setDialogState(() => selectedSection = v!))),
                    ],
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () {
                final newEmail = emailCtrl.text.trim().toLowerCase();
                final newPassword = passCtrl.text;
                final s = Student(
                  id: 'uid_${DateTime.now().millisecondsSinceEpoch}', studentId: '2024-${MockData.students.length + 1}',
                  firstName: firstCtrl.text.trim(), lastName: lastCtrl.text.trim(), email: newEmail,
                  phone: '00000000000', program: selectedProgram, yearLevel: selectedYear, gpa: 0.0,
                );
                setState(() {
                  MockData.students.add(s);
                  MockData.userCredentials[newEmail] = newPassword.isNotEmpty ? newPassword : 'password123';
                });
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${s.firstName} added!'), backgroundColor: AppTheme.success));
              },
              child: const Text('Register Student'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _formField(String label, TextEditingController ctrl) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: TextField(controller: ctrl, decoration: InputDecoration(labelText: label, filled: true, border: InputBorder.none)),
  );

  Widget _formDropdown(String label, String value, List<String> items, ValueChanged<String?> onChanged) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.textSecondary)),
      const SizedBox(height: 4),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
        decoration: BoxDecoration(color: AppTheme.bgMain, borderRadius: BorderRadius.circular(8)),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            isExpanded: true, value: value,
            items: items.map((i) => DropdownMenuItem(value: i, child: Text(i, style: const TextStyle(fontSize: 13)))).toList(),
            onChanged: onChanged,
          ),
        ),
      ),
    ],
  );

  Widget _buildStudentList(List<Student> list) {
    if (list.isEmpty) return const Center(child: Text('No students found.', style: TextStyle(color: AppTheme.textSecondary)));
    return ListView.builder(
      itemCount: list.length,
      itemBuilder: (ctx, i) => Card(
        elevation: 0,
        shape: RoundedRectangleBorder(side: const BorderSide(color: AppTheme.border), borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.only(bottom: 12),
        child: InkWell(
          onTap: () => _showStudentDetails(list[i]), // TRiggers the new modal!
          borderRadius: BorderRadius.circular(12),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            leading: CircleAvatar(backgroundColor: AppTheme.primaryLight, child: Text(list[i].initials, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
            title: Text(list[i].fullName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            subtitle: Text('${list[i].program} • ${list[i].yearLevel} • ${list[i].email}', style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
            trailing: const Icon(Icons.chevron_right_rounded, color: AppTheme.textSecondary),
          ),
        ),
      ),
    );
  }
}