import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://usukapslkqbcplaedaag.supabase.co',          // ✅ Correct URL (from dashboard)
    anonKey: 'sb_publishable_W4XOlxEsu4THN8vKQVV4EQ_H9-DaChm', // ✅ Publishable key
  );

  runApp(const FinanceTrackerApp());
}

final supabase = Supabase.instance.client;

class FinanceTrackerApp extends StatelessWidget {
  const FinanceTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Finance Tracker',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2E7D32),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      home: supabase.auth.currentSession == null
          ? const LoginScreen()
          : const HomeScreen(),
    );
  }
}