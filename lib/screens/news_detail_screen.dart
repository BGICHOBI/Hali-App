import 'package:flutter/material.dart';

class NewsDetailScreen extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (imageUrl != null && imageUrl!.isNotEmpty) ...[
              Hero(
                tag: 'news-$docId',
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    imageUrl!,
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
              title,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              body,
              style: const TextStyle(fontSize: 16, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }
}
