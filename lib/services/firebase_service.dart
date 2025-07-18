import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:image_picker/image_picker.dart';

class FirebaseService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final Uuid _uuid = Uuid();

  // Authentication methods
  Future<UserCredential?> signUp(String email, String password) async {
    try {
      return await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      print('Error signing up: $e');
      return null;
    }
  }

  Future<UserCredential?> signIn(String email, String password) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      print('Error signing in: $e');
      return null;
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  User? get currentUser => _auth.currentUser;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // User management
  Future<void> createUserProfile({
    required String uid,
    required String email,
    required String firstName,
    required String lastName,
    required String phoneNumber,
    required String address,
    String userType = 'customer', // 'customer' or 'seller'
  }) async {
    await _firestore.collection('users').doc(uid).set({
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
      'phoneNumber': phoneNumber,
      'address': address,
      'userType': userType,
      'createdAt': FieldValue.serverTimestamp(),
      'isActive': true,
    });
  }

  Future<Map<String, dynamic>?> getUserProfile(String uid) async {
    try {
      DocumentSnapshot doc = await _firestore.collection('users').doc(uid).get();
      return doc.data() as Map<String, dynamic>?;
    } catch (e) {
      print('Error getting user profile: $e');
      return null;
    }
  }

  // Product management
  Future<String> uploadProductImage(XFile imageFile) async {
    String fileName = '${_uuid.v4()}.jpg';
    Reference ref = _storage.ref().child('product_images/$fileName');
    UploadTask uploadTask;
    if (kIsWeb) {
      final bytes = await imageFile.readAsBytes();
      uploadTask = ref.putData(bytes);
    } else {
      uploadTask = ref.putFile(File(imageFile.path));
    }
    TaskSnapshot snapshot = await uploadTask;
    return await snapshot.ref.getDownloadURL();
  }

  Future<void> addProduct({
    required String sellerId,
    required String title,
    required String description,
    required double price,
    required List<String> images,
    required String category,
    double rating = 0.0,
    bool isPopular = false,
    bool isFavourite = false,
  }) async {
    await _firestore.collection('products').add({
      'sellerId': sellerId,
      'title': title,
      'description': description,
      'price': price,
      'images': images,
      'category': category,
      'rating': rating,
      'isPopular': isPopular,
      'isFavourite': isFavourite,
      'createdAt': FieldValue.serverTimestamp(),
      'isActive': true,
      'isApproved': false, // Require admin approval
    });
  }

  Future<List<Map<String, dynamic>>> getProducts() async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('products')
          .where('isActive', isEqualTo: true)
          .where('isApproved', isEqualTo: true)
          .orderBy('createdAt', descending: true)
          .get();
      
      return snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return data;
      }).toList();
    } catch (e) {
      print('Error getting products: $e');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getSellerProducts(String sellerId) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('products')
          .where('sellerId', isEqualTo: sellerId)
          .where('isActive', isEqualTo: true)
          .orderBy('createdAt', descending: true)
          .get();
      
      return snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return data;
      }).toList();
    } catch (e) {
      print('Error getting seller products: $e');
      return [];
    }
  }

  Future<void> updateProduct(String productId, Map<String, dynamic> data) async {
    await _firestore.collection('products').doc(productId).update(data);
  }

  Future<void> deleteProduct(String productId) async {
    await _firestore.collection('products').doc(productId).update({
      'isActive': false,
    });
  }

  // Order management
  Future<void> createOrder({
    required String customerId,
    required String sellerId,
    required String productId,
    required int quantity,
    required double totalPrice,
    required String shippingAddress,
  }) async {
    await _firestore.collection('orders').add({
      'customerId': customerId,
      'sellerId': sellerId,
      'productId': productId,
      'quantity': quantity,
      'totalPrice': totalPrice,
      'shippingAddress': shippingAddress,
      'status': 'pending', // pending, confirmed, shipped, delivered, cancelled
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<List<Map<String, dynamic>>> getCustomerOrders(String customerId) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('orders')
          .where('customerId', isEqualTo: customerId)
          .orderBy('createdAt', descending: true)
          .get();
      
      return snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return data;
      }).toList();
    } catch (e) {
      print('Error getting customer orders: $e');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getSellerOrders(String sellerId) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('orders')
          .where('sellerId', isEqualTo: sellerId)
          .orderBy('createdAt', descending: true)
          .get();
      
      return snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return data;
      }).toList();
    } catch (e) {
      print('Error getting seller orders: $e');
      return [];
    }
  }

  Future<void> updateOrderStatus(String orderId, String status) async {
    await _firestore.collection('orders').doc(orderId).update({
      'status': status,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // Analytics
  Future<Map<String, dynamic>> getSellerAnalytics(String sellerId) async {
    try {
      // Get total products
      QuerySnapshot productsSnapshot = await _firestore
          .collection('products')
          .where('sellerId', isEqualTo: sellerId)
          .where('isActive', isEqualTo: true)
          .get();
      
      // Get total orders
      QuerySnapshot ordersSnapshot = await _firestore
          .collection('orders')
          .where('sellerId', isEqualTo: sellerId)
          .get();
      
      // Get total revenue
      double totalRevenue = 0;
      for (var doc in ordersSnapshot.docs) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        if (data['status'] == 'delivered') {
          totalRevenue += (data['totalPrice'] ?? 0).toDouble();
        }
      }
      
      // Get orders by status
      Map<String, int> ordersByStatus = {};
      for (var doc in ordersSnapshot.docs) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        String status = data['status'] ?? 'unknown';
        ordersByStatus[status] = (ordersByStatus[status] ?? 0) + 1;
      }
      
      return {
        'totalProducts': productsSnapshot.docs.length,
        'totalOrders': ordersSnapshot.docs.length,
        'totalRevenue': totalRevenue,
        'ordersByStatus': ordersByStatus,
      };
    } catch (e) {
      print('Error getting seller analytics: $e');
      return {
        'totalProducts': 0,
        'totalOrders': 0,
        'totalRevenue': 0.0,
        'ordersByStatus': {},
      };
    }
  }

  Future<List<Map<String, dynamic>>> getPendingProducts() async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('products')
          .where('isApproved', isEqualTo: false)
          .where('isActive', isEqualTo: true)
          .orderBy('createdAt', descending: true)
          .get();
      return snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return data;
      }).toList();
    } catch (e) {
      print('Error getting pending products: $e');
      return [];
    }
  }

  Future<Map<String, dynamic>> getAdminAnalytics() async {
    try {
      // Total users
      QuerySnapshot usersSnapshot = await _firestore.collection('users').get();
      // Total products
      QuerySnapshot productsSnapshot = await _firestore.collection('products').get();
      // Total revenue (sum of totalPrice for delivered orders)
      QuerySnapshot ordersSnapshot = await _firestore
          .collection('orders')
          .where('status', isEqualTo: 'delivered')
          .get();
      double totalRevenue = 0;
      for (var doc in ordersSnapshot.docs) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        totalRevenue += (data['totalPrice'] ?? 0).toDouble();
      }
      return {
        'totalUsers': usersSnapshot.docs.length,
        'totalProducts': productsSnapshot.docs.length,
        'totalRevenue': totalRevenue,
      };
    } catch (e) {
      print('Error getting admin analytics: $e');
      return {
        'totalUsers': 0,
        'totalProducts': 0,
        'totalRevenue': 0.0,
      };
    }
  }

  // Cart management
  Future<void> addToCart({
    required String userId,
    required Map<String, dynamic> product, // Assuming Product object is a Map
    int quantity = 1,
  }) async {
    final cartItemRef = _firestore.collection('carts').doc(userId).collection('items').doc(product['id']);
    final doc = await cartItemRef.get();
    if (doc.exists) {
      // Increment quantity
      await cartItemRef.update({
        'quantity': FieldValue.increment(quantity),
      });
    } else {
      await cartItemRef.set({
        'productId': product['id'],
        'title': product['title'],
        'price': product['price'],
        'image': product['images'].isNotEmpty ? product['images'][0] : '',
        'quantity': quantity,
        'category': product['category'],
      });
    }
  }

  Future<List<Map<String, dynamic>>> getCartItems(String userId) async {
    final snapshot = await _firestore.collection('carts').doc(userId).collection('items').get();
    return snapshot.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id;
      return data;
    }).toList();
  }

  Future<void> removeCartItem({
    required String userId,
    required String productId,
  }) async {
    await _firestore.collection('carts').doc(userId).collection('items').doc(productId).delete();
  }

  Future<void> updateCartItemQuantity({
    required String userId,
    required String productId,
    required int quantity,
  }) async {
    await _firestore.collection('carts').doc(userId).collection('items').doc(productId).update({
      'quantity': quantity,
    });
  }
} 