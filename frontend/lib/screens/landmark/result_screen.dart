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

  // ===================== STYLES (match Wrap/Profile) =====================
  static const Color _titleColor = Color(0xFF363E44);
  static const Color _muted = Color(0xFF9CA3AF);
  static const Color _teal = Color(0xFF1F8A70);
  static const Color _mint = Color(0xFFE6F4F1);

  static const TextStyle _titleTilt = TextStyle(
    fontFamily: 'Tilt Warp',
    fontSize: 26,
    fontWeight: FontWeight.w700,
    height: 1.15,
    color: _titleColor,
  );

  static const TextStyle _sectionComfortaa = TextStyle(
    fontFamily: 'Comfortaa',
    fontSize: 18,
    fontWeight: FontWeight.w700,
    height: 1.25,
    color: _titleColor,
  );

  static const TextStyle _bodyComfortaa = TextStyle(
    fontFamily: 'Comfortaa',
    fontSize: 16,
    fontWeight: FontWeight.w500,
    height: 1.5,
    color: _titleColor,
  );

  static const TextStyle _bulletComfortaa = TextStyle(
    fontFamily: 'Comfortaa',
    fontSize: 15,
    fontWeight: FontWeight.w500,
    height: 1.35,
    color: _titleColor,
  );

  static const TextStyle _tileTitleComfortaa = TextStyle(
    fontFamily: 'Comfortaa',
    fontSize: 15,
    fontWeight: FontWeight.w700,
    height: 1.2,
    color: _titleColor,
  );

  static const TextStyle _tileSubComfortaa = TextStyle(
    fontFamily: 'Comfortaa',
    fontSize: 13,
    fontWeight: FontWeight.w500,
    height: 1.2,
    color: _muted,
  );

  static const TextStyle _tabTextComfortaa = TextStyle(
    fontFamily: 'Comfortaa',
    fontSize: 14,
    fontWeight: FontWeight.w700,
    height: 1.2,
  );

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
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
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
            color: isActive ? _teal : _mint,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: _tabTextComfortaa.copyWith(
              color: isActive ? Colors.white : _teal,
            ),
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Text(text, style: _sectionComfortaa),
    );
  }

  Widget _bullet(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Text('• $text', style: _bulletComfortaa),
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
    final matchFacts = List<String>.from(funFacts['match_facts'] ?? []);
    final discoveryFacts = List<String>.from(funFacts['discovery_facts'] ?? []);

    final nearby = widget.landmarkData['nearby'] ?? {};
    final nearbyLandmarks = _asMapList(nearby['landmarks']);
    final nearbyFood = _asMapList(nearby['food']);

    final events = _asMapList(widget.landmarkData['events']);

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
                        style: _titleTilt,
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        _isSpeaking ? Icons.volume_up : Icons.volume_up_outlined,
                        color: _titleColor,
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
                  style: _bodyComfortaa,
                ),
              ),

              if (matchFacts.isNotEmpty) ...[
                const SizedBox(height: 24),
                _sectionTitle('Just for You'),
                ...matchFacts.map(_bullet),
              ],

              if (discoveryFacts.isNotEmpty) ...[
                const SizedBox(height: 24),
                _sectionTitle('Fun Facts'),
                ...discoveryFacts.map(_bullet),
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
                const SizedBox(height: 12),

                if (_nearbyTab == 0 && nearbyLandmarks.isNotEmpty)
                  ...nearbyLandmarks.map((place) {
                    final name = place['name'] ?? '';
                    final vicinity = place['vicinity'] ?? '';
                    final distance = _formatDistance(place['distance']);
                    final rating = _formatRating(
                      place['rating'],
                      place['user_ratings_total'],
                    );
                    final openNow = _formatOpenNow(place['open_now']);

                    return ListTile(
                      leading: const Icon(Icons.location_on, color: _teal),
                      title: Text(name, style: _tileTitleComfortaa),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (vicinity.isNotEmpty)
                            Text(vicinity, style: _tileSubComfortaa),
                          Row(
                            children: [
                              if (distance.isNotEmpty)
                                Text(distance, style: _tileSubComfortaa),
                              if (rating.isNotEmpty) ...[
                                if (distance.isNotEmpty)
                                  Text(' • ', style: _tileSubComfortaa),
                                const Icon(Icons.star,
                                    size: 14, color: Colors.amber),
                                Text(' $rating', style: _tileSubComfortaa),
                              ],
                              if (openNow.isNotEmpty) ...[
                                if (distance.isNotEmpty || rating.isNotEmpty)
                                  Text(' • ', style: _tileSubComfortaa),
                                Text(openNow, style: _tileSubComfortaa),
                              ],
                            ],
                          ),
                        ],
                      ),
                    );
                  }),

                if (_nearbyTab == 1 && nearbyFood.isNotEmpty)
                  ...nearbyFood.map((place) {
                    final name = place['name'] ?? '';
                    final vicinity = place['vicinity'] ?? '';
                    final distance = _formatDistance(place['distance']);
                    final rating = _formatRating(
                      place['rating'],
                      place['user_ratings_total'],
                    );
                    final openNow = _formatOpenNow(place['open_now']);

                    return ListTile(
                      leading: const Icon(Icons.restaurant, color: _teal),
                      title: Text(name, style: _tileTitleComfortaa),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (vicinity.isNotEmpty)
                            Text(vicinity, style: _tileSubComfortaa),
                          Row(
                            children: [
                              if (distance.isNotEmpty)
                                Text(distance, style: _tileSubComfortaa),
                              if (rating.isNotEmpty) ...[
                                if (distance.isNotEmpty)
                                  Text(' • ', style: _tileSubComfortaa),
                                const Icon(Icons.star,
                                    size: 14, color: Colors.amber),
                                Text(' $rating', style: _tileSubComfortaa),
                              ],
                              if (openNow.isNotEmpty) ...[
                                if (distance.isNotEmpty || rating.isNotEmpty)
                                  Text(' • ', style: _tileSubComfortaa),
                                Text(openNow, style: _tileSubComfortaa),
                              ],
                            ],
                          ),
                        ],
                      ),
                    );
                  }),
              ],

              if (events.isNotEmpty) ...[
                const SizedBox(height: 24),
                _sectionTitle('Nearby Events'),
                const SizedBox(height: 12),
                ...events.map((event) {
                  final name = event['name'] ?? '';
                  final venue = event['venue'] ?? '';
                  final dateTime = _formatEventDateTime(event['date']);
                  final distance = _formatDistance(event['distance']);

                  return ListTile(
                    leading: const Icon(Icons.event, color: _teal),
                    title: Text(name, style: _tileTitleComfortaa),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (venue.isNotEmpty)
                          Text(venue, style: _tileSubComfortaa),
                        if (dateTime.isNotEmpty)
                          Text(dateTime, style: _tileSubComfortaa),
                        if (distance.isNotEmpty)
                          Text(distance, style: _tileSubComfortaa),
                      ],
                    ),
                  );
                }),
              ],

              if (suggestedQuestions.isNotEmpty) ...[
                const SizedBox(height: 24),
                _sectionTitle('Ask Me About'),
                ...suggestedQuestions.map(
                  (q) => ListTile(
                    leading: const Icon(Icons.chat_bubble_outline,
                        color: _titleColor),
                    title: Text(q, style: _tileTitleComfortaa),
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
                  ),
                ),
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
