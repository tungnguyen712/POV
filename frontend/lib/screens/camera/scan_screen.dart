import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../services/landmark_service.dart';
import '../../services/scan_location_store.dart';
import '../landmark/result_screen.dart';

class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  final ImagePicker _picker = ImagePicker();
  final LandmarkService _service = LandmarkService();

  bool _loading = false;

  String? _currentUserId() {
    final user = Supabase.instance.client.auth.currentUser;
    return user?.id;
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
      final userId = _currentUserId();
      if (userId == null) {
        if (!mounted) return;
        setState(() => _loading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please log in to scan.')),
        );
        return;
      }

      final result = await _service.identifyLandmark(
        imageFile: file,
        userId: userId,
      );

      if (!mounted) return;
      setState(() => _loading = false);

      final resLat = result['landmark_lat'];
      final resLng = result['landmark_lng'];
      if (resLat is num && resLng is num) {
        ScanLocationStore.instance.upsertPin(
          ScanPin(
            id: '${userId}-${DateTime.now().millisecondsSinceEpoch}',
            name: (result['landmark_name'] as String?) ?? 'Scan',
            position: LatLng(resLat.toDouble(), resLng.toDouble()),
            description: result['description'] as String?,
            imagePath: file.path,
            landmarkData: result,
            scannedAt: DateTime.now(),
          ),
        );
      }

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
        SnackBar(content: Text('$e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Scan')),
      body: Center(
        child: _loading
            ? const CircularProgressIndicator()
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton.icon(
                    onPressed: () => _scan(ImageSource.camera),
                    icon: const Icon(Icons.camera_alt),
                    label: const Text('Take Photo'),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: () => _scan(ImageSource.gallery),
                    icon: const Icon(Icons.photo_library),
                    label: const Text('Choose from Gallery'),
                  ),
                ],
              ),
      ),
    );
  }
}
