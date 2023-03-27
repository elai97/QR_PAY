import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

// import '../models/user.dart';
// import '../models/transaction.dart';
// import '../services/firestore_service.dart';
// import '../utils/qr_utils.dart';

class SendScreen extends StatefulWidget {
  final currentUser = FirebaseAuth.instance.currentUser;

  SendScreen({
    super.key,
  });

  @override
  _SendScreenState createState() => _SendScreenState();
}

class _SendScreenState extends State<SendScreen> {
  String amount = "0.00";
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  bool transferSuccessful = false;
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  bool isShowQr = false;
  bool isShowForm = true;

  // Uint8List? _qrCodeBytes;

  // Future<void> _generateQRCode() async {
  //   if (_formKey.currentState!.validate()) {
  //     final transaction = Transaction(
  //       senderUID: widget.currentUser.uid,
  //       senderName: widget.currentUser.name,
  //       receiverUID: '',
  //       receiverName: '',
  //       amount: double.parse(_amountController.text),
  //       timestamp: DateTime.now(),
  //     );
  //     final qrCodeData = await generateQRCode(transaction);
  //     final qrCodeBytes = await QrPainter(
  //       data: qrCodeData,
  //       version: QrVersions.auto,
  //       gapless: false,
  //       color: Colors.black,
  //       emptyColor: Colors.white,
  //     ).toImageData(200);
  //     setState(() {
  //       _qrCodeBytes = qrCodeBytes;
  //     });
  //   }
  // }

  // Future<void> _shareQRCode() async {
  //   final tempDir = await getTemporaryDirectory();
  //   final qrCodeFile = File('${tempDir.path}/qr_code.png');
  //   await qrCodeFile.writeAsBytes(_qrCodeBytes!);
  //   await Share.shareFiles([qrCodeFile.path],
  //       text: 'Scan this QR code to pay me');
  // }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Send Payment'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              isShowForm == true
                  ? TextFormField(
                      controller: _amountController,
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Please enter an amount';
                        }
                        if (double.tryParse(value) == null) {
                          return 'Please enter a valid amount';
                        }
                        if (double.parse(value) <= 0) {
                          return 'Please enter an amount greater than zero';
                        }
                        return null;
                      },
                      decoration: const InputDecoration(
                        labelText: 'Amount',
                        prefixIcon: Icon(Icons.money),
                      ),
                    )
                  : const SizedBox.shrink(),
              const SizedBox(height: 16.0),
              isShowForm == true
                  ? ElevatedButton.icon(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          setState(() {
                            isShowQr = true;
                            isShowForm = false;
                          });
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('QR code generated successfully.'),
                            ),
                          );
                        }
                      }, // _generateQRCode,
                      icon: const Icon(Icons.qr_code),
                      label: const Text('Generate QR Code'),
                    )
                  : const SizedBox.shrink(),
              const SizedBox(height: 16.0),
              isShowQr == true
                  ? Center(
                      child: QrImage(
                        data:
                            "${widget.currentUser!.uid},${_amountController.text}",
                        key: qrKey,
                        size: 250,
                      ),
                    )
                  : const SizedBox.shrink(),
              const SizedBox(height: 20),
              isShowQr == true
                  ? Center(
                      child: Text(
                        "Scan the QR code to receive ₦${_amountController.text}",
                        style: const TextStyle(fontSize: 18),
                        textAlign: TextAlign.center,
                      ),
                    )
                  : const SizedBox.shrink(),
              // Center(
              //   child: _qrCodeBytes != null
              //       ? Image.memory(_qrCodeBytes!)
              //       : const SizedBox.shrink(),
              // ),

              // const SizedBox(height: 16.0),
              // ElevatedButton.icon(
              //   onPressed: () {}, // _qrCodeBytes != null ? _shareQRCode : null,
              //   icon: const Icon(Icons.share),
              //   label: const Text('Share QR Code'),
              // ),
            ],
          ),
        ),
      ),
    );
  }
}
