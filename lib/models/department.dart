import 'package:flutter/material.dart';

class Department {
  final String code;
  final String name;
  final String dean;
  final int totalStudents;
  final int totalCourses;
  final Color color;

  Department({
    required this.code,
    required this.name,
    required this.dean,
    required this.totalStudents,
    required this.totalCourses,
    required this.color,
  });
}