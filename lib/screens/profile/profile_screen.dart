import 'package:flutter/material.dart';
import '../../services/firebase_service.dart';
import 'components/profile_menu.dart';
import 'components/profile_pic.dart';
import '../account/account_screen.dart';
import '../sign_in/sign_in_screen.dart';

class ProfileScreen extends StatelessWidget {
  static String routeName = "/profile";

  const ProfileScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          children: [
            const ProfilePic(),
            const SizedBox(height: 20),
            ProfileMenu(
              text: "My Account",
              icon: "assets/icons/User Icon.svg",
              press: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AccountScreen()),
                );
              },
            ),
            ProfileMenu(
              text: "Log Out",
              icon: "assets/icons/Log out.svg",
              press: () async {
                await FirebaseService().signOut();
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  SignInScreen.routeName,
                  (route) => false,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
