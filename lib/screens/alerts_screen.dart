import 'package:flutter/material.dart';
import '../models/item.dart';
import '../services/firestore_service.dart';

class AlertsScreen extends StatelessWidget {
  const AlertsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final service = FirestoreService();
    return Scaffold(
      appBar: AppBar(title: const Text('Low-Stock Alerts')),
      body: StreamBuilder<List<Item>>(
        stream: service.getItems(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          final lowStock = (snapshot.data ?? []).where((i) => i.quantity < 5).toList();
          if (lowStock.isEmpty) {
            return const Center(child: Text('All items are sufficiently stocked!'));
          }
          return ListView.builder(
            itemCount: lowStock.length,
            itemBuilder: (_, i) {
              final item = lowStock[i];
              return ListTile(
                leading: const Icon(Icons.warning_amber, color: Colors.amber),
                title: Text(item.name),
                subtitle: Text('Only ${item.quantity} left in stock'),
              );
            },
          );
        },
      ),
    );
  }
}