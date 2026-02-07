import 'dart:io';
import 'package:flutter/material.dart';
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
  bool _isSpeaking = false;
  int _nearbyTab = 0;

  void _toggleSpeech() {
    setState(() {
      _isSpeaking = !_isSpeaking;
    });
    // TODO: Implement text-to-speech functionality
  }

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
    final m = meters is num ? meters.toDouble() : double.tryParse(meters.toString());
    if (m == null) return '';
    final miles = m / 1609.34;
    if (miles < 0.1) {
      return '<0.1 mi';
    }
    return '${miles.toStringAsFixed(1)} mi';
  }

  String _formatRating(dynamic rating, dynamic count) {
    if (rating == null) return '';
    final r = rating is num ? rating.toDouble() : double.tryParse(rating.toString());
    if (r == null) return '';
    final c = count is num ? count.toInt() : int.tryParse(count?.toString() ?? '');
    if (c == null) {
      return r.toStringAsFixed(1);
    }
    return '${r.toStringAsFixed(1)} (${c.toString()})';
  }

  String _formatOpenNow(dynamic openNow) {
    if (openNow == null) return '';
    return openNow == true ? 'Open now' : 'Closed';
  }

  String _formatEventDateTime(dynamic value) {
    if (value == null) return '';
    final raw = value.toString().trim();
    if (raw.isEmpty) return '';
    final dt = DateTime.tryParse(raw);
    if (dt == null) return raw;
    final local = dt.toLocal();
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    final month = months[local.month - 1];
    final day = local.day;
    final year = local.year;
    final hour24 = local.hour;
    final minute = local.minute.toString().padLeft(2, '0');
    final ampm = hour24 >= 12 ? 'PM' : 'AM';
    final hour12 = hour24 % 12 == 0 ? 12 : hour24 % 12;
    return '$month $day, $year • $hour12:$minute $ampm';
  }

  Widget _buildNearbyTabButton(String label, int index) {
    final isActive = _nearbyTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _nearbyTab = index;
          });
        },
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

  Widget _buildPlaceCard(Map<String, dynamic> place) {
    final distance = _formatDistance(place['distance_meters']);
    final rating = _formatRating(place['rating'], place['user_ratings_total']);
    final openNow = _formatOpenNow(place['open_now']);
    final address = place['address'] ?? '';

    return Container(
      width: 230,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            place['name'] ?? 'Place',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontFamily: 'Arimo',
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 6),
          if (address.isNotEmpty)
            Text(
              address,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontFamily: 'Arimo',
                fontSize: 12,
                color: Colors.black54,
              ),
            ),
          const SizedBox(height: 8),
          Row(
            children: [
              if (distance.isNotEmpty)
                Text(
                  distance,
                  style: const TextStyle(
                    fontFamily: 'Arimo',
                    fontSize: 12,
                    color: Colors.black54,
                  ),
                ),
              if (distance.isNotEmpty && rating.isNotEmpty)
                const Text(' - ', style: TextStyle(color: Colors.black45)),
              if (rating.isNotEmpty)
                Row(
                  children: [
                    const Icon(Icons.star, size: 14, color: Color(0xFFFFB703)),
                    const SizedBox(width: 2),
                    Text(
                      rating,
                      style: const TextStyle(
                        fontFamily: 'Arimo',
                        fontSize: 12,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
            ],
          ),
          if (openNow.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              openNow,
              style: TextStyle(
                fontFamily: 'Arimo',
                fontSize: 12,
                color: openNow == 'Open now' ? const Color(0xFF1F8A70) : Colors.black54,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildEventCard(Map<String, dynamic> event) {
    final distance = _formatDistance(event['distance_meters']);
    final venue = event['venue'] ?? '';
    final address = event['address'] ?? '';
    final start = _formatEventDateTime(event['start_time']);
    final category = event['category'] ?? '';

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            event['name'] ?? 'Event',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontFamily: 'Arimo',
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 6),
          if (venue.isNotEmpty)
            Text(
              venue,
              style: const TextStyle(
                fontFamily: 'Arimo',
                fontSize: 13,
                color: Colors.black87,
              ),
            ),
          if (address.isNotEmpty)
            Text(
              address,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontFamily: 'Arimo',
                fontSize: 12,
                color: Colors.black54,
              ),
            ),
          const SizedBox(height: 8),
          Row(
            children: [
              if (start.isNotEmpty)
                Text(
                  start,
                  style: const TextStyle(
                    fontFamily: 'Arimo',
                    fontSize: 12,
                    color: Colors.black54,
                  ),
                ),
              if (start.isNotEmpty && distance.isNotEmpty)
                const Text(' - ', style: TextStyle(color: Colors.black45)),
              if (distance.isNotEmpty)
                Text(
                  distance,
                  style: const TextStyle(
                    fontFamily: 'Arimo',
                    fontSize: 12,
                    color: Colors.black54,
                  ),
                ),
              if (category.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE6F4F1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      category,
                      style: const TextStyle(
                        fontFamily: 'Arimo',
                        fontSize: 11,
                        color: Color(0xFF1F8A70),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final landmarkName = widget.landmarkData['landmark_name'] ?? '';
    final location = widget.landmarkData['location'] ?? '';
    final tags = List<String>.from(widget.landmarkData['tags'] ?? []);
    final description = widget.landmarkData['description'] ?? '';
    
    // Extract fun_facts
    final funFacts = widget.landmarkData['fun_facts'] ?? {};
    final matchFacts = List<String>.from(funFacts['match_facts'] ?? []);
    final discoveryFacts = List<String>.from(funFacts['discovery_facts'] ?? []);
    
    // Extract suggested questions
    final suggestedQuestions = List<String>.from(widget.landmarkData['suggested_questions'] ?? []);
    final nearby = widget.landmarkData['nearby'] ?? {};
    final nearbyLandmarks = _asMapList(nearby['landmarks']);
    final nearbyFood = _asMapList(nearby['food']);
    final events = _asMapList(widget.landmarkData['events']);

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
                            onPressed: _toggleSpeech,
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

                    if (nearbyLandmarks.isNotEmpty || nearbyFood.isNotEmpty) ...[
                      const SizedBox(height: 24),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.0),
                        child: Text(
                          'Nearby Suggestions',
                          style: TextStyle(
                            fontFamily: 'Arimo',
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Row(
                          children: [
                            _buildNearbyTabButton('Landmarks', 0),
                            const SizedBox(width: 8),
                            _buildNearbyTabButton('Food', 1),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: SizedBox(
                          height: 150,
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: (_nearbyTab == 0 ? nearbyLandmarks : nearbyFood).isNotEmpty
                                  ? (_nearbyTab == 0 ? nearbyLandmarks : nearbyFood)
                                      .map((place) => _buildPlaceCard(place))
                                      .toList()
                                  : [
                                      const Text(
                                        'No suggestions available.',
                                        style: TextStyle(
                                          fontFamily: 'Arimo',
                                          fontSize: 14,
                                          color: Colors.black54,
                                        ),
                                      ),
                                    ],
                            ),
                          ),
                        ),
                      ),
                    ],

                    if (events.isNotEmpty) ...[
                      const SizedBox(height: 24),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.0),
                        child: Text(
                          'Events Nearby',
                          style: TextStyle(
                            fontFamily: 'Arimo',
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Column(
                          children: events.map((event) => _buildEventCard(event)).toList(),
                        ),
                      ),
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
}
