import 'package:flutter/material.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

/// Global Analytics instance (same one you attached to your navigatorObservers)
final FirebaseAnalytics analytics = FirebaseAnalytics.instance;

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  // Helper to log & then perform an action
  Future<void> _onFeatureTap({
    required String feature,
    required VoidCallback navigate,
  }) async {
    try {
      await analytics.logEvent(
        name: 'select_feature',
        parameters: {'feature': feature},
      );
    } catch (e, st) {
      // Report any logging error
      await FirebaseCrashlytics.instance
          .recordError(e, st, reason: 'logging $feature tap');
    }
    navigate();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🏠 Home'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            const Text(
              'Welcome to Hali 👋',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.teal,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Explore news, chat, shop in the marketplace, send money and more!',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 32),

            // Quick Feature Cards
            _buildFeatureCard(
              context,
              icon: Icons.article,
              title: 'News Feed',
              subtitle: 'Stay updated with latest news',
              onTap: () {
                _onFeatureTap(
                  feature: 'news_feed',
                  navigate: () => Navigator.pushNamed(context, '/news'),
                );
              },
            ),
            const SizedBox(height: 16),
            _buildFeatureCard(
              context,
              icon: Icons.chat_bubble_outline,
              title: 'Chat with Friends',
              subtitle: 'Connect instantly',
              onTap: () {
                _onFeatureTap(
                  feature: 'chat',
                  navigate: () => Navigator.pushNamed(context, '/chat'),
                );
              },
            ),
            const SizedBox(height: 16),
            _buildFeatureCard(
              context,
              icon: Icons.video_call,
              title: 'Live Streaming',
              subtitle: 'Start or join live streams',
              onTap: () {
                _onFeatureTap(
                  feature: 'live_streaming',
                  navigate: () => Navigator.pushNamed(context, '/live'),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 3,
      child: ListTile(
        leading: Icon(icon, size: 40, color: Colors.teal),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: onTap,
      ),
    );
  }
}
