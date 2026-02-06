import 'package:flutter/material.dart';

class HomeDashboard extends StatelessWidget {
  const HomeDashboard({super.key});

  @override
  Widget build(BuildContext context) {
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
      appBar: AppBar(
        title: const Text('Landmark Lens'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Header
          Row(
            children: const [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome back 👋',
                      style:
                          TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Discover and track landmarks instantly.',
                      style: TextStyle(fontSize: 13),
                    ),
                  ],
                ),
              ),
              CircleAvatar(
                radius: 20,
                child: Icon(Icons.person),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Stats row
          Row(
            children: [
              _StatCard(
                  icon: Icons.place, label: 'Places', value: '$placesVisited'),
              const SizedBox(width: 12),
              _StatCard(
                  icon: Icons.calendar_month,
                  label: 'This week',
                  value: '$scansThisWeek'),
              const SizedBox(width: 12),
              _StatCard(
                  icon: Icons.local_fire_department,
                  label: 'Streak',
                  value: '${streakDays}d'),
            ],
          ),

          const SizedBox(height: 16),

          // Scan CTA card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Ready to scan?',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w700),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Open the Scan tab and capture a landmark.',
                          style: TextStyle(fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                  FilledButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content:
                                Text('Tap the Scan tab to start scanning.')),
                      );
                    },
                    icon: const Icon(Icons.camera_alt),
                    label: const Text('Scan'),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Recent
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Recent scans',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
              TextButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Later: connect to History/Calendar.')),
                  );
                },
                child: const Text('See all'),
              ),
            ],
          ),

          const SizedBox(height: 8),

          ...recent.map((r) => _RecentScanTile(scan: r)),

          const SizedBox(height: 16),

          // Tip
          Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: const [
                  Icon(Icons.lightbulb_outline),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Tip: Keep the landmark centered and avoid blurry shots.',
                      style: TextStyle(fontSize: 13),
                    ),
                  ),
                ],
              ),
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

class _RecentScan {
  final String title;
  final String subtitle;
  const _RecentScan({required this.title, required this.subtitle});
}

class _RecentScanTile extends StatelessWidget {
  final _RecentScan scan;
  const _RecentScanTile({required this.scan});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: const CircleAvatar(child: Icon(Icons.image)),
        title: Text(scan.title,
            style: const TextStyle(fontWeight: FontWeight.w700)),
        subtitle: Text(scan.subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Later: open scan details page.')),
          );
        },
      ),
    );
  }
}
