import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'screens/landmark/result_screen.dart';
import 'services/landmark_service.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Landmark Lens',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      home: const TestLandmarkScreen(),
    );
  }
}

class TestLandmarkScreen extends StatefulWidget {
  const TestLandmarkScreen({super.key});

  @override
  State<TestLandmarkScreen> createState() => _TestLandmarkScreenState();
}

class _TestLandmarkScreenState extends State<TestLandmarkScreen> {
  final ImagePicker _picker = ImagePicker();
  final LandmarkService _landmarkService = LandmarkService();
  bool _loading = false;

  Future<void> _pickAndIdentify() async {
    try {
      // Pick image
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      
      if (image == null) return;

      setState(() => _loading = true);

      // Call API
      final result = await _landmarkService.identifyLandmark(
        imageFile: File(image.path),
        userId: 'test-user-123',
      );

      setState(() => _loading = false);

      // Navigate to result screen
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => LandmarkResultScreen(
              imageFile: File(image.path),
              landmarkData: result,
            ),
          ),
        );
      }
    } catch (e) {
      setState(() => _loading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Landmark Lens Test'),
        backgroundColor: const Color(0xFF9EE3D8),
      ),
      body: Center(
        child: _loading
            ? const CircularProgressIndicator()
            : ElevatedButton.icon(
                onPressed: _pickAndIdentify,
                icon: const Icon(Icons.photo_library),
                label: const Text('Pick Image & Identify'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  textStyle: const TextStyle(fontSize: 18),
                ),
              ),
      ),
    );
  }
}