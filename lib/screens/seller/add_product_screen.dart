import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:image_picker/image_picker.dart';
import '../../../services/firebase_service.dart';
import '../../../constants.dart';

class AddProductScreen extends StatefulWidget {
  static String routeName = "/add_product";

  const AddProductScreen({super.key});

  @override
  _AddProductScreenState createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final FirebaseService _firebaseService = FirebaseService();
  final ImagePicker _picker = ImagePicker();
  
  String? title;
  String? description;
  double? price;
  List<XFile> selectedImages = [];
  String? category;
  final List<String> categories = ['Clothing', 'Food', 'Handicrafts'];
  bool isPopular = false;
  bool isFavourite = false;
  bool isLoading = false;

  Future<void> _pickImages() async {
    final List<XFile> images = await _picker.pickMultiImage();
    if (images.isNotEmpty) {
      setState(() {
        selectedImages.addAll(images);
      });
    }
  }

  Future<void> _removeImage(int index) async {
    setState(() {
      selectedImages.removeAt(index);
    });
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate() && selectedImages.isNotEmpty && category != null) {
      _formKey.currentState!.save();
      setState(() {
        isLoading = true;
      });

      try {
        final user = _firebaseService.currentUser;
        if (user == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('User not authenticated')),
          );
          return;
        }

        // Upload images
        List<String> imageUrls = [];
        for (XFile imageFile in selectedImages) {
          String imageUrl = await _firebaseService.uploadProductImage(imageFile);
          imageUrls.add(imageUrl);
        }

        // Add product to Firestore
        await _firebaseService.addProduct(
          sellerId: user.uid,
          title: title!,
          description: description!,
          price: price!,
          images: imageUrls,
          category: category!,
          isPopular: isPopular,
          isFavourite: isFavourite,
        );

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Product added successfully!')),
        );

        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error adding product: $e')),
        );
      } finally {
        setState(() {
          isLoading = false;
        });
      }
    } else if (selectedImages.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one image')),
      );
    } else if (category == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a category')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Product'),
        backgroundColor: kPrimaryColor,
        foregroundColor: Colors.white,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Product Images
                    const Text(
                      'Product Images',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      height: 120,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: selectedImages.length + 1,
                        itemBuilder: (context, index) {
                          if (index == selectedImages.length) {
                            return GestureDetector(
                              onTap: _pickImages,
                              child: Container(
                                width: 100,
                                margin: const EdgeInsets.only(right: 12),
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(
                                  Icons.add_photo_alternate,
                                  size: 40,
                                  color: Colors.grey,
                                ),
                              ),
                            );
                          }
                          return Stack(
                            children: [
                              Container(
                                width: 100,
                                height: 100,
                                margin: const EdgeInsets.only(right: 12),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  image: DecorationImage(
                                    image: kIsWeb
                                        ? NetworkImage(selectedImages[index].path)
                                        : FileImage(File(selectedImages[index].path)) as ImageProvider,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              Positioned(
                                top: 4,
                                right: 8,
                                child: GestureDetector(
                                  onTap: () => _removeImage(index),
                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: const BoxDecoration(
                                      color: Colors.red,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.close,
                                      size: 16,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Product Title
                    TextFormField(
                      onSaved: (value) => title = value,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter product title';
                        }
                        return null;
                      },
                      decoration: const InputDecoration(
                        labelText: 'Product Title',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Product Description
                    TextFormField(
                      onSaved: (value) => description = value,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter product description';
                        }
                        return null;
                      },
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: 'Product Description',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Product Price
                    TextFormField(
                      onSaved: (value) => price = double.tryParse(value ?? ''),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter product price';
                        }
                        if (double.tryParse(value) == null) {
                          return 'Please enter a valid price';
                        }
                        return null;
                      },
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Product Price (\$)',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.attach_money),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Product Category
                    const Text(
                      'Category',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: categories.map((cat) {
                        final isSelected = category == cat;
                        return ChoiceChip(
                          label: Text(cat),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() {
                              category = selected ? cat : null;
                            });
                          },
                          selectedColor: kPrimaryColor.withOpacity(0.2),
                          labelStyle: TextStyle(
                            color: isSelected ? kPrimaryColor : Colors.black,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),

                    // Product Options
                    Row(
                      children: [
                        Expanded(
                          child: CheckboxListTile(
                            title: const Text('Popular Product'),
                            value: isPopular,
                            onChanged: (value) {
                              setState(() {
                                isPopular = value ?? false;
                              });
                            },
                          ),
                        ),
                        Expanded(
                          child: CheckboxListTile(
                            title: const Text('Favourite'),
                            value: isFavourite,
                            onChanged: (value) {
                              setState(() {
                                isFavourite = value ?? false;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Submit Button
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _submitForm,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: kPrimaryColor,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text(
                          'Add Product',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
} 