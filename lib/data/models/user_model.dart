import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  String userId;
  String email;
  String name;
  num balance;

  UserModel({
    required this.userId,
    required this.email,
    required this.name,
    required this.balance,
  });

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'email': email,
      'name': name,
      'balance': balance,
    };
  }

  factory UserModel.fromDocument(DocumentSnapshot doc) {
    String userId = doc.get('userId');
    String email = doc.get('email');
    String name = doc.get('name');
    num balance = doc.get('balance');
    return UserModel(
      userId: userId,
      email: email,
      name: name,
      balance: balance,
    );
  }
}
