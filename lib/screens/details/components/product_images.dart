import 'package:flutter/material.dart';

import '../../../constants.dart';
import '../../../models/Product.dart';

class ProductImages extends StatefulWidget {
  const ProductImages({
    Key? key,
    required this.product,
  }) : super(key: key);

  final Product product;

  @override
  _ProductImagesState createState() => _ProductImagesState();
}

class _ProductImagesState extends State<ProductImages> {
  int selectedImage = 0;
  @override
  Widget build(BuildContext context) {
    final image = widget.product.images[selectedImage];
    final isNetwork = image.startsWith('http://') ||
        image.startsWith('https://') ||
        image.contains('firebasestorage.googleapis.com');
    return Column(
      children: [
        SizedBox(
          width: 238,
          child: AspectRatio(
            aspectRatio: 1,
            child: isNetwork
                ? Image.network(image)
                : Image.asset(image),
          ),
        ),
        // SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ...List.generate(
              widget.product.images.length,
              (index) => SmallProductImage(
                isSelected: index == selectedImage,
                press: () {
                  setState(() {
                    selectedImage = index;
                  });
                },
                image: widget.product.images[index],
              ),
            ),
          ],
        )
      ],
    );
  }
}

class SmallProductImage extends StatefulWidget {
  const SmallProductImage(
      {super.key,
      required this.isSelected,
      required this.press,
      required this.image});

  final bool isSelected;
  final VoidCallback press;
  final String image;

  @override
  State<SmallProductImage> createState() => _SmallProductImageState();
}

class _SmallProductImageState extends State<SmallProductImage> {
  @override
  Widget build(BuildContext context) {
    final isNetwork = widget.image.startsWith('http://') ||
        widget.image.startsWith('https://') ||
        widget.image.contains('firebasestorage.googleapis.com');
    return GestureDetector(
      onTap: widget.press,
      child: AnimatedContainer(
        duration: defaultDuration,
        margin: const EdgeInsets.only(right: 16),
        padding: const EdgeInsets.all(8),
        height: 48,
        width: 48,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
              color: kPrimaryColor.withOpacity(widget.isSelected ? 1 : 0)),
        ),
        child: isNetwork
            ? Image.network(widget.image)
            : Image.asset(widget.image),
      ),
    );
  }
}
