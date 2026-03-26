import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../auth/auth_service.dart';
import '../models/models.dart';
import 'dashboard_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _loading = false;
  String? _error;

  Future<void> _login() async {
    setState(() { _loading = true; _error = null; });
    try {
      final user = await AuthService().signIn(
        _emailCtrl.text.trim(),
        _passCtrl.text.trim(),
      );
      if (!mounted) return;
      if (user != null) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => DashboardScreen(user: user)),
        );
      } else {
        setState(() => _error = 'Account not found in database.');
      }
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF0D0D0D), Color(0xFF1A0A0A), Color(0xFF0D0D0D)],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo
                  Container(
                    width: 90, height: 90,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        colors: [Color(0xFFE50914), Color(0xFFD4AF37)],
                      ),
                      boxShadow: [
                        BoxShadow(color: const Color(0xFFE50914).withOpacity(0.5), blurRadius: 24, spreadRadius: 2),
                      ],
                    ),
                    child: const Icon(Icons.leaderboard_rounded, size: 48, color: Colors.white),
                  ),
                  const SizedBox(height: 24),
                  Text('SCOREBOARD', style: GoogleFonts.outfit(
                    fontSize: 34, fontWeight: FontWeight.w800, letterSpacing: 4,
                    foreground: Paint()..shader = const LinearGradient(
                      colors: [Color(0xFFE50914), Color(0xFFD4AF37)],
                    ).createShader(const Rect.fromLTWH(0, 0, 200, 30)),
                  )),
                  const SizedBox(height: 6),
                  Text('Performance Tracking System', style: GoogleFonts.inter(
                    fontSize: 13, color: Colors.white54, letterSpacing: 1,
                  )),
                  const SizedBox(height: 48),
                  // Email
                  _buildField(_emailCtrl, 'Email', Icons.email_outlined, false),
                  const SizedBox(height: 14),
                  // Password
                  _buildField(_passCtrl, 'Password', Icons.lock_outline, true),
                  if (_error != null) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE50914).withOpacity(0.15),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFFE50914).withOpacity(0.4)),
                      ),
                      child: Row(children: [
                        const Icon(Icons.error_outline, color: Color(0xFFE50914), size: 18),
                        const SizedBox(width: 8),
                        Expanded(child: Text(_error!, style: const TextStyle(color: Color(0xFFE50914), fontSize: 13))),
                      ]),
                    ),
                  ],
                  const SizedBox(height: 28),
                  // Login button
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: double.infinity,
                    height: 54,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      gradient: const LinearGradient(
                        colors: [Color(0xFFE50914), Color(0xFFD4AF37)],
                      ),
                      boxShadow: [
                        BoxShadow(color: const Color(0xFFE50914).withOpacity(0.4), blurRadius: 20, offset: const Offset(0, 8)),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: _loading ? null : _login,
                        borderRadius: BorderRadius.circular(14),
                        child: Center(
                          child: _loading
                              ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                              : Text('SIGN IN', style: GoogleFonts.outfit(
                                  fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white, letterSpacing: 2,
                                )),
                        ),
                      ),
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

  Widget _buildField(TextEditingController ctrl, String label, IconData icon, bool obscure) {
    return TextField(
      controller: ctrl,
      obscureText: obscure,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white54),
        prefixIcon: Icon(icon, color: const Color(0xFFD4AF37), size: 20),
        filled: true,
        fillColor: const Color(0xFF1A1A1A),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE50914), width: 1.5),
        ),
      ),
    );
  }
}
