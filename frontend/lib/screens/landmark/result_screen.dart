import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../../constants/colors.dart';
import '../chatbot/chatbot_screen.dart';

class LandmarkResultScreen extends StatefulWidget {
  final File imageFile;
  final Map<String, dynamic> landmarkData;

  const LandmarkResultScreen({
    super.key,
    required this.imageFile,
    required this.landmarkData,
  });

  @override
  State<LandmarkResultScreen> createState() => _LandmarkResultScreenState();
}

class _LandmarkResultScreenState extends State<LandmarkResultScreen> {
  // ===================== TTS =====================
  final FlutterTts _tts = FlutterTts();
  bool _isSpeaking = false;
  bool _ttsReady = false;

  Future<void> _initTts() async {
    if (_ttsReady) return;

    await _tts.setLanguage('en-US');
    await _tts.setSpeechRate(0.45);
    await _tts.setPitch(1.0);

    _tts.setCompletionHandler(() {
      if (!mounted) return;
      setState(() => _isSpeaking = false);
    });

    _tts.setCancelHandler(() {
      if (!mounted) return;
      setState(() => _isSpeaking = false);
    });

    _tts.setErrorHandler((_) {
      if (!mounted) return;
      setState(() => _isSpeaking = false);
    });

    _ttsReady = true;
  }

  Future<void> _toggleSpeech(String text) async {
    await _initTts();
    if (text.trim().isEmpty) return;

    if (_isSpeaking) {
      await _tts.stop();
      if (!mounted) return;
      setState(() => _isSpeaking = false);
    } else {
      if (!mounted) return;
      setState(() => _isSpeaking = true);
      await _tts.speak(text);
    }
  }

  // ===================== STATE =====================
  int _nearbyTab = 0;

  // ===================== HELPERS =====================
  List<Map<String, dynamic>> _asMapList(dynamic value) {
    if (value is List) {
      return value
          .whereType<Map>()
          .map((item) => Map<String, dynamic>.from(item))
          .toList();
    }
    return [];
  }

  String _formatDistance(dynamic meters) {
    if (meters == null) return '';
    final m =
        meters is num ? meters.toDouble() : double.tryParse(meters.toString());
    if (m == null) return '';
    final miles = m / 1609.34;
    if (miles < 0.1) return '<0.1 mi';
    return '${miles.toStringAsFixed(1)} mi';
  }

  String _formatRating(dynamic rating, dynamic count) {
    if (rating == null) return '';
    final r =
        rating is num ? rating.toDouble() : double.tryParse(rating.toString());
    if (r == null) return '';
    final c =
        count is num ? count.toInt() : int.tryParse(count?.toString() ?? '');
    if (c == null) return r.toStringAsFixed(1);
    return '${r.toStringAsFixed(1)} ($c)';
  }

  String _formatOpenNow(dynamic openNow) {
    if (openNow == null) return '';
    return openNow == true ? 'Open now' : 'Closed';
  }

  String _formatEventDateTime(dynamic value) {
    if (value == null) return '';
    final dt = DateTime.tryParse(value.toString());
    if (dt == null) return value.toString();
    final local = dt.toLocal();
    final hour24 = local.hour;
    final hour12 = hour24 % 12 == 0 ? 12 : hour24 % 12;
    final ampm = hour24 >= 12 ? 'PM' : 'AM';
    final minute = local.minute.toString().padLeft(2, '0');
    const months = [
      'Jan','Feb','Mar','Apr','May','Jun',
      'Jul','Aug','Sep','Oct','Nov','Dec'
    ];
    return '${months[local.month - 1]} ${local.day}, ${local.year} • $hour12:$minute $ampm';
  }

  // ===================== UI =====================
  Widget _buildNearbyTabButton(String label, int index) {
    final isActive = _nearbyTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _nearbyTab = index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isActive ? const Color(0xFF1F8A70) : const Color(0xFFE6F4F1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Arimo',
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isActive ? Colors.white : const Color(0xFF1F8A70),
            ),
          ),
        ),
      ),
    );
  }

  // ===================== BUILD =====================
  @override
  Widget build(BuildContext context) {
    final landmarkName = widget.landmarkData['landmark_name'] ?? '';
    final location = widget.landmarkData['location'] ?? '';
    final description = widget.landmarkData['description'] ?? '';

    final ttsText = [landmarkName, location, description]
        .where((e) => e.toString().trim().isNotEmpty)
        .join('. ');

    final funFacts = widget.landmarkData['fun_facts'] ?? {};
    final matchFacts =
        List<String>.from(funFacts['match_facts'] ?? []);
    final discoveryFacts =
        List<String>.from(funFacts['discovery_facts'] ?? []);

    final nearby = widget.landmarkData['nearby'] ?? {};
    final nearbyLandmarks = _asMapList(nearby['landmarks']);
    final nearbyFood = _asMapList(nearby['food']);

    final suggestedQuestions =
        List<String>.from(widget.landmarkData['suggested_questions'] ?? []);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: AppColors.topBarBackground,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AspectRatio(
                      aspectRatio: 1,
                      child: Image.file(widget.imageFile, fit: BoxFit.cover),
                    ),

                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          const Icon(Icons.location_on),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              landmarkName,
                              style: const TextStyle(
                                fontFamily: 'Arimo',
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: Icon(
                              _isSpeaking
                                  ? Icons.volume_up
                                  : Icons.volume_up_outlined,
                            ),
                            onPressed: () => _toggleSpeech(ttsText),
                          ),
                        ],
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        description,
                        style: const TextStyle(
                          fontFamily: 'Arimo',
                          fontSize: 16,
                          height: 1.5,
                        ),
                      ),
                    ),

                    if (matchFacts.isNotEmpty) ...[
                      const SizedBox(height: 24),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          'Just for You',
                          style: TextStyle(
                            fontFamily: 'Arimo',
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      ...matchFacts.map((f) => Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                        child: Text('• $f'),
                      )),
                    ],

                    if (discoveryFacts.isNotEmpty) ...[
                      const SizedBox(height: 24),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          'Fun Facts',
                          style: TextStyle(
                            fontFamily: 'Arimo',
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      ...discoveryFacts.map((f) => Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                        child: Text('• $f'),
                      )),
                    ],

                    if (nearbyLandmarks.isNotEmpty || nearbyFood.isNotEmpty) ...[
                      const SizedBox(height: 24),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          children: [
                            _buildNearbyTabButton('Landmarks', 0),
                            const SizedBox(width: 8),
                            _buildNearbyTabButton('Food', 1),
                          ],
                        ),
                      ),
                    ],

                    if (suggestedQuestions.isNotEmpty) ...[
                      const SizedBox(height: 24),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          'Ask Me About',
                          style: TextStyle(
                            fontFamily: 'Arimo',
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      ...suggestedQuestions.map((q) => ListTile(
                        leading: const Icon(Icons.chat_bubble_outline),
                        title: Text(q),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ChatbotScreen(
                                landmarkName: landmarkName,
                                landmarkDescription: description,
                                initialQuestion: q,
                              ),
                            ),
                          );
                        },
                      )),
                    ],

                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ),
    );
  }

  @override
  void dispose() {
    _tts.stop();
    super.dispose();
  }
}
