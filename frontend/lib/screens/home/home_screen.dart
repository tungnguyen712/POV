import 'package:flutter/material.dart';
import '../camera/scan_screen.dart';
<<<<<<< HEAD:frontend/lib/screens/home/home_screen.dart
=======
import '../profile/profile_dashboard.dart';
import '../wrap/wrap_screen.dart';

>>>>>>> 950d0b1 (change font):frontend/lib/screens/home/nav_bar.dart

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
<<<<<<< HEAD:frontend/lib/screens/home/home_screen.dart
  int _currentIndex = 2; // mở app vào tab Scan cho tiện (muốn 0 thì đổi lại)
=======
  int _currentIndex = 2; 
>>>>>>> 950d0b1 (change font):frontend/lib/screens/home/nav_bar.dart

  static const _placeholderStyle = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
  );

  // ✅ Must match 5 destinations
  final List<Widget> _pages = const [
<<<<<<< HEAD:frontend/lib/screens/home/home_screen.dart
    _PlaceholderPage(title: 'Home (Wrapped/History)'),
    _PlaceholderPage(title: 'Calendar (Events)'),
=======
    WrapScreen(),
    _PlaceholderPage(title: 'Location (Nearby)'),
>>>>>>> 950d0b1 (change font):frontend/lib/screens/home/nav_bar.dart
    ScanScreen(),
    _PlaceholderPage(title: 'Search (Nearby)'),
    _PlaceholderPage(title: 'Profile (Chatbot)'),
  ];

<<<<<<< HEAD:frontend/lib/screens/home/home_screen.dart
=======
  static const double _iconSize = 28; 
>>>>>>> 950d0b1 (change font):frontend/lib/screens/home/nav_bar.dart
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],

      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (int index) {
          setState(() => _currentIndex = index);
        },
<<<<<<< HEAD:frontend/lib/screens/home/home_screen.dart
=======
        labelBehavior: NavigationDestinationLabelBehavior.alwaysHide, 
>>>>>>> 950d0b1 (change font):frontend/lib/screens/home/nav_bar.dart
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.calendar_month),
            label: 'Calendar',
          ),
          NavigationDestination(
            icon: Icon(Icons.camera_alt),
            label: 'Scan',
          ),
          NavigationDestination(
            icon: Icon(Icons.search),
            label: 'Search',
          ),
          NavigationDestination(
            icon: Icon(Icons.person),
            label: 'Profile',
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
