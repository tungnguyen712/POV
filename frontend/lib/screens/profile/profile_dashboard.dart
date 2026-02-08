import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileDashboard extends StatelessWidget {
  const ProfileDashboard({super.key});

  // ===== Match Login typography/colors =====
  static const Color _titleColor = Color(0xFF363E44);
  static const Color _muted = Color(0xFF9CA3AF);

  static const TextStyle _appBarTilt = TextStyle(
    fontFamily: 'Tilt Warp',
    fontSize: 18,
    fontWeight: FontWeight.w700,
    color: _titleColor,
    height: 1.2,
  );

  static const TextStyle _sectionTilt = TextStyle(
    fontFamily: 'Tilt Warp',
    fontSize: 16,
    fontWeight: FontWeight.w700,
    color: _titleColor,
    height: 1.2,
  );

  static const TextStyle _emailComfortaa = TextStyle(
    fontFamily: 'Comfortaa',
    fontSize: 18,
    fontWeight: FontWeight.w700,
    color: _titleColor,
    height: 1.25,
  );

  static const TextStyle _smallComfortaa = TextStyle(
    fontFamily: 'Comfortaa',
    fontSize: 13,
    fontWeight: FontWeight.w600,
    color: _muted,
    height: 1.25,
  );

  static const TextStyle _buttonComfortaa = TextStyle(
    fontFamily: 'Comfortaa',
    fontSize: 14,
    fontWeight: FontWeight.w700,
    height: 1.2,
  );

  static const TextStyle _snackComfortaa = TextStyle(
    fontFamily: 'Comfortaa',
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 1.33,
  );

  @override
  Widget build(BuildContext context) {
    final supabase = Supabase.instance.client;
    final user = supabase.auth.currentUser;

    // Mock values for now (replace with Supabase later)
    const int placesVisited = 12;
    const int scansThisWeek = 3;
    const int streakDays = 2;

    final recent = const [
      _RecentScan(title: 'Fushimi Inari', subtitle: 'Kyoto • Yesterday'),
      _RecentScan(title: 'Kinkaku-ji', subtitle: 'Kyoto • 3 days ago'),
      _RecentScan(title: 'Tokyo Tower', subtitle: 'Tokyo • Last week'),
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text('Profile', style: _appBarTilt),
        iconTheme: const IconThemeData(color: _titleColor),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: _titleColor),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Settings coming soon', style: _snackComfortaa),
                ),
              );
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Profile Header
          Center(
            child: Column(
              children: [
                CircleAvatar(
                  radius: 50,
                  child: Text(
                    user?.email?.substring(0, 1).toUpperCase() ?? 'U',
                    style: const TextStyle(
                      fontFamily: 'Tilt Warp',
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      height: 1.0,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  user?.email ?? 'User',
                  style: _emailComfortaa,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Text(
                  'Member since ${DateTime.now().year - 1}',
                  style: _smallComfortaa,
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Stats row
          Row(
            children: [
              _StatCard(
                icon: Icons.place,
                label: 'Places',
                value: '$placesVisited',
              ),
              const SizedBox(width: 12),
              _StatCard(
                icon: Icons.calendar_month,
                label: 'This week',
                value: '$scansThisWeek',
              ),
              const SizedBox(width: 12),
              _StatCard(
                icon: Icons.local_fire_department,
                label: 'Streak',
                value: '${streakDays}d',
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Recent Activity
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Recent Activity', style: _sectionTilt),
              TextButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'View full history coming soon',
                        style: _snackComfortaa,
                      ),
                    ),
                  );
                },
                child: const Text('See all', style: _buttonComfortaa),
              ),
            ],
          ),

          const SizedBox(height: 8),
          ...recent.map((r) => _RecentScanTile(scan: r)),
          const SizedBox(height: 24),

          // Account Actions
          const Text('Account', style: _sectionTilt),
          const SizedBox(height: 8),

          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.edit, color: _titleColor),
                  title: const Text(
                    'Edit Profile',
                    style: TextStyle(
                      fontFamily: 'Comfortaa',
                      fontSize: 14.5,
                      fontWeight: FontWeight.w700,
                      color: _titleColor,
                    ),
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content:
                            Text('Edit profile coming soon', style: _snackComfortaa),
                      ),
                    );
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.notifications, color: _titleColor),
                  title: const Text(
                    'Notifications',
                    style: TextStyle(
                      fontFamily: 'Comfortaa',
                      fontSize: 14.5,
                      fontWeight: FontWeight.w700,
                      color: _titleColor,
                    ),
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content:
                            Text('Notifications coming soon', style: _snackComfortaa),
                      ),
                    );
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.privacy_tip, color: _titleColor),
                  title: const Text(
                    'Privacy',
                    style: TextStyle(
                      fontFamily: 'Comfortaa',
                      fontSize: 14.5,
                      fontWeight: FontWeight.w700,
                      color: _titleColor,
                    ),
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Privacy settings coming soon',
                          style: _snackComfortaa,
                        ),
                      ),
                    );
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.logout, color: Colors.red),
                  title: const Text(
                    'Sign Out',
                    style: TextStyle(
                      fontFamily: 'Comfortaa',
                      fontSize: 14.5,
                      fontWeight: FontWeight.w800,
                      color: Colors.red,
                    ),
                  ),
                  onTap: () async {
                    await supabase.auth.signOut();
                    if (context.mounted) {
                      Navigator.of(context).pushReplacementNamed('/login');
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
  });

  static const Color _titleColor = Color(0xFF363E44);
  static const Color _muted = Color(0xFF9CA3AF);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: _titleColor),
              const SizedBox(height: 10),
              Text(
                value,
                style: const TextStyle(
                  fontFamily: 'Comfortaa',
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: _titleColor,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: const TextStyle(
                  fontFamily: 'Comfortaa',
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: _muted,
                  height: 1.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RecentScan {
  final String title;
  final String subtitle;
  const _RecentScan({required this.title, required this.subtitle});
}

class _RecentScanTile extends StatelessWidget {
  final _RecentScan scan;
  const _RecentScanTile({required this.scan});

  static const Color _titleColor = Color(0xFF363E44);
  static const Color _muted = Color(0xFF9CA3AF);
  static const TextStyle _title = TextStyle(
    fontFamily: 'Comfortaa',
    fontSize: 14.5,
    fontWeight: FontWeight.w800,
    color: _titleColor,
    height: 1.2,
  );
  static const TextStyle _subtitle = TextStyle(
    fontFamily: 'Comfortaa',
    fontSize: 13,
    fontWeight: FontWeight.w600,
    color: _muted,
    height: 1.2,
  );

  static const TextStyle _snackComfortaa = TextStyle(
    fontFamily: 'Comfortaa',
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 1.33,
  );

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: const CircleAvatar(child: Icon(Icons.image)),
        title: Text(scan.title, style: _title),
        subtitle: Text(scan.subtitle, style: _subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Scan details coming soon', style: _snackComfortaa),
            ),
          );
        },
      ),
    );
  }
}
