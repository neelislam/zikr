import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/zikr_provider.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ZikrProvider()),
      ],
      child: const SmartZikrApp(),
    ),
  );
}

class SmartZikrApp extends StatelessWidget {
  const SmartZikrApp({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ZikrProvider>(context);

    return MaterialApp(
      title: 'Smart Zikr',
      debugShowCheckedModeBanner: false,
      themeMode: provider.isDarkMode ? ThemeMode.dark : ThemeMode.light,

      // LIGHT THEME
      theme: ThemeData(
        brightness: Brightness.light,
        scaffoldBackgroundColor: const Color(0xFFF7F9F6),
        colorScheme: const ColorScheme.light(
          primary: Color(0xFF0F4C3A), // Emerald Green
          secondary: Color(0xFFD4AF37), // Gold
          surface: Colors.white,
        ),
        useMaterial3: true,
      ),

      // DARK THEME
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF121212),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF2E8B57), // Lighter Green for dark mode
          secondary: Color(0xFFE5C158),
          surface: Color(0xFF1E1E1E),
        ),
        useMaterial3: true,
      ),

      home: const HomeScreen(),
    );
  }
}