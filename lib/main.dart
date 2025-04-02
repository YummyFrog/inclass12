import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';
import 'screens/list_screen.dart';  // Add this
import 'screens/add_edit_screen.dart';  // Add this
import 'models/item.dart';  // Add this

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const InventoryApp());
}

class InventoryApp extends StatelessWidget {
  const InventoryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Inventory Manager',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const InventoryListScreen(),
      routes: {
        '/add': (context) => const AddEditItemScreen(),
        '/edit': (context) => const AddEditItemScreen(isEditing: true),
      },
    );
  }
}