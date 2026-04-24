// lib/screens/role_login_screen.dart
import 'package:flutter/material.dart';
import '../backend/models/user_role.dart';
import 'home_screen.dart';

class RoleLoginScreen extends StatefulWidget {
  const RoleLoginScreen({super.key});

  @override
  State<RoleLoginScreen> createState() => _RoleLoginScreenState();
}

class _RoleLoginScreenState extends State<RoleLoginScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _nameController = TextEditingController();

  // Simple fade animation
  late AnimationController _animationController;
  late Animation<double> _fadeIn;

  @override
  void initState() {
    super.initState();
    _animationController =
        AnimationController(vsync: this, duration: const Duration(milliseconds: 900));

    _fadeIn = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  void _login(UserRole role) {
    final name = _nameController.text.trim().isEmpty
        ? (role == UserRole.doctor ? 'Doctor' : 'Nurse')
        : _nameController.text.trim();

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => HomeScreen(
          role: role,
          userName: name,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        // Subtle gradient
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFFF5F7FA),
              Color(0xFFE8EAF6),
              Color(0xFFEDE7F6),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: FadeTransition(
            opacity: _fadeIn,
            child: Container(
              width: 340,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.local_hospital_rounded,
                    size: 58,
                    color: Color(0xFF5C6BC0),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'MDR Screening App',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.5,
                      color: Color(0xFF37474F),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Name Input
                  TextField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: 'Your name (optional)',
                      labelStyle: const TextStyle(color: Color(0xFF5C6BC0)),
                      filled: true,
                      fillColor: const Color(0xFFF8F9FA),
                      prefixIcon: const Icon(Icons.person, color: Color(0xFF5C6BC0)),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(color: Color(0xFF5C6BC0), width: 1.5),
                      ),
                    ),
                  ),

                  const SizedBox(height: 28),
                  const Text(
                    'Login as',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF37474F),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Buttons Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _login(UserRole.doctor),
                          icon: const Icon(Icons.medical_services_rounded),
                          label: const Text('Doctor'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF5C6BC0),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _login(UserRole.nurse),
                          icon: const Icon(Icons.healing_rounded),
                          label: const Text('Nurse'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF66BB6A),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}