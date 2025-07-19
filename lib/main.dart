import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shop_app/screens/splash/splash_screen.dart';


import 'routes.dart';
import 'theme.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      // Web config
      return const FirebaseOptions(
        apiKey: "AIzaSyBirwXXHCTL6xcPuT-cAeJoSCESumEBvms",
        authDomain: "she-app-82589.firebaseapp.com",
        projectId: "she-app-82589",
        storageBucket: "she-app-82589.firebasestorage.app", // <-- Corrected to .appspot.com for web
        messagingSenderId: "779472617354",
        appId: "1:779472617354:web:07093f24068f5a61c51273",
        measurementId: "G-68KY4GE93H",
      );
    } else {
      // Android config
      return const FirebaseOptions(
        apiKey: "AIzaSyAtH4eVD04bD6DR8RebYF9fiv1ueU-ueps",
        appId: "1:779472617354:android:55f8adfad098e5e6c51273",
        messagingSenderId: "779472617354",
        projectId: "she-app-82589",
        storageBucket: "she-app-82589.firebasestorage.app",
      );
    }
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'The Flutter Way - Template',
      theme: AppTheme.lightTheme(context),
      initialRoute: SplashScreen.routeName,
      routes: routes,
    );
  }
}
