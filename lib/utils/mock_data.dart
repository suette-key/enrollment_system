import 'package:flutter/material.dart';
import '../models/student.dart';
import '../models/course.dart';
import '../models/enrollment.dart';
import '../models/department.dart'; 

class MockData {
  static final Map<String, String> userCredentials = {
    'admin@isatu.edu': 'admin123',
    'maria.santos@students.isatu.edu': 'password123',
    'juan.delacruz@students.isatu.edu': 'password123',
    'ana.reyes@students.isatu.edu': 'password123',
    'carlos.garcia@students.isatu.edu': 'password123',
    'elena.torres@students.isatu.edu': 'password123',
    'miguel.luna@students.isatu.edu': 'password123',
    'sofia.villanueva@students.isatu.edu': 'password123',
    'leo.bautista@students.isatu.edu': 'password123',
  };

  static final List<Student> students = [
    Student(id: 'uid_1', studentId: '2024-0001', firstName: 'Maria', lastName: 'Santos', email: 'maria.santos@students.isatu.edu', phone: '09171234567', program: 'BS Computer Science', yearLevel: '3rd Year', gpa: 0.0),
    Student(id: 'uid_2', studentId: '2024-0002', firstName: 'Juan', lastName: 'dela Cruz', email: 'juan.delacruz@students.isatu.edu', phone: '09182345678', program: 'BS Information Technology', yearLevel: '2nd Year', gpa: 0.0),
    Student(id: 'uid_3', studentId: '2024-0003', firstName: 'Ana', lastName: 'Reyes', email: 'ana.reyes@students.isatu.edu', phone: '09193456789', program: 'BS Information Systems', yearLevel: '1st Year', gpa: 0.0),
    // NEW STUDENTS
    Student(id: 'uid_4', studentId: '2024-0004', firstName: 'Carlos', lastName: 'Garcia', email: 'carlos.garcia@students.isatu.edu', phone: '09204567890', program: 'BS Information Technology', yearLevel: '4th Year', gpa: 0.0),
    Student(id: 'uid_5', studentId: '2024-0005', firstName: 'Elena', lastName: 'Torres', email: 'elena.torres@students.isatu.edu', phone: '09215678901', program: 'BS Information Systems', yearLevel: '3rd Year', gpa: 0.0),
    Student(id: 'uid_6', studentId: '2024-0006', firstName: 'Miguel', lastName: 'Luna', email: 'miguel.luna@students.isatu.edu', phone: '09226789012', program: 'BS Computer Science', yearLevel: '2nd Year', gpa: 0.0),
    Student(id: 'uid_7', studentId: '2024-0007', firstName: 'Sofia', lastName: 'Villanueva', email: 'sofia.villanueva@students.isatu.edu', phone: '09237890123', program: 'BS Information Technology', yearLevel: '1st Year', gpa: 0.0),
    Student(id: 'uid_8', studentId: '2024-0008', firstName: 'Leo', lastName: 'Bautista', email: 'leo.bautista@students.isatu.edu', phone: '09248901234', program: 'BS Information Systems', yearLevel: '2nd Year', gpa: 0.0),
  ];

