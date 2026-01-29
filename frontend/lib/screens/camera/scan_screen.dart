import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

import 'scan_screen_web.dart';
import 'scan_screen_mobile.dart';

class ScanScreen extends StatelessWidget {
  const ScanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      return const ScanScreenWeb();
    } else {
      return const ScanScreenMobile();
    }
  }
}
