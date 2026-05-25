import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import '../theme/app_theme.dart';
import '../utils/mock_data.dart';
import '../widgets/page_header.dart';

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const PageHeader(
              title: 'Reports & Analytics',
              subtitle: 'Academic Year 2024–2025 enrollment insights',
            ),
            const SizedBox(height: 20),
            _buildReportCards(),
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 3, child: _buildEnrollmentTrend()),
                const SizedBox(width: 16),
                Expanded(flex: 2, child: _buildStatusBreakdown()),
              ],
            ),
            const SizedBox(height: 16),
            _buildDepartmentTable(),
          ],
        ),
      ),
    );
  }

  Widget _buildReportCards() {
    final reports = [
      {'icon': Icons.summarize_rounded, 'title': 'Enrollment Summary', 'desc': 'Complete enrollment data by program', 'color': AppTheme.primaryLight, 'bg': const Color(0xFFEFF6FF)},
      {'icon': Icons.bar_chart_rounded, 'title': 'Retention Rate', 'desc': 'Student retention analytics', 'color': AppTheme.success, 'bg': const Color(0xFFECFDF5)},
      {'icon': Icons.trending_up_rounded, 'title': 'Growth Report', 'desc': 'Enrollment growth over time', 'color': const Color(0xFF7C3AED), 'bg': const Color(0xFFF5F3FF)},
      {'icon': Icons.grade_rounded, 'title': 'Academic Performance', 'desc': 'GPA distribution report', 'color': AppTheme.warning, 'bg': const Color(0xFFFFFBEB)},
    ];

    return GridView.count(
      crossAxisCount: 4,
      crossAxisSpacing: 14,
      childAspectRatio: 2.0,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: reports.map((r) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.bgCard,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppTheme.border),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: r['bg'] as Color,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(r['icon'] as IconData, color: r['color'] as Color, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(r['title'] as String, style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w700, color: AppTheme.textPrimary), overflow: TextOverflow.ellipsis),
                  Text(r['desc'] as String, style: GoogleFonts.plusJakartaSans(fontSize: 11, color: AppTheme.textSecondary), overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
            const Icon(Icons.download_rounded, size: 16, color: AppTheme.textSecondary),
          ],
        ),
      )).toList(),
    );
  }

  Widget _buildEnrollmentTrend() {
    final data = MockData.monthlyEnrollment;
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
          Text('Enrollment Trend', style: GoogleFonts.plusJakartaSans(fontSize: 15, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
          const SizedBox(height: 4),
          Text('12-month overview', style: GoogleFonts.plusJakartaSans(fontSize: 12, color: AppTheme.textSecondary)),
          const SizedBox(height: 20),
          SizedBox(
            height: 220,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (v) => FlLine(color: AppTheme.border, strokeWidth: 1),
                ),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 36,
                      getTitlesWidget: (v, _) => Text(v.toInt().toString(), style: GoogleFonts.plusJakartaSans(fontSize: 10, color: AppTheme.textSecondary)),
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (v, _) {
                        final idx = v.toInt();
                        if (idx >= 0 && idx < data.length) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(data[idx]['month'] as String, style: GoogleFonts.plusJakartaSans(fontSize: 10, color: AppTheme.textSecondary)),
                          );
                        }
                        return const SizedBox();
                      },
                    ),
                  ),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: data.asMap().entries.map((e) => FlSpot(e.key.toDouble(), (e.value['count'] as int).toDouble())).toList(),
                    isCurved: true,
                    color: AppTheme.primaryLight,
                    barWidth: 2.5,
                    isStrokeCapRound: true,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      color: AppTheme.primaryLight.withOpacity(0.08),
                    ),
                  ),
                ],
                minX: 0,
                maxX: 11,
                minY: 0,
                maxY: 200,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBreakdown() {
    final statuses = [
      {'label': 'Enrolled', 'value': 1248, 'color': AppTheme.success},
      {'label': 'Pending', 'value': 89, 'color': AppTheme.warning},
      {'label': 'Dropped', 'value': 43, 'color': AppTheme.danger},
      {'label': 'Graduated', 'value': 25, 'color': AppTheme.primaryLight},
    ];
    final total = statuses.fold(0, (sum, s) => sum + (s['value'] as int));

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
          Text('Status Breakdown', style: GoogleFonts.plusJakartaSans(fontSize: 15, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
          const SizedBox(height: 4),
          Text('Current semester', style: GoogleFonts.plusJakartaSans(fontSize: 12, color: AppTheme.textSecondary)),
          const SizedBox(height: 20),
          SizedBox(
            height: 160,
            child: PieChart(
              PieChartData(
                sections: statuses.map((s) {
                  final pct = (s['value'] as int) / total * 100;
                  return PieChartSectionData(
                    value: (s['value'] as int).toDouble(),
                    color: s['color'] as Color,
                    radius: 55,
                    title: '${pct.toStringAsFixed(0)}%',
                    titleStyle: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.white),
                  );
                }).toList(),
                sectionsSpace: 2,
                centerSpaceRadius: 30,
              ),
            ),
          ),
          const SizedBox(height: 16),
          ...statuses.map((s) {
            final pct = ((s['value'] as int) / total * 100).toStringAsFixed(1);
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: s['color'] as Color,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(child: Text(s['label'] as String, style: GoogleFonts.plusJakartaSans(fontSize: 12, color: AppTheme.textSecondary))),
                  Text('${s['value']}', style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
                  const SizedBox(width: 8),
                  Text('$pct%', style: GoogleFonts.plusJakartaSans(fontSize: 11, color: AppTheme.textSecondary)),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildDepartmentTable() {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.bgCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: AppTheme.border)),
            ),
            child: Row(
              children: [
                Text('Department Summary', style: GoogleFonts.plusJakartaSans(fontSize: 15, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppTheme.bgMain,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppTheme.border),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.download_rounded, size: 14, color: AppTheme.textSecondary),
                      const SizedBox(width: 6),
                      Text('Export CSV', style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.textSecondary)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Row(
              children: [
                Expanded(flex: 3, child: Text('DEPARTMENT', style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w600, color: AppTheme.textSecondary, letterSpacing: 0.5))),
                Expanded(flex: 2, child: Text('DEAN', style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w600, color: AppTheme.textSecondary, letterSpacing: 0.5))),
                Expanded(flex: 1, child: Text('STUDENTS', style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w600, color: AppTheme.textSecondary, letterSpacing: 0.5))),
                Expanded(flex: 1, child: Text('COURSES', style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w600, color: AppTheme.textSecondary, letterSpacing: 0.5))),
                Expanded(flex: 2, child: Text('ENROLLMENT RATE', style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w600, color: AppTheme.textSecondary, letterSpacing: 0.5))),
              ],
            ),
          ),
          const Divider(height: 1, color: AppTheme.border),
          ...MockData.departments.map((dept) {
            final totalStudents = MockData.departments.fold(0, (s, d) => s + d.totalStudents);
            final rate = dept.totalStudents / totalStudents;
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: Row(
                          children: [
                            Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: dept.color.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Center(
                                child: Text(dept.code.substring(0, 2),
                                    style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w800, color: dept.color)),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(dept.code, style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
                                  Text(dept.name, style: GoogleFonts.plusJakartaSans(fontSize: 11, color: AppTheme.textSecondary), overflow: TextOverflow.ellipsis),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(dept.dean, style: GoogleFonts.plusJakartaSans(fontSize: 13, color: AppTheme.textPrimary), overflow: TextOverflow.ellipsis),
                      ),
                      Expanded(
                        flex: 1,
                        child: Text('${dept.totalStudents}', style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
                      ),
                      Expanded(
                        flex: 1,
                        child: Text('${dept.totalCourses}', style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
                      ),
                      Expanded(
                        flex: 2,
                        child: Row(
                          children: [
                            Expanded(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: LinearProgressIndicator(
                                  value: rate,
                                  minHeight: 8,
                                  backgroundColor: AppTheme.border,
                                  valueColor: AlwaysStoppedAnimation<Color>(dept.color),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text('${(rate * 100).toStringAsFixed(0)}%',
                                style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w700, color: AppTheme.textSecondary)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1, color: AppTheme.border),
              ],
            );
          }),
        ],
      ),
    );
  }
}
