import 'package:cached_network_image/cached_network_image.dart';
import 'package:customer_portal/constants/styles.dart';
import 'package:customer_portal/model/mobiapp.dart';
import 'package:customer_portal/shared/dialog.dart';
import 'package:flutter/material.dart';
import 'package:mailto/mailto.dart';
import 'package:url_launcher/url_launcher.dart';

class EmailForm extends StatefulWidget {
  const EmailForm({
    super.key,
    this.contactvalue,
    this.email,
    this.message,
    this.sortCriteria,
    required this.imageData,
  });
  final String? contactvalue;
  final String? email;
  final String? message;
  final int? sortCriteria;
  final List<ImageData> imageData;

  @override
  State<EmailForm> createState() => _EmailFormState();
}

class _EmailFormState extends State<EmailForm> {
  //keys allow us to access widgets from a different place in the code
  final _formKey = GlobalKey<FormState>();
  //form values
  String? _subject;
  String? _email;
  String? _message = '';
  bool loading = false;
  String error = '';

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is removed from the widget tree.
    // This also removes the _printLatestValue listener.
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      errorWidget: (context, url, error) => const Icon(Icons.error),
      imageUrl:
          widget.imageData
              .where((element) => element.title == "featurebackground")
              .first
              .url,
      imageBuilder:
          (context, imageProvider) => Container(
            decoration: BoxDecoration(
              image: DecorationImage(image: imageProvider, fit: BoxFit.cover),
            ),
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            child: Scaffold(
              backgroundColor: Colors.blue.withValues(alpha: .4),
              body: Card(
                color: Colors.black.withValues(alpha: .7),
                child: Form(
                  key: _formKey,
                  child: ListView(
                    padding: const EdgeInsets.all(8),
                    children: <Widget>[
                      const SizedBox(height: 10),
                      TextFormField(
                        onTapOutside: (b) {
                          FocusManager.instance.primaryFocus?.unfocus();
                        },
                        style: kButtonTextStyle,
                        validator: _validateSubject,
                        initialValue: widget.contactvalue,
                        textCapitalization: TextCapitalization.words,
                        onSaved: (val) {
                          setState(() => _subject = val);
                        },
                        decoration: userInputDecoration.copyWith(
                          hintText: 'Enter subject',
                          labelText: 'Subject',
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        onTapOutside: (b) {
                          FocusManager.instance.primaryFocus?.unfocus();
                        },
                        style: kButtonTextStyle,
                        validator: _validateEmail,
                        initialValue: widget.email,
                        textCapitalization: TextCapitalization.words,
                        onSaved: (val) {
                          setState(() => _email = val);
                        },
                        decoration: userInputDecoration.copyWith(
                          hintText: 'Enter email',
                          labelText: 'Email',
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        onTapOutside: (b) {
                          FocusManager.instance.primaryFocus?.unfocus();
                        },
                        style: kButtonTextStyle,
                        validator: _validateMessage,
                        initialValue: widget.message,
                        textCapitalization: TextCapitalization.words,
                        keyboardType: TextInputType.multiline,
                        maxLines: null,
                        onSaved: (val) {
                          setState(() => _message = val);
                        },
                        decoration: userInputDecoration.copyWith(
                          hintText: 'Enter message',
                          labelText: 'Message',
                        ),
                      ),
                      const SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            _formKey.currentState!.save();
                            setState(() => loading = true);
                            final email = Mailto(
                              body: _message!,
                              subject: _subject!,
                              to: [_email!],
                            );
                            final navigator = Navigator.of(context);
                            try {
                              await launchUrl(Uri.parse(email.toString()));
                              navigator.pop();
                              if (context.mounted) {
                                await DialogService(
                                  button: 'dismiss',
                                  origin: "Opening mail client please wait...",
                                ).showSnackBar(context: context);
                              }
                            } catch (e) {
                              debugPrint(e.toString());
                              navigator.pop();
                              if (context.mounted) {
                                await DialogService(
                                  button: 'dismiss',
                                  origin: "Message cannot be sent...",
                                ).showSnackBar(context: context);
                              }
                            }
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          minimumSize: Size(
                            MediaQuery.of(context).size.width * .6,
                            50,
                          ),
                          backgroundColor: kColorBackground,
                          foregroundColor: kColorForeground,
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Text('Submit'),
                            Icon(Icons.email, size: 18),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: () async {
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          minimumSize: Size(
                            MediaQuery.of(context).size.width * .6,
                            50,
                          ),
                          backgroundColor: kColorBackground,
                          foregroundColor: kColorForeground,
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Text('Cancel'),
                            Icon(Icons.home, size: 18),
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
  String? _validateSubject(String? value) {
    if (value!.isEmpty) {
      return ('Subject is required');
    }
    return null;
  }

  String? _validateEmail(String? value) {
    if (value!.isEmpty) {
      return ('Email is required');
    }
    return null;
  }

  String? _validateMessage(String? value) {
    if (value!.isEmpty) {
      return ('Message is required');
    }
    return null;
  }
}
