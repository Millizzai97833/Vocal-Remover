import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const VocalRemoverApp());
}

class VocalRemoverApp extends StatelessWidget {
  const VocalRemoverApp({super.key});

  @override
  Widget build(BuildContext context) {
    const purple = Color(0xFF9B72FF);
    return MaterialApp(
      title: 'Vocal Remover',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: purple,
          brightness: Brightness.dark,
          surface: const Color(0xFF151520),
        ),
        scaffoldBackgroundColor: const Color(0xFF0B0B12),
      ),
      home: const HomeScreen(),
    );
  }
}
