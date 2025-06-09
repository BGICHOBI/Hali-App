// lib/screens/news_detail_screen.dart

import 'package:flutter/material.dart';
import 'package:firebase_analytics/firebase_analytics.dart';

class NewsDetailScreen extends StatefulWidget {
  final String docId;
  final String title;
  final String body;
  final String? imageUrl;

  const NewsDetailScreen({
    Key? key,
    required this.docId,
    required this.title,
    required this.body,
    this.imageUrl,
  }) : super(key: key);

  @override
  State<NewsDetailScreen> createState() => _NewsDetailScreenState();
}

class _NewsDetailScreenState extends State<NewsDetailScreen> {
  final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;

  @override
  void initState() {
    super.initState();
    // Log that the user viewed this news piece
    _analytics.logEvent(
      name: 'news_detail_view',
      parameters: {
        'doc_id': widget.docId,
        'title': widget.title,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        centerTitle: true,
        actions: [
          if (widget.imageUrl != null)
            IconButton(
              icon: const Icon(Icons.share),
              onPressed: () {
                // Log a “share” event
                _analytics.logEvent(
                  name: 'news_detail_share',
                  parameters: {'doc_id': widget.docId},
                );
                // TODO: hook up your share mechanism here
              },
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.imageUrl != null && widget.imageUrl!.isNotEmpty) ...[
              Hero(
                tag: 'news-${widget.docId}',
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    widget.imageUrl!,
                    width: double.infinity,
                    height: 200,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      height: 200,
                      color: Colors.grey[300],
                      alignment: Alignment.center,
                      child: const Icon(Icons.broken_image, size: 48),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
            Text(
              widget.title,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              widget.body,
              style: const TextStyle(fontSize: 16, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }
}
