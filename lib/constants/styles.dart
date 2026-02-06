import 'package:flutter/material.dart';

// UI Colors
const kColorBar = Colors.white;
const kColorText = Color.fromARGB(255, 102, 102, 102);
const kColorAccent = Color.fromARGB(255, 16, 130, 223);
const kColorError = Colors.red;
const kColorSuccess = Colors.green;
const kColorNavIcon = Color.fromRGBO(131, 136, 139, 1.0);
const kColorScaffoldBackground = Colors.transparent;
const kColorBackground = Color.fromRGBO(237, 48, 36, 1.0);
const kColorForeground = Colors.white;
const kColorSplash = Color.fromRGBO(237, 48, 36, 1.0);

// Text Styles
const kFontSizeSmallest = 7.0;
const kFontSizeSuperSmall = 10.0;
const kFontSizeMediumNormal = 13.0;
const kFontSizeNormal = 16.0;
const kFontSizeSuperNormal = 20.0;
const kFontSizeMedium = 30.0;
const kFontSizeLarge = 80.0;

const kbotTitleTextStyle = TextStyle(
  color: Color.fromARGB(255, 9, 87, 151),
  fontWeight: FontWeight.normal,
  fontSize: kFontSizeMediumNormal,
);

const kChatTextStyle = TextStyle(
  color: Colors.black,
  fontWeight: FontWeight.normal,
  fontSize: kFontSizeMediumNormal,
);

const kMarkerTextStyle = TextStyle(
  color: kColorBar,
  fontWeight: FontWeight.normal,
  fontSize: kFontSizeSuperSmall,
);

const kErrorTextStyle = TextStyle(
  color: kColorError,
  fontWeight: FontWeight.normal,
  fontSize: kFontSizeMediumNormal,
);

const kSuccessTextStyle = TextStyle(
  color: kColorSuccess,
  fontWeight: FontWeight.normal,
  fontSize: kFontSizeMediumNormal,
);

const kMarkerTextStyle1 = TextStyle(
  color: Colors.black,
  fontWeight: FontWeight.normal,
  fontSize: kFontSizeSuperSmall,
);

const kDescriptionTextStyle = TextStyle(
  color: Colors.white,
  fontWeight: FontWeight.normal,
  fontSize: kFontSizeMedium,
);

const kTitleTextStyle = TextStyle(
  color: Color.fromRGBO(139, 197, 63, 1.0),
  fontWeight: FontWeight.bold,
  fontSize: kFontSizeLarge,
);

const kHeaderTextStyle = TextStyle(
  color: Color.fromRGBO(139, 197, 63, 1.0),
  fontWeight: FontWeight.bold,
  fontSize: kFontSizeSuperNormal,
);

const kHeaderHomeTextStyle = TextStyle(
  color: Colors.white,
  fontWeight: FontWeight.bold,
  fontSize: kFontSizeSuperNormal,
);
const kHeaderHomeBlackTextStyle = TextStyle(
  color: Colors.black,
  fontWeight: FontWeight.bold,
  fontSize: kFontSizeSuperNormal,
);
const kMapHeaderTextStyle = TextStyle(
  color: kColorBackground,
  fontWeight: FontWeight.bold,
  fontSize: kFontSizeSuperNormal,
);
const kMapHeaderTextStyle1 = TextStyle(
  color: kColorBackground,
  fontWeight: FontWeight.bold,
  fontSize: kFontSizeNormal,
);

const kSubTitleTextStyle = TextStyle(
  color: Color.fromRGBO(237, 48, 36, 1.0),
  fontWeight: FontWeight.normal,
  fontSize: kFontSizeMediumNormal,
);

const kListTitleTextStyle = TextStyle(
  color: Color.fromRGBO(237, 48, 36, 1.0),
  fontWeight: FontWeight.normal,
  fontSize: kFontSizeNormal,
);

const kListValueTextStyle = TextStyle(
  color: kColorBar,
  fontWeight: FontWeight.normal,
  fontSize: kFontSizeNormal,
);

const kHeaderLabelTextStyle = TextStyle(
  color: Colors.white,
  fontWeight: FontWeight.bold,
  fontSize: kFontSizeNormal,
);

const kLabelTextStyle = TextStyle(
  color: Colors.white,
  fontWeight: FontWeight.normal,
  fontSize: kFontSizeMediumNormal,
);

const kAnnouncementTextStyle = TextStyle(
  color: Color.fromRGBO(139, 197, 63, 1.0),
  fontWeight: FontWeight.normal,
  fontSize: kFontSizeMediumNormal,
);

const kHypelinkTextStyle = TextStyle(
  decoration: TextDecoration.underline,
  decorationColor: Color.fromARGB(255, 16, 130, 223),
  color: Colors.white,
  fontWeight: FontWeight.bold,
  fontSize: kFontSizeNormal,
);

const kTextStyle = TextStyle(
  color: Colors.black,
  fontWeight: FontWeight.normal,
  fontSize: kFontSizeNormal,
);

const kButtonTextStyle = TextStyle(
  color: Colors.white,
  fontWeight: FontWeight.normal,
  fontSize: kFontSizeNormal,
);

const kNormalTextStyle = TextStyle(
  color: Colors.white,
  fontWeight: FontWeight.normal,
  fontSize: kFontSizeNormal,
);

const kSmallestTextStyle = TextStyle(
  color: Colors.white,
  fontWeight: FontWeight.normal,
  fontSize: kFontSizeSmallest,
);
const kSmallestTextStyle1 = TextStyle(
  color: Colors.black,
  fontWeight: FontWeight.normal,
  fontSize: kFontSizeSmallest,
);

// Inputs
const kButtonRadius = 10.0;

const userInputDecoration = InputDecoration(
  errorStyle: TextStyle(color: kColorForeground),
  labelStyle: TextStyle(color: kColorForeground),
  hintStyle: TextStyle(color: kColorForeground),
  enabledBorder: UnderlineInputBorder(
    borderSide: BorderSide(color: kColorForeground),
  ),
  errorBorder: UnderlineInputBorder(
    borderSide: BorderSide(color: kColorForeground),
  ),
  focusedBorder: UnderlineInputBorder(
    borderSide: BorderSide(color: kColorForeground),
  ),
);
