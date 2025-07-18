import 'package:flutter/material.dart';
import '../../../components/product_card.dart';
import '../../../services/firebase_service.dart';
import '../../details/details_screen.dart';
import '../../../models/Product.dart';

class ProductFeed extends StatefulWidget {
  final String? category;
  const ProductFeed({super.key, this.category});

  @override
  State<ProductFeed> createState() => _ProductFeedState();
}

class _ProductFeedState extends State<ProductFeed> {
  final FirebaseService _firebaseService = FirebaseService();
  List<Map<String, dynamic>> products = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  @override
  void didUpdateWidget(covariant ProductFeed oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.category != widget.category) {
      _loadProducts();
    }
  }

  Future<void> _loadProducts() async {
    setState(() { isLoading = true; });
    List<Map<String, dynamic>> all = await _firebaseService.getProducts();
    List<Map<String, dynamic>> filtered = all.where((p) {
      final matchesCategory = widget.category == null || p['category'] == widget.category;
      return matchesCategory;
    }).toList();
    setState(() {
      products = filtered;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (widget.category == null)
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Products",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        isLoading
            ? const Padding(
                padding: EdgeInsets.all(32),
                child: Center(child: CircularProgressIndicator()),
              )
            : products.isEmpty
                ? const Padding(
                    padding: EdgeInsets.all(32),
                    child: Center(child: Text('No products found.')),
                  )
                : SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        ...products.map((product) => Padding(
                              padding: const EdgeInsets.only(left: 20),
                              child: ProductCard(
                                product: Product.fromMap(product, id: product['id']),
                                onPress: () => Navigator.pushNamed(
                                  context,
                                  '/details',
                                  arguments: ProductDetailsArguments(
                                    product: Product.fromMap(product, id: product['id']),
                                  ),
                                ),
                              ),
                            )),
                        const SizedBox(width: 20),
                      ],
                    ),
                  ),
      ],
    );
  }
}
