import 'package:flutter/material.dart';
import '../../services/firebase_service.dart';

class ManageOrdersScreen extends StatefulWidget {
  const ManageOrdersScreen({super.key});

  @override
  State<ManageOrdersScreen> createState() => _ManageOrdersScreenState();
}

class _ManageOrdersScreenState extends State<ManageOrdersScreen> {
  final FirebaseService _firebaseService = FirebaseService();
  List<Map<String, dynamic>> orders = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    setState(() { isLoading = true; });
    final snapshot = await _firebaseService.getAllOrders();
    setState(() {
      orders = snapshot;
      isLoading = false;
    });
  }

  String _formatDate(dynamic timestamp) {
    if (timestamp == null) return 'Unknown';
    try {
      DateTime date = timestamp.toDate();
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return 'Unknown';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Orders'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadOrders,
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadOrders,
              child: ListView.builder(
                itemCount: orders.length,
                itemBuilder: (context, index) {
                  final order = orders[index];
                  return ListTile(
                    leading: const Icon(Icons.receipt_long),
                    title: Text('Order #${order['id'].substring(0, 8)}'),
                    subtitle: Text('Buyer: ${order['buyerName'] ?? ''}\nProduct: ${order['productId'] ?? ''}\nStatus: ${order['status'] ?? ''}'),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('\$${(order['totalPrice'] ?? 0.0).toStringAsFixed(2)}'),
                        Text(_formatDate(order['createdAt'])),
                      ],
                    ),
                    isThreeLine: true,
                  );
                },
              ),
            ),
    );
  }
} 