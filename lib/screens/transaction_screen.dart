import 'package:flutter/material.dart';

class TransactionScreen extends StatelessWidget {
  const TransactionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('💰 Transactions'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildTransactionTile(
            title: 'Sent to Alice',
            amount: '- KES 500',
            time: 'Today, 10:30 AM',
          ),
          const Divider(),
          _buildTransactionTile(
            title: 'Received from Brian',
            amount: '+ KES 1,200',
            time: 'Yesterday, 4:20 PM',
          ),
          const Divider(),
          _buildTransactionTile(
            title: 'Bought from Marketplace',
            amount: '- KES 3,000',
            time: '2 days ago',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Initiate Transaction')),
          );
        },
        backgroundColor: Colors.teal,
        child: const Icon(Icons.add),
        tooltip: 'New Transaction',
      ),
    );
  }

  Widget _buildTransactionTile({
    required String title,
    required String amount,
    required String time,
  }) {
    return ListTile(
      leading: const CircleAvatar(
        backgroundColor: Colors.teal,
        child: Icon(Icons.swap_horiz, color: Colors.white),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(time),
      trailing: Text(
        amount,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: amount.startsWith('-') ? Colors.red : Colors.green,
        ),
      ),
      onTap: () {
        // Optional: View transaction details
      },
    );
  }
}
