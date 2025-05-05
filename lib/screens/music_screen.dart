import 'package:flutter/material.dart';

class MusicScreen extends StatelessWidget {
  const MusicScreen({super.key});

  @override
  Widget build(BuildContext ctx) {
    final playlists = [
      {'title': 'Chill Vibes', 'likes': 120},
      {'title': 'Workout Mix', 'likes': 85},
      {'title': 'Top Hits', 'likes': 200},
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('🎵 Music'), centerTitle: true),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: playlists.length,
        itemBuilder: (_, i) {
          final p = playlists[i];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: const Icon(Icons.queue_music, color: Colors.teal),
              title: Text(p['title'] as String),
              subtitle: Text('${p['likes']} likes'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                // TODO: open playlist detail / comment screen
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.teal,
        child: const Icon(Icons.add),
        tooltip: 'Create Playlist',
        onPressed: () {
          // TODO: open “New Playlist” form
        },
      ),
    );
  }
}
