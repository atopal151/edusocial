import 'package:flutter/material.dart';
import '../../models/story_model.dart';

class StoryCard extends StatelessWidget {
  final StoryModel story;

  const StoryCard({super.key, required this.story});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 6),
          padding: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: story.isViewed
                ? LinearGradient(colors: [Colors.grey.shade400, Colors.grey.shade200])
                : const LinearGradient(colors: [Color(0xfffb535c), Colors.orange]),
          ),
          child: CircleAvatar(
            radius: 32,
            backgroundColor: Colors.white,
            child: CircleAvatar(
              radius: 30,
              backgroundImage: NetworkImage(story.profileImage),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          story.username,
          style: const TextStyle(fontSize: 12),
          overflow: TextOverflow.ellipsis,
        )
      ],
    );
  }
}
