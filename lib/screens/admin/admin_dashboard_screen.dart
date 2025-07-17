import 'package:flutter/material.dart';
import '../../services/firebase_service.dart';

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

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() { isLoading = true; });
    final products = await _firebaseService.getPendingProducts();
    final stats = await _firebaseService.getAdminAnalytics();
    setState(() {
      pendingProducts = products;
      analytics = stats;
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