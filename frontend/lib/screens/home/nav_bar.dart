import 'package:flutter/material.dart';
import '../camera/scan_screen.dart';
import '../location/location_screen.dart';
import '../profile/profile_dashboard.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 2; // mở app vào tab Camera

  final List<Widget> _pages = const [
    _PlaceholderPage(title: 'Calendar (Events)'),
    LocationScreen(),
    ScanScreen(),
    _PlaceholderPage(title: 'Search'),
    ProfileDashboard(),
  ];

  static const double _iconSize = 28; // 👈 phóng to icon

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],

      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() => _currentIndex = index);
        },
        labelBehavior: NavigationDestinationLabelBehavior.alwaysHide, // 👈 bỏ chữ
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.calendar_month, size: _iconSize),
            label: '',
          ),
          NavigationDestination(
            icon: Icon(Icons.location_on, size: _iconSize),
            label: '',
          ),
          NavigationDestination(
            icon: Icon(Icons.camera_alt, size: _iconSize),
            label: '',
          ),
          NavigationDestination(
            icon: Icon(Icons.search, size: _iconSize),
            label: '',
          ),
          NavigationDestination(
            icon: Icon(Icons.person, size: _iconSize),
            label: '',
          ),
        ],
      ),
    );
  }
}

class _PlaceholderPage extends StatelessWidget {
  const _PlaceholderPage({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        textAlign: TextAlign.center,
      ),
    );
  }
}
