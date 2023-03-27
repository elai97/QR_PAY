import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
// import 'package:shared_preferences/shared_preferences.dart';

import '../core/constants/firestore_constants.dart';
import '../data/models/models.dart';

class FirestoreProvider {
  // final SharedPreferences prefs;
  final FirebaseFirestore firebaseFirestore;
  final FirebaseStorage firebaseStorage;

  FirestoreProvider({
    required this.firebaseFirestore,
    // required this.prefs,
    required this.firebaseStorage,
  });

  // String? getPref(String key) {
  //   return prefs.getString(key);
  // }

  // UploadTask uploadFile(File image, String fileName) {
  //   Reference reference = firebaseStorage.ref().child(fileName);
  //   UploadTask uploadTask = reference.putFile(image);
  //   return uploadTask;
  // }

  // Future<void> updateDataFirestore(String collectionPath, String docPath,
  //     Map<String, dynamic> dataNeedUpdate) {
  //   return firebaseFirestore
  //       .collection(collectionPath)
  //       .doc(docPath)
  //       .update(dataNeedUpdate);
  // }

  void sendAndReceive(String receiverId, String senderId, String amount) async {
    createTransaction(senderId, receiverId, amount);
  }

  Future<void> createTransaction(
      String senderId, String receiverId, String amount) async {
    // String trxId = groupTrxId;
    DateTime now = DateTime.now();

    Map<String, dynamic> trxData = {
      'senderId': senderId,
      'receiverId': receiverId,
      'amount': amount,
      'trxTimestamp':
          "${now.hour}:${now.minute} ${now.day}/${now.month}/${now.year}",
      // Add any other metadata you want to store here
    };

    await firebaseFirestore
        .collection('transactions')
        .doc()
        .set(trxData, SetOptions(merge: true));
  }

  Future<List<TransactionModel>> getTrx(String userId) async {
    QuerySnapshot querySnapshot = await firebaseFirestore
        .collection('transactions')
        .where('senderId', isEqualTo: userId)
        .get();

    List<DocumentSnapshot> documents = querySnapshot.docs;

    QuerySnapshot querySnapshot2 = await firebaseFirestore
        .collection('transactions')
        .where('receiverId', isEqualTo: userId)
        .get();

    documents.addAll(querySnapshot2.docs);

    return documents.map((doc) => TransactionModel.fromDocument(doc)).toList();
  }
}
