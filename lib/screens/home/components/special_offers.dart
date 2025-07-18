import 'package:flutter/material.dart';
import 'package:shop_app/screens/products/products_screen.dart';

import 'section_title.dart';

class SpecialOffers extends StatelessWidget {
  final String? selectedCategory;
  final void Function(String?) onCategorySelected;
  const SpecialOffers({
    Key? key,
    required this.selectedCategory,
    required this.onCategorySelected,
  }) : super(key: key);

  static const List<String> categories = [
    'Clothing',
    'Food',
    'Handicrafts',
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: SectionTitle(
            title: "Special for you",
            press: () {},
          ),
        ),
        const SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              const SizedBox(width: 20),
              ...categories.map((cat) {
                final isSelected = selectedCategory == cat;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(cat),
                    selected: isSelected,
                    onSelected: (selected) {
                      onCategorySelected(selected ? cat : null);
                    },
                    selectedColor: Theme.of(context).primaryColor.withOpacity(0.2),
                    labelStyle: TextStyle(
                      color: isSelected ? Theme.of(context).primaryColor : Colors.black,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                );
              }).toList(),
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: const Text('Clear'),
                  selected: selectedCategory == null,
                  onSelected: (_) => onCategorySelected(null),
                  selectedColor: Colors.grey[300],
                  labelStyle: TextStyle(
                    color: selectedCategory == null ? Colors.black : Colors.grey,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
