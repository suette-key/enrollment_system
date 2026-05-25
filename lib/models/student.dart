class Student {
  final String id; // Maps to Firebase Auth UID
  final String studentId; 
  final String firstName;
  final String lastName;
  final String email;
  final String phone;
  final String program;
  final String yearLevel;
  final double gpa; // Added from Class Diagram

  Student({
    required this.id,
    required this.studentId,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    required this.program,
    required this.yearLevel,
    this.gpa = 0.0,
  });

  String get fullName => '$firstName $lastName';
  String get initials => '${firstName[0]}${lastName[0]}'.toUpperCase();

  // Convert Firestore Document to Dart Object
  factory Student.fromMap(Map<String, dynamic> map, String documentId) {
    return Student(
      id: documentId,
      studentId: map['studentId'] ?? '',
      firstName: map['firstName'] ?? '',
      lastName: map['lastName'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'] ?? '',
      program: map['program'] ?? '',
      yearLevel: map['yearLevel'] ?? '',
      gpa: (map['gpa'] ?? 0.0).toDouble(),
    );
  }

  // Convert Dart Object to Firestore Document
  Map<String, dynamic> toMap() {
    return {
      'studentId': studentId,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'phone': phone,
      'program': program,
      'yearLevel': yearLevel,
      'gpa': gpa,
    };
  }
}