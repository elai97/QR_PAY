import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:qr_pay/ui/screens/home.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

import '../../blocs/auth/auth_bloc.dart';
import '../../core/resources/resources.dart';
import '../../core/themes/themes.dart';
import '../components/apply_button.dart';
import 'login.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});
  static String routeName = "/registerPage";

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  String? email;
  String? password;
  String? conformPassword;

  bool _isValid = false;

  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

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

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _createAccountWithEmailAndPassword(BuildContext context) {
    _isValid = EmailValidator.validate(_emailController.text);
    if (_formKey.currentState!.validate() && _isValid) {
      _formKey.currentState!.save();
      BlocProvider.of<AuthBloc>(context).add(
        SignUpRequested(_emailController.text, _passwordController.text),
      );
    } else if (!_isValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ooops... enter a valid email'),
        ),
      );
    }
  }

  void _authenticateWithGoogle(context) {
    BlocProvider.of<AuthBloc>(context).add(
      GoogleSignInRequested(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorPalette.white,
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthenticatedState) {
            Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (context) => const HomePage()));
          }
          if (state is AuthErrorState) {
            ScaffoldMessenger.of(context)
                .showSnackBar(SnackBar(content: Text(state.error)));
          }
        },
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                const SizedBox(
                  height: 50,
                ),
                Text(
                  'Register',
                  style: TextStyles.title.copyWith(
                    color: ColorPalette.primaryBrandColor,
                  ),
                ),
                Form(
                  key: _formKey,
                  child: SizedBox(
                    height: 50.h,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
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
                        // password
                        TextFormField(
                          obscureText: !_isPasswordVisible,
                          controller: _passwordController,
                          onSaved: (newValue) => password = newValue,
                          onChanged: (value) {
                            if (value.isNotEmpty) {
                              removeError(error: passNullError);
                            } else if (value.length >= 8) {
                              removeError(error: shortPassError);
                            }
                            password = value;
                          },
                          validator: (value) {
                            if (value!.isEmpty) {
                              addError(error: passNullError);
                              return "Enter password";
                            } else if (value.length < 8) {
                              addError(error: shortPassError);
                              return "Password too short";
                            }
                            return null;
                          },
                          decoration: InputDecoration(
                            suffixIcon: IconButton(
                              icon: Icon(
                                _isPasswordVisible
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                              ),
                              onPressed: () {
                                setState(() {
                                  _isPasswordVisible = !_isPasswordVisible;
                                });
                              },
                            ),
                            hintText: "Password",
                          ),
                        ),

                        // confirm password
                        TextFormField(
                          obscureText: !_isConfirmPasswordVisible,
                          onSaved: (newValue) => conformPassword = newValue,
                          onChanged: (value) {
                            if (value.isNotEmpty) {
                              removeError(error: passNullError);
                            } else if (value.isNotEmpty &&
                                password == conformPassword) {
                              removeError(error: matchPassError);
                            }
                            conformPassword = value;
                          },
                          validator: (value) {
                            if (value!.isEmpty) {
                              addError(error: passNullError);
                              return "Enter confirm password";
                            } else if ((password != value)) {
                              addError(error: matchPassError);
                              return "Password don't match";
                            }
                            return null;
                          },
                          decoration: InputDecoration(
                            suffixIcon: IconButton(
                              icon: Icon(
                                _isConfirmPasswordVisible
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                              ),
                              onPressed: () {
                                setState(() {
                                  _isConfirmPasswordVisible =
                                      !_isConfirmPasswordVisible;
                                });
                              },
                            ),
                            hintText: "Comfirm password",
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Text(
                              'Already have an account?',
                              style: TextStyles.subTitle.copyWith(
                                color: ColorPalette.black75,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(
                              width: 5,
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute<void>(
                                    builder: (BuildContext context) =>
                                        const LoginPage(),
                                  ),
                                );
                              },
                              child: Text(
                                'Sign in here.',
                                style: TextStyles.subTitle.copyWith(
                                  color: ColorPalette.primaryBrandColor,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                        // password requirements
                        // display password requirement and delete those satified until cleared
                        // FormError(errors: errors),
                        // display state
                        BlocBuilder<AuthBloc, AuthState>(
                          builder: (context, state) {
                            if (state is AuthLoadingState) {
                              return const Center(
                                  child: CircularProgressIndicator(
                                strokeWidth: 1,
                                color: ColorPalette.primaryBrandColor,
                              ));
                            }
                            return Container();
                          },
                        ),
                        // submit
                        ApplyButton(
                          text: "Sign Up",
                          textColor: ColorPalette.white,
                          boderColor: ColorPalette.primaryBrandColor,
                          backgroundColor: ColorPalette.primaryBrandColor,
                          press: () {
                            _createAccountWithEmailAndPassword(context);
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  height: 30.h,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          const Expanded(
                            child: Divider(
                              color: ColorPalette.black50,
                              thickness: 1,
                              indent: 20,
                              endIndent: 20,
                            ),
                          ),
                          Text(
                            'or',
                            style: TextStyles.subTitle.copyWith(
                              color: ColorPalette.black,
                              fontSize: 14,
                            ),
                          ),
                          const Expanded(
                            child: Divider(
                              color: ColorPalette.black50,
                              thickness: 1,
                              indent: 20,
                              endIndent: 20,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          GestureDetector(
                            onTap: () {
                              // _authenticateWithGoogle(context);
                            },
                            child: SvgPicture.asset(MainIcons.google),
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          SvgPicture.asset(MainIcons.facebook),
                          const SizedBox(
                            width: 10,
                          ),
                          SvgPicture.asset(MainIcons.apple),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
