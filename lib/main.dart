import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zikr/providers/zikr_provider.dart';
import 'package:zikr/screens/home_screen.dart';

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
    return MaterialApp(
      title: 'Smart Zikr',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}

// --- MODELS ---



// --- PROVIDERS ---



// --- SCREENS ---


