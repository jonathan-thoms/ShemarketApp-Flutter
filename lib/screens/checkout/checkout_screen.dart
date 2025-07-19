import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/firebase_service.dart';
import '../../constants.dart';
import 'components/address_section.dart';
import 'components/payment_method_section.dart';
import 'components/order_summary.dart';

class CheckoutScreen extends StatefulWidget {
  static String routeName = "/checkout";

  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final FirebaseService _firebaseService = FirebaseService();
  List<Map<String, dynamic>> cartItems = [];
  Map<String, dynamic>? userProfile;
  String selectedPaymentMethod = 'card';
  String deliveryAddress = '';
  bool isLoading = true;
  bool isPlacingOrder = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      Navigator.pushReplacementNamed(context, '/sign_in');
      return;
    }

    try {
      final items = await _firebaseService.getCartItems(user.uid);
      final profile = await _firebaseService.getUserProfile(user.uid);
      
      setState(() {
        cartItems = items;
        userProfile = profile;
        deliveryAddress = profile?['address'] ?? '';
        isLoading = false;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading checkout data: $e')),
      );
      setState(() {
        isLoading = false;
      });
    }
  }

  double get totalAmount {
    return cartItems.fold(0.0, (sum, item) {
      final price = (item['price'] ?? 0.0).toDouble();
      final quantity = (item['quantity'] ?? 1).toInt();
      return sum + (price * quantity);
    });
  }

  Future<void> _placeOrder() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || userProfile == null) return;

    setState(() {
      isPlacingOrder = true;
    });

    try {
      // Create orders for each cart item
      for (var item in cartItems) {
        await _firebaseService.createOrder(
          customerId: user.uid,
          sellerId: item['sellerId'] ?? 'unknown',
          productId: item['productId'] ?? item['id'],
          quantity: item['quantity'] ?? 1,
          totalPrice: (item['price'] ?? 0.0) * (item['quantity'] ?? 1),
          shippingAddress: deliveryAddress,
          buyerName: userProfile?['firstName'] ?? '',
          buyerEmail: userProfile?['email'] ?? '',
          buyerPhone: userProfile?['phoneNumber'] ?? '',
        );
      }

      // Clear cart
      for (var item in cartItems) {
        await _firebaseService.removeCartItem(
          userId: user.uid,
          productId: item['productId'] ?? item['id'],
        );
      }

      // Navigate to success page
      Navigator.pushReplacementNamed(context, '/order_success');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error placing order: $e')),
      );
    } finally {
      setState(() {
        isPlacingOrder = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Checkout",
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : cartItems.isEmpty
              ? const Center(child: Text('Your cart is empty.'))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Address Section
                      AddressSection(
                        address: deliveryAddress,
                        onAddressChanged: (address) {
                          setState(() {
                            deliveryAddress = address;
                          });
                        },
                      ),
                      const SizedBox(height: 30),

                      // Payment Method Section
                      PaymentMethodSection(
                        selectedMethod: selectedPaymentMethod,
                        onMethodChanged: (method) {
                          setState(() {
                            selectedPaymentMethod = method;
                          });
                        },
                      ),
                      const SizedBox(height: 30),

                      // Order Summary
                      OrderSummary(
                        cartItems: cartItems,
                        totalAmount: totalAmount,
                      ),
                      const SizedBox(height: 30),

                      // Place Order Button
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: isPlacingOrder || deliveryAddress.isEmpty
                              ? null
                              : _placeOrder,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: kPrimaryColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                          child: isPlacingOrder
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                  ),
                                )
                              : const Text(
                                  "Place Order",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }
} 