import 'package:flutter/material.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'post_product_screen.dart';

/// Global analytics instance
final FirebaseAnalytics analytics = FirebaseAnalytics.instance;

class MarketplaceScreen extends StatefulWidget {
  const MarketplaceScreen({Key? key}) : super(key: key);

  @override
  State<MarketplaceScreen> createState() => _MarketplaceScreenState();
}

class _MarketplaceScreenState extends State<MarketplaceScreen> {
  @override
  void initState() {
    super.initState();
    // Log that user has viewed the marketplace
    analytics.setCurrentScreen(screenName: 'MarketplaceScreen');
  }

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
        backgroundColor: Colors.teal,
        tooltip: 'Post Product',
        child: const Icon(Icons.add),
        onPressed: () async {
          // Log that the user started posting an item
          await analytics.logEvent(name: 'start_post_item');

          // Navigate to the PostProductScreen and await a "refresh" signal
          final didPost = await Navigator.push<bool>(
            context,
            MaterialPageRoute(builder: (_) => const PostProductScreen()),
          );

          if (didPost == true) {
            // You could re-fetch your live product list here.
            setState(() {});
          }
        },
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
          // Log which item was viewed
          analytics.logEvent(
            name: 'view_item',
            parameters: {
              'item_title': title,
              'item_price': price,
            },
          );
          // TODO: push to a detailed ProductDetailScreen
        },
      ),
    );
  }
}
