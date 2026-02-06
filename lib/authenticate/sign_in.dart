import 'package:cached_network_image/cached_network_image.dart';
import 'package:customer_portal/authenticate/forgot_password.dart';
import 'package:customer_portal/authenticate/register.dart';
import 'package:customer_portal/authenticate/register_api.dart';
import 'package:customer_portal/authenticate/register_spotlight.dart';
import 'package:customer_portal/authenticate/verification_email.dart';
import 'package:customer_portal/constants/styles.dart';
import 'package:customer_portal/main.dart';
import 'package:customer_portal/model/mobiapp.dart';
import 'package:customer_portal/model/singletons_data.dart';
import 'package:customer_portal/screens/home.dart';
import 'package:customer_portal/services/auth.dart';
import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SignIn extends StatefulWidget {
  const SignIn({super.key});
  @override
  State<SignIn> createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  final _formKey = GlobalKey<FormState>();
  bool loading = false, obscureText = true, checkboxState = false;
  final textUserName = TextEditingController(),
      textPassword = TextEditingController();

  String email = '', password = '', error = '';
  int failedLoginAttempts = 0;

  @override
  void initState() {
    textUserName.text = "";
    textPassword.text = "";
    _loadUserEmailPassword();

    super.initState();
  }

  @override
  void dispose() {
    textUserName.dispose();
    textPassword.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    List<ImageData> imageData = appData.imageData;
    return loading || imageData.isEmpty
        ? const SizedBox(
          height: 100,
          width: 100,
          child: CircularProgressIndicator(color: kColorError),
        )
        : CachedNetworkImage(
          placeholder:
              (context, url) => const Center(
                child: CircularProgressIndicator(color: kColorBar),
              ),
          errorWidget: (context, url, error) {
            return const Icon(Icons.error);
          },
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
                  extendBody: true,
                  extendBodyBehindAppBar: true,
                  resizeToAvoidBottomInset: false,
                  backgroundColor: kColorScaffoldBackground,
                  body: SingleChildScrollView(
                    physics: const NeverScrollableScrollPhysics(),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Expanded(
                                child: CachedNetworkImage(
                                  errorWidget:
                                      (context, url, error) =>
                                          const Icon(Icons.error),
                                  imageUrl:
                                      imageData
                                          .where(
                                            (element) =>
                                                element.title == 'TPTLogo',
                                          )
                                          .first
                                          .url,
                                  imageBuilder:
                                      (context, imageProvider) => Container(
                                        width: 100,
                                        height: 100,
                                        decoration: BoxDecoration(
                                          image: DecorationImage(
                                            image: imageProvider,
                                            fit: BoxFit.contain,
                                            alignment: Alignment.topRight,
                                          ),
                                        ),
                                      ),
                                ),
                              ),
                            ],
                          ),
                          Card(
                            color: Colors.black.withValues(alpha: .7),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                const Padding(
                                  padding: EdgeInsets.only(left: 8.0),
                                  child: Text(
                                    "Sign in",
                                    style: kHeaderTextStyle,
                                  ),
                                ),
                                const Align(
                                  alignment: Alignment.centerLeft,
                                  child: Padding(
                                    padding: EdgeInsets.only(left: 8.0),
                                    child: Text(
                                      "Your connection portal to TPT",
                                      style: kSubTitleTextStyle,
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: TextFormField(
                                    style: kButtonTextStyle,
                                    controller: textUserName,
                                    decoration: userInputDecoration.copyWith(
                                      hintText: 'Enter email to sign in...',
                                      suffixIcon: const Icon(
                                        Icons.email,
                                        color: kColorForeground,
                                      ),
                                    ),
                                    validator: _validateEmail,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: TextFormField(
                                    style: kButtonTextStyle,
                                    controller: textPassword,
                                    decoration: userInputDecoration.copyWith(
                                      hintText: 'Enter password',
                                      suffixIcon: IconButton(
                                        onPressed: () {
                                          setState(
                                            () => obscureText = !obscureText,
                                          );
                                        },
                                        icon:
                                            !obscureText
                                                ? const Icon(Icons.lock)
                                                : const Icon(
                                                  Icons.remove_red_eye,
                                                ),
                                        color: kColorBar,
                                      ),
                                    ),
                                    validator: _validatePassword,
                                    obscureText: obscureText,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(left: 10.0),
                                  child: InkWell(
                                    onTap: () {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder:
                                              (_) => const ForgotPassword(),
                                        ),
                                      );
                                    },
                                    child: const Text(
                                      "Forgot password?",
                                      style: kLabelTextStyle,
                                    ),
                                  ),
                                ),

                                Center(
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: ElevatedButton(
                                      onPressed: () async {
                                        if (_formKey.currentState!.validate()) {
                                          setState(() {
                                            error = '';
                                            loading = false;
                                          });

                                          try {
                                            await context
                                                .read<AuthService>()
                                                .signInWithEmailAndPassword(
                                                  textUserName.text,
                                                  textPassword.text,
                                                )
                                                .then((result) async {
                                                  if (result
                                                      .toString()
                                                      .startsWith('err:')) {
                                                    failedLoginAttempts++;

                                                    setState(() {
                                                      error =
                                                          failedLoginAttempts >
                                                                  3
                                                              ? '$failedLoginAttempts invalid login attempts, try again in 5 mins...'
                                                              : result;
                                                      loading = false;
                                                    });
                                                  } else {
                                                    _handleRememberMe();
                                                    User? user =
                                                        FirebaseAuth
                                                            .instance
                                                            .currentUser;
                                                    if (user != null) {
                                                      await user.reload();
                                                      if (!context.mounted) {
                                                        return;
                                                      }
                                                      Navigator.pop(context);
                                                      if (user.emailVerified ==
                                                          true) {
                                                        Navigator.of(
                                                          context,
                                                        ).push(
                                                          MaterialPageRoute(
                                                            builder:
                                                                (_) =>
                                                                    const Home(),
                                                          ),
                                                        );
                                                      } else {
                                                        Navigator.of(
                                                          context,
                                                        ).push(
                                                          MaterialPageRoute(
                                                            builder:
                                                                (
                                                                  _,
                                                                ) => const VerificationEmail(
                                                                  source:
                                                                      'sign_in',
                                                                ),
                                                          ),
                                                        );
                                                      }
                                                    }
                                                  }
                                                });
                                          } on FirebaseAuthException catch (e) {
                                            setState(() {
                                              error = e.message.toString();
                                              loading = false;
                                            });
                                          } catch (error) {
                                            debugPrint(error.toString());
                                          }
                                        }
                                      },
                                      style: ElevatedButton.styleFrom(
                                        minimumSize: Size(
                                          MediaQuery.of(context).size.width *
                                              .6,
                                          50,
                                        ),
                                        backgroundColor: kColorBackground,
                                      ),
                                      child: const Text(
                                        'Sign in',
                                        style: kButtonTextStyle,
                                      ),
                                    ),
                                  ),
                                ),
                                error.isEmpty
                                    ? Container()
                                    : Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Flexible(
                                            child: Text(
                                              error,
                                              style: const TextStyle(
                                                fontSize: kFontSizeMediumNormal,
                                                color: kColorError,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Flexible(
                                        child: Text(
                                          "New to TPT Customer Portal? ",
                                          style:
                                              isMobile
                                                  ? kSmallestTextStyle
                                                  : kNormalTextStyle,
                                        ),
                                      ),
                                      Flexible(
                                        child: InkWell(
                                          splashColor: kColorSplash,
                                          onTap: () {
                                            Navigator.pop(context);
                                            Navigator.of(context).push(
                                              MaterialPageRoute(
                                                builder:
                                                    (_) => const Register(),
                                              ),
                                            );
                                          },
                                          child: const Text(
                                            "Join Now",
                                            style: kHypelinkTextStyle,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Center(
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Flexible(
                                        fit: FlexFit.loose,
                                        child: Divider(color: kColorNavIcon),
                                      ),
                                      Flexible(
                                        fit: FlexFit.loose,
                                        child: Text(
                                          ' or ',
                                          style: kLabelTextStyle,
                                        ),
                                      ),
                                      Flexible(
                                        fit: FlexFit.loose,
                                        child: Divider(color: kColorNavIcon),
                                      ),
                                    ],
                                  ),
                                ),
                                Center(
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: ElevatedButton.icon(
                                          onPressed: () async {
                                            Navigator.pop(context);
                                            Navigator.of(context).push(
                                              MaterialPageRoute(
                                                builder:
                                                    (_) =>
                                                        const RegisterSpotlight(),
                                              ),
                                            );
                                          },
                                          style: ElevatedButton.styleFrom(
                                            elevation: 10,
                                            minimumSize: Size(
                                              MediaQuery.of(
                                                    context,
                                                  ).size.width *
                                                  .3,
                                              50,
                                            ),
                                            backgroundColor:
                                                kColorScaffoldBackground,
                                          ),
                                          icon: Image.asset(
                                            'assets/spotlight.png',
                                            height: 40,
                                            width: 40,
                                            fit: BoxFit.contain,
                                          ),
                                          label: const Text(
                                            'Register with Spotlight account',
                                            style: kButtonTextStyle,
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: ElevatedButton.icon(
                                          onPressed: () async {
                                            Navigator.pop(context);
                                            Navigator.of(context).push(
                                              MaterialPageRoute(
                                                builder:
                                                    (_) => const RegisterApi(),
                                              ),
                                            );
                                          },
                                          style: ElevatedButton.styleFrom(
                                            elevation: 10,
                                            minimumSize: Size(
                                              MediaQuery.of(
                                                    context,
                                                  ).size.width *
                                                  .3,
                                              50,
                                            ),
                                            backgroundColor:
                                                kColorScaffoldBackground,
                                          ),
                                          icon: Image.asset(
                                            'assets/api.png',
                                            height: 40,
                                            width: 40,
                                            fit: BoxFit.contain,
                                          ),
                                          label: const Text(
                                            'Register for API account',
                                            style: kButtonTextStyle,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
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

  //load email and password
  void _loadUserEmailPassword() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      var email = prefs.getString("email") ?? "";
      var password = prefs.getString("password") ?? "";

      if (checkboxState) {
        textUserName.text = email;
        textPassword.text = password;
      }
      setState(() {});
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  //handle remember me function
  void _handleRememberMe() {
    SharedPreferences.getInstance().then((prefs) {
      prefs.setString('email', textUserName.text);
      prefs.setString('password', textPassword.text);
    });
  }

  //Validators either return an error string or null
  //if the value is in the correct format
  String? _validateEmail(String? value) {
    if (value!.isEmpty) {
      return ('Email address is required');
    } else if (EmailValidator.validate(value) == false) {
      return ('A valid email address is required');
    }
    return null;
  }

  String? _validatePassword(String? password) {
    String errorMessage = '';
    // Password length greater than 6
    if (password!.length < 6) {
      errorMessage += 'Password must be longer than 6 characters.\n';
    }
    // Contains at least one uppercase letter
    if (!password.contains(RegExp(r'[A-Z]'))) {
      errorMessage += '• Uppercase letter is missing.\n';
    }
    // Contains at least one lowercase letter
    if (!password.contains(RegExp(r'[a-z]'))) {
      errorMessage += '• Lowercase letter is missing.\n';
    }
    // Contains at least one digit
    if (!password.contains(RegExp(r'[0-9]'))) {
      errorMessage += '• Digit is missing.\n';
    }
    // Contains at least one special character
    if (!(RegExp(
      r'[\^$*.\[\]{}()?\-"!@#%&/\,><:;_~`+=' // <-- Notice the escaped symbols
      "'" // <-- ' is added to the expression
      ']',
    ).hasMatch(password))) {
      errorMessage += '• Special character is missing.\n';
    }
    // If there are no error messages, the password is valid
    if (errorMessage == "") {
      debugPrint('success');
      return null;
    }
    debugPrint('failed');
    return errorMessage;
  }
}
