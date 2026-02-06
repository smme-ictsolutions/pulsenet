import 'package:customer_portal/constants/styles.dart';
import 'package:customer_portal/services/file_picker.dart';
import 'package:customer_portal/shared/dialog.dart';
import 'package:flutter/material.dart';

class TrackTraceInputButtons extends StatelessWidget {
  final ValueChanged<List<String?>> onSubmitted;
  const TrackTraceInputButtons({super.key, required this.onSubmitted});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      height: 50,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          SizedBox(
            width: 220,
            child: ListTile(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              tileColor: kColorBar,
              leading: Icon(Icons.keyboard, size: 50, color: kColorSuccess),
              title: InkWell(
                onTap: () => onSubmitted(['manual']),
                child: Text(
                  'Type Manually',
                  style: kbotTitleTextStyle,
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
          SizedBox(width: 10),
          SizedBox(
            width: 220,
            child: ListTile(
              onTap: () async {
                await FilePickerService().pickFile('xml').then((value) async {
                  try {
                    await FilePickerService().validateXML(value ?? '').then((
                      isValid,
                    ) {
                      if (isValid) {
                        onSubmitted([value]);
                      } else {
                        onSubmitted([null]);
                        if (!context.mounted) return;
                        DialogService(
                          button: '',
                          origin:
                              'The uploaded XML file is not valid. Please ensure it contains the required structure.',
                        ).showSnackBar(context: context);
                      }
                    });
                  } catch (e) {
                    debugPrint('Error parsing XML: $e');
                  }
                });
              },
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              tileColor: kColorBar,
              leading: Image.asset('assets/xml.png', height: 50, width: 50),
              trailing: InkWell(
                onTap: () {
                  DialogService(
                    button: '',
                    origin: 'XML Sample Info',
                  ).showNotice(
                    context: context,
                    assetPath: 'assets/xmlsample.png',
                  );
                },
                child: Image.asset('assets/example.png', height: 50, width: 50),
              ),
              title: Text(
                'XML Request',
                style: kbotTitleTextStyle,
                textAlign: TextAlign.center,
              ),
            ),
          ),
          SizedBox(width: 10),
          SizedBox(
            width: 220,
            child: ListTile(
              onTap: () async {
                await FilePickerService().pickFile('json').then((value) async {
                  try {
                    await FilePickerService().validateJSON(value ?? '').then((
                      isValid,
                    ) {
                      if (isValid.isNotEmpty) {
                        onSubmitted([isValid]);
                      } else {
                        onSubmitted([isValid]);
                        if (!context.mounted) return;
                        DialogService(
                          button: '',
                          origin:
                              'The uploaded JSON file is not valid. Please ensure it contains the required structure.',
                        ).showSnackBar(context: context);
                      }
                    });
                  } catch (e) {
                    debugPrint('Error parsing JSON: $e');
                  }
                });
              },
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              tileColor: kColorBar,
              leading: Image.asset('assets/json.png', height: 50, width: 50),
              trailing: InkWell(
                onTap: () {
                  DialogService(
                    button: '',
                    origin: 'JSON Sample Info',
                  ).showNotice(
                    context: context,
                    assetPath: 'assets/jsonsample.png',
                  );
                },
                child: Image.asset('assets/example.png', height: 50, width: 50),
              ),
              title: Text(
                'JSON Request',
                style: kbotTitleTextStyle,
                textAlign: TextAlign.center,
              ),
            ),
          ),
          SizedBox(width: 10),
          SizedBox(
            width: 220,
            child: ListTile(
              onTap: () async {
                await FilePickerService().pickFile('csv').then((value) async {
                  try {
                    await FilePickerService().validateCSV(value ?? '').then((
                      isValid,
                    ) {
                      if (isValid.isNotEmpty) {
                        onSubmitted([isValid]);
                      } else {
                        onSubmitted([isValid]);
                        if (!context.mounted) return;
                        DialogService(
                          button: '',
                          origin:
                              'The uploaded CSV file is not valid. Please ensure it contains the required structure.',
                        ).showSnackBar(context: context);
                      }
                    });
                  } catch (e) {
                    debugPrint('Error parsing CSV: $e');
                  }
                });
              },
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              tileColor: kColorBar,
              leading: Image.asset('assets/csv.png', height: 50, width: 50),
              trailing: InkWell(
                onTap: () {
                  DialogService(
                    button: '',
                    origin: 'CSV Sample Info',
                  ).showNotice(
                    context: context,
                    assetPath: 'assets/csvsample.png',
                  );
                },
                child: Image.asset('assets/example.png', height: 50, width: 50),
              ),
              title: Text(
                'CSV Request',
                style: kbotTitleTextStyle,
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
