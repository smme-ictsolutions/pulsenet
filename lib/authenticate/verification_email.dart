import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:customer_portal/constants/styles.dart';
import 'package:customer_portal/model/mobiapp.dart';
import 'package:customer_portal/model/singletons_data.dart';
import 'package:customer_portal/screens/home.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class VerificationEmail extends StatefulWidget {
  const VerificationEmail({super.key, required this.source});
  final String source;

  @override
  State<VerificationEmail> createState() => _VerificationEmailState();
}

class _VerificationEmailState extends State<VerificationEmail> {
  bool loading = false, registerAPI = false;
  late Timer timer;

  @override
  void initState() {
    timer = Timer.periodic(Duration(seconds: 5), (timer) {
      FirebaseAuth.instance.currentUser?.reload();
      if (FirebaseAuth.instance.currentUser!.emailVerified == true) {
        timer.cancel();
        if (widget.source == 'register_api') {
          setState(() {
            registerAPI = true;
          });
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const Home()),
          );
        }
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    if (!mounted) return;
    timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    List<ImageData> imageData = appData.imageData;
    //Instance to know the authentication state.
    final user = context.watch<User?>();

    return loading || imageData.isEmpty
        ? CircularProgressIndicator()
        : CachedNetworkImage(
          placeholder:
              (context, url) => const Center(
                child: CircularProgressIndicator(color: kColorBar),
              ),
          errorWidget: (context, url, error) => const Icon(Icons.error),
          imageUrl:
              imageData
                  .where((element) => element.title == "featurebackground")
                  .first
                  .url,
          imageBuilder:
              (context, imageProvider) => Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: imageProvider,
                    fit: BoxFit.cover,
                  ),
                ),
                height: MediaQuery.of(context).size.height,
                width: MediaQuery.of(context).size.width,
                child: Scaffold(
                  backgroundColor: Colors.transparent,
                  body: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Card(
                          color: kColorScaffoldBackground,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                            side: BorderSide(color: Colors.black),
                          ),
                          child:
                              !registerAPI
                                  ? const Text(
                                    'We have sent an email for verification. If you have not received email check your spam folder or click resend button below.',
                                    style: kDescriptionTextStyle,
                                  )
                                  : const Text(
                                    'Email successfully verified. You may now close the web browser and proceed to use your chosen API.',
                                    style: kDescriptionTextStyle,
                                  ),
                        ),
                        const SizedBox(height: 20),
                        if (!registerAPI)
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              minimumSize: Size(
                                MediaQuery.of(context).size.width * .6,
                                50,
                              ),
                              backgroundColor: kColorBackground,
                              foregroundColor: kColorForeground,
                            ),
                            child: const Text('Resend Email'),
                            onPressed: () async {
                              await user?.sendEmailVerification();
                            },
                          ),
                      ],
                    ),
                  ),
                ),
              ),
        );
  }
}
