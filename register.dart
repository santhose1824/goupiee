import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:groupiee/helper/helper.dart';
import 'package:groupiee/pages/auth/home.dart';
import 'package:groupiee/pages/auth/login.dart';
import 'package:groupiee/services/auth_service.dart';

import '../../widgets/widgets.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({Key? key}) : super(key: key);

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  bool _isLoading = false;
  final formKey = GlobalKey<FormState>();
  String email = "";
  String password = "";
  String fullName = "";
  AuthService authservice = AuthService();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
              color: Theme.of(context).primaryColor,
            ))
          : SingleChildScrollView(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 80),
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      const Text(
                        'Groupiee',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 40,
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      const Text(
                        'Create an account to chat and explore...',
                        style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.w400),
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Image.asset('assets/register.png'),
                      TextFormField(
                        decoration: textInputDecoration.copyWith(
                          labelText: "Enter the FullName",
                          prefixIcon: Icon(
                            Icons.person,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                        onChanged: (val) {
                          setState(() {
                            fullName = val;
                          });
                        },
                        validator: (val) {
                          if (val!.isNotEmpty) {
                            return null;
                          } else {
                            return "Name cannot be empty";
                          }
                        },
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      TextFormField(
                        decoration: textInputDecoration.copyWith(
                          labelText: "Enter the email",
                          prefixIcon: Icon(
                            Icons.email,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                        onChanged: (val) {
                          setState(() {
                            email = val;
                          });
                        },
                        validator: (val) {
                          return RegExp(
                                      r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%'*+/=?^_`{|}~]+[a-zA-z0-9]+")
                                  .hasMatch(val!)
                              ? null
                              : "Please enter the valid Email";
                        },
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      TextFormField(
                        obscureText: true,
                        decoration: textInputDecoration.copyWith(
                          labelText: "Enter the password",
                          prefixIcon: Icon(
                            Icons.lock,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                        onChanged: (val) {
                          setState(() {
                            password = val;
                          });
                        },
                        validator: (val) {
                          if (val!.length < 6) {
                            return "Password must be 6 characters";
                          } else {
                            return null;
                          }
                        },
                      ),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              primary: Theme.of(context).primaryColor,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30))),
                          child: Text(
                            "Sign Up",
                            style: TextStyle(color: Colors.white),
                          ),
                          onPressed: () {
                            register();
                          },
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Text.rich(TextSpan(
                          text: "Are you have already account?",
                          style: TextStyle(color: Colors.black, fontSize: 14),
                          children: [
                            TextSpan(
                                text: "Login here",
                                style: TextStyle(
                                    color: Colors.black,
                                    decoration: TextDecoration.underline),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () {
                                    nextScreenReplace(
                                      context,
                                      const LoginPage(),
                                    );
                                  }),
                          ])),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  register() async {
    if (formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });
      await authservice
          .registerUserWithEmailandPassword(fullName, email, password)
          .then((value) async {
        if (value == true) {
          await HelperFunctions.saveUserLoggInStatus(true);
          await HelperFunctions.saveUserEmailSF(email);
          await HelperFunctions.saveUserNameSF(fullName);
          nextScreenReplace(context, const HomePage());
        } else {
          showSnackbar(context, Colors.red, value);
          _isLoading = false;
        }
      });
    }
  }
}
