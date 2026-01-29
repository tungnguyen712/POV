import 'package:flutter/material.dart';
import 'screens/home/home_shell.dart';

class LandmarkLensApp extends StatelessWidget {
  const LandmarkLensApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Landmark Lens',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.teal,
      ),
      home: const HomeShell(),
    );
  }
}
