import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:image_picker/image_picker.dart';

import '../../services/landmark_service.dart';
import '../../services/user_service.dart';
import '../landmark/result_screen.dart';

class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> with WidgetsBindingObserver {
  CameraController? _cameraController;
  final ImagePicker _picker = ImagePicker();
  final LandmarkService _service = LandmarkService();
  final UserService _userService = UserService();

  bool _loading = false;
  bool _isCameraInitialized = false;
  String? _errorMessage;
  int _currentCameraIndex = 0;
  List<CameraDescription> _cameras = [];
  File? _capturedImage;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeCamera();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _cameraController?.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final controller = _cameraController;
    if (controller == null || !controller.value.isInitialized) {
      return;
    }

    if (state == AppLifecycleState.inactive) {
      controller.dispose();
    } else if (state == AppLifecycleState.resumed) {
      _initializeCamera();
    }
  }

  Future<void> _initializeCamera() async {
    try {
      _cameras = await availableCameras();
      if (_cameras.isEmpty) {
        setState(() {
          _errorMessage = 'No cameras available';
        });
        return;
      }

      final camera = _cameras[_currentCameraIndex];
      _cameraController = CameraController(
        camera,
        ResolutionPreset.high,
        enableAudio: false,
      );

      await _cameraController!.initialize();
      
      if (mounted) {
        setState(() {
          _isCameraInitialized = true;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Camera error: $e';
      });
    }
  }

  Future<void> _flipCamera() async {
    if (_cameras.length < 2) return;

    setState(() {
      _isCameraInitialized = false;
    });

    await _cameraController?.dispose();

    _currentCameraIndex = (_currentCameraIndex + 1) % _cameras.length;

    await _initializeCamera();
  }

  Future<void> _takePicture() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }

    try {
      final XFile image = await _cameraController!.takePicture();
      final file = File(image.path);
      
      setState(() {
        _capturedImage = file;
        _loading = true;
      });
      
      await _processImage(file);
    } catch (e) {
      if (mounted) {
        setState(() {
          _capturedImage = null;
          _loading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  Future<void> _pickFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );
      if (image == null) return;

      final file = File(image.path);
      
      setState(() {
        _capturedImage = file;
        _loading = true;
      });
      
      await _processImage(file);
    } catch (e) {
      if (mounted) {
        setState(() {
          _capturedImage = null;
          _loading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  Future<void> _processImage(File file) async {
    try {
      final userId = _userService.getUserId();
      final prefs = await _userService.getUserPreferences();

      final result = await _service.identifyLandmark(
        imageFile: file,
        userId: userId,
        ageBracket: prefs['age_group'],
        interests: prefs['interests'],
      );

      if (!mounted) return;
      
      setState(() {
        _loading = false;
        _capturedImage = null;
      });

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
      setState(() {
        _loading = false;
        _capturedImage = null;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$e', style: _snackComfortaa),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_errorMessage != null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text(_errorMessage!, textAlign: TextAlign.center),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _errorMessage = null;
                  });
                  _initializeCamera();
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (!_isCameraInitialized || _cameraController == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Camera Preview or Captured Image
          if (_loading && _capturedImage != null)
            // Show captured image while loading
            Center(
              child: Image.file(
                _capturedImage!,
                fit: BoxFit.cover,
              ),
            )
          else
            // Show live camera preview
            Center(
              child: CameraPreview(_cameraController!),
            ),

          // Loading Overlay
          if (_loading)
            Container(
              color: Colors.black54,
              child: const Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
            ),

          // Bottom Controls
          if (!_loading)
            Positioned(
              bottom: 40,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Gallery Button
                  GestureDetector(
                    onTap: _pickFromGallery,
                    child: Container(
                      width: 56,
                      height: 56,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(13.0),
                        child: Image.asset(
                          'assets/add_photo_icon.png',
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ),

                  // Capture Button (Circle - no icon inside)
                  GestureDetector(
                    onTap: _takePicture,
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: const Color(0xFF9EE3D8), width: 4),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(6),
                        child: Container(
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Flip Camera Button
                  GestureDetector(
                    onTap: _flipCamera,
                    child: Container(
                      width: 56,
                      height: 56,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(13.0),
                        child: Image.asset(
                          'assets/flip_camera_icon.png',
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
