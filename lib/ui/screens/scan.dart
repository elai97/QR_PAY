import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

import '../../providers/firestore_provider.dart';
import 'home.dart';

class ScanScreen extends StatefulWidget {
  final currentUser = FirebaseAuth.instance.currentUser;

  ScanScreen({
    super.key,
  });

  @override
  _ScanScreenState createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  final GlobalKey _qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? qrViewController;
  bool transferSuccessful = false;

  bool _isLoading = false;
  bool _isOnQRViewCreated = true;
  bool _isScanned = false;

  late String currentUserId;
  String groupChatId = "";

  // Future<void> _handleScan(String qrData) async {
  //   final transaction = await parseQRCode(qrData);
  //   if (transaction.senderUID == widget.currentUser.uid) {
  //     return showDialog(
  //       context: context,
  //       builder: (context) {
  //         return AlertDialog(
  //           title: const Text('Cannot transfer to yourself'),
  //           actions: [
  //             ElevatedButton(
  //               onPressed: () => Navigator.of(context).pop(),
  //               child: const Text('OK'),
  //             ),
  //           ],
  //         );
  //       },
  //     );
  //   }
  //   setState(() {
  //     _isLoading = true;
  //   });
  //   try {
  //     await FirestoreService().transferFunds(transaction);
  //     Navigator.of(context).pop();
  //   } catch (error) {
  //     setState(() {
  //       _isLoading = false;
  //     });
  //     return showDialog(
  //       context: context,
  //       builder: (context) {
  //         return AlertDialog(
  //           title: const Text('Error'),
  //           content: const Text(
  //               'An error occurred while transferring funds. Please try again later.'),
  //           actions: [
  //             ElevatedButton(
  //               onPressed: () => Navigator.of(context).pop(),
  //               child: const Text('OK'),
  //             ),
  //           ],
  //         );
  //       },
  //     );
  //   }
  // }

  late FirestoreProvider firestoreProvider;

  @override
  void initState() {
    super.initState();
    firestoreProvider = context.read<FirestoreProvider>();
  }

  @override
  void dispose() {
    qrViewController?.dispose();
    super.dispose();
  }

  void _onQRViewCreated(QRViewController controller) {
    if (!_isScanned) {
      setState(() {
        qrViewController = controller;
        qrViewController!.scannedDataStream.listen((scanData) {
          if (!_isScanned) {
            _isScanned = true;
            _transferAmount(scanData.code!);
          }
        });
      });
    }
  }

  // void _null(QRViewController controller) {}

  Future<void> _transferAmount(String qrData) async {
    try {
      setState(() {
        _isLoading = true;
      });

      String receiverId = widget.currentUser!.uid;
      String senderId = qrData.split(",")[0];
      String amount = qrData.split(",")[1];

      final senderWalletRef =
          FirebaseFirestore.instance.collection('users').doc(receiverId);
      final receiverWalletRef =
          FirebaseFirestore.instance.collection('users').doc(senderId);

      final senderWallet = await senderWalletRef.get();
      final receiverWallet = await receiverWalletRef.get();

      final senderBalance = senderWallet['balance'];
      final receiverBalance = receiverWallet['balance'];

      if (senderBalance < int.parse(amount)) {
        setState(() {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Insufficient balance.'),
            ),
          );
          _isLoading = false;
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const HomePage()),
          );
        });
        return;
      }

      await FirebaseFirestore.instance.runTransaction((transaction) async {
        transaction.update(
            senderWalletRef, {'balance': senderBalance - int.parse(amount)});
        transaction.update(receiverWalletRef,
            {'balance': receiverBalance + int.parse(amount)});
      });

      // if (receiverId.compareTo(senderId) > 0) {
      //   groupChatId = '$receiverId-$senderId';
      // } else {
      //   groupChatId = '$senderId-$receiverId';
      // }

      firestoreProvider.sendAndReceive(
        // groupChatId,
        senderId,
        receiverId,
        amount,
      );

      await Future.delayed(const Duration(seconds: 5));

      setState(() {
        print("ReceiverId >>>> $receiverId");
        print("SenderId >>>>>> $senderId");
        print("Amount >>>>>> $amount");
        transferSuccessful = true;
        _isLoading = false;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$amount received successfully.'),
          ),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomePage()),
        );
      });
    } catch (e) {
      print(e.toString());
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomePage()),
      ); // Navigate back to HomeScreen
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan QR Code'),
      ),
      body: Stack(
        children: [
          QRView(
            key: _qrKey,
            onQRViewCreated: _onQRViewCreated,
            overlay: QrScannerOverlayShape(
              borderColor: Colors.green,
              borderRadius: 10,
              borderLength: 30,
              borderWidth: 10,
              cutOutSize: MediaQuery.of(context).size.width * 0.8,
            ),
          ),
          const SizedBox(height: 16.0),
          Positioned(
            bottom: 50,
            right: 25,
            left: 25,
            child: Align(
              alignment: Alignment.bottomCenter,
              child: ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.qr_code_scanner_rounded),
                label: const Text('Scan QR Code'),
              ),
            ),
          ),
          Positioned.fill(
            child: Align(
              alignment: Alignment.center,
              child: _isLoading
                  ? const CircularProgressIndicator()
                  : const SizedBox.shrink(),
            ),
          ),
        ],
      ),
    );
  }
}
