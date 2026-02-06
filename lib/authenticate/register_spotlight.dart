import 'package:cached_network_image/cached_network_image.dart';
import 'package:customer_portal/authenticate/sign_in.dart';
import 'package:customer_portal/authenticate/verification_email.dart';
import 'package:customer_portal/constants/styles.dart';
import 'package:customer_portal/database/database_service.dart';
import 'package:customer_portal/model/mobiapp.dart';
import 'package:customer_portal/model/singletons_data.dart';
import 'package:customer_portal/model/user.dart';
import 'package:customer_portal/services/auth.dart';
import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:multi_select_flutter/dialog/multi_select_dialog_field.dart';
import 'package:multi_select_flutter/util/multi_select_item.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class RegisterSpotlight extends StatefulWidget {
  const RegisterSpotlight({super.key});

  @override
  State<RegisterSpotlight> createState() => _RegisterSpotlightState();
}

class _RegisterSpotlightState extends State<RegisterSpotlight> {
  final FirebaseAuth _authSpotlight = FirebaseAuth.instanceFor(
    app: Firebase.app('com.transnet.spotlight-3'),
  );
  final _formKey = GlobalKey<FormState>();
  final GlobalKey<FormFieldState> _multiModulesSelectKey =
      GlobalKey<FormFieldState>();
  String email = '', password = '', displayname = '', error = '';
  bool loading = false,
      obscureText = true,
      _isValidAccount = false,
      isRegistered = false;
  var _myStakeholderSelection = "";
  List<String> _myPortSelection = [],
      _mySectorSelection = [],
      _myModulesSelection = [];
  List<ModuleData> _modulesList = [];

  void getLookups() async {
    _modulesList = appData.modulesList;
  }

  //Sign in existing user
  Future signInWithEmailAndPassword(String email, String password) async {
    try {
      UserCredential result = await _authSpotlight.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      User? user = result.user;

      return user!.uid;
    } catch (e) {
      error = e.toString();
      debugPrint('err: ${e.toString()}');
      return 'err: ${e.toString()}';
    }
  }

