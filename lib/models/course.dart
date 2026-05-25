class Course {
  final String id; // Firestore Document ID
  final String code;
  final String title;
  final String instructorId; // Links to a User document UID
  final String schedule;
  final String room;
  final int units; 
  final int currentCapacity;
  final int maxCapacity;
  final String departmentId;
  final List<String> prerequisites; // Crucial for your prerequisite validation workflow

  Course({
    required this.id,
    required this.code,
    required this.title,
    required this.instructorId,
    required this.schedule,
    required this.room,
    required this.units,
    required this.currentCapacity,
    required this.maxCapacity,
    required this.departmentId,
    this.prerequisites = const [],
  });

  // I placed the getters right here!
  double get fillRate => maxCapacity == 0 ? 0 : currentCapacity / maxCapacity;
  bool get isFull => currentCapacity >= maxCapacity;
  bool get hasSpace => currentCapacity < maxCapacity;

  // Convert Firestore Document to Dart Object
  factory Course.fromMap(Map<String, dynamic> map, String documentId) {
    return Course(
      id: documentId,
      code: map['code'] ?? '',
      title: map['title'] ?? '',
      instructorId: map['instructorId'] ?? '',
      schedule: map['schedule'] ?? '',
      room: map['room'] ?? '',
      units: map['units']?.toInt() ?? 0,
      currentCapacity: map['currentCapacity']?.toInt() ?? 0,
      maxCapacity: map['maxCapacity']?.toInt() ?? 0,
      departmentId: map['departmentId'] ?? '',
      prerequisites: List<String>.from(map['prerequisites'] ?? []),
    );
  }

  // Convert Dart Object to Firestore Document
  Map<String, dynamic> toMap() {
    return {
      'code': code,
      'title': title,
      'instructorId': instructorId,
      'schedule': schedule,
      'room': room,
      'units': units,
      'currentCapacity': currentCapacity,
      'maxCapacity': maxCapacity,
      'departmentId': departmentId,
      'prerequisites': prerequisites,
    };
  }
}