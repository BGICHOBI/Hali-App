import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_analytics/firebase_analytics.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({Key? key}) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _msgCtrl = TextEditingController();
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;
  final _analytics = FirebaseAnalytics.instance;

  @override
  void initState() {
    super.initState();
    // Log screen open with timestamp
    _analytics.logEvent(
      name: 'chat_screen_opened',
      parameters: {
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
  }

  Future<void> _sendMessage() async {
    final text = _msgCtrl.text.trim();
    final nowIso = DateTime.now().toIso8601String();

    if (text.isEmpty) {
      // Log failed empty-send with timestamp
      await _analytics.logEvent(
        name: 'message_send_failed_empty',
        parameters: {
          'timestamp': nowIso,
        },
      );
      return;
    }

    _msgCtrl.clear();

    // Write to Firestore
    await _firestore.collection('chats').add({
      'text': text,
      'sender': _auth.currentUser?.email ?? 'anonymous',
      'timestamp': FieldValue.serverTimestamp(),
    });

    // Log successful send with length, sender, and timestamp
    await _analytics.logEvent(
      name: 'message_sent',
      parameters: {
        'message_length': text.length,
        'sender': _auth.currentUser?.email ?? 'anonymous',
        'timestamp': nowIso,
      },
    );
  }

  @override
  void dispose() {
    // Log screen close with timestamp
    _analytics.logEvent(
      name: 'chat_screen_closed',
      parameters: {
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
    _msgCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext ctx) {
    return Scaffold(
      appBar: AppBar(title: const Text('💬 Chat'), centerTitle: true),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('chats')
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (ctx, snap) {
                if (!snap.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final docs = snap.data!.docs;
                return ListView.builder(
                  reverse: true,
                  itemCount: docs.length,
                  itemBuilder: (_, i) {
                    final data = docs[i].data()! as Map<String, dynamic>;
                    return ListTile(
                      title: Text(data['sender'] ?? 'unknown'),
                      subtitle: Text(data['text'] ?? ''),
                      trailing: Text(
                        data['timestamp'] != null
                            ? (data['timestamp'] as Timestamp)
                                .toDate()
                                .toLocal()
                                .hour
                                .toString()
                            : '',
                        style: const TextStyle(fontSize: 10),
                      ),
                    );
                  },
                );
              },
            ),
          ),

          // Message input
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _msgCtrl,
                      decoration: const InputDecoration(
                        hintText: 'Type a message...',
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.send, color: Colors.teal),
                    onPressed: _sendMessage,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
