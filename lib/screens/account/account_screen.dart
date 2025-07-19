import 'package:flutter/material.dart';
import '../../services/firebase_service.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  final FirebaseService _firebaseService = FirebaseService();
  Map<String, dynamic>? userProfile;
  List<Map<String, dynamic>> orders = [];
  bool isLoading = true;
  final _formKey = GlobalKey<FormState>();
  String? address;
  String? phoneNumber;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() { isLoading = true; });
    final user = _firebaseService.currentUser;
    if (user != null) {
      final profile = await _firebaseService.getUserProfile(user.uid);
      final userOrders = await _firebaseService.getCustomerOrders(user.uid);
      setState(() {
        userProfile = profile;
        orders = userOrders;
        address = profile?['address'] ?? '';
        phoneNumber = profile?['phoneNumber'] ?? '';
        isLoading = false;
      });
    }
  }

  Future<void> _saveProfile() async {
    final user = _firebaseService.currentUser;
    if (user != null && _formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      await _firebaseService.updateUserProfile(user.uid, {
        'address': address,
        'phoneNumber': phoneNumber,
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated!')),
      );
      _loadData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Account')),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextFormField(
                          initialValue: userProfile?['firstName'] ?? '',
                          decoration: const InputDecoration(labelText: 'First Name'),
                          enabled: false,
                        ),
                        TextFormField(
                          initialValue: userProfile?['lastName'] ?? '',
                          decoration: const InputDecoration(labelText: 'Last Name'),
                          enabled: false,
                        ),
                        TextFormField(
                          initialValue: userProfile?['email'] ?? '',
                          decoration: const InputDecoration(labelText: 'Email'),
                          enabled: false,
                        ),
                        TextFormField(
                          initialValue: phoneNumber,
                          decoration: const InputDecoration(labelText: 'Phone Number'),
                          keyboardType: TextInputType.phone,
                          onSaved: (val) => phoneNumber = val,
                        ),
                        TextFormField(
                          initialValue: address,
                          decoration: const InputDecoration(labelText: 'Address'),
                          onSaved: (val) => address = val,
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _saveProfile,
                            child: const Text('Save Changes'),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  const Text('My Orders', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  ...orders.map((order) => Card(
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        child: ListTile(
                          title: Text('Order #${order['id'].substring(0, 8)}'),
                          subtitle: Text('Status: ${order['status']}\nTotal: \$${(order['totalPrice'] ?? 0.0).toStringAsFixed(2)}'),
                        ),
                      )),
                  if (orders.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(32),
                      child: Center(child: Text('No orders found.')),
                    ),
                ],
              ),
            ),
    );
  }
} 