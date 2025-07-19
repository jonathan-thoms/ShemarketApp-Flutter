import 'package:flutter/material.dart';
import '../../services/firebase_service.dart';

class ManageUsersScreen extends StatefulWidget {
  const ManageUsersScreen({super.key});

  @override
  State<ManageUsersScreen> createState() => _ManageUsersScreenState();
}

class _ManageUsersScreenState extends State<ManageUsersScreen> {
  final FirebaseService _firebaseService = FirebaseService();
  List<Map<String, dynamic>> users = [];
  List<Map<String, dynamic>> filteredUsers = [];
  bool isLoading = true;
  String searchQuery = '';
  String? filterType; // customer/seller
  String? filterStatus; // active/inactive

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    setState(() { isLoading = true; });
    final snapshot = await _firebaseService.getAllUsers();
    setState(() {
      users = snapshot;
      _applyFilters();
      isLoading = false;
    });
  }

  void _applyFilters() {
    setState(() {
      filteredUsers = users.where((user) {
        final name = ((user['firstName'] ?? '') + ' ' + (user['lastName'] ?? '')).toLowerCase();
        final email = (user['email'] ?? '').toLowerCase();
        final type = (user['userType'] ?? '').toLowerCase();
        final status = (user['isActive'] == false) ? 'inactive' : 'active';
        final matchesSearch = searchQuery.isEmpty ||
          name.contains(searchQuery.toLowerCase()) ||
          email.contains(searchQuery.toLowerCase());
        final matchesType = filterType == null || filterType == type;
        final matchesStatus = filterStatus == null || filterStatus == status;
        return matchesSearch && matchesType && matchesStatus;
      }).toList();
    });
  }

  void _showUserDetails(Map<String, dynamic> user) async {
    // Fetch order history for this user
    final orders = await _firebaseService.getCustomerOrders(user['id']);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${user['firstName'] ?? ''} ${user['lastName'] ?? ''}'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Email: ${user['email'] ?? ''}'),
              Text('Type: ${user['userType'] ?? ''}'),
              Text('Status: ${user['isActive'] == false ? 'Inactive' : 'Active'}'),
              Text('Phone: ${user['phoneNumber'] ?? ''}'),
              Text('Address: ${user['address'] ?? ''}'),
              const SizedBox(height: 16),
              const Text('Order History:', style: TextStyle(fontWeight: FontWeight.bold)),
              ...orders.map((order) => Text('Order #${order['id'].substring(0, 8)} - ${order['status']} - \$${(order['totalPrice'] ?? 0.0).toStringAsFixed(2)}')),
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

  void _deactivateUser(Map<String, dynamic> user) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Deactivate User'),
        content: Text('Are you sure you want to deactivate ${user['firstName']} ${user['lastName']}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Deactivate')),
        ],
      ),
    );
    if (confirm == true) {
      await _firebaseService.updateUserStatus(user['id'], false);
      _loadUsers();
    }
  }

  void _reactivateUser(Map<String, dynamic> user) async {
    await _firebaseService.updateUserStatus(user['id'], true);
    _loadUsers();
  }

  void _deleteUser(Map<String, dynamic> user) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete User'),
        content: Text('Are you sure you want to permanently delete ${user['firstName']} ${user['lastName']}? This cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete', style: TextStyle(color: Colors.red))),
        ],
      ),
    );
    if (confirm == true) {
      await _firebaseService.deleteUser(user['id']);
      _loadUsers();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Users'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadUsers,
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
                      labelText: 'Search by name or email',
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
                  value: filterType,
                  hint: const Text('Type'),
                  items: [null, 'customer', 'seller']
                      .map((type) => DropdownMenuItem(
                            value: type,
                            child: Text(type == null ? 'All' : type[0].toUpperCase() + type.substring(1)),
                          ))
                      .toList(),
                  onChanged: (value) {
                    filterType = value;
                    _applyFilters();
                  },
                ),
                const SizedBox(width: 8),
                DropdownButton<String?>(
                  value: filterStatus,
                  hint: const Text('Status'),
                  items: [null, 'active', 'inactive']
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
              ],
            ),
          ),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    onRefresh: _loadUsers,
                    child: ListView.builder(
                      itemCount: filteredUsers.length,
                      itemBuilder: (context, index) {
                        final user = filteredUsers[index];
                        return ListTile(
                          leading: const Icon(Icons.person),
                          title: Text('${user['firstName'] ?? ''} ${user['lastName'] ?? ''}'),
                          subtitle: Text('${user['email'] ?? ''}\nType: ${user['userType'] ?? ''}'),
                          isThreeLine: true,
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (user['isActive'] == false)
                                IconButton(
                                  icon: const Icon(Icons.check_circle, color: Colors.green),
                                  tooltip: 'Reactivate',
                                  onPressed: () => _reactivateUser(user),
                                )
                              else
                                IconButton(
                                  icon: const Icon(Icons.block, color: Colors.red),
                                  tooltip: 'Deactivate',
                                  onPressed: () => _deactivateUser(user),
                                ),
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.grey),
                                tooltip: 'Delete',
                                onPressed: () => _deleteUser(user),
                              ),
                            ],
                          ),
                          onTap: () => _showUserDetails(user),
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