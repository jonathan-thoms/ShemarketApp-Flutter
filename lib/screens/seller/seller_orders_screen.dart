import 'package:flutter/material.dart';
import '../../../services/firebase_service.dart';
import '../../../models/Order.dart';
import '../../../constants.dart';

class SellerOrdersScreen extends StatefulWidget {
  static String routeName = "/seller_orders";

  const SellerOrdersScreen({super.key});

  @override
  _SellerOrdersScreenState createState() => _SellerOrdersScreenState();
}

class _SellerOrdersScreenState extends State<SellerOrdersScreen> {
  final FirebaseService _firebaseService = FirebaseService();
  List<Map<String, dynamic>> orders = [];
  bool isLoading = true;
  String selectedStatus = 'all';

  final List<String> statusFilters = [
    'all',
    'pending',
    'confirmed',
    'shipped',
    'delivered',
    'cancelled',
  ];

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    final user = _firebaseService.currentUser;
    if (user != null) {
      final data = await _firebaseService.getSellerOrders(user.uid);
      setState(() {
        orders = data;
        isLoading = false;
      });
    }
  }

  Future<void> _updateOrderStatus(String orderId, String newStatus) async {
    try {
      await _firebaseService.updateOrderStatus(orderId, newStatus);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Order status updated to $newStatus')),
      );
      _loadOrders();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating order status: $e')),
      );
    }
  }

  List<Map<String, dynamic>> get filteredOrders {
    if (selectedStatus == 'all') {
      return orders;
    }
    return orders.where((order) => order['status'] == selectedStatus).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Orders'),
        backgroundColor: kPrimaryColor,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Status Filter
          Container(
            padding: const EdgeInsets.all(16),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: statusFilters.map((status) {
                  bool isSelected = selectedStatus == status;
                  return Container(
                    margin: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(
                        status == 'all' ? 'All' : status.toUpperCase(),
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.black,
                        ),
                      ),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          selectedStatus = status;
                        });
                      },
                      selectedColor: kPrimaryColor,
                      checkmarkColor: Colors.white,
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          
          // Orders List
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : filteredOrders.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.shopping_cart,
                              size: 64,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No orders found',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Orders will appear here when customers place them',
                              style: TextStyle(
                                color: Colors.grey[500],
                              ),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _loadOrders,
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: filteredOrders.length,
                          itemBuilder: (context, index) {
                            final order = filteredOrders[index];
                            final orderModel = OrderModel.fromMap(
                              order['id'],
                              order,
                            );
                            
                            return Card(
                              margin: const EdgeInsets.only(bottom: 16),
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Order Header
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'Order #${order['id'].substring(0, 8)}',
                                                style: const TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                _formatDate(order['createdAt']),
                                                style: TextStyle(
                                                  color: Colors.grey[600],
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 6,
                                          ),
                                          decoration: BoxDecoration(
                                            color: orderModel.statusColor,
                                            borderRadius: BorderRadius.circular(16),
                                          ),
                                          child: Text(
                                            orderModel.statusText,
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 12,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 16),
                                    
                                    // Order Details
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              const Text(
                                                'Quantity',
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.grey,
                                                ),
                                              ),
                                              Text(
                                                '${order['quantity']}',
                                                style: const TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              const Text(
                                                'Total Price',
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.grey,
                                                ),
                                              ),
                                              Text(
                                                '\$${(order['totalPrice'] ?? 0.0).toStringAsFixed(2)}',
                                                style: const TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w600,
                                                  color: kPrimaryColor,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 16),
                                    
                                    // Buyer Details
                                    const Text(
                                      'Buyer Details',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Name: ${order['buyerName'] ?? 'N/A'}',
                                      style: const TextStyle(fontSize: 14),
                                    ),
                                    Text(
                                      'Email: ${order['buyerEmail'] ?? 'N/A'}',
                                      style: const TextStyle(fontSize: 14),
                                    ),
                                    Text(
                                      'Phone: ${order['buyerPhone'] ?? 'N/A'}',
                                      style: const TextStyle(fontSize: 14),
                                    ),
                                    const SizedBox(height: 16),
                                    
                                    // Shipping Address
                                    const Text(
                                      'Shipping Address',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      order['shippingAddress'] ?? 'No address provided',
                                      style: const TextStyle(fontSize: 14),
                                    ),
                                    const SizedBox(height: 16),
                                    
                                    // Action Buttons
                                    if (order['status'] == 'pending')
                                      Row(
                                        children: [
                                          Expanded(
                                            child: OutlinedButton(
                                              onPressed: () => _updateOrderStatus(
                                                order['id'],
                                                'confirmed',
                                              ),
                                              child: const Text('Confirm'),
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: OutlinedButton(
                                              onPressed: () => _updateOrderStatus(
                                                order['id'],
                                                'cancelled',
                                              ),
                                              style: OutlinedButton.styleFrom(
                                                foregroundColor: Colors.red,
                                              ),
                                              child: const Text('Cancel'),
                                            ),
                                          ),
                                        ],
                                      ),
                                    if (order['status'] == 'confirmed')
                                      Row(
                                        children: [
                                          Expanded(
                                            child: OutlinedButton(
                                              onPressed: () => _updateOrderStatus(
                                                order['id'],
                                                'shipped',
                                              ),
                                              child: const Text('Mark as Shipped'),
                                            ),
                                          ),
                                        ],
                                      ),
                                    if (order['status'] == 'shipped')
                                      Row(
                                        children: [
                                          Expanded(
                                            child: OutlinedButton(
                                              onPressed: () => _updateOrderStatus(
                                                order['id'],
                                                'delivered',
                                              ),
                                              child: const Text('Mark as Delivered'),
                                            ),
                                          ),
                                        ],
                                      ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  String _formatDate(dynamic timestamp) {
    if (timestamp == null) return 'Unknown';
    try {
      DateTime date = timestamp.toDate();
      return '${date.day}/${date.month}/${date.year} at ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return 'Unknown';
    }
  }
} 