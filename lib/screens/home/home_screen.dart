import 'package:flutter/material.dart';

import 'components/home_header.dart';
import 'components/special_offers.dart';
import 'components/product_feed.dart';

class HomeScreen extends StatefulWidget {
  static String routeName = "/home";

  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? selectedCategory;

  void _onCategorySelected(String? category) {
    setState(() {
      selectedCategory = category;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            children: [
              const HomeHeader(),
              SpecialOffers(
                selectedCategory: selectedCategory,
                onCategorySelected: _onCategorySelected,
              ),
              const SizedBox(height: 20),
              ProductFeed(category: selectedCategory),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
