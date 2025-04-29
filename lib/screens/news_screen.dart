import 'package:flutter/material.dart';

class NewsScreen extends StatelessWidget {
  const NewsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('📰 News Feed'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildNewsCard(
            title: 'Breaking News!',
            description: 'New marketplace launched in Hali app today.',
            imageUrl: 'https://via.placeholder.com/300',
          ),
          const SizedBox(height: 16),
          _buildNewsCard(
            title: 'Live Update',
            description: 'Hali users can now go live and stream events.',
            imageUrl: 'https://via.placeholder.com/300',
          ),
          const SizedBox(height: 16),
          _buildNewsCard(
            title: 'Hot Deals 🔥',
            description: 'Shop amazing deals in the marketplace section!',
            imageUrl: 'https://via.placeholder.com/300',
          ),
        ],
      ),
    );
  }

  Widget _buildNewsCard({
    required String title,
    required String description,
    required String imageUrl,
  }) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: Image.network(imageUrl, height: 180, width: double.infinity, fit: BoxFit.cover),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text(description),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
