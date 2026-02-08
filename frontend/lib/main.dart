import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'screens/login/login.dart';
import 'screens/login/signup.dart';
import 'screens/onboarding/onboarding_screen.dart';
import 'screens/camera/scan_screen.dart';
import 'screens/landmark/result_screen.dart';
import 'services/landmark_service.dart';
import 'screens/home/nav_bar.dart';
import 'screens/wrap/wrap_screen.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: ".env");

  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_PUBLISHABLE_KEY']!,
  );

  runApp(const LandmarkApp());
}

class LandmarkApp extends StatelessWidget {
  const LandmarkApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Landmark Identify',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      home: const SplashToAuth(),
      routes: {
        '/login': (context) => const LoginScreen(),
        '/signup': (context) => const SignupScreen(),
        '/onboarding': (context) => const OnboardingScreen(),
        '/scan': (context) => const ScanScreen(),
        '/nav_bar': (context) => HomeScreen(),
        '/wrap': (context) => const WrapScreen(),
      },
    );
  }
}

/// Splash nền trắng + logo giữa, rồi chuyển sang AuthGate
class SplashToAuth extends StatefulWidget {
  const SplashToAuth({super.key});

  @override
  State<SplashToAuth> createState() => _SplashToAuthState();
}

class _SplashToAuthState extends State<SplashToAuth> {
  @override
  void initState() {
    super.initState();

    // Cho splash hiện ngắn để m nhìn thấy logo (có thể chỉnh thời gian)
    Future.delayed(const Duration(milliseconds: 900), () {
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const AuthGate()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Image(
          image: AssetImage('assets/logo.png'),
          width: 140,
        ),
      ),
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final supabase = Supabase.instance.client;

    return StreamBuilder<AuthState>(
      stream: supabase.auth.onAuthStateChange,
      builder: (context, snapshot) {
        // Loading state (lúc app mới mở, tránh trắng)
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final session = supabase.auth.currentSession;

        // Chưa login
        if (session == null) return const LoginScreen();

        // Đã login
        return HomeScreen();
      },
    );
  }
}
