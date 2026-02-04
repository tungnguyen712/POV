import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../../constants/colors.dart';

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
    if (text.trim().isEmpty) return;
    await _initTts();
    if (_isSpeaking) {
      await _tts.stop();
      if (!mounted) return;
      setState(() => _isSpeaking = false);
      return;
    }

    setState(() => _isSpeaking = true);
    await _tts.speak(text);
  }

  @override
  Widget build(BuildContext context) {
    final landmarkName = widget.landmarkData['landmark_name'] ?? '';
    final location = widget.landmarkData['location'] ?? '';
    final tags = List<String>.from(widget.landmarkData['tags'] ?? []);
    final description = widget.landmarkData['description'] ?? '';
    final ttsText = [
      landmarkName,
      location,
      description,
    ].where((p) => p.toString().trim().isNotEmpty).join('. ');
    
    // Extract fun_facts
    final funFacts = widget.landmarkData['fun_facts'] ?? {};
    final matchFacts = List<String>.from(funFacts['match_facts'] ?? []);
    final discoveryFacts = List<String>.from(funFacts['discovery_facts'] ?? []);
    
    // Extract suggested questions
    final suggestedQuestions = List<String>.from(widget.landmarkData['suggested_questions'] ?? []);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Top bar with title
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
              decoration: const BoxDecoration(
                color: AppColors.topBarBackground,
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.black),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Expanded(
                    child: Text(
                      'Landmark Identify',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'TiltWrap',
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
            ),

            // Scrollable content
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Landmark image
                    AspectRatio(
                      aspectRatio: 1,
                      child: Image.file(
                        widget.imageFile,
                        fit: BoxFit.cover,
                      ),
                    ),

                    // Tags
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: tags.map((tag) {
                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: const Color(0xFFEEF2FF),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Text(
                              '#$tag',
                              style: const TextStyle(
                                fontFamily: 'Arimo',
                                fontSize: 16,
                                color: AppColors.tagColor,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),

                    // Landmark name with speaker icon
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Row(
                        children: [
                          const Icon(Icons.location_on, size: 28, color: Colors.black54),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              landmarkName,
                              style: const TextStyle(
                                fontFamily: 'Arimo',
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: Icon(
                              _isSpeaking ? Icons.volume_up : Icons.volume_up_outlined,
                              size: 28,
                              color: Colors.black54,
                            ),
                            onPressed: () => _toggleSpeech(ttsText),
                          ),
                        ],
                      ),
                    ),

                    // Location
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                      child: Text(
                        location,
                        style: const TextStyle(
                          fontFamily: 'Arimo',
                          fontSize: 16,
                          color: Colors.black54,
                        ),
                      ),
                    ),

                    // Description heading
                    const Padding(
                      padding: EdgeInsets.only(left: 16.0, right: 16.0, top: 16.0, bottom: 8.0),
                      child: Text(
                        'Description',
                        style: TextStyle(
                          fontFamily: 'Arimo',
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: Colors.black87,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),

                    // Description text
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                      child: Text(
                        description,
                        style: const TextStyle(
                          fontFamily: 'Arimo',
                          fontSize: 16,
                          color: Colors.black87,
                          height: 1.5,
                        ),
                      ),
                    ),
                    
                    // Just for You section (match_facts)
                    if (matchFacts.isNotEmpty) ...[
                      const SizedBox(height: 24),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.0),
                        child: Text(
                          'Just for You',
                          style: TextStyle(
                            fontFamily: 'Arimo',
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      ...matchFacts.map((fact) => Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('• ', style: TextStyle(fontSize: 16, color: Colors.black87)),
                            Expanded(
                              child: Text(
                                fact,
                                style: const TextStyle(
                                  fontFamily: 'Arimo',
                                  fontSize: 16,
                                  color: Colors.black87,
                                  height: 1.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                      )),
                    ],
                    
                    // Fun Facts section (discovery_facts)
                    if (discoveryFacts.isNotEmpty) ...[
                      const SizedBox(height: 24),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.0),
                        child: Text(
                          'Fun Facts',
                          style: TextStyle(
                            fontFamily: 'Arimo',
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      ...discoveryFacts.map((fact) => Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('• ', style: TextStyle(fontSize: 16, color: Colors.black87)),
                            Expanded(
                              child: Text(
                                fact,
                                style: const TextStyle(
                                  fontFamily: 'Arimo',
                                  fontSize: 16,
                                  color: Colors.black87,
                                  height: 1.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                      )),
                    ],
                    
                    // Suggested Questions section
                    if (suggestedQuestions.isNotEmpty) ...[
                      const SizedBox(height: 24),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.0),
                        child: Text(
                          'Ask Me About',
                          style: TextStyle(
                            fontFamily: 'Arimo',
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      ...suggestedQuestions.map((question) => Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
                        child: InkWell(
                          onTap: () {
                            // TODO: Open chat with this question
                            print('Question tapped: $question');
                          },
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(top: 2.0),
                                child: const Icon(
                                  Icons.chat_bubble_outline,
                                  size: 18,
                                  color: Color(0xFF1F8A70),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  question,
                                  style: const TextStyle(
                                    fontFamily: 'Arimo',
                                    fontSize: 15,
                                    color: Color(0xFF1F8A70),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(top: 3),
                                child: const Icon(
                                  Icons.arrow_forward_ios,
                                  size: 14,
                                  color: Color(0xFF1F8A70),
                                ),
                              ),
                            ],
                          ),
                        ),
                      )),
                    ],

                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ),

            // Bottom buttons
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.buttonPrevious,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Previous',
                        style: TextStyle(
                          fontFamily: 'Arimo',
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        // TODO: Navigate to next screen
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.buttonNext,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Next',
                        style: TextStyle(
                          fontFamily: 'Arimo',
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
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
