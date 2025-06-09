import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_analytics/firebase_analytics.dart';

/// Same global analytics instance
final FirebaseAnalytics analytics = FirebaseAnalytics.instance;

class PostProductScreen extends StatefulWidget {
  const PostProductScreen({Key? key}) : super(key: key);

  @override
  State<PostProductScreen> createState() => _PostProductScreenState();
}

class _PostProductScreenState extends State<PostProductScreen> {
  final _titleCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  String _category = 'Electronics';
  bool _submitting = false;

  final _categories = ['Electronics', 'Clothing', 'Groceries', 'Other'];

  @override
  void initState() {
    super.initState();
    // Log that user has landed on the post screen
    analytics.setCurrentScreen(screenName: 'PostProductScreen');
  }

  Future<void> _submit() async {
    final title = _titleCtrl.text.trim();
    final price = _priceCtrl.text.trim();
    if (title.isEmpty || price.isEmpty) {
      ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('All fields required')));
      return;
    }

    setState(() => _submitting = true);

    // 1) write to Firestore
    final docRef = await FirebaseFirestore.instance
      .collection('marketplace')
      .add({
        'title': title,
        'price': price,
        'category': _category,
        'imageUrl': '', // hook up an image picker later
        'createdAt': FieldValue.serverTimestamp(),
      });

    // 2) log completion event
    await analytics.logEvent(
      name: 'complete_post_item',
      parameters: {
        'item_id': docRef.id,
        'title': title,
        'category': _category,
      },
    );

    setState(() => _submitting = false);

    // 3) pop and signal Marketplace to refresh
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Post a Product')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _titleCtrl,
              decoration: const InputDecoration(labelText: 'Title'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _priceCtrl,
              decoration: const InputDecoration(labelText: 'Price'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _category,
              decoration: const InputDecoration(labelText: 'Category'),
              items: _categories
                  .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                  .toList(),
              onChanged: (v) => setState(() => _category = v!),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _submitting ? null : _submit,
                child: _submitting
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Post Product'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
