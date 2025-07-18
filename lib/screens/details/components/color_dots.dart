import 'package:flutter/material.dart';
import '../../../models/Product.dart';

class ColorDots extends StatelessWidget {
  const ColorDots({
    Key? key,
    required this.product,
  }) : super(key: key);

  final Product product;

  @override
  Widget build(BuildContext context) {
    // Instead of color dots, show the product's category if available
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          if (product.category != null)
            Text('Category: ${product.category}',
                style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
