import 'package:flutter/material.dart';
import '../models/item.dart';
import '../services/firestore_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirestoreService _service = FirestoreService();
  String _sortOption = 'Quantity (Low to High)';

  final List<String> _sortOptions = [
    'Quantity (Low to High)',
    'Quantity (High to Low)',
    'Price (Low to High)',
    'Price (High to Low)',
  ];

  List<Item> _sorted(List<Item> items) {
    final list = [...items];
    switch (_sortOption) {
      case 'Quantity (Low to High)': list.sort((a, b) => a.quantity.compareTo(b.quantity)); break;
      case 'Quantity (High to Low)': list.sort((a, b) => b.quantity.compareTo(a.quantity)); break;
      case 'Price (Low to High)': list.sort((a, b) => a.price.compareTo(b.price)); break;
      case 'Price (High to Low)': list.sort((a, b) => b.price.compareTo(a.price)); break;
    }
    return list;
  }

  void _showForm({Item? item}) {
    final nameCtrl = TextEditingController(text: item?.name);
    final qtyCtrl = TextEditingController(text: item?.quantity.toString());
    final priceCtrl = TextEditingController(text: item?.price.toString());
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(item == null ? 'Add Item' : 'Edit Item'),
        content: Form(
          key: formKey,
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            TextFormField(
              controller: nameCtrl,
              decoration: const InputDecoration(labelText: 'Name'),
              validator: (v) => v == null || v.isEmpty ? 'Name is required' : null,
            ),
            TextFormField(
              controller: qtyCtrl,
              decoration: const InputDecoration(labelText: 'Quantity'),
              keyboardType: TextInputType.number,
              validator: (v) {
                if (v == null || v.isEmpty) return 'Quantity is required';
                final n = int.tryParse(v);
                if (n == null || n < 0) return 'Enter a valid number';
                return null;
              },
            ),
            TextFormField(
              controller: priceCtrl,
              decoration: const InputDecoration(labelText: 'Price'),
              keyboardType: TextInputType.number,
              validator: (v) {
                if (v == null || v.isEmpty) return 'Price is required';
                final n = double.tryParse(v);
                if (n == null || n < 0) return 'Enter a valid price';
                return null;
              },
            ),
          ]),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                final newItem = Item(
                  id: item?.id ?? '',
                  name: nameCtrl.text.trim(),
                  quantity: int.parse(qtyCtrl.text),
                  price: double.parse(priceCtrl.text),
                );
                if (item == null) {
                  _service.addItem(newItem);
                } else {
                  _service.updateItem(item.id, newItem);
                }
                Navigator.pop(context);
              }
            },
            child: Text(item == null ? 'Add' : 'Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inventory'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: DropdownButton<String>(
              value: _sortOption,
              underline: const SizedBox(),
              items: _sortOptions.map((o) =>
                  DropdownMenuItem(value: o, child: Text(o, style: const TextStyle(fontSize: 13)))).toList(),
              onChanged: (v) => setState(() => _sortOption = v!),
            ),
          )
        ],
      ),
      body: StreamBuilder<List<Item>>(
        stream: _service.getItems(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          final items = _sorted(snapshot.data ?? []);
          if (items.isEmpty) {
            return const Center(child: Text('No items yet. Tap + to add one.'));
          }
          return ListView.builder(
            itemCount: items.length,
            itemBuilder: (context, i) {
              final item = items[i];
              return ListTile(
                title: Text(item.name),
                subtitle: Text('Qty: ${item.quantity}  |  \$${item.price.toStringAsFixed(2)}'),
                trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                  IconButton(icon: const Icon(Icons.edit), onPressed: () => _showForm(item: item)),
                  IconButton(icon: const Icon(Icons.delete), onPressed: () => _service.deleteItem(item.id)),
                ]),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showForm(),
        child: const Icon(Icons.add),
      ),
    );
  }
}