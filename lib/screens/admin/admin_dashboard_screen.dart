import 'package:flutter/material.dart';
import '../../services/firebase_service.dart';
import 'manage_users_screen.dart';
import 'manage_orders_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  static String routeName = "/admin_dashboard";
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  final FirebaseService _firebaseService = FirebaseService();
  List<Map<String, dynamic>> pendingProducts = [];
  Map<String, dynamic> analytics = {};
  bool isLoading = true;
  List<Map<String, dynamic>> userGrowth = [];
  List<Map<String, dynamic>> productGrowth = [];
  List<Map<String, dynamic>> orderVolume = [];
  List<Map<String, dynamic>> revenueTrends = [];
  List<Map<String, dynamic>> topSellers = [];
  List<Map<String, dynamic>> topProducts = [];
  List<Map<String, dynamic>> systemLogs = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() { isLoading = true; });
    final products = await _firebaseService.getPendingProducts();
    final stats = await _firebaseService.getAdminAnalytics();
    final users = await _firebaseService.getUserGrowth();
    final prodGrowth = await _firebaseService.getProductGrowth();
    final orders = await _firebaseService.getOrderVolume();
    final revenue = await _firebaseService.getRevenueTrends();
    final sellers = await _firebaseService.getTopSellers();
    final productsTop = await _firebaseService.getTopProducts();
    final logs = await _firebaseService.getSystemLogs();
    setState(() {
      pendingProducts = products;
      analytics = stats;
      userGrowth = users;
      productGrowth = prodGrowth;
      orderVolume = orders;
      revenueTrends = revenue;
      topSellers = sellers;
      topProducts = productsTop;
      systemLogs = logs;
      isLoading = false;
    });
  }

  Future<void> _approveProduct(String productId) async {
    await _firebaseService.updateProduct(productId, {'isApproved': true});
    _loadData();
  }

  Future<void> _rejectProduct(String productId) async {
    await _firebaseService.deleteProduct(productId);
    _loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadData,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // Analytics
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Analytics', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          Text('Total Users: ${analytics['totalUsers'] ?? '-'}'),
                          Text('Total Products: ${analytics['totalProducts'] ?? '-'}'),
                          Text('Total Revenue: \$${(analytics['totalRevenue'] ?? 0.0).toStringAsFixed(2)}'),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Advanced Analytics
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Advanced Analytics', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          Text('User Growth (last 30 days): ${userGrowth.length}'),
                          Text('Product Growth (last 30 days): ${productGrowth.length}'),
                          Text('Order Volume (last 30 days): ${orderVolume.length}'),
                          Text('Revenue (last 30 days): \$${revenueTrends.fold(0.0, (sum, e) => sum + (e['totalPrice'] ?? 0.0)).toStringAsFixed(2)}'),
                          const SizedBox(height: 8),
                          Text('Top Sellers:'),
                          ...topSellers.map((s) => Text('Seller: ${s['sellerId']} Revenue: \$${s['revenue'].toStringAsFixed(2)}')),
                          const SizedBox(height: 8),
                          Text('Top Products:'),
                          ...topProducts.map((p) => Text('Product: ${p['productId']} Sold: ${p['quantity']}')),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // System Logs
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('System Logs', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          ...systemLogs.map((log) => Text('[${log['type']}] ${log['id']} - ${log['createdAt'] != null ? log['createdAt'].toDate().toString() : ''}')),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Quick Actions
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const ManageUsersScreen()),
                            );
                          },
                          child: const Text('Manage Users'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const ManageOrdersScreen()),
                            );
                          },
                          child: const Text('Manage Orders'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('Export Data'),
                                content: const Text('Export functionality coming soon!'),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text('OK'),
                                  ),
                                ],
                              ),
                            );
                          },
                          child: const Text('Export Data'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  // Pending Products
                  const Text('Pending Products', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  ...pendingProducts.map((product) => Card(
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        child: ListTile(
                          leading: product['images'] != null && (product['images'] as List).isNotEmpty
                              ? Image.network(product['images'][0], width: 56, height: 56, fit: BoxFit.cover)
                              : const Icon(Icons.image, size: 56),
                          title: Text(product['title'] ?? ''),
                          subtitle: Text(product['description'] ?? ''),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.check, color: Colors.green),
                                onPressed: () => _approveProduct(product['id']),
                                tooltip: 'Approve',
                              ),
                              IconButton(
                                icon: const Icon(Icons.close, color: Colors.red),
                                onPressed: () => _rejectProduct(product['id']),
                                tooltip: 'Reject',
                              ),
                            ],
                          ),
                        ),
                      )),
                  if (pendingProducts.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(32),
                      child: Center(child: Text('No pending products.')),
                    ),
                ],
              ),
            ),
    );
  }
} 