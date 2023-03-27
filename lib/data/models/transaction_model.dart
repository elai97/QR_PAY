import 'package:cloud_firestore/cloud_firestore.dart';

class TransactionModel{
  String senderId;
  String receiverId;
  String amount;
  String trxTimestamp;

  TransactionModel({
    required this.senderId,
    required this.receiverId,
    required this.amount,
    required this.trxTimestamp,
  });

  Map<String, dynamic> toJson() {
    return {
      'senderId': senderId,
      'receiverId': receiverId,
      'amount': amount,
      'trxTimestamp': trxTimestamp,
    };
  }

  factory TransactionModel.fromDocument(DocumentSnapshot doc) {
    String senderId = doc.get('senderId');
    String receiverId = doc.get('receiverId');
    String amount = doc.get('amount');
    String trxTimestamp = doc.get('trxTimestamp');
    return TransactionModel(
      senderId: senderId,
      receiverId: receiverId,
      amount: amount,
      trxTimestamp: trxTimestamp,
    );
  }
}
