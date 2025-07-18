import 'package:flutter/material.dart';

import '../../../constants.dart';

class CartCard extends StatelessWidget {
  const CartCard({
    Key? key,
    required this.cartItem,
  }) : super(key: key);

  final Map<String, dynamic> cartItem;

  @override
  Widget build(BuildContext context) {
    final image = cartItem['image'] ?? '';
    final isNetwork = image.startsWith('http://') ||
        image.startsWith('https://') ||
        image.contains('firebasestorage.googleapis.com');
    return Row(
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
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              cartItem['title'] ?? '',
              style: const TextStyle(color: Colors.black, fontSize: 16),
              maxLines: 2,
            ),
            const SizedBox(height: 8),
            Text.rich(
              TextSpan(
                text: "\$${cartItem['price'] ?? 0}",
                style: const TextStyle(
                    fontWeight: FontWeight.w600, color: kPrimaryColor),
                children: [
                  TextSpan(
                      text: " x${cartItem['quantity'] ?? 1}",
                      style: Theme.of(context).textTheme.bodyLarge),
                ],
              ),
            )
          ],
        )
      ],
    );
  }
}
