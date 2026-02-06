import 'package:cached_network_image/cached_network_image.dart';
import 'package:customer_portal/constants/styles.dart';
import 'package:customer_portal/model/mobiapp.dart';
import 'package:customer_portal/model/singletons_data.dart';
import 'package:customer_portal/services/auth.dart';
import 'package:customer_portal/shared/dialog.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ForgotPassword extends StatefulWidget {
  static String id = 'forgot-password';
  const ForgotPassword({super.key});

  @override
  State<ForgotPassword> createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  //text field string
  String email = '';
  String error = '';
  final _formKey = GlobalKey<FormState>();
  bool loading = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    List<ImageData> imageData = appData.imageData;
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
                  body: Form(
                    key: _formKey,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 30.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'Email Your Password',
                            style: kDescriptionTextStyle,
                          ),
                          TextFormField(
                            style: kButtonTextStyle,
                            validator:
                                (val) =>
                                    val!.isEmpty ? 'Email is required' : null,
                            onChanged: (val) {
                              setState(() => email = val);
                            },
                            decoration: userInputDecoration.copyWith(
                              hintText: 'Enter your registered email',
                              labelText: 'Email',
                              prefixIcon: const Icon(
                                Icons.mail,
                                color: kColorForeground,
                              ),
                              errorStyle: const TextStyle(
                                color: kColorForeground,
                              ),
                              labelStyle: const TextStyle(
                                color: kColorForeground,
                              ),
                              hintStyle: const TextStyle(
                                color: kColorForeground,
                              ),
                              focusedBorder: const UnderlineInputBorder(
                                borderSide: BorderSide(color: kColorForeground),
                              ),
                              enabledBorder: const UnderlineInputBorder(
                                borderSide: BorderSide(color: kColorForeground),
                              ),
                              errorBorder: const UnderlineInputBorder(
                                borderSide: BorderSide(color: kColorForeground),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              minimumSize: Size(
                                MediaQuery.of(context).size.width * .6,
                                50,
                              ),
                              backgroundColor: kColorBackground,
                              foregroundColor: kColorForeground,
                            ),
                            child: const Text('Send Email'),
                            onPressed: () async {
                              if (_formKey.currentState!.validate()) {
                                _formKey.currentState!.save();
                                setState(() => loading = true);
                                try {
                                  dynamic result = await context
                                      .read<AuthService>()
                                      .passwordReset(email);
                                  if (result == null) {
                                    if (!context.mounted) return;
                                    await DialogService(
                                      button: 'dismiss',
                                      origin: "Password Reset",
                                    ).confirmEmail(context: context);

                                    setState(() {
                                      error = 'Please enter a valid email';
                                      loading = false;
                                      Navigator.pop(context);
                                    });
                                  }
                                } on FirebaseAuthException catch (e) {
                                  error = e.message!;
                                }
                              }
                            },
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: TextButton(
                              style: TextButton.styleFrom(
                                minimumSize: Size(
                                  MediaQuery.of(context).size.width * .6,
                                  50,
                                ),
                                backgroundColor: kColorBackground,
                                foregroundColor: kColorForeground,
                              ),
                              child: const Text('Sign In'),
                              onPressed: () {
                                Navigator.pop(context);
                              },
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

  State<StatefulWidget> createState() {
    throw UnimplementedError();
  }
}
