import 'package:flutter/material.dart';
import 'admin_order_screen.dart';
import '../admin/admin_panel_screen.dart';

class AdminHomeScreen extends StatelessWidget {
  const AdminHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF75a2b9),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(30.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                elevation: 4,
                child: ListTile(
                  contentPadding: const EdgeInsets.all(20),
                  leading: const Icon(Icons.list_alt, color: Colors.indigo, size: 40),
                  title: const Text(
                    'Manage All Orders',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  subtitle: const Text('View and update order statuses.'),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const AdminOrderScreen(),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),

              Card(
                elevation: 4,
                child: ListTile(
                  contentPadding: const EdgeInsets.all(20),
                  leading: const Icon(Icons.inventory_2_outlined, color: Colors.teal, size: 40),
                  title: const Text(
                    'Add / Manage Products',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  subtitle: const Text('Add new products or edit existing ones.'),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const AdminAddProductScreen(),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}