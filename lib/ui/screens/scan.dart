// ignore_for_file: use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:qr_pay/core/themes/color_theme.dart';

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
            _transferAmount(scanData.code!, context);
          }
        });
      });
    }
  }

  Future<void> _transferAmount(String qrData, BuildContext context) async {
    try {
      setState(() {
        _isLoading = true;
      });

      String senderId = widget.currentUser!.uid;
      String receiverId = qrData.split(",")[0];
      String amount = qrData.split(",")[1];
      String name = qrData.split(",")[2];

      final senderWalletRef =
          FirebaseFirestore.instance.collection('users').doc(senderId);
      final receiverWalletRef =
          FirebaseFirestore.instance.collection('users').doc(receiverId);

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

      // Show confirmation dialog
      bool? confirm = await showDialog<bool>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Confirm Transaction'),
            content: Text('Transfer ₦$amount to $name?'),
            actions: <Widget>[
              TextButton(
                child: const Text('Cancel'),
                onPressed: () {
                  Navigator.of(context).pop(false);
                },
              ),
              TextButton(
                child: const Text('Confirm'),
                onPressed: () {
                  Navigator.of(context).pop(true);
                },
              ),
            ],
          );
        },
      );

      if (confirm == null || !confirm) {
        // User canceled transfer
        setState(() {
          _isLoading = false;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Transaction cancelled.'),
            ),
          );
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const HomePage()),
          );
        });
        return;
      }

      // update sender and receiver balance
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        transaction.update(
            senderWalletRef, {'balance': senderBalance - int.parse(amount)});
        transaction.update(receiverWalletRef,
            {'balance': receiverBalance + int.parse(amount)});
      });

      firestoreProvider.sendAndReceive(
        senderId,
        receiverId,
        amount,
      );

      // await Future.delayed(const Duration(seconds: 5));

      setState(() {
        transferSuccessful = true;
        _isLoading = false;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('₦$amount sent successfully.'),
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
      );
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
          const Positioned(
            bottom: 100,
            right: 25,
            left: 25,
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Text(
                "Align the QR code within the frame to scan",
                style: TextStyle(color: ColorPalette.white),
                textAlign: TextAlign.center,
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
