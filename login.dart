import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:groupiee/pages/auth/home.dart';
import 'package:groupiee/pages/auth/register.dart';
import 'package:groupiee/services/auth_service.dart';
import 'package:groupiee/services/database_service.dart';
import 'package:groupiee/widgets/widgets.dart';

import '../../helper/helper.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final formKey = GlobalKey<FormState>();
  String email = "";
  String password = "";
  bool _isLoading = false;
  AuthService authService = AuthService();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                color: Theme.of(context).primaryColor,
              ),
            )
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
                        'Login now to see what they are talk!...',
                        style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.w400),
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Image.asset('assets/login.png'),
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
                            "Sign In",
                            style: TextStyle(color: Colors.white),
                          ),
                          onPressed: () {
                            login();
                          },
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Text.rich(TextSpan(
                          text: "Don't have an Account?",
                          style: TextStyle(color: Colors.black, fontSize: 14),
                          children: [
                            TextSpan(
                                text: "Register Here",
                                style: TextStyle(
                                    color: Colors.black,
                                    decoration: TextDecoration.underline),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () {
                                    nextScreen(context, const RegisterPage());
                                  }),
                          ])),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  login() async {
    if (formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });
      await authService
          .loginWithUserEmailandPassword(email, password)
          .then((value) async {
        if (value == true) {
          QuerySnapshot snapshot =
              await DatabaseService(FirebaseAuth.instance.currentUser!.uid)
                  .gettingUserData(email);
          await HelperFunctions.saveUserLoggInStatus(true);
          await HelperFunctions.saveUserEmailSF(email);
          await HelperFunctions.saveUserNameSF(snapshot.docs[0]['fullName']);
          nextScreenReplace(context, const HomePage());
        } else {
          showSnackbar(context, Colors.red, value);
          _isLoading = false;
        }
      });
    }
  }
}
