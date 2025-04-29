import 'package:flutter/material.dart';

class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('💬 Chat'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildChatTile(
            username: 'Alice',
            lastMessage: 'Hey, how are you?',
            time: '5 min ago',
          ),
          const Divider(),
          _buildChatTile(
            username: 'Brian',
            lastMessage: 'Let\'s meet tomorrow!',
            time: '10 min ago',
          ),
          const Divider(),
          _buildChatTile(
            username: 'Cynthia',
            lastMessage: 'Hali marketplace is awesome 🔥',
            time: '1 hour ago',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('New Chat Clicked')),
          );
        },
        backgroundColor: Colors.teal,
        child: const Icon(Icons.add_comment),
        tooltip: 'Start new chat',
      ),
    );
  }

  Widget _buildChatTile({
    required String username,
    required String lastMessage,
    required String time,
  }) {
    return ListTile(
      leading: const CircleAvatar(
        radius: 24,
        child: Icon(Icons.person),
      ),
      title: Text(username, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(lastMessage),
      trailing: Text(time, style: const TextStyle(color: Colors.grey)),
      onTap: () {
        // Optional: Open chat conversation
      },
    );
  }
}
