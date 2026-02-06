import 'package:customer_portal/authenticate/authenticate.dart';
import 'package:customer_portal/authenticate/verification_email.dart';
import 'package:customer_portal/model/mobiapp.dart';
import 'package:customer_portal/screens/home.dart';
import 'package:customer_portal/screens/spotlight_queries/vessel_status/terminal_layout.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// ignore: camel_case_types
class authenticate_wrapper extends StatelessWidget {
  const authenticate_wrapper({super.key});

  @override
  Widget build(BuildContext context) {
    MobiAppData mobiAppData = Provider.of<MobiAppData>(context, listen: false);

    //Instance to know the authentication state.
    final user = context.watch<User?>();

    //either return authenticate or home
    if (user != null) {
      if (user.emailVerified) {
        //Means that the user is logged in already and email is verified hence navigate to HomePage
        return Home(mobiAppData: mobiAppData);
        //return TerminalLayout(title: 'Vessel Status');
      } else {
        return VerificationEmail(source: 'authenticate_wrapper');
      }
    }
    //The user isn't logged in and hence navigate to SignInPage.
    return const Authenticate();
  }
}
