import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class ScanPin {
  final String id;
  final String name;
  final LatLng position;
  final String? locationLabel;
  final String? description;
  final String? imagePath;
  final Map<String, dynamic>? landmarkData;
  final DateTime? scannedAt;

  const ScanPin({
    required this.id,
    required this.name,
    required this.position,
    this.locationLabel,
    this.description,
    this.imagePath,
    this.landmarkData,
    this.scannedAt,
  });
}

class ScanLocationState {
  final List<ScanPin> pins;
  final String? selectedId;
  final DateTime? lastUpdated;

  const ScanLocationState({
    required this.pins,
    required this.selectedId,
    required this.lastUpdated,
  });

  bool get hasPins => pins.isNotEmpty;

  ScanPin? get selected {
    if (selectedId == null) return null;
    for (final pin in pins) {
      if (pin.id == selectedId) return pin;
    }
    return null;
  }
}

class ScanLocationStore extends ChangeNotifier {
  static final ScanLocationStore instance = ScanLocationStore._();

  ScanLocationStore._();

  ScanLocationState _state = const ScanLocationState(
    pins: [],
    selectedId: null,
    lastUpdated: null,
  );

  ScanLocationState get state => _state;

  void setPins(List<ScanPin> pins) {
    final deduped = _dedupePins(pins);
    _state = ScanLocationState(
      pins: deduped,
      selectedId: _state.selectedId,
      lastUpdated: DateTime.now(),
    );
    notifyListeners();
  }

  void upsertPin(ScanPin pin) {
    final next = List<ScanPin>.from(_state.pins);
    final idx = next.indexWhere((p) => p.id == pin.id);
    if (idx >= 0) {
      next[idx] = pin;
    } else {
      next.add(pin);
    }

    final deduped = _dedupePins(next);
    _state = ScanLocationState(
      pins: deduped,
      selectedId: _state.selectedId,
      lastUpdated: DateTime.now(),
    );
    notifyListeners();
  }

  void selectPin(String? id) {
    _state = ScanLocationState(
      pins: _state.pins,
      selectedId: id,
      lastUpdated: _state.lastUpdated,
    );
    notifyListeners();
  }

  List<ScanPin> _dedupePins(List<ScanPin> pins) {
    final byKey = <String, ScanPin>{};
    for (final pin in pins) {
      final key = _buildKey(pin);
      final existing = byKey[key];
      if (existing == null) {
        byKey[key] = pin;
        continue;
      }
      if (_isNewer(pin, existing)) {
        byKey[key] = pin;
      }
    }
    return byKey.values.toList();
  }

  bool _isNewer(ScanPin candidate, ScanPin existing) {
    if (candidate.scannedAt == null) return false;
    if (existing.scannedAt == null) return true;
    return candidate.scannedAt!.isAfter(existing.scannedAt!);
  }

  String _buildKey(ScanPin pin) {
    final lat = pin.position.latitude.toStringAsFixed(4);
    final lng = pin.position.longitude.toStringAsFixed(4);
    final name = pin.name.toLowerCase();
    if (name.isNotEmpty) {
      return 'loc:$name:$lat:$lng';
    }
    if (pin.id.isNotEmpty) return 'id:${pin.id}';
    return 'loc:unknown:$lat:$lng';
  }
}
