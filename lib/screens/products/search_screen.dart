import 'package:flutter/material.dart';
import '../../services/firebase_service.dart';
import '../details/details_screen.dart';
import '../../models/Product.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final FirebaseService _firebaseService = FirebaseService();
  List<Map<String, dynamic>> results = [];
  bool isLoading = false;
  String query = '';

  void _onSearchChanged(String value) async {
    setState(() {
      query = value;
      isLoading = true;
    });
    if (value.isEmpty) {
      setState(() {
        results = [];
        isLoading = false;
      });
      return;
    }
    final products = await _firebaseService.searchProducts(value);
    setState(() {
      results = products;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search Products'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Search by product name, description, or category',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: _onSearchChanged,
            ),
          ),
          if (isLoading)
            const Padding(
              padding: EdgeInsets.all(24),
              child: CircularProgressIndicator(),
            ),
          if (!isLoading && results.isEmpty && query.isNotEmpty)
            const Padding(
              padding: EdgeInsets.all(24),
              child: Text('No products found.'),
            ),
          if (!isLoading && results.isNotEmpty)
            (results.length == 1
                ? Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: SizedBox(
                      width: 180,
                      height: 250,
                      child: _ProductCard(product: results[0]),
                    ),
                  )
                : Expanded(
                    child: GridView.builder(
                      padding: const EdgeInsets.all(8),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.9,
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 8,
                      ),
                      itemCount: results.length,
                      itemBuilder: (context, index) {
                        final product = results[index];
                        return _ProductCard(product: product);
                      },
                    ),
                  )
            ),
        ],
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  final Map<String, dynamic> product;
  const _ProductCard({required this.product});

  @override
  Widget build(BuildContext context) {
    final image = (product['images'] is List && product['images'].isNotEmpty)
        ? product['images'][0]
        : null;
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(
          context,
          DetailsScreen.routeName,
          arguments: ProductDetailsArguments(
            product: Product.fromMap(product, id: product['id']),
          ),
        );
      },
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(6.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: AspectRatio(
                  aspectRatio: 1.1,
                  child: image != null
                      ? Image.network(image, fit: BoxFit.cover)
                      : const Icon(Icons.image, size: 36),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                product['title'] ?? '',
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                '\$${(product['price'] ?? 0.0).toStringAsFixed(2)}',
                style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 