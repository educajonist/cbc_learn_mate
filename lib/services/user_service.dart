import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserService {
  static Future<String> getRole() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return "guest";

    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    if (!doc.exists) return "student";

    return doc.data()?['role'] ?? "student";
  }

  static Future<void> createUserRecord(User user) async {
    final ref = FirebaseFirestore.instance.collection('users').doc(user.uid);

    final doc = await ref.get();

    if (!doc.exists) {
      await ref.set({
        "email": user.email,
        "role": "student", // default role
        "createdAt": FieldValue.serverTimestamp(),
      });
    }
  }
}
