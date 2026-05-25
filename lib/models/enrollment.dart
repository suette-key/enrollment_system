enum EnrollmentStatus { enrolled, pending, dropped, waitlisted, completed }

class Enrollment {
  final String id;
  final String studentId;
  final String courseId;
  final String semester;
  final EnrollmentStatus status;
  final DateTime dateRequested;
  final double? grade;

  Enrollment({
    required this.id,
    required this.studentId,
    required this.courseId,
    required this.semester,
    required this.status,
    required this.dateRequested,
    this.grade,
  });

  Enrollment copyWithStatus(EnrollmentStatus newStatus) {
    return Enrollment(
      id: id,
      studentId: studentId,
      courseId: courseId,
      semester: semester,
      status: newStatus, 
      dateRequested: dateRequested,
      grade: grade,
    );
  }  

  // Convert Firestore Document to Dart Object
  factory Enrollment.fromMap(Map<String, dynamic> map, String documentId) {
    return Enrollment(
      id: documentId,
      studentId: map['studentId'] ?? '',
      courseId: map['courseId'] ?? '',
      semester: map['semester'] ?? '',
      status: EnrollmentStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => EnrollmentStatus.pending,
      ),
      dateRequested: map['dateRequested'] != null 
          ? DateTime.parse(map['dateRequested']) 
          : DateTime.now(),
      grade: map['grade']?.toDouble(),
    );
  }

  // Convert Dart Object to Firestore Document
  Map<String, dynamic> toMap() {
    return {
      'studentId': studentId,
      'courseId': courseId,
      'semester': semester,
      'status': status.name, 
      'dateRequested': dateRequested.toIso8601String(),
      'grade': grade,
    };
  }
}