  static final List<Course> courses = [
    // --- CS 1st Year ---
    Course(id: 'cs_102', code: 'ICT 102', title: 'Introduction to Computing', instructorId: 'prof_1', schedule: 'MWF 7:30–9:00 AM', room: 'Lab 1', units: 3, currentCapacity: 0, maxCapacity: 40, departmentId: 'CCI', prerequisites: []),
    Course(id: 'cs_1', code: 'CS 1', title: 'Programming Logic Formulation', instructorId: 'prof_2', schedule: 'TTH 9:00–10:30 AM', room: 'Lab 2', units: 3, currentCapacity: 0, maxCapacity: 40, departmentId: 'CCI', prerequisites: []),
    Course(id: 'ge_1', code: 'GE 4 MATH', title: 'Mathematics in the Modern World', instructorId: 'prof_ge', schedule: 'MWF 9:00-10:00 AM', room: 'Rm 101', units: 3, currentCapacity: 0, maxCapacity: 40, departmentId: 'CAS', prerequisites: []),
    Course(id: 'ge_2', code: 'GE 5 ENG', title: 'Purposive Communication', instructorId: 'prof_ge', schedule: 'TTH 10:30-12:00 PM', room: 'Rm 102', units: 3, currentCapacity: 0, maxCapacity: 40, departmentId: 'CAS', prerequisites: []),
    Course(id: 'pe_1', code: 'PE 1', title: 'Movement Competency Training', instructorId: 'prof_pe', schedule: 'Sat 7:00-9:00 AM', room: 'Gym', units: 2, currentCapacity: 0, maxCapacity: 40, departmentId: 'CAS', prerequisites: []),
    Course(id: 'cs_103', code: 'ICT 103', title: 'Fundamentals of Programming', instructorId: 'prof_2', schedule: 'MWF 1:00–2:30 PM', room: 'Lab 2', units: 3, currentCapacity: 0, maxCapacity: 40, departmentId: 'CCI', prerequisites: ['CS 1']),
    Course(id: 'cs_105', code: 'ICT 105', title: 'Discrete Structure 1', instructorId: 'prof_3', schedule: 'TTH 1:00–2:30 PM', room: 'Rm 305', units: 3, currentCapacity: 0, maxCapacity: 35, departmentId: 'CCI', prerequisites: ['CS 1']),
    Course(id: 'cs_106', code: 'ICT 106', title: 'System Fundamentals', instructorId: 'prof_1', schedule: 'MWF 3:00-4:30 PM', room: 'Lab 3', units: 3, currentCapacity: 0, maxCapacity: 40, departmentId: 'CCI', prerequisites: ['ICT 102']),
    
    // --- CS 2nd Year ---
    Course(id: 'cs_104', code: 'ICT 104', title: 'Intermediate Programming', instructorId: 'prof_1', schedule: 'MWF 9:00–10:30 AM', room: 'Lab 3', units: 3, currentCapacity: 0, maxCapacity: 30, departmentId: 'CCI', prerequisites: ['ICT 103']),
    Course(id: 'cs_107', code: 'ICT 107', title: 'Data Structures and Algorithms', instructorId: 'prof_4', schedule: 'TTH 3:00–4:30 PM', room: 'Lab 1', units: 3, currentCapacity: 0, maxCapacity: 30, departmentId: 'CCI', prerequisites: ['ICT 103']),
    Course(id: 'cs_113', code: 'ICT 113', title: 'Networks and Communications', instructorId: 'prof_5', schedule: 'MWF 10:30-12:00 PM', room: 'Cisco Lab', units: 3, currentCapacity: 0, maxCapacity: 30, departmentId: 'CCI', prerequisites: []),
    Course(id: 'cs_m12', code: 'MATH 12', title: 'Introduction to Calculus', instructorId: 'prof_m', schedule: 'TTH 9:00-10:30 AM', room: 'Rm 201', units: 3, currentCapacity: 0, maxCapacity: 35, departmentId: 'CAS', prerequisites: ['ICT 105']),
    Course(id: 'cs_110', code: 'ICT 110', title: 'Applications Dev & Emerging Tech', instructorId: 'prof_6', schedule: 'MWF 1:00-2:30 PM', room: 'Lab 4', units: 3, currentCapacity: 0, maxCapacity: 30, departmentId: 'CCI', prerequisites: ['ICT 104']),
    Course(id: 'cs_111', code: 'ICT 111', title: 'Object Oriented Programming', instructorId: 'prof_4', schedule: 'TTH 10:30-12:00 PM', room: 'Lab 2', units: 3, currentCapacity: 0, maxCapacity: 30, departmentId: 'CCI', prerequisites: ['ICT 104']),
    Course(id: 'cs_112', code: 'ICT 112', title: 'Operating Systems', instructorId: 'prof_5', schedule: 'MWF 3:00-4:30 PM', room: 'Lab 1', units: 3, currentCapacity: 0, maxCapacity: 30, departmentId: 'CCI', prerequisites: ['ICT 107']),
    Course(id: 'cs_114', code: 'ICT 114', title: 'Software Engineering 1', instructorId: 'prof_7', schedule: 'TTH 1:00-2:30 PM', room: 'Rm 301', units: 3, currentCapacity: 0, maxCapacity: 30, departmentId: 'CCI', prerequisites: ['ICT 104']),
    Course(id: 'cs_122', code: 'ICT 122', title: 'Algorithms and Complexity', instructorId: 'prof_3', schedule: 'MWF 4:30-6:00 PM', room: 'Rm 302', units: 3, currentCapacity: 0, maxCapacity: 30, departmentId: 'CCI', prerequisites: ['ICT 107']),

    // --- CS 3rd Year ---
    Course(id: 'cs_108', code: 'ICT 108', title: 'Information Assurance and Security', instructorId: 'prof_8', schedule: 'TTH 7:30-9:00 AM', room: 'Lab 5', units: 3, currentCapacity: 0, maxCapacity: 30, departmentId: 'CCI', prerequisites: ['ICT 104']),
    Course(id: 'cs_115', code: 'ICT 115', title: 'Programming Languages', instructorId: 'prof_4', schedule: 'MWF 9:00-10:30 AM', room: 'Lab 2', units: 3, currentCapacity: 0, maxCapacity: 30, departmentId: 'CCI', prerequisites: ['ICT 107']),
    Course(id: 'cs_109', code: 'ICT 109', title: 'Information Management', instructorId: 'prof_9', schedule: 'TTH 10:30-12:00 PM', room: 'Lab 3', units: 3, currentCapacity: 0, maxCapacity: 30, departmentId: 'CCI', prerequisites: ['ICT 107']),
    Course(id: 'cs_117', code: 'ICT 117', title: 'Discrete Structure 2', instructorId: 'prof_3', schedule: 'MWF 1:00-2:30 PM', room: 'Rm 304', units: 3, currentCapacity: 0, maxCapacity: 30, departmentId: 'CCI', prerequisites: ['ICT 105']),
    Course(id: 'cs_118', code: 'ICT 118', title: 'Architecture and Organization', instructorId: 'prof_5', schedule: 'TTH 1:00-2:30 PM', room: 'Rm 305', units: 3, currentCapacity: 0, maxCapacity: 30, departmentId: 'CCI', prerequisites: ['ICT 102']),
    Course(id: 'cs_116', code: 'ICT 116', title: 'Human Computer Interaction', instructorId: 'prof_10', schedule: 'MWF 3:00-4:30 PM', room: 'Mac Lab', units: 3, currentCapacity: 0, maxCapacity: 30, departmentId: 'CCI', prerequisites: []),
    Course(id: 'cs_119', code: 'ICT 119', title: 'Parallel and Distributed Computing', instructorId: 'prof_11', schedule: 'TTH 3:00-4:30 PM', room: 'Lab 5', units: 3, currentCapacity: 0, maxCapacity: 30, departmentId: 'CCI', prerequisites: ['ICT 118']),
    Course(id: 'cs_120', code: 'ICT 120', title: 'Intelligent Systems', instructorId: 'prof_12', schedule: 'MWF 4:30-6:00 PM', room: 'Lab 4', units: 3, currentCapacity: 0, maxCapacity: 30, departmentId: 'CCI', prerequisites: ['ICT 107']),
    Course(id: 'cs_121', code: 'ICT 121', title: 'Software Engineering 2', instructorId: 'prof_7', schedule: 'Sat 8:00-11:00 AM', room: 'Lab 2', units: 3, currentCapacity: 0, maxCapacity: 30, departmentId: 'CCI', prerequisites: ['ICT 114']),
    Course(id: 'cs_t1', code: 'CS 7', title: 'Computer Science Thesis 1', instructorId: 'prof_13', schedule: 'Sat 1:00-4:00 PM', room: 'Rm 401', units: 3, currentCapacity: 0, maxCapacity: 30, departmentId: 'CCI', prerequisites: ['ICT 114', 'ICT 122']),

    // --- CS 4th Year ---
    Course(id: 'cs_123', code: 'ICT 123', title: 'Web Information Systems', instructorId: 'prof_14', schedule: 'TTH 9:00-10:30 AM', room: 'Lab 3', units: 3, currentCapacity: 0, maxCapacity: 30, departmentId: 'CCI', prerequisites: ['ICT 103']),
    Course(id: 'cs_136', code: 'ICT 136', title: 'Social Issues and Prof Practice 1', instructorId: 'prof_15', schedule: 'MWF 10:30-12:00 PM', room: 'Rm 402', units: 3, currentCapacity: 0, maxCapacity: 30, departmentId: 'CCI', prerequisites: ['ICT 102']),
    Course(id: 'cs_t2', code: 'CS 8', title: 'Computer Science Thesis 2', instructorId: 'prof_13', schedule: 'TTH 10:30-12:00 PM', room: 'Rm 401', units: 3, currentCapacity: 0, maxCapacity: 30, departmentId: 'CCI', prerequisites: ['CS 7']),
    Course(id: 'cs_124', code: 'ICT 124', title: 'Automata Theory and Formal Lang', instructorId: 'prof_3', schedule: 'MWF 1:00-2:30 PM', room: 'Rm 403', units: 3, currentCapacity: 0, maxCapacity: 30, departmentId: 'CCI', prerequisites: ['ICT 117']),
    Course(id: 'cs_125', code: 'ICT 125', title: 'Student Internship Program (300hrs)', instructorId: 'prof_16', schedule: 'TBA', room: 'Off-Campus', units: 3, currentCapacity: 0, maxCapacity: 100, departmentId: 'CCI', prerequisites: ['CS 8']),

    // --- BS INFORMATION TECHNOLOGY ---
    Course(id: 'it_101', code: 'IT 101', title: 'IT Fundamentals', instructorId: 'prof_it1', schedule: 'MWF 7:30–9:00 AM', room: 'Rm 101', units: 3, currentCapacity: 0, maxCapacity: 40, departmentId: 'CCI', prerequisites: []),
    Course(id: 'it_102', code: 'IT 102', title: 'Computer Programming 1', instructorId: 'prof_it2', schedule: 'TTH 9:00–10:30 AM', room: 'Lab 5', units: 3, currentCapacity: 0, maxCapacity: 40, departmentId: 'CCI', prerequisites: []),
    Course(id: 'it_103', code: 'IT 103', title: 'Computer Programming 2', instructorId: 'prof_it2', schedule: 'MWF 10:30–12:00 PM', room: 'Lab 5', units: 3, currentCapacity: 0, maxCapacity: 40, departmentId: 'CCI', prerequisites: ['IT 102']),
    Course(id: 'it_104', code: 'IT 104', title: 'Data Structures for IT', instructorId: 'prof_it3', schedule: 'TTH 1:00–2:30 PM', room: 'Lab 6', units: 3, currentCapacity: 0, maxCapacity: 40, departmentId: 'CCI', prerequisites: ['IT 103']),
    Course(id: 'it_201', code: 'IT 201', title: 'Networking 1', instructorId: 'prof_it4', schedule: 'MWF 1:00–2:30 PM', room: 'Cisco Lab', units: 3, currentCapacity: 0, maxCapacity: 30, departmentId: 'CCI', prerequisites: ['IT 101']),
    Course(id: 'it_202', code: 'IT 202', title: 'Networking 2', instructorId: 'prof_it4', schedule: 'TTH 3:00–4:30 PM', room: 'Cisco Lab', units: 3, currentCapacity: 0, maxCapacity: 30, departmentId: 'CCI', prerequisites: ['IT 201']),
    Course(id: 'it_203', code: 'IT 203', title: 'Web Systems and Technologies', instructorId: 'prof_it5', schedule: 'MWF 3:00–4:30 PM', room: 'Lab 7', units: 3, currentCapacity: 0, maxCapacity: 40, departmentId: 'CCI', prerequisites: ['IT 103']),
    Course(id: 'it_301', code: 'IT 301', title: 'Systems Integration', instructorId: 'prof_it7', schedule: 'MWF 9:00–10:30 AM', room: 'Rm 501', units: 3, currentCapacity: 0, maxCapacity: 30, departmentId: 'CCI', prerequisites: ['IT 203']),
    Course(id: 'it_402', code: 'IT 402', title: 'Capstone Project 2', instructorId: 'prof_it9', schedule: 'MWF 3:00–4:30 PM', room: 'Rm 502', units: 3, currentCapacity: 0, maxCapacity: 30, departmentId: 'CCI', prerequisites: ['IT 301']),

    // --- BS INFORMATION SYSTEMS ---
    Course(id: 'is_101', code: 'IS 101', title: 'Fundamentals of IS', instructorId: 'prof_is1', schedule: 'TTH 7:30–9:00 AM', room: 'Rm 601', units: 3, currentCapacity: 0, maxCapacity: 40, departmentId: 'CCI', prerequisites: []),
    Course(id: 'is_102', code: 'IS 102', title: 'Organizational Behavior in IT', instructorId: 'prof_is2', schedule: 'MWF 9:00–10:30 AM', room: 'Rm 602', units: 3, currentCapacity: 0, maxCapacity: 40, departmentId: 'CCI', prerequisites: []),
    Course(id: 'is_103', code: 'IS 103', title: 'IS Programming 1', instructorId: 'prof_is3', schedule: 'TTH 10:30–12:00 PM', room: 'Lab 9', units: 3, currentCapacity: 0, maxCapacity: 40, departmentId: 'CCI', prerequisites: []),
    Course(id: 'is_201', code: 'IS 201', title: 'Database Management Systems', instructorId: 'prof_is4', schedule: 'TTH 1:00–2:30 PM', room: 'Lab 10', units: 3, currentCapacity: 0, maxCapacity: 30, departmentId: 'CCI', prerequisites: ['IS 101']),
    Course(id: 'is_301', code: 'IS 301', title: 'Enterprise Architecture', instructorId: 'prof_is7', schedule: 'MWF 7:30–9:00 AM', room: 'Rm 605', units: 3, currentCapacity: 0, maxCapacity: 30, departmentId: 'CCI', prerequisites: ['IS 201']),
  ];

