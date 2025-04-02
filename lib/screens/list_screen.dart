import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/item.dart';
import '../screens/add_edit_screen.dart';  // Ensure this import exists

class InventoryListScreen extends StatefulWidget {
  const InventoryListScreen({super.key});

  @override
  State<InventoryListScreen> createState() => _InventoryListScreenState();
}

class _InventoryListScreenState extends State<InventoryListScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<InventoryItem> _allItems = [];
  bool _isDescending = false;
  String _sortColumn = 'name';

  // 1. Move all methods before build()
  Future<bool> _confirmDelete(BuildContext context, InventoryItem item) async {
    return await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Item'),
        content: Text('Are you sure you want to delete ${item.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteItem(String id) async {
    try {
      await _firestore.collection('items').doc(id).delete();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Item deleted successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deleting item: $e')),
        );
      }
    }
  }

  void _navigateToEditScreen(BuildContext context, InventoryItem item) {
    Navigator.pushNamed(
      context,
      '/edit',
      arguments: item,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inventory Items'),
        actions: [
          IconButton(
            icon: Icon(
              Icons.sort,
              color: _isDescending ? Colors.blue : Colors.grey,
            ),
            onPressed: _showSortDialog,
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection('items').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          _allItems = snapshot.data!.docs.map((doc) {
            return InventoryItem.fromMap(doc.id, doc.data() as Map<String, dynamic>);
          }).toList();

          final sortedItems = _sortItemsInternal(_allItems, _sortColumn, _isDescending);

          return ListView.builder(
            itemCount: sortedItems.length,
            itemBuilder: (context, index) {
              final item = sortedItems[index];
              return Dismissible(
                key: Key(item.id!),
                background: Container(color: Colors.red),
                confirmDismiss: (direction) async {
                  return await _confirmDelete(context, item);
                },
                onDismissed: (direction) => _deleteItem(item.id!),
                child: ListTile(
                  title: Text(item.name),
                  subtitle: Text(
                    'Qty: ${item.quantity} | \$${item.price.toStringAsFixed(2)} | ${item.category}',
                  ),
                  trailing: Icon(
                    _sortColumn == 'name' ? Icons.sort_by_alpha :
                    _sortColumn == 'quantity' ? Icons.numbers :
                    Icons.attach_money,
                    color: Colors.blue,
                  ),
                  onTap: () => _navigateToEditScreen(context, item),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () => Navigator.pushNamed(context, '/add'),
      ),
    );
  }

  List<InventoryItem> _sortItemsInternal(List<InventoryItem> items, String field, bool isDescending) {
    final sortedItems = List<InventoryItem>.from(items);
    
    sortedItems.sort((a, b) {
      dynamic aValue, bValue;
      
      switch (field) {
        case 'name':
          aValue = a.name.toLowerCase();
          bValue = b.name.toLowerCase();
          break;
        case 'quantity':
          aValue = a.quantity;
          bValue = b.quantity;
          break;
        case 'price':
          aValue = a.price;
          bValue = b.price;
          break;
        case 'category':
          aValue = a.category.toLowerCase();
          bValue = b.category.toLowerCase();
          break;
        default:
          aValue = a.name.toLowerCase();
          bValue = b.name.toLowerCase();
      }
      
      if (isDescending) {
        return bValue.compareTo(aValue);
      } else {
        return aValue.compareTo(bValue);
      }
    });
    
    return sortedItems;
  }

  void _sortItems(String field, {bool isDescending = false}) {
    setState(() {
      _sortColumn = field;
      _isDescending = isDescending;
    });
  }

  void _showSortDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sort Items By'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('Name (A-Z)'),
              trailing: _sortColumn == 'name' 
                  ? Icon(_isDescending ? Icons.arrow_downward : Icons.arrow_upward)
                  : null,
              onTap: () {
                _sortItems('name', isDescending: _sortColumn == 'name' ? !_isDescending : false);
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('Quantity (High-Low)'),
              trailing: _sortColumn == 'quantity' 
                  ? Icon(_isDescending ? Icons.arrow_downward : Icons.arrow_upward)
                  : null,
              onTap: () {
                _sortItems('quantity', isDescending: _sortColumn == 'quantity' ? !_isDescending : true);
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('Price (High-Low)'),
              trailing: _sortColumn == 'price' 
                  ? Icon(_isDescending ? Icons.arrow_downward : Icons.arrow_upward)
                  : null,
              onTap: () {
                _sortItems('price', isDescending: _sortColumn == 'price' ? !_isDescending : true);
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('Category (A-Z)'),
              trailing: _sortColumn == 'category' 
                  ? Icon(_isDescending ? Icons.arrow_downward : Icons.arrow_upward)
                  : null,
              onTap: () {
                _sortItems('category', isDescending: _sortColumn == 'category' ? !_isDescending : false);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}