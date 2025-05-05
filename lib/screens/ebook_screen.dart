import 'package:flutter/material.dart';

class EbookScreen extends StatelessWidget {
  const EbookScreen({super.key});

  @override
  Widget build(BuildContext ctx) {
    final books = [
      {'title': 'Flutter for Beginners', 'author': 'Jane Doe'},
      {'title': 'Dart in Action',      'author': 'John Smith'},
      {'title': 'Mobile UI Design',    'author': 'Alice Lee'},
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('📚 E-Books'), centerTitle: true),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: books.length,
        itemBuilder: (_, i) {
          final b = books[i];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: const Icon(Icons.menu_book, color: Colors.teal),
              title: Text(b['title'] as String),
              subtitle: Text(b['author'] as String),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                // TODO: open reader view for this book
              },
            ),
          );
        },
      ),
    );
  }
}
