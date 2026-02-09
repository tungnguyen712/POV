import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../services/wrapped_service.dart';
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

  /// ✅ Extract recent scans from either payload shape:
  /// - Old backend: { recent_scans: [...] }
  /// - New backend: { items: [...] }
  List<Map<String, dynamic>> _extractRecent(Map<String, dynamic> raw) {
    if (raw['recent_scans'] is List) {
      return (raw['recent_scans'] as List)
          .whereType<Map>()
          .map((e) => Map<String, dynamic>.from(e))
          .toList();
    }

    final items = (raw['items'] is List) ? (raw['items'] as List) : const [];
    return items
        .whereType<Map>()
        .map((e) {
          return <String, dynamic>{
            'landmark_name': e['landmark_name'],
            'timestamp': e['timestamp'],
            'image_url': e['image_url'],
          };
        })
        .toList();
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

            final raw = (snap.data ?? <String, dynamic>{});
            final recent = _extractRecent(raw);

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Your Journey',
                    style: _h1Tilt.copyWith(color: _titleColor),
                  ),
                  const SizedBox(height: 24),

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
                              final scan = recent[i];
                              final title =
                                  (scan['landmark_name'] ?? 'Unknown').toString();
                              final time = _formatTime(scan['timestamp']);
                              final thumb = scan['image_url']?.toString();

                              return RecentScanTile(
                                title: title,
                                subtitle: time,
                                thumbnailUrl: thumb,
                                onTap: () {
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
