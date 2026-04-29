import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // SIGN UP FUNCTION
  Future<String> signUp(String email, String password, String confirmPassword) async {

    if (email.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
      return "EMPTY_FIELDS";
    }
    if (!email.contains('@')) {
      return "INVALID_EMAIL";
    }
    if (password.length < 6) {
      return "WEAK_PASSWORD";
    }
    if (password != confirmPassword) {
      return "PASSWORD_NOT_MATCH";
    }

    try {
      // 1. Create user in Firebase Auth
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      // 2. Save user data to Firestore
      await _firestore
          .collection('users')
          .doc(userCredential.user!.uid)
          .set({
        'email': email.trim(),
        'uid': userCredential.user!.uid,
        'createdAt': FieldValue.serverTimestamp(),
      });

      return "SUCCESS";

    } on FirebaseAuthException catch (e) {
      print("FirebaseAuthException code: ${e.code}");
      print("FirebaseAuthException message: ${e.message}");

      switch (e.code) {
        case 'email-already-in-use':
          return "USER_ALREADY_EXISTS";
        case 'invalid-email':
          return "INVALID_EMAIL";
        case 'weak-password':
          return "WEAK_PASSWORD";
        case 'network-request-failed':
          return "NO_INTERNET";
        default:
          return "ERROR: ${e.code}";
      }
    } catch (e) {
      print("General error: ${e.toString()}");
      return "ERROR: ${e.toString()}";
    }
  }

  // LOGIN FUNCTION
  Future<String> login(String email, String password) async {

    if (email.isEmpty || password.isEmpty) {
      return "EMPTY_FIELDS";
    }
    if (!email.contains('@')) {
      return "INVALID_EMAIL";
    }

    try {
      await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
      return "SUCCESS";

    } on FirebaseAuthException catch (e) {
      print("FirebaseAuthException code: ${e.code}");
      print("FirebaseAuthException message: ${e.message}");

      switch (e.code) {
        case 'user-not-found':
          return "USER_NOT_FOUND";
        case 'wrong-password':
          return "WRONG_PASSWORD";
        case 'invalid-credential':
          return "WRONG_PASSWORD";
        case 'invalid-email':
          return "INVALID_EMAIL";
        case 'network-request-failed':
          return "NO_INTERNET";
        default:
          return "ERROR: ${e.code}";
      }
    } catch (e) {
      print("General error: ${e.toString()}");
      return "ERROR: ${e.toString()}";
    }
  }
}