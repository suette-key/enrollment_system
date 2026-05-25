import '../models/student.dart';
import '../models/course.dart';
import '../models/enrollment.dart';
import '../utils/mock_data.dart';

// --- NEW: GLOBAL SYSTEM SETTINGS ---
class SystemSettings {
  static bool autoApprove = false;
  static int maxUnits = 24;
}

class EnrollmentController {

  static int getOccupancy(String courseId) {
    return MockData.enrollments.where((e) => 
      e.courseId == courseId && 
      (e.status == EnrollmentStatus.enrolled || 
       e.status == EnrollmentStatus.pending || 
       e.status == EnrollmentStatus.completed)
    ).length;
  }

  static bool isCourseFull(Course course) {
    return getOccupancy(course.id) >= course.maxCapacity;
  }
  
  static String? canEnroll(Student student, Course course) {
    bool alreadyEnrolled = MockData.enrollments.any((e) =>
        e.studentId == student.id && e.courseId == course.id &&
        (e.status == EnrollmentStatus.enrolled || e.status == EnrollmentStatus.pending || 
         e.status == EnrollmentStatus.completed || e.status == EnrollmentStatus.waitlisted));

    if (alreadyEnrolled) return 'You are already enrolled, pending, waitlisted, or have completed this course.';

    int studentYear = _parseYear(student.yearLevel);
    int courseYear = _parseCourseYear(course.code);

    if (courseYear > studentYear) {
      return 'Year Level Restriction! You are a ${student.yearLevel} standing student, but ${course.code} is a ${_getYearString(courseYear)} course.';
    }

    final activeEnrollments = MockData.enrollments.where((e) => 
        e.studentId == student.id && 
        (e.status == EnrollmentStatus.enrolled || e.status == EnrollmentStatus.pending || e.status == EnrollmentStatus.waitlisted));
    
    int currentUnits = 0;
    for (var e in activeEnrollments) {
      final c = MockData.courses.firstWhere((c) => c.id == e.courseId);
      currentUnits += c.units;
    }

    // --- WIRED TO DYNAMIC SYSTEM SETTINGS ---
    if ((currentUnits + course.units) > SystemSettings.maxUnits) {
      return 'Unit Limit Exceeded! Adding this course exceeds the ${SystemSettings.maxUnits}-unit maximum set by the Registrar.';
    }

    if (course.prerequisites.isNotEmpty) {
      List<String> failedOrMissing = [];
      for (String prereqCode in course.prerequisites) {
        try {
          final prereqCourse = MockData.courses.firstWhere((c) => c.code == prereqCode);
          bool hasPassed = MockData.enrollments.any((e) =>
              e.studentId == student.id && e.courseId == prereqCourse.id &&
              e.status == EnrollmentStatus.completed && e.grade != null && e.grade! <= 3.0);
          if (!hasPassed) failedOrMissing.add(prereqCode);
        } catch (_) { failedOrMissing.add(prereqCode); }
      }
      if (failedOrMissing.isNotEmpty) return 'Prerequisite Error! You must pass [ ${failedOrMissing.join(" and ")} ].';
    }

    if (course.schedule.trim().toUpperCase() != 'TBA') {
      final parts = course.schedule.split(' ');
      if (parts.length > 1) {
        final timeStr = course.schedule.substring(parts[0].length).trim();
        final timeRange = parseTimeRange(timeStr);
        if (timeRange != null && timeRange['end']! > 1170) { 
          return 'School hours are strictly limited until 7:30 PM. This course schedule exceeds operating hours.';
        }
      }
    }

    for (var e in activeEnrollments) {
      try {
        final existingCourse = MockData.courses.firstWhere((c) => c.id == e.courseId);
        if (_hasScheduleConflict(course.schedule, existingCourse.schedule)) {
          return 'Schedule Conflict! This class conflicts with ${existingCourse.code} (${existingCourse.schedule}).';
        }
      } catch (_) {}
    }

    return null; 
  }

  static void processEnrollment(Student student, Course course) {
    bool isFull = isCourseFull(course);

    // --- WIRED TO DYNAMIC SYSTEM SETTINGS ---
    EnrollmentStatus targetStatus = EnrollmentStatus.pending;
    if (isFull) {
      targetStatus = EnrollmentStatus.waitlisted;
    } else if (SystemSettings.autoApprove) {
      targetStatus = EnrollmentStatus.enrolled;
    }

    final newEnrollment = Enrollment(
      id: 'e_${DateTime.now().millisecondsSinceEpoch}',
      studentId: student.id,
      courseId: course.id,
      semester: '1st Sem 2024-2025',
      status: targetStatus,
      dateRequested: DateTime.now(),
    );

    MockData.enrollments.add(newEnrollment);
  }

  static void processDrop(Enrollment enrollment) {
    final idx = MockData.enrollments.indexWhere((e) => e.id == enrollment.id);
    if (idx != -1) {
      MockData.enrollments[idx] = MockData.enrollments[idx].copyWithStatus(EnrollmentStatus.dropped);
    }

    if (enrollment.status == EnrollmentStatus.waitlisted) return;

    final course = MockData.courses.firstWhere((c) => c.id == enrollment.courseId);
    if (!isCourseFull(course)) {
      final waitlisted = MockData.enrollments
          .where((e) => e.courseId == enrollment.courseId && e.status == EnrollmentStatus.waitlisted)
          .toList()..sort((a, b) => a.dateRequested.compareTo(b.dateRequested)); 

      if (waitlisted.isNotEmpty) {
        final luckyStudent = waitlisted.first;
        final luckyIdx = MockData.enrollments.indexWhere((e) => e.id == luckyStudent.id);
        
        // Obey auto-approve rule for waitlist bumps too!
        MockData.enrollments[luckyIdx] = MockData.enrollments[luckyIdx].copyWithStatus(
          SystemSettings.autoApprove ? EnrollmentStatus.enrolled : EnrollmentStatus.pending
        );
      }
    }
  }

