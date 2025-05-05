import 'package:flutter/material.dart';
import 'video_player_screen.dart'; 

class VideoScreen extends StatelessWidget {
  const VideoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final videos = [
      {
        'title': 'African Short Film',
        'thumbnail': 'https://picsum.photos/300/180',     // <-- updated
        'videoUrl': 'https://www.sample-videos.com/video123/mp4/720/big_buck_bunny_720p_20mb.mp4',
      },
      // ... other videos
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('🎥 Videos'), centerTitle: true),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: videos.length,
        itemBuilder: (ctx, i) {
          final vid = videos[i];
          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // thumbnail with errorBuilder
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                  child: Image.network(
                    vid['thumbnail']!,
                    width: double.infinity,
                    height: 180,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      height: 180,
                      color: Colors.grey[300],
                      alignment: Alignment.center,
                      child: const Icon(Icons.broken_image, size: 48),
                    ),
                  ),
                ),

                // title + navigation
                ListTile(
                  title: Text(vid['title']!, style: const TextStyle(fontWeight: FontWeight.bold)),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => VideoPlayerScreen(url: vid['videoUrl']!),
                      ),
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
