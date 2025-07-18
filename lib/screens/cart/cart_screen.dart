import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/firebase_service.dart';
import 'components/cart_card.dart';
import 'components/check_out_card.dart';

class CartScreen extends StatefulWidget {
  static String routeName = "/cart";

  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final FirebaseService _firebaseService = FirebaseService();
  List<Map<String, dynamic>> cartItems = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCart();
  }

  Future<void> _loadCart() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(() {
        cartItems = [];
        isLoading = false;
      });
      return;
    }
    final items = await _firebaseService.getCartItems(user.uid);
    setState(() {
      cartItems = items;
      isLoading = false;
    });
  }

  Future<void> _removeCartItem(String productId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    await _firebaseService.removeCartItem(userId: user.uid, productId: productId);
    _loadCart();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          children: [
            const Text(
              "Your Cart",
              style: TextStyle(color: Colors.black),
            ),
            Text(
              "${cartItems.length} items",
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : cartItems.isEmpty
              ? const Center(child: Text('Your cart is empty.'))
              : Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: ListView.builder(
                    itemCount: cartItems.length,
                    itemBuilder: (context, index) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Dismissible(
                        key: Key(cartItems[index]['productId'] ?? cartItems[index]['id']),
                        direction: DismissDirection.endToStart,
                        onDismissed: (direction) {
                          _removeCartItem(cartItems[index]['productId'] ?? cartItems[index]['id']);
                        },
                        background: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFE6E6),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Row(
                            children: [
                              const Spacer(),
                              SvgPicture.asset("assets/icons/Trash.svg"),
                            ],
                          ),
                        ),
                        child: CartCard(cartItem: cartItems[index]),
                      ),
                    ),
                  ),
                ),
      bottomNavigationBar: const CheckoutCard(),
    );
  }
}
