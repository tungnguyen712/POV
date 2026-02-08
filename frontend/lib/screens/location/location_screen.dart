import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../services/scan_location_store.dart';
import '../../services/scans_service.dart';

class LocationScreen extends StatefulWidget {
  const LocationScreen({super.key});

  @override
  State<LocationScreen> createState() => _LocationScreenState();
}

class _LocationScreenState extends State<LocationScreen> {
  static const LatLng _fallbackCenter = LatLng(20.0, 0.0);
  static const double _fallbackZoom = 2.4;

  GoogleMapController? _controller;
  bool _loadingScans = true;
  final ScansService _scansService = ScansService();

  ScanLocationStore get _store => ScanLocationStore.instance;

  @override
  void initState() {
    super.initState();
    _loadScans();
  }

  @override
  void dispose() {
    super.dispose();
  }

  String? _currentUserId() {
    final user = Supabase.instance.client.auth.currentUser;
    return user?.id;
  }

  Future<void> _loadScans() async {
    setState(() {
      _loadingScans = true;
    });

    final userId = _currentUserId();
    if (userId == null) {
      setState(() {
        _loadingScans = false;
      });
      return;
    }

    try {
      final scans = await _scansService.fetchScans(userId: userId);
      final pins = <ScanPin>[];
      for (final scan in scans) {
        final lat = scan['lat'];
        final lng = scan['lng'];
        if (lat is! num || lng is! num) continue;
        final name = (scan['landmark_name'] as String?) ?? 'Scan';
        final id = (scan['id'] as String?) ?? '$lat,$lng';
        final description = scan['description'] as String?;
        final ts = scan['timestamp'] as String?;
        pins.add(
          ScanPin(
            id: id,
            name: name,
            position: LatLng(lat.toDouble(), lng.toDouble()),
            description: description,
            scannedAt: ts == null ? null : DateTime.tryParse(ts),
          ),
        );
      }

      _store.setPins(pins);
      setState(() {
        _loadingScans = false;
      });

      if (pins.isNotEmpty) {
        _zoomToFitMarkers(_markersFromPins(pins));
      }
    } catch (e) {
      setState(() {
        _loadingScans = false;
      });
    }
  }

  Set<Marker> _markersFromPins(List<ScanPin> pins) {
    return pins
        .map(
          (pin) => Marker(
                markerId: MarkerId(pin.id),
                position: pin.position,
                infoWindow: InfoWindow(title: pin.name),
                onTap: () => _showPinSheet(pin),
              ),
        )
        .toSet();
  }

  Future<void> _zoomToFitMarkers(Set<Marker> markers) async {
    if (_controller == null || markers.isEmpty) return;
    double? minLat;
    double? maxLat;
    double? minLng;
    double? maxLng;

    for (final marker in markers) {
      final lat = marker.position.latitude;
      final lng = marker.position.longitude;
      minLat = minLat == null ? lat : (lat < minLat ? lat : minLat);
      maxLat = maxLat == null ? lat : (lat > maxLat ? lat : maxLat);
      minLng = minLng == null ? lng : (lng < minLng ? lng : minLng);
      maxLng = maxLng == null ? lng : (lng > maxLng ? lng : maxLng);
    }

    if (minLat == null ||
        maxLat == null ||
        minLng == null ||
        maxLng == null) {
      return;
    }

    final bounds = LatLngBounds(
      southwest: LatLng(minLat, minLng),
      northeast: LatLng(maxLat, maxLng),
    );
    await _controller!.animateCamera(
      CameraUpdate.newLatLngBounds(bounds, 80),
    );
  }

  void _showPinSheet(ScanPin pin) {
    _store.selectPin(pin.id);
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 6, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                pin.name,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (pin.scannedAt != null)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    DateFormat('MMM d, yyyy • HH:mm').format(pin.scannedAt!),
                    style: const TextStyle(color: Colors.black54),
                  ),
                ),
              if (pin.imagePath != null)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.file(
                      File(pin.imagePath!),
                      height: 160,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              if (pin.description != null && pin.description!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Text(
                    pin.description!,
                    style: const TextStyle(height: 1.4),
                  ),
                ),
            ],
          ),
        );
      },
    ).whenComplete(() => _store.selectPin(null));
  }

  @override
  Widget build(BuildContext context) {
    final pins = _store.state.pins;
    final markers = _markersFromPins(pins);

    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: const CameraPosition(
              target: _fallbackCenter,
              zoom: _fallbackZoom,
            ),
            myLocationEnabled: false,
            myLocationButtonEnabled: false,
            markers: markers,
            onMapCreated: (controller) {
              _controller = controller;
              if (markers.isNotEmpty) {
                _zoomToFitMarkers(markers);
              }
            },
          ),
          if (_loadingScans)
            const Align(
              alignment: Alignment.topCenter,
              child: Padding(
                padding: EdgeInsets.only(top: 48),
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _loadScans,
        child: const Icon(Icons.refresh),
      ),
    );
  }
}
