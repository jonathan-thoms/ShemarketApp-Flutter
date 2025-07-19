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
  List<Map<String, dynamic>> filteredOrders = [];
  bool isLoading = true;
  String searchQuery = '';
  String? filterStatus;
  DateTimeRange? filterDateRange;

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
      _applyFilters();
      isLoading = false;
    });
  }

  void _applyFilters() {
    setState(() {
      filteredOrders = orders.where((order) {
        final orderId = (order['id'] ?? '').toLowerCase();
        final buyer = (order['buyerName'] ?? '').toLowerCase();
        final status = (order['status'] ?? '').toLowerCase();
        final createdAt = order['createdAt'] != null ? order['createdAt'].toDate() : null;
        final matchesSearch = searchQuery.isEmpty ||
          orderId.contains(searchQuery.toLowerCase()) ||
          buyer.contains(searchQuery.toLowerCase());
        final matchesStatus = filterStatus == null || filterStatus == status;
        final matchesDate = filterDateRange == null || (
          createdAt != null &&
          createdAt.isAfter(filterDateRange!.start.subtract(const Duration(days: 1))) &&
          createdAt.isBefore(filterDateRange!.end.add(const Duration(days: 1)))
        );
        return matchesSearch && matchesStatus && matchesDate;
      }).toList();
    });
  }

  void _showOrderDetails(Map<String, dynamic> order) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Order #${order['id'].substring(0, 8)}'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Buyer: ${order['buyerName'] ?? ''}'),
              Text('Email: ${order['buyerEmail'] ?? ''}'),
              Text('Phone: ${order['buyerPhone'] ?? ''}'),
              Text('Shipping Address: ${order['shippingAddress'] ?? ''}'),
              Text('Status: ${order['status'] ?? ''}'),
              Text('Total: \$${(order['totalPrice'] ?? 0.0).toStringAsFixed(2)}'),
              const SizedBox(height: 16),
              const Text('Order Details:', style: TextStyle(fontWeight: FontWeight.bold)),
              Text('Product ID: ${order['productId'] ?? ''}'),
              Text('Quantity: ${order['quantity'] ?? ''}'),
              Text('Created: ${_formatDate(order['createdAt'])}'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
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
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: const InputDecoration(
                      labelText: 'Search by order ID or buyer',
                      prefixIcon: Icon(Icons.search),
                    ),
                    onChanged: (value) {
                      searchQuery = value;
                      _applyFilters();
                    },
                  ),
                ),
                const SizedBox(width: 8),
                DropdownButton<String?>(
                  value: filterStatus,
                  hint: const Text('Status'),
                  items: [null, 'pending', 'confirmed', 'shipped', 'delivered', 'cancelled']
                      .map((status) => DropdownMenuItem(
                            value: status,
                            child: Text(status == null ? 'All' : status[0].toUpperCase() + status.substring(1)),
                          ))
                      .toList(),
                  onChanged: (value) {
                    filterStatus = value;
                    _applyFilters();
                  },
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.date_range),
                    label: const Text('Date'),
                    onPressed: () async {
                      final picked = await showDateRangePicker(
                        context: context,
                        firstDate: DateTime(2020),
                        lastDate: DateTime.now().add(const Duration(days: 1)),
                        initialDateRange: filterDateRange,
                      );
                      if (picked != null) {
                        filterDateRange = picked;
                        _applyFilters();
                      }
                    },
                  ),
                ),
                if (filterDateRange != null)
                  IconButton(
                    icon: const Icon(Icons.clear),
                    tooltip: 'Clear date filter',
                    onPressed: () {
                      filterDateRange = null;
                      _applyFilters();
                    },
                  ),
              ],
            ),
          ),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    onRefresh: _loadOrders,
                    child: ListView.builder(
                      itemCount: filteredOrders.length,
                      itemBuilder: (context, index) {
                        final order = filteredOrders[index];
                        return ListTile(
                          leading: const Icon(Icons.receipt_long),
                          title: Text('Order #${order['id'].substring(0, 8)}'),
                          subtitle: Text('Buyer: ${order['buyerName'] ?? ''}\nStatus: ${order['status'] ?? ''}'),
                          trailing: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text('\$${(order['totalPrice'] ?? 0.0).toStringAsFixed(2)}'),
                              Text(_formatDate(order['createdAt'])),
                            ],
                          ),
                          isThreeLine: true,
                          onTap: () => _showOrderDetails(order),
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }
} 