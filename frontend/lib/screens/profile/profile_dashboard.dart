import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import '../../services/user_service.dart';

class ProfileDashboard extends StatefulWidget {
  const ProfileDashboard({super.key});

  @override
  State<ProfileDashboard> createState() => _ProfileDashboardState();
}

class _ProfileDashboardState extends State<ProfileDashboard> {
  final UserService _userService = UserService();
  final supabase = Supabase.instance.client;

  @override
  Widget build(BuildContext context) {
    final user = supabase.auth.currentUser;

    return Scaffold(
      // appBar: AppBar(
      //   title: const Text('Profile'),
      //   actions: [
      //     IconButton(
      //       icon: const Icon(Icons.settings),
      //       onPressed: () {
      //         ScaffoldMessenger.of(context).showSnackBar(
      //           const SnackBar(content: Text('Settings coming soon')),
      //         );
      //       },
      //     ),
      //   ],
      // ),
      body: FutureBuilder<Map<String, dynamic>?>(
        future: _userService.getUserProfileWithStats(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // Extract data or use defaults
          final profileData = snapshot.data;
          final stats = profileData?['stats'] ?? {};
          final profile = profileData?['profile'] ?? {};
          
          final int placesVisited = stats['places_visited'] ?? 0;
          final int scansThisWeek = stats['scans_this_week'] ?? 0;
          final int streakDays = stats['streak_days'] ?? 0;
          final String displayName = profile['username'] ?? user?.email ?? 'User';

          return FutureBuilder<List<Map<String, dynamic>>>(
            future: _userService.getRecentScans(limit: 3),
            builder: (context, scansSnapshot) {
              final recentScans = scansSnapshot.data ?? [];

              return ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  const SizedBox(height: 24),
                  // Profile Header
                  Center(
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 50,
                          child: Text(
                            displayName.substring(0, 1).toUpperCase(),
                            style: const TextStyle(
                                fontSize: 32, fontWeight: FontWeight.bold),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          displayName,
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          user?.createdAt != null 
                              ? 'Member since ${DateTime.parse(user!.createdAt).year}'
                              : 'Member since ${DateTime.now().year}',
                          style: const TextStyle(fontSize: 13, color: Colors.grey),
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
                          value: '$placesVisited'),
                      const SizedBox(width: 12),
                      _StatCard(
                          icon: Icons.calendar_month,
                          label: 'This week',
                          value: '$scansThisWeek'),
                      const SizedBox(width: 12),
                      _StatCard(
                          icon: Icons.local_fire_department,
                          label: 'Streak',
                          value: '${streakDays}'),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // // Recent Activity
                  // Row(
                  //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  //   children: [
                  //     const Text(
                  //       'Recent Activity',
                  //       style:
                  //           TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  //     ),
                  //     TextButton(
                  //       onPressed: () {
                  //         ScaffoldMessenger.of(context).showSnackBar(
                  //           const SnackBar(
                  //               content: Text('View full history coming soon')),
                  //         );
                  //       },
                  //       child: const Text('See all'),
                  //     ),
                  //   ],
                  // ),

                  // const SizedBox(height: 8),

                  // // Recent scans
                  // if (recentScans.isEmpty)
                  //   const Card(
                  //     child: Padding(
                  //       padding: EdgeInsets.all(24),
                  //       child: Center(
                  //         child: Text(
                  //           'No scans yet. Start scanning landmarks!',
                  //           style: TextStyle(color: Colors.grey),
                  //         ),
                  //       ),
                  //     ),
                  //   )
                  // else
                  //   ...recentScans.map((scan) => _RecentScanTile(scan: scan)),

                  // const SizedBox(height: 24),

                  // Account Actions
                  const Text(
                    'Account',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 8),

                  Card(
                    child: Column(
                      children: [
                        ListTile(
                          leading: const Icon(Icons.edit),
                          title: const Text('Edit Profile'),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('Edit profile coming soon')),
                            );
                          },
                        ),
                        const Divider(height: 1),
                        ListTile(
                          leading: const Icon(Icons.notifications),
                          title: const Text('Notifications'),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('Notifications coming soon')),
                            );
                          },
                        ),
                        const Divider(height: 1),
                        ListTile(
                          leading: const Icon(Icons.privacy_tip),
                          title: const Text('Privacy'),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('Privacy settings coming soon')),
                            );
                          },
                        ),
                        const Divider(height: 1),
                        ListTile(
                          leading: const Icon(Icons.logout, color: Colors.red),
                          title: const Text('Sign Out',
                              style: TextStyle(color: Colors.red)),
                          onTap: () async {
                            await supabase.auth.signOut();
                            if (context.mounted) {
                              Navigator.of(context)
                                  .pushReplacementNamed('/login');
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          );
        },
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

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon),
              const SizedBox(height: 10),
              Text(value,
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.w800)),
              const SizedBox(height: 2),
              Text(label, style: const TextStyle(fontSize: 12)),
            ],
          ),
        ),
      ),
    );
  }
}

// class _RecentScanTile extends StatelessWidget {
//   final Map<String, dynamic> scan;
//   const _RecentScanTile({required this.scan});

//   String _formatDate(String? timestamp) {
//     if (timestamp == null) return 'Unknown date';
//     try {
//       final date = DateTime.parse(timestamp);
//       final now = DateTime.now();
//       final difference = now.difference(date);

//       if (difference.inDays == 0) {
//         return 'Today';
//       } else if (difference.inDays == 1) {
//         return 'Yesterday';
//       } else if (difference.inDays < 7) {
//         return '${difference.inDays} days ago';
//       } else {
//         return DateFormat('MMM d, yyyy').format(date);
//       }
//     } catch (e) {
//       return 'Unknown date';
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final landmarkName = scan['landmark_name'] ?? 'Unknown Landmark';
//     final description = scan['description'] ?? '';
//     final timestamp = scan['timestamp'];
    
//     // Create subtitle with location if available
//     String subtitle = _formatDate(timestamp);
//     if (scan['lat'] != null && scan['lng'] != null) {
//       subtitle = '$subtitle • Location recorded';
//     }

//     return Card(
//       child: ListTile(
//         leading: const CircleAvatar(child: Icon(Icons.image)),
//         title: Text(landmarkName,
//             style: const TextStyle(fontWeight: FontWeight.w700)),
//         subtitle: Text(subtitle),
//         trailing: const Icon(Icons.chevron_right),
//         onTap: () {
//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(content: Text('Scan details coming soon')),
//           );
//         },
//       ),
//     );
//   }
// }
