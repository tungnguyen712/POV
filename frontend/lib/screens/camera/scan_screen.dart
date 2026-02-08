import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:geolocator/geolocator.dart';

import '../../services/landmark_service.dart';
import '../../services/user_service.dart';
import '../landmark/result_screen.dart';

class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  final ImagePicker _picker = ImagePicker();
  final LandmarkService _service = LandmarkService();
  final UserService _userService = UserService();

  bool _loading = false;

  // ===== Match Login typography/colors =====
  static const Color _titleColor = Color(0xFF363E44);
  static const Color _buttonBg = Color(0xFFF05B55);

  static const TextStyle _appBarTilt = TextStyle(
    fontFamily: 'Tilt Warp',
    fontSize: 18,
    fontWeight: FontWeight.w700,
    color: _titleColor,
    height: 1.2,
  );

  static const TextStyle _buttonTextComfortaa = TextStyle(
    fontFamily: 'Comfortaa',
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 1.33,
  );

  static const TextStyle _snackComfortaa = TextStyle(
    fontFamily: 'Comfortaa',
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 1.33,
  );

  Future<Position?> _getPosition() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return null;

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      return null;
    }

    return Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.medium,
    );
  }

  Future<void> _scan(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        imageQuality: 85,
      );
      if (image == null) return;

      setState(() => _loading = true);

      final file = File(image.path);

      // ✅ Always use Supabase auth user id
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) {
        throw Exception('Please log in first.');
      }
      final userId = user.id;

      // Personalization preferences from profiles
      final prefs = await _userService.getUserPreferences();

      // Location (optional)
      final position = await _getPosition();

      // Call backend/service
      // Location (optional)
      final position = await _getPosition();

      // Call backend/service
      final result = await _service.identifyLandmark(
        imageFile: file,
        userId: userId,
        ageBracket: prefs['age_group'],
        interests: prefs['interests'],
        // If your LandmarkService supports lat/lng, keep these:
        lat: position?.latitude,
        lng: position?.longitude,
        // If your LandmarkService supports lat/lng, keep these:
        lat: position?.latitude,
        lng: position?.longitude,
      );

      if (!mounted) return;
      setState(() => _loading = false);

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => LandmarkResultScreen(
            imageFile: file,
            landmarkData: result,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$e', style: _snackComfortaa)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text('Scan', style: _appBarTilt),
        iconTheme: const IconThemeData(color: _titleColor),
      ),
      body: Center(
        child: _loading
            ? const CircularProgressIndicator()
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 260,
                    height: 48,
                    child: ElevatedButton.icon(
                      onPressed: () => _scan(ImageSource.camera),
                      icon: const Icon(Icons.camera_alt, color: Colors.white),
                      label: const Text('Take Photo', style: _buttonTextComfortaa),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _buttonBg,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: 260,
                    height: 48,
                    child: OutlinedButton.icon(
                      onPressed: () => _scan(ImageSource.gallery),
                      icon: const Icon(Icons.photo_library, color: _titleColor),
                      label: const Text(
                        'Choose from Gallery',
                        style: _buttonTextComfortaa,
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: _titleColor,
                        side: const BorderSide(color: _titleColor, width: 1),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
Future<Position?> _getPosition() async {
  final serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) return null;

  var permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
  }
  if (permission == LocationPermission.denied ||
      permission == LocationPermission.deniedForever) {
    return null;
  }

  return Geolocator.getCurrentPosition(
    desiredAccuracy: LocationAccuracy.medium,
  );
}
