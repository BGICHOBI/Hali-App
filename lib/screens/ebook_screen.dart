import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:firebase_analytics/firebase_analytics.dart';

class Ebook {
  final String title, author, coverUrl, infoUrl;
  Ebook({
    required this.title,
    required this.author,
    required this.coverUrl,
    required this.infoUrl,
  });
}

class EbookScreen extends StatefulWidget {
  const EbookScreen({super.key});
  @override
  State<EbookScreen> createState() => _EbookScreenState();
}

class _EbookScreenState extends State<EbookScreen> {
  late Future<List<Ebook>> _futureEbooks;
  final _analytics = FirebaseAnalytics.instance;

  @override
  void initState() {
    super.initState();
    _futureEbooks = fetchFreeEbooks();
  }

  Future<List<Ebook>> fetchFreeEbooks() async {
    final url = Uri.parse('https://openlibrary.org/subjects/free_ebooks.json?limit=20');
    final resp = await http.get(url);
    if (resp.statusCode != 200) throw Exception('Failed to load e-books');
    final data = json.decode(resp.body);
    final works = (data['works'] as List<dynamic>);
    return works.map((w) {
      final authors = (w['authors'] as List).map((a) => a['name']).join(', ');
      final coverId = w['cover_id'];
      final coverUrl = coverId != null
          ? 'https://covers.openlibrary.org/b/id/$coverId-M.jpg'
          : '';
      final infoUrl = 'https://openlibrary.org${w['key']}';
      return Ebook(
        title: w['title'] ?? 'Unknown',
        author: authors.isNotEmpty ? authors : 'Unknown',
        coverUrl: coverUrl,
        infoUrl: infoUrl,
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('📚 Free E-Books'), centerTitle: true),
      body: FutureBuilder<List<Ebook>>(
        future: _futureEbooks,
        builder: (ctx, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return Center(child: Text('Error: ${snap.error}'));
          }
          final ebooks = snap.data!;
          return ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: ebooks.length,
            itemBuilder: (ctx, i) {
              final book = ebooks[i];
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 6),
                child: ListTile(
                  leading: book.coverUrl.isNotEmpty
                      ? Image.network(book.coverUrl, width: 48, fit: BoxFit.cover)
                      : const Icon(Icons.menu_book, color: Colors.teal),
                  title: Text(book.title),
                  subtitle: Text(book.author),
                  onTap: () async {
                    // log analytics
                    await _analytics.logEvent(
                      name: 'ebook_open',
                      parameters: {'ebook_title': book.title},
                    );
                    // then open link
                    await launchUrlString(book.infoUrl);
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
