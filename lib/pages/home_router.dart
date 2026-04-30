import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'category_page.dart';
import 'login_page.dart';

class HomeRouter extends StatelessWidget {
  const HomeRouter({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return const LoginPage();
    return const CategoryPage();
  }
}