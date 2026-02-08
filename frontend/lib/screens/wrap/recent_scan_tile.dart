import 'package:flutter/material.dart';

class RecentScanTile extends StatelessWidget {
  final String title; // landmark name
  final String subtitle; // time • category
  final String? thumbnailUrl;
  final VoidCallback? onTap;

  const RecentScanTile({
    super.key,
    required this.title,
    required this.subtitle,
    this.thumbnailUrl,
    this.onTap,
  });

 
  static const Color _titleColor = Color(0xFF363E44);
  static const Color _muted = Color(0xFF9CA3AF);

  static const TextStyle _titleComfortaa = TextStyle(
    fontFamily: 'Comfortaa',
    fontSize: 17,
    fontWeight: FontWeight.w700,
    color: _titleColor,
    height: 1.25,
  );

  static const TextStyle _subtitleComfortaa = TextStyle(
    fontFamily: 'Comfortaa',
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: _muted,
    height: 1.3,
  );

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: const Color(0xFFF0F0F0)),
      ),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        leading: CircleAvatar(
          radius: 24,
          backgroundColor: const Color(0xFFEFEFEF),
          backgroundImage: (thumbnailUrl != null && thumbnailUrl!.isNotEmpty)
              ? NetworkImage(thumbnailUrl!)
              : null,
          child: (thumbnailUrl == null || thumbnailUrl!.isEmpty)
              ? const Icon(Icons.image, color: Colors.black38)
              : null,
        ),
        title: Text(
          title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: _titleComfortaa,
        ),
        subtitle: Text(
          subtitle,
          style: _subtitleComfortaa,
        ),
        trailing:
            const Icon(Icons.chevron_right, color: Color(0xFFD1D5DB)),
        onTap: onTap,
      ),
    );
  }
}
