import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../services/wrapped_service.dart';
import 'city_card.dart';
import 'recent_scan_tile.dart';
import 'city_wrap_screen.dart';

class WrapScreen extends StatefulWidget {
  const WrapScreen({super.key});

  @override
  State<WrapScreen> createState() => _WrapScreenState();
}

class _WrapScreenState extends State<WrapScreen> {
  final WrappedService _service = WrappedService();
  Future<Map<String, dynamic>>? _future;

  // === Match Login/Profile vibe ===
  static const Color _titleColor = Color(0xFF363E44);
  static const Color _muted = Color(0xFF9CA3AF);

  // Login button orange
  static const Color _accentOrange = Color(0xFFF05B55);

  // Login field mint background
  static const Color _bgMint = Color(0xFFEDFFFC);

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

  String _formatTime(dynamic ts) {
    if (ts == null) return '';
    final dt = DateTime.tryParse(ts.toString());
    final local = (dt ?? DateTime.now()).toLocal();

    int h = local.hour;
    final ampm = h >= 12 ? 'PM' : 'AM';
    h = h % 12 == 0 ? 12 : h % 12;
    final m = local.minute.toString().padLeft(2, '0');
    return '$h:$m $ampm';
  }

  /// ✅ Compatibility adapter:
  /// - Old backend: { cities: [...], recent_scans: [...] }
  /// - New backend: { top_city: "...", items: [...], ... }
  /// This function returns a map that ALWAYS contains cities + recent_scans
  Map<String, dynamic> _normalizeWrapped(Map<String, dynamic> raw) {
    final hasOldCities = raw['cities'] is List;
    final hasOldRecent = raw['recent_scans'] is List;
    if (hasOldCities && hasOldRecent) return raw;

    final topCityRaw = raw['top_city'];
    final topCity = (topCityRaw is String && topCityRaw.trim().isNotEmpty)
        ? topCityRaw.trim()
        : null;

    final items = (raw['items'] is List) ? (raw['items'] as List) : const [];

    final List<Map<String, dynamic>> cities = topCity == null
        ? <Map<String, dynamic>>[]
        : <Map<String, dynamic>>[
            {
              'name': topCity,
              'color_hex': '#7ADBCF',
            }
          ];

    final List<Map<String, dynamic>> recent = items
        .whereType<Map>()
        .map((e) {
          return <String, dynamic>{
            'landmark_name': e['landmark_name'],
            'timestamp': e['timestamp'],
            'image_url': e['image_url'],
          };
        })
        .toList();

    return <String, dynamic>{
      ...raw,
      'cities': cities,
      'recent_scans': recent,
    };
  }

  @override
  Widget build(BuildContext context) {
    final user = Supabase.instance.client.auth.currentUser;

    if (user == null) {
      return const Scaffold(
        backgroundColor: _bgMint,
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
      backgroundColor: _bgMint,
      appBar: AppBar(
        backgroundColor: _accentOrange,
        elevation: 0,
        title: const Text(
          'Wrap',
          style: TextStyle(
            fontFamily: 'Tilt Warp',
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Colors.white,
            height: 1.2,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SafeArea(
        child: FutureBuilder<Map<String, dynamic>>(
          future: _future,
          builder: (context, snap) {
            if (snap.connectionState != ConnectionState.done) {
              return const Center(
                child: CircularProgressIndicator(color: _accentOrange),
              );
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

            final raw = snap.data ?? <String, dynamic>{};
            final data = _normalizeWrapped(raw);

            final List cities = (data['cities'] as List?) ?? const [];
            final List recent = (data['recent_scans'] as List?) ?? const [];

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Your Journey',
                    style: _h1Tilt.copyWith(color: _titleColor),
                  ),
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
                                  (city?['name'] ?? 'Unknown').toString();
                              final color =
                                  (city?['color_hex'] ?? '#7ADBCF').toString();

                              return CityCard(
                                name: name,
                                colorHex: color,
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          CityWrapScreen(cityName: name),
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                  ),

                  const SizedBox(height: 28),
                  Text(
                    'RECENT SCANS',
                    style: _sectionCapsComfortaa.copyWith(
                      color: _accentOrange.withOpacity(0.85),
                    ),
                  ),
                  const SizedBox(height: 12),

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
                              final title =
                                  (scan?['landmark_name'] ?? 'Unknown')
                                      .toString();
                              final time = _formatTime(scan?['timestamp']);
                              final thumb = scan?['image_url']?.toString();

                              return RecentScanTile(
                                title: title,
                                subtitle: time,
                                thumbnailUrl: thumb,
                                onTap: () {
                                  // TODO: navigate to scan detail if needed
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
