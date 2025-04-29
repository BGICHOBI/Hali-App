import 'package:flutter/material.dart';

class MarketplaceScreen extends StatelessWidget {
  const MarketplaceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🛒 Marketplace'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildProductCard(
            title: 'iPhone 14 Pro',
            price: 'KES 150,000',
            imageUrl: 'https://via.placeholder.com/150',
          ),
          const SizedBox(height: 16),
          _buildProductCard(
            title: 'Gaming Laptop',
            price: 'KES 95,000',
            imageUrl: 'https://via.placeholder.com/150',
          ),
          const SizedBox(height: 16),
          _buildProductCard(
            title: 'Sneakers',
            price: 'KES 7,000',
            imageUrl: 'https://via.placeholder.com/150',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Post a Product')),
          );
        },
        backgroundColor: Colors.teal,
        child: const Icon(Icons.add),
        tooltip: 'Post Product',
      ),
    );
  }

  Widget _buildProductCard({
    required String title,
    required String price,
    required String imageUrl,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.network(imageUrl, width: 60, height: 60, fit: BoxFit.cover),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(price),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {
          // Optional: View product details
        },
      ),
    );
  }
}
