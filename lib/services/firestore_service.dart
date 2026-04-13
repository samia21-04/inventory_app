import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/item.dart';

class FirestoreService {
  final CollectionReference _collection =
      FirebaseFirestore.instance.collection('inventory');

  // Stream all items
  Stream<List<Item>> getItems() {
    return _collection.snapshots().map((snapshot) =>
        snapshot.docs.map((doc) =>
            Item.fromMap(doc.data() as Map<String, dynamic>, doc.id)).toList());
  }

  // Add
  Future<void> addItem(Item item) => _collection.add(item.toMap());

  // Update
  Future<void> updateItem(String id, Item item) =>
      _collection.doc(id).update(item.toMap());

  // Delete
  Future<void> deleteItem(String id) => _collection.doc(id).delete();
}