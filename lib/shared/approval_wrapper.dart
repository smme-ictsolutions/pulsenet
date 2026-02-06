import 'package:customer_portal/constants/styles.dart';
import 'package:customer_portal/model/singletons_data.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ApprovalWrapper extends StatelessWidget {
  final String adminAddress;
  const ApprovalWrapper({super.key, required this.adminAddress});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Expanded(
          child: Center(
            child: Card(
              color: kColorScaffoldBackground,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
                side: BorderSide(color: Colors.black),
              ),
              child: Text(
                textAlign: TextAlign.center,
                "Thank you for enrolling on Customer Web Portal.Your account is pending approval, the module will be unlocked when the account is approved. Download and complete the application by clicking on the link below. Completed forms can be emailed to $adminAddress",
                style: kDescriptionTextStyle,
              ),
            ),
          ),
        ),
        Flexible(
          child: InkWell(
            splashColor: kColorSplash,
            onTap: () async {
              final Uri url = Uri.parse(
                appData.imageData
                    .where((element) => element.title == 'template')
                    .first
                    .url,
              );
              if (!await launchUrl(url)) {
                throw Exception('Could not launch');
              }
            },
            child: const Text(
              "Download Application Form",
              style: TextStyle(
                decorationColor: kColorForeground,
                decoration: TextDecoration.underline,
                fontSize: kFontSizeSuperNormal,
                color: kColorForeground,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
