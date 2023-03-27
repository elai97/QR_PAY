import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:qr_pay/ui/screens/login.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

import '../../core/resources/resources.dart';
import '../../core/themes/themes.dart';
import '../components/components.dart';

class ForgotPassword extends StatefulWidget {
  const ForgotPassword({super.key});

  @override
  State<ForgotPassword> createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();

  String? email;

  bool canResendPasswordResetEmail = false;

  final List<String?> errors = [];

  void addError({String? error}) {
    if (errors.contains(error)) {
      setState(() {
        errors.add(error);
      });
    }
  }

  void removeError({String? error}) {
    if (errors.contains(error)) {
      setState(() {
        errors.remove(error);
      });
    }
  }

  Future sendPasswordResetEmail() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      try {
        await FirebaseAuth.instance
            .sendPasswordResetEmail(email: _emailController.text)
            .then((value) {
          showPopup("Password reset link has been sent to your email.");
        });

        setState(() {
          canResendPasswordResetEmail = false;
        });
        await Future.delayed(
          const Duration(seconds: 30),
        );
        setState(() {
          canResendPasswordResetEmail = true;
        });
      } on FirebaseAuthException catch (e) {
        if (e.code == 'user-not-found') {
          return showPopup("No user found for that email.");
        }
        // else if (e.code == 'unknown') {
        //   throw Exception('Unknown exception');
        // }
      } catch (e) {
        log(e.toString());
        throw Exception(e);
      }
    }
  }

  Future<void> showPopup(String message) {
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Container(
            margin: const EdgeInsets.all(16),
            width: double.infinity,
            child: Text(message),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorPalette.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'Forgot Password',
                style: TextStyles.title.copyWith(
                  color: ColorPalette.primaryBrandColor,
                ),
              ),
              const SizedBox(
                width: double.infinity,
                child: Align(
                  alignment: Alignment.topCenter,
                  child: Text(
                    'Enter the email associated with your account and we\'ll sent a link to reset your password.',
                  ),
                ),
              ),
              Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    // email
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      onSaved: (newValue) => email = newValue,
                      onChanged: (value) {
                        if (value.isNotEmpty) {
                          removeError(error: emailNullError);
                        }
                        email = value;
                      },
                      validator: (value) {
                        if (value!.isEmpty) {
                          addError(error: emailNullError);
                          return 'Enter email';
                        }
                        return null;
                      },
                      decoration: const InputDecoration(
                        hintText: "Email",
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              KeyboardVisibilityBuilder(builder: (context, isKeyboardVisible) {
                return Align(
                  alignment: Alignment.bottomCenter,
                  child: SizedBox(
                    height: !isKeyboardVisible ? 15.h : null,
                    child: !isKeyboardVisible
                        ? Column(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              ApplyButton(
                                text: 'Send link',
                                boderColor: ColorPalette.primaryBrandColor,
                                press: () {
                                  sendPasswordResetEmail();
                                },
                                backgroundColor: ColorPalette.primaryBrandColor,
                                textColor: ColorPalette.white,
                              ),
                              ApplyButton(
                                text: 'Close',
                                boderColor: ColorPalette.primaryBrandColor,
                                press: () {
                                  FirebaseAuth.instance.signOut();
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const LoginPage(),
                                    ),
                                  );
                                },
                                backgroundColor: ColorPalette.white,
                                textColor: ColorPalette.black,
                              ),
                            ],
                          )
                        : Container(),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}
