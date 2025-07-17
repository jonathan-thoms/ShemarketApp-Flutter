# Firebase Setup and Seller Features

This Flutter e-commerce app has been enhanced with Firebase backend integration and seller dashboard functionality.

## Features Added

### 1. Firebase Integration
- Authentication (Email/Password)
- Firestore Database for products, users, and orders
- Firebase Storage for product images
- Real-time data synchronization

### 2. Seller Dashboard
- **Dashboard Overview**: Analytics cards showing total products, orders, and revenue
- **Product Management**: Add, edit, and delete products with image upload
- **Order Management**: View and update order status (pending, confirmed, shipped, delivered, cancelled)
- **Analytics**: Detailed analytics with charts and performance metrics

### 3. Authentication Updates
- OTP bypassed for faster registration/login
- User type selection (Customer/Seller)
- Automatic navigation based on user type

## Firebase Setup Instructions

### 1. Create Firebase Project
1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click "Create a project"
3. Enter project name and follow the setup wizard
4. Enable Google Analytics (optional)

### 2. Add Android App
1. In Firebase Console, click the Android icon
2. Enter package name: `com.example.shop_app`
3. Enter app nickname: "Shop App"
4. Download the `google-services.json` file
5. Replace the placeholder file in `android/app/google-services.json`

### 3. Enable Services
1. **Authentication**:
   - Go to Authentication > Sign-in method
   - Enable Email/Password

2. **Firestore Database**:
   - Go to Firestore Database
   - Create database in test mode
   - Set up security rules (see below)

3. **Storage**:
   - Go to Storage
   - Create storage bucket
   - Set up security rules (see below)

### 4. Security Rules

#### Firestore Rules
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users can read/write their own profile
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Anyone can read products
    match /products/{productId} {
      allow read: if true;
      allow write: if request.auth != null && 
        request.auth.uid == resource.data.sellerId;
    }
    
    // Users can read/write their own orders
    match /orders/{orderId} {
      allow read, write: if request.auth != null && 
        (request.auth.uid == resource.data.customerId || 
         request.auth.uid == resource.data.sellerId);
    }
  }
}
```

#### Storage Rules
```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /product_images/{imageId} {
      allow read: if true;
      allow write: if request.auth != null;
    }
  }
}
```

## App Features

### Customer Features
- Browse products
- Add to cart
- Place orders
- View order history
- User profile management

### Seller Features
- **Dashboard**: Overview with key metrics
- **Add Products**: Upload images, set prices, manage inventory
- **Manage Orders**: Update order status, track shipments
- **Analytics**: Revenue tracking, order statistics
- **Product Management**: Edit/delete products

### User Types
- **Customer**: Can browse and purchase products
- **Seller**: Can manage products and orders

## File Structure

```
lib/
├── models/
│   ├── Product.dart (existing)
│   ├── User.dart (new)
│   └── Order.dart (new)
├── screens/
│   ├── seller/
│   │   ├── seller_dashboard_screen.dart
│   │   ├── seller_products_screen.dart
│   │   ├── seller_orders_screen.dart
│   │   ├── seller_analytics_screen.dart
│   │   └── add_product_screen.dart
│   └── (existing screens)
├── services/
│   └── firebase_service.dart (new)
└── (existing files)
```

## Dependencies Added

```yaml
dependencies:
  firebase_core: ^2.24.2
  firebase_auth: ^4.15.3
  cloud_firestore: ^4.13.6
  firebase_storage: ^11.5.6
  image_picker: ^1.0.4
  cached_network_image: ^3.3.0
  intl: ^0.18.1
  uuid: ^4.2.1
```

## Usage

### For Customers
1. Sign up as a customer
2. Browse products
3. Add items to cart
4. Complete purchase

### For Sellers
1. Sign up as a seller
2. Access seller dashboard
3. Add products with images
4. Manage orders and view analytics

## Important Notes

1. **Firebase Configuration**: Make sure to replace the placeholder `google-services.json` with your actual Firebase configuration.

2. **Image Upload**: Product images are stored in Firebase Storage and referenced in Firestore.

3. **Authentication**: The app uses Firebase Authentication with email/password. OTP verification has been bypassed for faster user experience.

4. **Data Structure**: The app uses the following Firestore collections:
   - `users`: User profiles and preferences
   - `products`: Product information and images
   - `orders`: Order details and status

5. **Security**: Implement proper security rules in Firebase Console to protect your data.

## Troubleshooting

1. **Firebase not initialized**: Make sure `google-services.json` is properly configured
2. **Image upload fails**: Check Firebase Storage rules and permissions
3. **Authentication errors**: Verify Firebase Auth is enabled in console
4. **Database errors**: Check Firestore rules and collection structure

## Next Steps

1. Set up Firebase project and add configuration files
2. Run `flutter pub get` to install dependencies
3. Test authentication flow
4. Add sample products as a seller
5. Test order flow as a customer

The app is now ready for Firebase integration with full seller dashboard functionality! 