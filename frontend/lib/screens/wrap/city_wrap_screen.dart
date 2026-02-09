import 'package:flutter/material.dart';

class CityWrapScreen extends StatelessWidget {
  final String cityName;
  const CityWrapScreen({super.key, required this.cityName});

  static const Color _titleColor = Color(0xFF363E44);
  static const Color _accentOrange = Color(0xFFF05B55);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: _accentOrange,
        elevation: 0,
        title: Text(
          cityName,
          style: const TextStyle(
            fontFamily: 'Tilt Warp',
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Colors.white,
            height: 1.2,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: const Center(
        child: Text(
          'City details coming soon.',
          textAlign: TextAlign.center,
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
}
