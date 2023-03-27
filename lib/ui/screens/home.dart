import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qr_pay/ui/screens/login.dart';
import 'package:qr_pay/ui/screens/scan.dart';
import 'package:qr_pay/ui/screens/generate.dart';

import '../../blocs/auth/auth_bloc.dart';
import '../../core/themes/themes.dart';
import '../../core/utils/utils.dart';
import '../../data/models/models.dart';
import '../../providers/providers.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  static String routeName = "/";

  static Route route() {
    return MaterialPageRoute(
      settings: RouteSettings(name: routeName),
      builder: (_) => const HomePage(),
    );
  }

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final currentUser = FirebaseAuth.instance.currentUser;

  bool _isBalanceVisible = false;

  int _balance = 0;

  @override
  void initState() {
    super.initState();
    _getWalletBalance();
    print("${currentUser?.uid}");
  }

  Future<void> _getWalletBalance() async {
    try {
      final walletRef =
          FirebaseFirestore.instance.collection('users').doc(currentUser!.uid);
      final walletData = await walletRef.get();
      setState(() {
        _balance = walletData['balance'] ?? 0;
      });
    } catch (e) {
      print(e.toString());
    }
  }

  Future<void> _refreshBalance() async {
    await _getWalletBalance();
  }

  Future<bool> onWillPop() {
    return Utilities.onBackPress(context);
  }

  List<PopupChoices> choices = <PopupChoices>[
    PopupChoices(title: 'Profile', icon: Icons.person),
    PopupChoices(title: 'Change password', icon: Icons.password),
    PopupChoices(title: 'Log out', icon: Icons.exit_to_app),
  ];

  void onItemMenuPress(PopupChoices choice) {
    if (choice.title == 'Log out') {
      context.read<AuthBloc>().add(
            SignOutRequested(),
          );
    } else if (choice.title == 'Change password') {
    } else {}
  }

  Widget buildPopupMenu() {
    return PopupMenuButton<PopupChoices>(
      onSelected: onItemMenuPress,
      itemBuilder: (BuildContext context) {
        return choices.map((PopupChoices choice) {
          return PopupMenuItem<PopupChoices>(
              value: choice,
              child: Row(
                children: <Widget>[
                  Icon(
                    choice.icon,
                    color: ColorPalette.black,
                  ),
                  Container(
                    width: 10,
                  ),
                  Text(
                    choice.title,
                    style: const TextStyle(color: ColorPalette.black),
                  ),
                ],
              ));
        }).toList();
      },
      child: const Padding(
        padding: EdgeInsets.all(10.0),
        child: Icon(Icons.person_2_rounded),
      ),
    );
  }

  FirestoreProvider firestoreProvider = FirestoreProvider(
    firebaseFirestore: FirebaseFirestore.instance,
    firebaseStorage: FirebaseStorage.instance,
  );

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;
    return WillPopScope(
      onWillPop: onWillPop,
      child: Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          backgroundColor: ColorPalette.black25,
          automaticallyImplyLeading: false,
          actions: <Widget>[buildPopupMenu()],
        ),
        backgroundColor: ColorPalette.black25,
        body: BlocListener<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state is UnAuthenticatedState) {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => const LoginPage()),
                (route) => false,
              );
            }
          },
          child: RefreshIndicator(
            displacement: 250,
            strokeWidth: 3,
            triggerMode: RefreshIndicatorTriggerMode.anywhere,
            onRefresh: _refreshBalance,
            child: Padding(
              padding: const EdgeInsets.only(
                right: 16.0,
                left: 16.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  balanceWidget(),
                  Expanded(
                    flex: 6,
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      width: double.infinity,
                      decoration: const BoxDecoration(
                        color: ColorPalette.white,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(25),
                          topRight: Radius.circular(25),
                        ),
                      ),
                      child: FutureBuilder<List<TransactionModel>>(
                        future: firestoreProvider.getTrx(currentUser!.uid),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }

                          if (snapshot.hasError) {
                            return const Center(
                              child: Text('Error retrieving chats'),
                            );
                          }

                          List<TransactionModel> trxs = snapshot.data ?? [];

                          if (trxs.isEmpty) {
                            return const Center(
                              child: Text('No transaction history'),
                            );
                          }

                          return ListView.builder(
                            physics: const BouncingScrollPhysics(),
                            itemCount: trxs.length,
                            itemBuilder: (context, index) {
                              return ListTile(
                                contentPadding: const EdgeInsets.all(0),
                                leading: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: ColorPalette.black10,
                                    borderRadius: BorderRadius.circular(25.0),
                                  ),
                                  child: const Icon(
                                    Icons.published_with_changes_rounded,
                                    color: ColorPalette.black,
                                  ),
                                ),
                                title: Text(
                                  '₦${trxs[index].amount}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                subtitle: Text(trxs[index].trxTimestamp),
                                trailing: const Icon(Icons.more_vert_rounded),
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Expanded balanceWidget() {
    return Expanded(
      flex: 4,
      child: Container(
        padding: const EdgeInsets.all(16),
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text("Balance"),
            Row(
              children: [
                Text(
                  !_isBalanceVisible ? "₦$_balance" : "* * * *",
                  style: TextStyles.title.copyWith(
                    fontSize: 32,
                  ),
                ),
                const SizedBox(
                  width: 10,
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _isBalanceVisible = !_isBalanceVisible;
                    });
                  },
                  child: Icon(
                    _isBalanceVisible
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                  ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute<void>(
                        builder: (BuildContext context) => ScanScreen(),
                      ),
                    );
                  },
                  style: ButtonStyle(
                    backgroundColor:
                        MaterialStateProperty.all<Color>(ColorPalette.black10),
                  ),
                  child: Row(
                    children: const [
                      Icon(
                        Icons.call_made_rounded,
                        color: ColorPalette.black,
                      ),
                      Text(
                        "Send",
                        style: TextStyle(
                          color: ColorPalette.black,
                        ),
                      ),
                    ],
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute<void>(
                        builder: (BuildContext context) => GenerateScreen(),
                      ),
                    );
                  },
                  style: ButtonStyle(
                    backgroundColor:
                        MaterialStateProperty.all<Color>(ColorPalette.black10),
                  ),
                  child: Row(
                    children: const [
                      Icon(
                        Icons.call_received_rounded,
                        color: ColorPalette.black,
                      ),
                      Text(
                        "Receive",
                        style: TextStyle(
                          color: ColorPalette.black,
                        ),
                      ),
                    ],
                  ),
                ),
                ElevatedButton(
                  onPressed: () {},
                  child: Row(
                    children: const [
                      Icon(
                        Icons.pending_rounded,
                        color: ColorPalette.black,
                      ),
                      Text(
                        "More",
                        style: TextStyle(
                          color: ColorPalette.black,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Text(
              "Transactions",
              style: TextStyles.title,
            ),
          ],
        ),
      ),
    );
  }
}