  static final List<Enrollment> enrollments = [
    // --- MARIA (3rd Year CS) ---
    Enrollment(id: 'eh_1', studentId: 'uid_1', courseId: 'cs_102', semester: '1st Sem 2022', status: EnrollmentStatus.completed, dateRequested: DateTime(2022, 6, 1), grade: 1.5),
    Enrollment(id: 'eh_2', studentId: 'uid_1', courseId: 'cs_1', semester: '1st Sem 2022', status: EnrollmentStatus.completed, dateRequested: DateTime(2022, 6, 1), grade: 1.75),
    Enrollment(id: 'eh_3', studentId: 'uid_1', courseId: 'cs_103', semester: '2nd Sem 2022', status: EnrollmentStatus.completed, dateRequested: DateTime(2022, 11, 1), grade: 2.0),
    Enrollment(id: 'eh_4', studentId: 'uid_1', courseId: 'cs_105', semester: '2nd Sem 2022', status: EnrollmentStatus.completed, dateRequested: DateTime(2022, 11, 1), grade: 5.0), 
    Enrollment(id: 'eh_5', studentId: 'uid_1', courseId: 'cs_104', semester: '1st Sem 2023', status: EnrollmentStatus.completed, dateRequested: DateTime(2023, 6, 1), grade: 2.25),
    Enrollment(id: 'eh_6', studentId: 'uid_1', courseId: 'cs_107', semester: '1st Sem 2023', status: EnrollmentStatus.completed, dateRequested: DateTime(2023, 6, 1), grade: 1.5),
    Enrollment(id: 'e_1', studentId: 'uid_1', courseId: 'cs_108', semester: '1st Sem 2024-2025', status: EnrollmentStatus.enrolled, dateRequested: DateTime.now().subtract(const Duration(days: 10))),
    Enrollment(id: 'e_2', studentId: 'uid_1', courseId: 'cs_115', semester: '1st Sem 2024-2025', status: EnrollmentStatus.enrolled, dateRequested: DateTime.now().subtract(const Duration(days: 9))),
    
    // --- JUAN (2nd Year IT) ---
    Enrollment(id: 'eh_7', studentId: 'uid_2', courseId: 'it_101', semester: '1st Sem 2023', status: EnrollmentStatus.completed, dateRequested: DateTime(2023, 6, 1), grade: 1.25),
    Enrollment(id: 'eh_8', studentId: 'uid_2', courseId: 'it_102', semester: '1st Sem 2023', status: EnrollmentStatus.completed, dateRequested: DateTime(2023, 6, 1), grade: 2.5),
    Enrollment(id: 'e_3', studentId: 'uid_2', courseId: 'it_201', semester: '1st Sem 2024-2025', status: EnrollmentStatus.pending, dateRequested: DateTime.now().subtract(const Duration(days: 5))),

    // --- ANA (1st Year IS) ---
    Enrollment(id: 'e_4', studentId: 'uid_3', courseId: 'is_101', semester: '1st Sem 2024-2025', status: EnrollmentStatus.pending, dateRequested: DateTime.now().subtract(const Duration(days: 1))),
    Enrollment(id: 'e_5', studentId: 'uid_3', courseId: 'is_102', semester: '1st Sem 2024-2025', status: EnrollmentStatus.enrolled, dateRequested: DateTime.now().subtract(const Duration(days: 2))),

    // --- CARLOS (4th Year IT) ---
    Enrollment(id: 'e_6', studentId: 'uid_4', courseId: 'it_402', semester: '1st Sem 2024-2025', status: EnrollmentStatus.enrolled, dateRequested: DateTime.now().subtract(const Duration(days: 12))),
    Enrollment(id: 'e_7', studentId: 'uid_4', courseId: 'it_301', semester: '1st Sem 2024-2025', status: EnrollmentStatus.completed, grade: 1.5, dateRequested: DateTime.now().subtract(const Duration(days: 300))),

    // --- ELENA (3rd Year IS) ---
    Enrollment(id: 'e_8', studentId: 'uid_5', courseId: 'is_301', semester: '1st Sem 2024-2025', status: EnrollmentStatus.enrolled, dateRequested: DateTime.now().subtract(const Duration(days: 8))),
    Enrollment(id: 'e_9', studentId: 'uid_5', courseId: 'is_201', semester: '1st Sem 2023-2024', status: EnrollmentStatus.completed, grade: 2.0, dateRequested: DateTime.now().subtract(const Duration(days: 365))),

    // --- MIGUEL (2nd Year CS) ---
    Enrollment(id: 'e_10', studentId: 'uid_6', courseId: 'cs_104', semester: '1st Sem 2024-2025', status: EnrollmentStatus.pending, dateRequested: DateTime.now().subtract(const Duration(days: 3))),
    Enrollment(id: 'e_11', studentId: 'uid_6', courseId: 'cs_107', semester: '1st Sem 2024-2025', status: EnrollmentStatus.enrolled, dateRequested: DateTime.now().subtract(const Duration(days: 4))),

    // --- SOFIA (1st Year IT) ---
    Enrollment(id: 'e_12', studentId: 'uid_7', courseId: 'it_101', semester: '1st Sem 2024-2025', status: EnrollmentStatus.enrolled, dateRequested: DateTime.now().subtract(const Duration(days: 1))),
    Enrollment(id: 'e_13', studentId: 'uid_7', courseId: 'it_102', semester: '1st Sem 2024-2025', status: EnrollmentStatus.pending, dateRequested: DateTime.now().subtract(const Duration(days: 1))),

    // --- LEO (2nd Year IS) ---
    Enrollment(id: 'e_14', studentId: 'uid_8', courseId: 'is_201', semester: '1st Sem 2024-2025', status: EnrollmentStatus.enrolled, dateRequested: DateTime.now().subtract(const Duration(days: 7))),
    Enrollment(id: 'e_15', studentId: 'uid_8', courseId: 'is_101', semester: '1st Sem 2023-2024', status: EnrollmentStatus.completed, grade: 1.75, dateRequested: DateTime.now().subtract(const Duration(days: 400))),
  ];

  static final List<Department> departments = [
    Department(code: 'CCI', name: 'College of Computing and Informatics', dean: 'Dr. Elena Bautista', totalStudents: 1200, totalCourses: 45, color: const Color(0xFF7C3AED)),
  ];

  static Map<String, int> get enrollmentByProgram => {
    'BS Computer Science': 450,
    'BS Information Technology': 520,
    'BS Information Systems': 230,
  };

  static List<Map<String, dynamic>> get monthlyEnrollment => [
    {'month': 'Jan', 'count': 42}, {'month': 'Feb', 'count': 38},
    {'month': 'Mar', 'count': 55}, {'month': 'Apr', 'count': 67},
    {'month': 'May', 'count': 48}, {'month': 'Jun', 'count': 130},
    {'month': 'Jul', 'count': 145}, {'month': 'Aug', 'count': 98},
    {'month': 'Sep', 'count': 62}, {'month': 'Oct', 'count': 45},
    {'month': 'Nov', 'count': 38}, {'month': 'Dec', 'count': 22},
  ];

  static const List<Color> avatarColors = [Color(0xFF2563AB), Color(0xFF7C3AED), Color(0xFFDB2777), Color(0xFF059669), Color(0xFFD97706), Color(0xFF0891B2)];
}