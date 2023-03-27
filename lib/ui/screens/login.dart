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
import 'forgot_password.dart';
import 'register.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  static String routeName = "/loginPage";

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  String? email;
  String? password;

  bool _isValid = false;

  bool _isPasswordVisible = false;

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
  void initState() {
    super.initState();
  }

  void _authenticateWithEmailAndPassword(context) {
    _isValid = EmailValidator.validate(_emailController.text);
    if (_formKey.currentState!.validate() && _isValid) {
      _formKey.currentState!.save();
      BlocProvider.of<AuthBloc>(context).add(
        SignInRequested(_emailController.text, _passwordController.text),
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
                  'Login',
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
                              return "Enter email";
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

                        // forgot password
                        Center(
                          child: TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute<void>(
                                  builder: (BuildContext context) =>
                                      const ForgotPassword(),
                                ),
                              );
                            },
                            child: Text(
                              "Forgot password?",
                              style: TextStyles.subTitle.copyWith(
                                color: ColorPalette.black,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Text(
                              "Don't have an account?",
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
                                        const RegisterPage(),
                                  ),
                                );
                              },
                              child: Text(
                                'Sign up here.',
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
                          text: "Sign In",
                          textColor: ColorPalette.white,
                          boderColor: ColorPalette.primaryBrandColor,
                          backgroundColor: ColorPalette.primaryBrandColor,
                          press: () {
                            _authenticateWithEmailAndPassword(context);
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
