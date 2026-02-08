import 'package:flutter/material.dart';

class CityCard extends StatelessWidget {
  final String name;
  final String? colorHex;
  final VoidCallback? onTap;

  const CityCard({
    super.key,
    required this.name,
    this.colorHex,
    this.onTap,
  });

  Color _parseHex(String? hex, {Color fallback = const Color(0xFFB8F3EA)}) {
    if (hex == null) return fallback;
    final h = hex.replaceAll('#', '').trim();
    if (h.length != 6) return fallback;
    try {
      return Color(int.parse('FF$h', radix: 16));
    } catch (_) {
      return fallback;
    }
  }

  static const TextStyle _cityComfortaa = TextStyle(
    fontFamily: 'Comfortaa',
    fontSize: 22,
    fontWeight: FontWeight.w700,
    color: Colors.white,
    letterSpacing: 0.8,
    height: 1.15,
  );

  @override
  Widget build(BuildContext context) {
    final bg = _parseHex(colorHex);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 170,
        height: 125,
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(32),
          boxShadow: const [
            BoxShadow(
              blurRadius: 18,
              offset: Offset(0, 10),
              color: Color(0x33000000),
            ),
          ],
        ),
        child: Center(
          child: Text(
            name.toUpperCase(),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: _cityComfortaa,
          ),
        ),
      ),
    );
  }
}
