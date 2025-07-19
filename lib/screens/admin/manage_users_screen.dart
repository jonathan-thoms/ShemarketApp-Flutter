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
  bool isLoading = true;

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
      isLoading = false;
    });
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
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadUsers,
              child: ListView.builder(
                itemCount: users.length,
                itemBuilder: (context, index) {
                  final user = users[index];
                  return ListTile(
                    leading: const Icon(Icons.person),
                    title: Text('${user['firstName'] ?? ''} ${user['lastName'] ?? ''}'),
                    subtitle: Text('${user['email'] ?? ''}\nType: ${user['userType'] ?? ''}'),
                    isThreeLine: true,
                    trailing: user['isActive'] == false
                        ? const Icon(Icons.block, color: Colors.red)
                        : const Icon(Icons.check_circle, color: Colors.green),
                  );
                },
              ),
            ),
    );
  }
} 