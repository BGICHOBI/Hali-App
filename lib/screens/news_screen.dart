import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'news_detail_screen.dart';

class NewsScreen extends StatefulWidget {
  const NewsScreen({super.key});

  @override
  State<NewsScreen> createState() => _NewsScreenState();
}

class _NewsScreenState extends State<NewsScreen> {
  String _searchTerm = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('📰 News Feed'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search articles…',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchTerm.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchTerm = '');
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: (val) => setState(
                  () => _searchTerm = val.trim().toLowerCase()),
            ),
          ),

          // Article list
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('news')
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                      child: Text('Error: ${snapshot.error}'));
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                      child: CircularProgressIndicator());
                }

                // Raw list of docs
                final docs = snapshot.data!.docs;

                // Filter by title if user typed
                final filtered = _searchTerm.isEmpty
                    ? docs
                    : docs.where((doc) {
                        final title = (doc['title'] as String)
                            .toLowerCase();
                        return title.contains(_searchTerm);
                      }).toList();

                if (filtered.isEmpty) {
                  return const Center(
                      child: Text('No matching articles'));
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final doc = filtered[index];
                    final data = doc.data()! as Map<String, dynamic>;
                    final title = data['title'] as String? ?? 'No title';
                    final body = data['body'] as String? ?? '';
                    final imageUrl = data['imageUrl'] as String?;
                    final docId = doc.id;

                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => NewsDetailScreen(
                              docId: docId,
                              title: title,
                              body: body,
                              imageUrl: imageUrl,
                            ),
                          ),
                        );
                      },
                      child: Card(
                        margin: const EdgeInsets.only(bottom: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 4,
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            if (imageUrl != null &&
                                imageUrl.isNotEmpty)
                              Hero(
                                tag: 'news-$docId',
                                child: ClipRRect(
                                  borderRadius: const BorderRadius.vertical(
                                      top: Radius.circular(16)),
                                  child: Image.network(
                                    imageUrl,
                                    height: 180,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                    errorBuilder:
                                        (_, __, ___) => Container(
                                      height: 180,
                                      color:
                                          Colors.grey[300],
                                      alignment:
                                          Alignment.center,
                                      child: const Icon(
                                          Icons.broken_image,
                                          size: 48),
                                    ),
                                  ),
                                ),
                              ),
                            Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    title,
                                    style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight:
                                            FontWeight.bold),
                                  ),
                                  const SizedBox(
                                      height: 8),
                                  Text(
                                    body,
                                    maxLines: 3,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
