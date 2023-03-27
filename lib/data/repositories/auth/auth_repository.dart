// import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthRepository {
  final _firebaseAuth = FirebaseAuth.instance;

  Future<void> signUp({required String email, required String password}) async {
    // String generateCardNo() {
    //   const length = 8;
    //   const numbers = '0123456789';

    //   String chars = '';
    //   chars += numbers;

    //   return List.generate(length, (index) {
    //     final indexRandom = Random.secure().nextInt(chars.length);

    //     return chars[indexRandom];
    //   }).join();
    // }

    try {
      await _firebaseAuth
          .createUserWithEmailAndPassword(
            email: email,
            password: password,
          )
          .then(
            (userData) => FirebaseFirestore.instance
                .collection('users')
                .doc(userData.user!.uid)
                .set({
              'userId': userData.user!.uid,
              'email': userData.user!.email,
              'name': userData.user!.displayName,
              'balance': 5000,
            }),
          );
    } on FirebaseAuthException catch (e) {
      if (e.code == 'Weak password') {
        throw Exception('The password provided is too weak.');
      } else if (e.code == 'email-already-in-use') {
        throw Exception('The account already exists for tha email.');
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        throw Exception('No user found for that email.');
      } else if (e.code == 'wrong-password') {
        throw Exception('Wrong password provided for that user.');
      }
    }
  }

  Future<void> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      final GoogleSignInAuthentication? googleAuth =
          await googleUser?.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );

      await FirebaseAuth.instance.signInWithCredential(credential).then(
            (userData) => FirebaseFirestore.instance
                .collection('users')
                .doc(userData.user!.uid)
                .set({
              'userId': userData.user!.uid,
              'email': userData.user!.email,
              'name': userData.user!.displayName,
              'balance': 5000,
            }),
          );
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<void> signOut() async {
    try {
      await _firebaseAuth.signOut();
    } catch (e) {
      throw Exception(e);
    }
  }
}
