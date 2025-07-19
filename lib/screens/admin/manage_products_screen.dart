import 'package:flutter/material.dart';
import '../../services/firebase_service.dart';

class ManageProductsScreen extends StatefulWidget {
  const ManageProductsScreen({super.key});

  @override
  State<ManageProductsScreen> createState() => _ManageProductsScreenState();
}

class _ManageProductsScreenState extends State<ManageProductsScreen> {
  final FirebaseService _firebaseService = FirebaseService();
  List<Map<String, dynamic>> products = [];
  List<Map<String, dynamic>> filteredProducts = [];
  bool isLoading = true;
  String searchQuery = '';
  String? filterSeller;
  String? filterCategory;
  String? filterApproval; // approved/pending

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    setState(() { isLoading = true; });
    final snapshot = await _firebaseService.getAllProducts();
    setState(() {
      products = snapshot;
      _applyFilters();
      isLoading = false;
    });
  }

  void _applyFilters() {
    setState(() {
      filteredProducts = products.where((product) {
        final title = (product['title'] ?? '').toLowerCase();
        final seller = (product['sellerId'] ?? '').toLowerCase();
        final category = (product['category'] ?? '').toLowerCase();
        final approval = (product['isApproved'] == true) ? 'approved' : 'pending';
        final matchesSearch = searchQuery.isEmpty || title.contains(searchQuery.toLowerCase());
        final matchesSeller = filterSeller == null || filterSeller == seller;
        final matchesCategory = filterCategory == null || filterCategory == category;
        final matchesApproval = filterApproval == null || filterApproval == approval;
        return matchesSearch && matchesSeller && matchesCategory && matchesApproval;
      }).toList();
    });
  }

  void _showEditProductDialog(Map<String, dynamic> product) async {
    final titleController = TextEditingController(text: product['title'] ?? '');
    final descController = TextEditingController(text: product['description'] ?? '');
    final priceController = TextEditingController(text: (product['price'] ?? '').toString());
    final categoryController = TextEditingController(text: product['category'] ?? '');
    final approved = product['isApproved'] == true;
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Product'),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(controller: titleController, decoration: const InputDecoration(labelText: 'Title')),
              TextField(controller: descController, decoration: const InputDecoration(labelText: 'Description')),
              TextField(controller: priceController, decoration: const InputDecoration(labelText: 'Price'), keyboardType: TextInputType.number),
              TextField(controller: categoryController, decoration: const InputDecoration(labelText: 'Category')),
              CheckboxListTile(
                value: approved,
                onChanged: null,
                title: const Text('Approved'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              await _firebaseService.updateProduct(product['id'], {
                'title': titleController.text,
                'description': descController.text,
                'price': double.tryParse(priceController.text) ?? 0.0,
                'category': categoryController.text,
              });
              Navigator.pop(context, true);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
    if (result == true) _loadProducts();
  }

  void _deleteProduct(Map<String, dynamic> product) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Product'),
        content: Text('Are you sure you want to delete ${product['title']}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete', style: TextStyle(color: Colors.red))),
        ],
      ),
    );
    if (confirm == true) {
      await _firebaseService.deleteProduct(product['id']);
      _loadProducts();
    }
  }

  @override
  Widget build(BuildContext context) {
    final uniqueSellers = products.map((p) => p['sellerId'] ?? '').toSet().toList();
    final uniqueCategories = products.map((p) => p['category'] ?? '').toSet().toList();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Products'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadProducts,
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
                      labelText: 'Search by title',
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
                  value: filterSeller,
                  hint: const Text('Seller'),
                  items: [null, ...uniqueSellers]
                      .map<DropdownMenuItem<String?>>((seller) => DropdownMenuItem<String?>(
                            value: seller,
                            child: Text(seller == null || seller.isEmpty ? 'All' : seller),
                          ))
                      .toList(),
                  onChanged: (value) {
                    filterSeller = value;
                    _applyFilters();
                  },
                ),
                const SizedBox(width: 8),
                DropdownButton<String?>(
                  value: filterCategory,
                  hint: const Text('Category'),
                  items: [null, ...uniqueCategories]
                      .map<DropdownMenuItem<String?>>((cat) => DropdownMenuItem<String?>(
                            value: cat,
                            child: Text(cat == null || cat.isEmpty ? 'All' : cat),
                          ))
                      .toList(),
                  onChanged: (value) {
                    filterCategory = value;
                    _applyFilters();
                  },
                ),
                const SizedBox(width: 8),
                DropdownButton<String?>(
                  value: filterApproval,
                  hint: const Text('Approval'),
                  items: [null, 'approved', 'pending']
                      .map((appr) => DropdownMenuItem(
                            value: appr,
                            child: Text(appr == null ? 'All' : appr[0].toUpperCase() + appr.substring(1)),
                          ))
                      .toList(),
                  onChanged: (value) {
                    filterApproval = value;
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
                    onRefresh: _loadProducts,
                    child: ListView.builder(
                      itemCount: filteredProducts.length,
                      itemBuilder: (context, index) {
                        final product = filteredProducts[index];
                        final image = (product['images'] is List && product['images'].isNotEmpty)
                            ? product['images'][0]
                            : null;
                        return ListTile(
                          leading: image != null
                              ? Image.network(image, width: 56, height: 56, fit: BoxFit.cover)
                              : const Icon(Icons.image, size: 56),
                          title: Text(product['title'] ?? ''),
                          subtitle: Text('Seller: ${product['sellerId'] ?? ''}\nCategory: ${product['category'] ?? ''}\nStatus: ${(product['isApproved'] == true) ? 'Approved' : 'Pending'}'),
                          isThreeLine: true,
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit, color: Colors.blue),
                                tooltip: 'Edit',
                                onPressed: () => _showEditProductDialog(product),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                tooltip: 'Delete',
                                onPressed: () => _deleteProduct(product),
                              ),
                            ],
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
} 