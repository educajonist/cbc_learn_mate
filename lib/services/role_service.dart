import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RoleService {
  static const String ownerEmail = "educajonist@gmail.com";

  static Future<bool> isOwner() async {
    final user = FirebaseAuth.instance.currentUser;
    return user != null && user.email == ownerEmail;
  }

  static Future<String> _getUserRole() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return "guest";

    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    final role = (doc.data()?['role'] ?? '').toString().toLowerCase().trim();
    if (role.isEmpty) return "student";
    return role;
  }

  static Future<bool> canManageContent() async {
    if (await isOwner()) return true;
    final role = await _getUserRole();
    return role == "admin";
  }
}
