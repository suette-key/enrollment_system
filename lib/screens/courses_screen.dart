import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/mock_data.dart';
import '../models/course.dart';
import '../controllers/enrollment_controller.dart';
import '../widgets/page_header.dart';
import '../theme/app_theme.dart';

class CoursesScreen extends StatefulWidget {
  const CoursesScreen({super.key});

  @override
  State<CoursesScreen> createState() => _CoursesScreenState();
}

class _CoursesScreenState extends State<CoursesScreen> {
  String _searchQuery = '';
  String? _filterProgram;

  void _showDeleteConfirmation(Course c) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Course?'),
        content: Text('Are you sure you want to delete ${c.code}? This action cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.danger),
            onPressed: () {
              setState(() => MockData.courses.removeWhere((course) => course.id == c.id));
              Navigator.pop(ctx);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  // --- NEW: ADD COURSE FORM ---
  void _showAddCourseForm() {
    final codeCtrl = TextEditingController();
    final titleCtrl = TextEditingController();
    final schedCtrl = TextEditingController(text: 'MWF 9:00-10:30 AM');
    final roomCtrl = TextEditingController(text: 'TBA');
    String unitsStr = '3';
    String capStr = '40';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('Add New Course', style: TextStyle(fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: SizedBox(
              width: 400,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _formField('Course Code (e.g. CS 101)', codeCtrl),
                  _formField('Descriptive Title', titleCtrl),
                  Row(
                    children: [
                      Expanded(child: _formDropdown('Units', unitsStr, ['1', '2', '3', '4', '5', '6'], (v) => setDialogState(() => unitsStr = v!))),
                      const SizedBox(width: 12),
                      Expanded(child: _formDropdown('Max Capacity', capStr, ['20', '30', '40', '50'], (v) => setDialogState(() => capStr = v!))),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _formField('Schedule (e.g. MWF 7:30-9:00 AM)', schedCtrl),
                  _formField('Room Assignment', roomCtrl),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () {
                if (codeCtrl.text.isEmpty || titleCtrl.text.isEmpty) return;
                
                final newCourse = Course(
                  id: 'new_${DateTime.now().millisecondsSinceEpoch}',
                  code: codeCtrl.text.trim().toUpperCase(),
                  title: titleCtrl.text.trim(),
                  units: int.parse(unitsStr),
                  maxCapacity: int.parse(capStr),
                  currentCapacity: 0,
                  schedule: schedCtrl.text.trim(),
                  room: roomCtrl.text.trim(),
                  instructorId: 'TBA',
                  departmentId: 'CCI',
                  prerequisites: [],
                );

                setState(() => MockData.courses.insert(0, newCourse)); // Adds to top of list
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Course Successfully Added!'), backgroundColor: AppTheme.success));
              },
              child: const Text('Save Course'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _formField(String label, TextEditingController ctrl) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: TextField(controller: ctrl, decoration: InputDecoration(labelText: label, filled: true, fillColor: AppTheme.bgMain, border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none))),
  );

  Widget _formDropdown(String label, String value, List<String> items, ValueChanged<String?> onChanged) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.textSecondary)),
      const SizedBox(height: 4),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(color: AppTheme.bgMain, borderRadius: BorderRadius.circular(8)),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            isExpanded: true, value: value,
            items: items.map((i) => DropdownMenuItem(value: i, child: Text(i, style: const TextStyle(fontSize: 14)))).toList(),
            onChanged: onChanged,
          ),
        ),
      ),
    ],
  );

  @override
  Widget build(BuildContext context) {
    final filteredCourses = MockData.courses.where((c) {
      final matchesSearch = c.title.toLowerCase().contains(_searchQuery.toLowerCase()) || c.code.toLowerCase().contains(_searchQuery.toLowerCase());
      bool matchesProgram = true;
      if (_filterProgram == 'Computer Science') matchesProgram = c.code.startsWith('CS') || c.code.startsWith('ICT') || c.code.startsWith('ANIM');
      if (_filterProgram == 'Information Technology') matchesProgram = c.code.startsWith('IT');
      if (_filterProgram == 'Information Systems') matchesProgram = c.code.startsWith('IS');
      return matchesSearch && matchesProgram;
    }).toList();

    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PageHeader(
            title: 'Course Management',
            subtitle: 'Manage curriculum, schedules, and capacity',
            actions: [
              ElevatedButton.icon(
                onPressed: _showAddCourseForm, // Wired up!
                icon: const Icon(Icons.add_rounded), label: const Text('Add New Course'),
              ),
            ],
          ),
          const SizedBox(height: 32),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: TextField(
                  onChanged: (v) => setState(() => _searchQuery = v),
                  decoration: InputDecoration(
                    hintText: 'Search course code or title...', prefixIcon: const Icon(Icons.search, size: 20),
                    filled: true, fillColor: Colors.white,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppTheme.border)),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                flex: 1,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                  decoration: BoxDecoration(color: Colors.white, border: Border.all(color: AppTheme.border), borderRadius: BorderRadius.circular(10)),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String?>(
                      isExpanded: true, value: _filterProgram, hint: const Text('All Programs', style: TextStyle(fontSize: 14)),
                      items: [null, 'Computer Science', 'Information Technology', 'Information Systems'].map((p) => DropdownMenuItem(value: p, child: Text(p ?? 'All Programs', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)))).toList(),
                      onChanged: (v) => setState(() => _filterProgram = v),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Expanded(
            child: filteredCourses.isEmpty
              ? const Center(child: Text("No courses found.", style: TextStyle(color: AppTheme.textSecondary, fontSize: 16)))
              : ListView.builder(itemCount: filteredCourses.length, itemBuilder: (ctx, i) => _courseRow(filteredCourses[i])),
          ),
        ],
      ),
    );
  }

  Widget _courseRow(Course c) {
    int currentOccupancy = EnrollmentController.getOccupancy(c.id);
    bool isFull = currentOccupancy >= c.maxCapacity;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppTheme.border)),
      child: Row(
        children: [
          Container(
            width: 90, padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(color: AppTheme.primaryLight.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
            child: Center(child: Text(c.code, style: const TextStyle(color: AppTheme.primaryLight, fontWeight: FontWeight.w900, fontSize: 13))),
          ),
          const SizedBox(width: 24),
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(c.title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: AppTheme.textPrimary)),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.access_time_rounded, size: 14, color: AppTheme.textSecondary),
                    const SizedBox(width: 6),
                    Text('${c.schedule}  •  Room: ${c.room}', style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary, fontWeight: FontWeight.w500)),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            flex: 1,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text("${c.units} Units", style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800)),
                const SizedBox(height: 4),
                Text("$currentOccupancy/${c.maxCapacity} Enrolled", style: TextStyle(fontSize: 12, color: isFull ? AppTheme.danger : AppTheme.success, fontWeight: FontWeight.w700)),
              ],
            ),
          ),
          const SizedBox(width: 32),
          IconButton(icon: const Icon(Icons.delete_sweep_rounded, color: AppTheme.danger, size: 24), onPressed: () => _showDeleteConfirmation(c), tooltip: 'Delete Course'),
        ],
      ),
    );
  }
}