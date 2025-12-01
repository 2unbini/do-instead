import 'package:do_instead/data/models/suggested_activity.dart';
import 'package:flutter/material.dart';

class ActivityCard extends StatelessWidget {
  final SuggestedActivity activity;
  final VoidCallback onLike;
  final VoidCallback onDislike;

  const ActivityCard({
    super.key,
    required this.activity,
    required this.onLike,
    required this.onDislike,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.blueAccent.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.flash_on, color: Colors.amber, size: 18),
              const SizedBox(width: 8),
              Text(
                'Doobie의 제안',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            activity.title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          Text('${activity.durationMinutes}분 • ${activity.type}'),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton.icon(
                onPressed: onLike,
                icon: const Icon(Icons.thumb_up_outlined, size: 16),
                label: const Text('좋아요'),
              ),
              TextButton.icon(
                onPressed: onDislike,
                icon: const Icon(Icons.thumb_down_outlined, size: 16, color: Colors.grey),
                label: const Text('싫어요', style: TextStyle(color: Colors.grey)),
              ),
            ],
          )
        ],
      ),
    );
  }
}