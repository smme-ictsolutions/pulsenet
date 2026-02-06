import 'package:customer_portal/authenticate/register.dart';
import 'package:customer_portal/authenticate/sign_in.dart';
import 'package:flutter/material.dart';

class Authenticate extends StatefulWidget {
  const Authenticate({super.key});

  @override
  State<Authenticate> createState() => _AuthenticateState();
}

class _AuthenticateState extends State<Authenticate> {
  bool showSignIn = true;

  @override
  Widget build(BuildContext context) {
    if (showSignIn) {
      return const SignIn();
    } else {
      return const Register();
    }
  }
}
