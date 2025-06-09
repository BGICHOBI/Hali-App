import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:share_plus/share_plus.dart';

final _playlistsRef = FirebaseFirestore.instance.collection('playlists');

class MusicScreen extends StatefulWidget {
  const MusicScreen({super.key});
  @override
  State<MusicScreen> createState() => _MusicScreenState();
}

class _MusicScreenState extends State<MusicScreen> {
  final _analytics = FirebaseAnalytics.instance;
  final _player = AudioPlayer();

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  Future<void> _play(String url, String playlistId) async {
    // 1) log listen event
    await _analytics.logEvent(
      name: 'playlist_listen',
      parameters: {'playlist_id': playlistId},
    );

    // 2) bump listener count
    await FirebaseFirestore.instance.runTransaction((tx) async {
      final doc = _playlistsRef.doc(playlistId);
      final snap = await tx.get(doc);
      final current = (snap.data()?['listeners'] as int?) ?? 0;
      tx.update(doc, {'listeners': current + 1});
    });

    // 3) actually play
    await _player.setUrl(url);
    _player.play();
  }

  Future<void> _like(String playlistId) async {
    await _analytics.logEvent(
      name: 'playlist_like',
      parameters: {'playlist_id': playlistId},
    );
    await FirebaseFirestore.instance.runTransaction((tx) async {
      final doc = _playlistsRef.doc(playlistId);
      final snap = await tx.get(doc);
      final current = (snap.data()?['likes'] as int?) ?? 0;
      tx.update(doc, {'likes': current + 1});
    });
  }

  Future<void> _share(String title, String playlistId) async {
    await _analytics.logEvent(
      name: 'playlist_share',
      parameters: {'playlist_id': playlistId},
    );
    await Share.share(
      'Check out this playlist on Hali: "$title"',
      subject: title,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('🎵 Music'), centerTitle: true),
      body: StreamBuilder<QuerySnapshot>(
        stream: _playlistsRef.orderBy('likes', descending: true).snapshots(),
        builder: (ctx, snap) {
          if (!snap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final docs = snap.data!.docs;
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            itemBuilder: (_, i) {
              final d = docs[i].data()! as Map<String, dynamic>;
              final id = docs[i].id;
              final title = d['title'] as String? ?? 'Untitled';
              final url = d['stream_url'] as String? ?? '';
              final likes = d['likes'] as int? ?? 0;
              final listens = d['listeners'] as int? ?? 0;
              final creator = d['creator_name'] as String? ?? 'Unknown';

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: const Icon(Icons.queue_music, color: Colors.teal),
                  title: Text(title),
                  subtitle: Text('$creator • $likes likes • $listens listens'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.play_arrow),
                        onPressed: url.isNotEmpty ? () => _play(url, id) : null,
                        tooltip: 'Listen',
                      ),
                      IconButton(
                        icon: const Icon(Icons.thumb_up),
                        onPressed: () => _like(id),
                        tooltip: 'Like',
                      ),
                      IconButton(
                        icon: const Icon(Icons.share),
                        onPressed: () => _share(title, id),
                        tooltip: 'Share',
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.teal,
        child: const Icon(Icons.add),
        tooltip: 'Create Playlist',
        onPressed: () {
          // push your CreatePlaylistScreen...
        },
      ),
    );
  }
}
