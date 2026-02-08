import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../services/wrapped_service.dart';
import 'city_card.dart';
import 'recent_scan_tile.dart';

class WrapScreen extends StatefulWidget {
  const WrapScreen({super.key});

  @override
  State<WrapScreen> createState() => _WrapScreenState();
}

class _WrapScreenState extends State<WrapScreen> {
  final WrappedService _service = WrappedService();
  Future<Map<String, dynamic>>? _future;

  // === Match LoginScreen typography/colors ===
  static const Color _titleColor = Color(0xFF363E44);
  static const Color _muted = Color(0xFF9CA3AF);

  static const TextStyle _h1Tilt = TextStyle(
    color: _titleColor,
    fontFamily: 'Tilt Warp',
    fontSize: 32,
    fontWeight: FontWeight.w700,
    height: 1.28,
  );

  static const TextStyle _sectionCapsComfortaa = TextStyle(
    color: _muted,
    fontFamily: 'Comfortaa',
    fontSize: 14,
    fontWeight: FontWeight.w700,
    letterSpacing: 1.2,
    height: 1.33,
  );

  static const TextStyle _bodyComfortaa = TextStyle(
    color: _titleColor,
    fontFamily: 'Comfortaa',
    fontSize: 16,
    fontWeight: FontWeight.w500,
    height: 1.33,
  );

  static const TextStyle _emptyStateComfortaa = TextStyle(
    color: _muted,
    fontFamily: 'Comfortaa',
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 1.33,
  );

  @override
  void initState() {
    super.initState();
    final user = Supabase.instance.client.auth.currentUser;
    if (user != null) {
      _future = _service.fetchWrapped(userId: user.id, limit: 50);
    }
  }

  String _formatTime(dynamic createdAt) {
    if (createdAt == null) return '';
    final raw = createdAt.toString();
    final dt = DateTime.tryParse(raw);
    final local = (dt ?? DateTime.now()).toLocal();

    int h = local.hour;
    final ampm = h >= 12 ? 'PM' : 'AM';
    h = h % 12 == 0 ? 12 : h % 12;
    final m = local.minute.toString().padLeft(2, '0');
    return '$h:$m $ampm';
  }

  @override
  Widget build(BuildContext context) {
    final user = Supabase.instance.client.auth.currentUser;

    if (user == null) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Text(
            'Please log in first.',
            style: TextStyle(
              fontFamily: 'Comfortaa',
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: _titleColor,
              height: 1.33,
            ),
          ),
        ),
      );
    }

    _future ??= _service.fetchWrapped(userId: user.id, limit: 50);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: FutureBuilder<Map<String, dynamic>>(
          future: _future,
          builder: (context, snap) {
            if (snap.connectionState != ConnectionState.done) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snap.hasError) {
              return Padding(
                padding: const EdgeInsets.all(20),
                child: Center(
                  child: Text(
                    'Error loading wrap:\n${snap.error}',
                    textAlign: TextAlign.center,
                    style: _bodyComfortaa.copyWith(
                      color: _titleColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              );
            }

            final data = snap.data ?? {};
            final List cities = (data['cities'] as List?) ?? const [];
            final List recent = (data['recent_scans'] as List?) ?? const [];

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Your Journey', style: _h1Tilt),
                  const SizedBox(height: 16),

                  // City blocks
                  SizedBox(
                    height: 145,
                    child: cities.isEmpty
                        ? const Center(
                            child: Text(
                              'No cities yet. Scan a landmark to start!',
                              style: _emptyStateComfortaa,
                              textAlign: TextAlign.center,
                            ),
                          )
                        : ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: cities.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(width: 18),
                            itemBuilder: (context, i) {
                              final city = cities[i] as Map?;
                              final name =
                                  (city?['name'] ?? city?['city'] ?? 'CITY')
                                      .toString();
                              final color =
                                  (city?['color'] ?? city?['color_hex'])
                                      ?.toString();

                              return CityCard(
                                name: name,
                                colorHex: color,
                                onTap: () {
                                  // TODO: open city history filter
                                },
                              );
                            },
                          ),
                  ),

                  const SizedBox(height: 28),
                  const Text('RECENT SCANS', style: _sectionCapsComfortaa),
                  const SizedBox(height: 12),

                  // Recent scans
                  Expanded(
                    child: recent.isEmpty
                        ? const Center(
                            child: Text(
                              'No recent scans yet.',
                              style: _emptyStateComfortaa,
                            ),
                          )
                        : ListView.builder(
                            itemCount: recent.length,
                            itemBuilder: (context, i) {
                              final scan = recent[i] as Map?;
                              final title = (scan?['landmark_name'] ??
                                      scan?['title'] ??
                                      'Unknown')
                                  .toString();
                              final category =
                                  (scan?['category'] ?? '').toString();
                              final time = _formatTime(scan?['created_at']);
                              final subtitle = category.isNotEmpty
                                  ? '$time • $category'
                                  : time;

                              final thumb = (scan?['thumbnail_url'] ??
                                      scan?['thumbnail'] ??
                                      scan?['image_url'])
                                  ?.toString();

                              return RecentScanTile(
                                title: title,
                                subtitle: subtitle,
                                thumbnailUrl: thumb,
                                onTap: () {
                                  // TODO: navigate to scan detail/result
                                },
                              );
                            },
                          ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
