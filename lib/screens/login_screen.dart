import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../utils/mock_data.dart';
import 'main_screen.dart'; // The Admin Dashboard
import 'student_dashboard.dart'; // The Student Dashboard

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isHovering = false; // Controls the hover state

  void _handleLogin() {
    final email = _emailController.text.trim().toLowerCase();
    final password = _passwordController.text;

    // 1. CHECK IF EMAIL EXISTS IN OUR "AUTH DATABASE"
    if (!MockData.userCredentials.containsKey(email)) {
       ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Account not found.'), backgroundColor: AppTheme.danger),
      );
      return;
    }

    // 2. CHECK IF PASSWORD MATCHES
    if (MockData.userCredentials[email] != password) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Incorrect password.'), backgroundColor: AppTheme.danger),
      );
      return; // Stop here if password is wrong
    }

    // 3. STUDENT CHECK
    if (email.endsWith('@students.isatu.edu')) {
      try {
        final student = MockData.students.firstWhere((s) => s.email == email);

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => StudentDashboard(studentId: student.id),
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Student account not found in database.'), backgroundColor: AppTheme.danger),
        );
      }
      return;
    }

    // 4. ADMIN CHECK
    if (email == 'admin@isatu.edu') {
      Navigator.pushReplacement(
        context, 
        MaterialPageRoute(builder: (context) => const MainScreen())
      );
      return;
    }

    // 5. INVALID FORMAT
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Invalid ISAT-U email address.'), backgroundColor: AppTheme.warning),
    );
  }

  // Helper method to automatically fill credentials and log in instantly
  void _quickLogin(String email, String password) {
    setState(() {
      _emailController.text = email;
      _passwordController.text = password;
    });
    _handleLogin();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          image: DecorationImage(
            image: const AssetImage('assets/isatu_bg.jpeg'),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              Colors.white.withValues(alpha: 0.3), 
              BlendMode.dstATop,
            ),
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Container(
              width: 400,
              padding: const EdgeInsets.all(40),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1), 
                    blurRadius: 20, 
                    offset: const Offset(0, 10)
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- LOGO SECTION ---
                  Center(
                    child: Image.asset(
                      'assets/logo.jpg',
                      height: 80,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(color: AppTheme.primaryLight.withValues(alpha: 0.1), shape: BoxShape.circle),
                          child: const Icon(Icons.school_rounded, size: 48, color: AppTheme.primary),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 24),
                  Center(
                    child: Text(
                      'ISAT U Portal', 
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 24, 
                        fontWeight: FontWeight.bold, 
                        color: AppTheme.textPrimary
                      )
                    ),
                  ),
                  Center(
                    child: Text(
                      'Sign in to continue', 
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14, 
                        color: AppTheme.textSecondary
                      )
                    ),
                  ),
                  const SizedBox(height: 32),
                  Text(
                    'Email Address', 
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12, 
                      fontWeight: FontWeight.w600, 
                      color: AppTheme.textPrimary
                    )
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _emailController,
                    textInputAction: TextInputAction.next,
                    decoration: InputDecoration(
                      hintText: 'Username or ISAT U email',
                      filled: true,
                      fillColor: Colors.white, 
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Password', 
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12, 
                      fontWeight: FontWeight.w600, 
                      color: AppTheme.textPrimary
                    )
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _passwordController,
                    obscureText: true,
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) => _handleLogin(), 
                    decoration: InputDecoration(
                      hintText: 'Password',
                      filled: true,
                      fillColor: Colors.white, 
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    ),
                  ),
                  const SizedBox(height: 32),
                  
                  // CUSTOM HOVER "SIGN IN" BUTTON
                  MouseRegion(
                    onEnter: (_) => setState(() => _isHovering = true),
                    onExit: (_) => setState(() => _isHovering = false),
                    cursor: SystemMouseCursors.click,
                    child: GestureDetector(
                      onTap: _handleLogin,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: double.infinity,
                        height: 48,
                        decoration: BoxDecoration(
                          color: _isHovering ? AppTheme.primaryLight : AppTheme.primary,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: _isHovering 
                            ? [BoxShadow(color: AppTheme.primaryLight.withValues(alpha: 0.4), blurRadius: 10, offset: const Offset(0, 4))]
                            : [],
                        ),
                        child: Center(
                          child: Text(
                            'Sign In', 
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 15, 
                              fontWeight: FontWeight.w600, 
                              color: Colors.white
                            )
                          ),
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 32),
                  const Divider(color: AppTheme.border),
                  const SizedBox(height: 16),
                  
                  // --- NEW: SYSTEM EVALUATION BANNER WITH ONE-CLICK LOGINS ---
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.bgMain,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppTheme.border),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.analytics_rounded, size: 16, color: AppTheme.primaryLight),
                            const SizedBox(width: 8),
                            Text(
                              'Evaluation Sandbox Keys',
                              style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w800, color: AppTheme.textPrimary),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        
                        // Admin Quick-Login Button
                        SizedBox(
                          width: double.infinity,
                          height: 36,
                          child: OutlinedButton.icon(
                            onPressed: () => _quickLogin('admin@isatu.edu', 'admin123'),
                            icon: const Icon(Icons.admin_panel_settings_rounded, size: 14),
                            label: const Text('Auto-Login as Admin', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppTheme.primaryLight,
                              side: const BorderSide(color: AppTheme.primaryLight),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        
                        // Student Quick-Login Button
                        SizedBox(
                          width: double.infinity,
                          height: 36,
                          child: OutlinedButton.icon(
                            onPressed: () => _quickLogin('maria.santos@students.isatu.edu', 'password123'),
                            icon: const Icon(Icons.person_rounded, size: 14),
                            label: const Text('Auto-Login as Student', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppTheme.textSecondary,
                              side: const BorderSide(color: AppTheme.border),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}