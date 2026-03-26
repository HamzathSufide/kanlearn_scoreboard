import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:google_fonts/google_fonts.dart';
import 'firebase_options.dart';
import 'auth/auth_service.dart';
import 'screens/login_screen.dart';
import 'screens/dashboard_screen.dart';

void main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

    // Catch Flutter framework errors and send to Crashlytics
    FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;

    runApp(const ScoreboardApp());
  } catch (e, stack) {
    runApp(
      MaterialApp(
        home: Scaffold(
          backgroundColor: Colors.black,
          body: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Text(
                'STARTUP ERROR:\n\n$e\n\n$stack',
                style: const TextStyle(color: Colors.redAccent, fontSize: 12),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class ScoreboardApp extends StatelessWidget {
  const ScoreboardApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Scoreboard System',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: const Color(0xFFE50914),
        scaffoldBackgroundColor: const Color(0xFF0D0D0D),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFFE50914),
          secondary: Color(0xFFD4AF37),
          surface: Color(0xFF1A1A1A),
        ),
        textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme),
        navigationBarTheme: const NavigationBarThemeData(
          backgroundColor: Color(0xFF1A1A1A),
          indicatorColor: Color(0x33E50914),
        ),
        useMaterial3: true,
      ),
      home: const _AuthGate(),
    );
  }
}

/// Listens to Firebase Auth state and routes accordingly
class _AuthGate extends StatelessWidget {
  const _AuthGate();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (ctx, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: Color(0xFF0D0D0D),
            body: Center(
              child: CircularProgressIndicator(color: Color(0xFFE50914)),
            ),
          );
        }
        if (snap.data == null) return const LoginScreen();
        return _UserLoader(uid: snap.data!.uid);
      },
    );
  }
}

class _UserLoader extends StatelessWidget {
  final String uid;
  const _UserLoader({required this.uid});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: AuthService().getAppUser(uid),
      builder: (ctx, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: Color(0xFF0D0D0D),
            body: Center(child: CircularProgressIndicator(color: Color(0xFFE50914))),
          );
        }
        if (snap.data == null) return const LoginScreen();
        return DashboardScreen(user: snap.data!);
      },
    );
  }
}