  static void submitGrade(String enrollmentId, double grade) {
    final idx = MockData.enrollments.indexWhere((e) => e.id == enrollmentId);
    if (idx != -1) {
      final e = MockData.enrollments[idx];
      MockData.enrollments[idx] = Enrollment(
        id: e.id, studentId: e.studentId, courseId: e.courseId, semester: e.semester,
        status: EnrollmentStatus.completed, dateRequested: e.dateRequested, grade: grade,
      );
    }
  }

  static int approveAllPending() {
    int count = 0;
    for (int i = 0; i < MockData.enrollments.length; i++) {
      if (MockData.enrollments[i].status == EnrollmentStatus.pending) {
        MockData.enrollments[i] = MockData.enrollments[i].copyWithStatus(EnrollmentStatus.enrolled);
        count++;
      }
    }
    return count;
  }

  static int _parseYear(String yearStr) {
    if (yearStr.contains('1')) return 1; if (yearStr.contains('2')) return 2;
    if (yearStr.contains('3')) return 3; if (yearStr.contains('4')) return 4;
    return 1;
  }

  static int _parseCourseYear(String code) {
    final exactFirstYear = ['ICT 102', 'CS 1', 'ICT 103', 'ICT 105', 'ICT 106', 'GE 4 MATH', 'GE 5 ENG', 'PE 1'];
    final exactSecondYear = ['ICT 104', 'ICT 107', 'ICT 113', 'MATH 12', 'ICT 110', 'ICT 111', 'ICT 112', 'ICT 114', 'ICT 122'];
    final exactThirdYear = ['ICT 108', 'ICT 115', 'ICT 109', 'ICT 117', 'ICT 118', 'ICT 116', 'ICT 119', 'ICT 120', 'ICT 121', 'CS 7'];
    final exactFourthYear = ['ICT 123', 'ICT 136', 'CS 8', 'ICT 124', 'ICT 125'];

    if (exactFirstYear.contains(code)) return 1; if (exactSecondYear.contains(code)) return 2;
    if (exactThirdYear.contains(code)) return 3; if (exactFourthYear.contains(code)) return 4;

    final match = RegExp(r'\b[1-4]').firstMatch(code);
    if (match != null) return int.parse(match.group(0)!);
    return 1; 
  }

  static String _getYearString(int year) {
    if (year == 1) return '1st Year'; if (year == 2) return '2nd Year';
    if (year == 3) return '3rd Year'; if (year == 4) return '4th Year';
    return 'Unknown Year';
  }

  static bool _hasScheduleConflict(String sched1, String sched2) {
    if (sched1.trim().toLowerCase() == 'tba' || sched2.trim().toLowerCase() == 'tba') return false;
    final p1 = sched1.split(' '); final p2 = sched2.split(' ');
    if (p1.length < 2 || p2.length < 2) return false;
    final d1 = extractDays(p1[0]); final d2 = extractDays(p2[0]);
    if (d1.intersection(d2).isEmpty) return false;
    final r1 = parseTimeRange(sched1.substring(p1[0].length).trim());
    final r2 = parseTimeRange(sched2.substring(p2[0].length).trim());
    if (r1 == null || r2 == null) return false;
    return r1['start']! < r2['end']! && r2['start']! < r1['end']!;
  }
  
  static Set<String> extractDays(String dayStr) {
    final Set<String> days = {};
    for (int i = 0; i < dayStr.length; i++) {
      if (dayStr[i] == 'M') days.add('Mon'); if (dayStr[i] == 'W') days.add('Wed');
      if (dayStr[i] == 'F') days.add('Fri'); if (dayStr[i] == 'S') days.add('Sat');
      if (dayStr[i] == 'T') {
        if (i + 1 < dayStr.length && dayStr[i + 1] == 'H') { days.add('Thu'); i++; } 
        else { days.add('Tue'); }
      }
    }
    return days;
  }

  static Map<String, int>? parseTimeRange(String t) {
    try {
      final parts = t.replaceAll('–', '-').replaceAll('—', '-').split('-');
      String sStr = parts[0].trim(), eStr = parts[1].trim();
      String amPm = eStr.substring(eStr.length - 2).toUpperCase();
      eStr = eStr.substring(0, eStr.length - 2).trim();
      String sAmPm = amPm;
      if (sStr.toUpperCase().endsWith('AM') || sStr.toUpperCase().endsWith('PM')) {
        sAmPm = sStr.substring(sStr.length - 2).toUpperCase();
        sStr = sStr.substring(0, sStr.length - 2).trim();
      }
      int sMin = _toMin(sStr, sAmPm), eMin = _toMin(eStr, amPm);
      if (sMin > eMin && sAmPm == 'PM' && sMin >= 720) sMin -= 720;
      return {'start': sMin, 'end': eMin};
    } catch (_) { return null; }
  }

  static int _toMin(String t, String ap) {
    final s = t.split(':');
    int h = int.parse(s[0]), m = s.length > 1 ? int.parse(s[1]) : 0;
    if (ap == 'PM' && h != 12) h += 12;
    if (ap == 'AM' && h == 12) h = 0;
    return (h * 60) + m;
  }
}