  @override
  void initState() {
    getLookups();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    List<ImageData> imageData = appData.imageData;
    appData.mobiAppData = Provider.of<MobiAppData>(context, listen: false);
    return loading || imageData.isEmpty
        ? const SizedBox(
          height: 100,
          width: 100,
          child: CircularProgressIndicator(color: kColorBar),
        )
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
                  extendBody: true,
                  extendBodyBehindAppBar: true,
                  resizeToAvoidBottomInset: false,
                  backgroundColor: kColorScaffoldBackground,
                  body: SingleChildScrollView(
                    physics: AlwaysScrollableScrollPhysics(),
                    child:
                        isRegistered
                            ? Center(
                              heightFactor: 10,
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    minimumSize: Size(
                                      MediaQuery.of(context).size.width * .6,
                                      50,
                                    ),
                                    backgroundColor: kColorBackground,
                                    foregroundColor: kColorForeground,
                                  ),
                                  child: const Text(
                                    'Go to Verification Screen',
                                  ),
                                  onPressed: () async {
                                    Navigator.of(context).pop;
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder:
                                            (_) => const VerificationEmail(
                                              source: 'register_spotlight',
                                            ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            )
                            : Form(
                              key: _formKey,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      CachedNetworkImage(
                                        errorWidget:
                                            (context, url, error) =>
                                                const Icon(Icons.error),
                                        imageUrl:
                                            imageData
                                                .where(
                                                  (element) =>
                                                      element.title ==
                                                      'TPTLogo',
                                                )
                                                .first
                                                .url,
                                        imageBuilder:
                                            (context, imageProvider) =>
                                                Container(
                                                  width: 100,
                                                  height: 100,
                                                  decoration: BoxDecoration(
                                                    image: DecorationImage(
                                                      image: imageProvider,
                                                      fit: BoxFit.contain,
                                                      alignment:
                                                          Alignment.topRight,
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
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        const Align(
                                          alignment: Alignment.centerLeft,
                                          child: Padding(
                                            padding: EdgeInsets.only(left: 8.0),
                                            child: Text(
                                              "Register using Spotlight",
                                              style: kHeaderTextStyle,
                                            ),
                                          ),
                                        ),
                                        const Align(
                                          alignment: Alignment.centerLeft,
                                          child: Padding(
                                            padding: EdgeInsets.only(left: 8.0),
                                            child: Text(
                                              "The port at your fingertips",
                                              style: kSubTitleTextStyle,
                                            ),
                                          ),
                                        ),
                                        if (!_isValidAccount)
                                          Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: TextFormField(
                                              style: kButtonTextStyle,
                                              decoration: userInputDecoration
                                                  .copyWith(
                                                    suffixIcon: const Icon(
                                                      Icons.email,
                                                      color: kColorForeground,
                                                    ),
                                                    hintText:
                                                        'Enter spotlight email',
                                                  ),
                                              validator: _validateEmail,
                                              onChanged: (val) {
                                                setState(() => email = val);
                                              },
                                            ),
                                          ),
                                        if (!_isValidAccount)
                                          Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: TextFormField(
                                              style: kButtonTextStyle,
                                              decoration: userInputDecoration.copyWith(
                                                suffixIcon: IconButton(
                                                  onPressed: () {
                                                    setState(
                                                      () =>
                                                          obscureText =
                                                              !obscureText,
                                                    );
                                                  },
                                                  icon:
                                                      !obscureText
                                                          ? const Icon(
                                                            Icons.lock,
                                                          )
                                                          : const Icon(
                                                            Icons
                                                                .remove_red_eye,
                                                          ),
                                                  color: kColorForeground,
                                                ),
                                                hintText:
                                                    'Enter spotlight password',
                                              ),
                                              validator: _validatePassword,
                                              obscureText: obscureText,
                                              onChanged: (val) {
                                                setState(() => password = val);
                                              },
                                            ),
                                          ),
                                        if (!_isValidAccount)
                                          Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                minimumSize: Size(
                                                  MediaQuery.of(
                                                        context,
                                                      ).size.width *
                                                      .2,
                                                  50,
                                                ),
                                                backgroundColor:
                                                    kColorBackground,
                                                foregroundColor:
                                                    kColorForeground,
                                              ),
                                              child: const Text('Next'),
                                              onPressed: () async {
                                                error = "";
                                                if (_formKey.currentState!
                                                    .validate()) {
                                                  await signInWithEmailAndPassword(
                                                    email,
                                                    password,
                                                  ).then((value) {
                                                    if (value != null &&
                                                        error == "") {
                                                      //retrieve spotlight user data
                                                      DatabaseService(
                                                        value,
                                                      ).spotlightUserData().then((
                                                        spotlightUser,
                                                      ) {
                                                        _myPortSelection =
                                                            spotlightUser.port!;
                                                        _mySectorSelection =
                                                            spotlightUser
                                                                .sector!;
                                                        displayname =
                                                            spotlightUser
                                                                .username!;
                                                        _myStakeholderSelection =
                                                            spotlightUser
                                                                .stakeholder!;
                                                        setState(() {
                                                          _isValidAccount =
                                                              true;
                                                        });
                                                      });
                                                      //register account on customer portal
                                                    } else {
                                                      setState(() {
                                                        _isValidAccount = false;
                                                      });
                                                    }
                                                  });
                                                }
                                              },
                                            ),
                                          ),
                                        if (_isValidAccount)
                                          Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child:
                                                _modulesList.isNotEmpty &&
                                                        _myPortSelection
                                                            .isNotEmpty
                                                    ? MultiSelectDialogField(
                                                      key:
                                                          _multiModulesSelectKey,
                                                      /*validator: (values) {
                                                        if (values == null ||
                                                            values.isEmpty) {
                                                          return "Module/s are required";
                                                        }
                                                        return null;
                                                      },*/
                                                      items:
                                                          _modulesList
                                                              .where(
                                                                (element) =>
                                                                    element
                                                                        .terminal ==
                                                                    _myPortSelection
                                                                        .first,
                                                              )
                                                              .toList()
                                                              .map(
                                                                (
                                                                  module,
                                                                ) => MultiSelectItem<
                                                                  String
                                                                >(
                                                                  module.module,
                                                                  module.module,
                                                                ),
                                                              )
                                                              .toList(),
                                                      selectedColor:
                                                          kColorSuccess,
                                                      decoration: BoxDecoration(
                                                        color: kColorText
                                                            .withValues(
                                                              alpha: .5,
                                                            ),
                                                        borderRadius:
                                                            const BorderRadius.only(
                                                              topRight:
                                                                  Radius.circular(
                                                                    5,
                                                                  ),
                                                              topLeft:
                                                                  Radius.circular(
                                                                    5,
                                                                  ),
                                                            ),
                                                      ),
                                                      buttonIcon: const Icon(
                                                        Icons
                                                            .arrow_drop_down_outlined,
                                                        color: kColorBar,
                                                      ),
                                                      buttonText: const Text.rich(
                                                        TextSpan(
                                                          children: [
                                                            WidgetSpan(
                                                              child: Icon(
                                                                Icons.computer,
                                                                color:
                                                                    kColorForeground,
                                                              ),
                                                            ),
                                                            TextSpan(
                                                              text:
                                                                  '  Tap to add additional modules',
                                                              style:
                                                                  kLabelTextStyle,
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                      onConfirm: (results) {
                                                        results.isNotEmpty
                                                            ? _multiModulesSelectKey
                                                                .currentState!
                                                                .validate()
                                                            : null;
                                                        setState(() {
                                                          _myModulesSelection =
                                                              results;
                                                        });
                                                      },
                                                    )
                                                    : Container(),
                                          ),
                                        if (_isValidAccount)
                                          Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                minimumSize: Size(
                                                  MediaQuery.of(
                                                        context,
                                                      ).size.width *
                                                      .6,
                                                  50,
                                                ),
                                                backgroundColor:
                                                    kColorBackground,
                                                foregroundColor:
                                                    kColorForeground,
                                              ),
                                              child: const Text('Register'),
                                              onPressed: () async {
                                                if (_formKey.currentState!
                                                    .validate() /*&&
                                                    _myModulesSelection
                                                        .isNotEmpty*/ ) {
                                                  _formKey.currentState!.save();
                                                  setState(
                                                    () => loading = true,
                                                  );
                                                  try {
                                                    await context
                                                        .read<AuthService>()
                                                        .registerWithEmailAndPassword(
                                                          email,
                                                          password,
                                                          displayname,
                                                          _mySectorSelection,
                                                          _myPortSelection,
                                                          _myStakeholderSelection,
                                                          _myModulesSelection,
                                                          true,
                                                        )
                                                        .then((value) async {
                                                          dynamic result =
                                                              value;
                                                          if (result == null) {
                                                            setState(() {
                                                              error =
                                                                  'Please enter a valid email or email already in use';
                                                              loading = false;
                                                            });
                                                          } else {
                                                            setState(() {
                                                              loading = false;
                                                              isRegistered =
                                                                  true;
                                                            });
                                                          }
                                                        });
                                                  } on FirebaseAuthException catch (
                                                    e
                                                  ) {
                                                    error = e.message!;
                                                    setState(() {
                                                      loading = false;
                                                      isRegistered = false;
                                                    });
                                                  }
                                                }
                                              },
                                            ),
                                          ),
                                        InkWell(
                                          onTap: () {
                                            Navigator.pop(context);
                                            Navigator.of(context).push(
                                              MaterialPageRoute(
                                                builder: (_) => const SignIn(),
                                              ),
                                            );
                                          },
                                          splashColor: kColorSplash,
                                          child: const Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Text(
                                                "Already registered? ",
                                                style: TextStyle(
                                                  fontSize: kFontSizeNormal,
                                                  color: kColorBar,
                                                ),
                                              ),
                                              Text(
                                                "Sign In",
                                                style: kHypelinkTextStyle,
                                              ),
                                            ],
                                          ),
                                        ),
                                        Text(
                                          error,
                                          style: const TextStyle(
                                            color: Colors.red,
                                            fontSize: 14.0,
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
