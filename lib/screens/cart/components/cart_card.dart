import 'package:flutter/material.dart';

import '../../../constants.dart';

class CartCard extends StatelessWidget {
  const CartCard({
    Key? key,
    required this.cartItem,
    required this.onRemove,
    required this.onQuantityChanged,
  }) : super(key: key);

  final Map<String, dynamic> cartItem;
  final VoidCallback onRemove;
  final Function(int) onQuantityChanged;

  @override
  Widget build(BuildContext context) {
    final image = cartItem['image'] ?? '';
    final isNetwork = image.startsWith('http://') ||
        image.startsWith('https://') ||
        image.contains('firebasestorage.googleapis.com');
    final quantity = cartItem['quantity'] ?? 1;
    final price = cartItem['price'] ?? 0.0;
    final totalPrice = price * quantity;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            offset: const Offset(0, 2),
            blurRadius: 8,
            color: Colors.grey.withOpacity(0.1),
          )
        ],
      ),
      child: Row(
        children: [
          SizedBox(
            width: 88,
            child: AspectRatio(
              aspectRatio: 0.88,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F6F9),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: image.isEmpty
                    ? const Icon(Icons.image)
                    : isNetwork
                        ? Image.network(image)
                        : Image.asset(image),
              ),
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  cartItem['title'] ?? '',
                  style: const TextStyle(color: Colors.black, fontSize: 16),
                  maxLines: 2,
                ),
                const SizedBox(height: 8),
                Text(
                  "\$${price.toStringAsFixed(2)}",
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: kPrimaryColor,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    IconButton(
                      onPressed: quantity > 1 ? () => onQuantityChanged(quantity - 1) : null,
                      icon: const Icon(Icons.remove_circle_outline),
                      color: quantity > 1 ? kPrimaryColor : Colors.grey,
                    ),
                    Text(
                      "$quantity",
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                      onPressed: () => onQuantityChanged(quantity + 1),
                      icon: const Icon(Icons.add_circle_outline),
                      color: kPrimaryColor,
                    ),
                    const Spacer(),
                    Text(
                      "\$${totalPrice.toStringAsFixed(2)}",
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: kPrimaryColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onRemove,
            icon: const Icon(Icons.delete_outline, color: Colors.red),
          ),
        ],
      ),
    );
  }
}
