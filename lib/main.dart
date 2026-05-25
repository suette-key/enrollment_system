import 'package:flutter/material.dart';
import 'screens/login_screen.dart';

void main() {
  runApp(const EnrollmentApp());
}

class EnrollmentApp extends StatelessWidget {
  const EnrollmentApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ISATU Enrollment System',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        // Using your CAS/Primary blue color as the seed for the whole app
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF2563AB)),
        useMaterial3: true,
      ),
      home: const LoginScreen(),
    );
  }
}
