import 'package:customer_portal/constants/styles.dart';
import 'package:customer_portal/services/file_picker.dart';
import 'package:customer_portal/shared/dialog.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

class UploadInputButtons extends StatelessWidget {
  final ValueChanged<FilePickerResult> onSubmitted;
  const UploadInputButtons({super.key, required this.onSubmitted});

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
              onTap: () async {
                try {
                  await FilePickerService().validateExcelHeaders().then((
                    result,
                  ) {
                    if (result != null) {
                      onSubmitted(result);
                    } else {
                      onSubmitted(FilePickerResult([]));
                      if (!context.mounted) return;
                      DialogService(
                        button: '',
                        origin:
                            'The uploaded XLS file is not valid. Please ensure it contains the required header structure as per the example.',
                      ).showSnackBar(context: context);
                    }
                  });
                } catch (e) {
                  debugPrint('Error parsing XLS: $e');
                }
              },
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              tileColor: kColorBar,
              leading: Image.asset('assets/excel.png', height: 50, width: 50),
              trailing: InkWell(
                onTap: () {
                  DialogService(
                    button: '',
                    origin: 'Excel Sample Info',
                  ).showNotice(
                    context: context,
                    assetPath: 'assets/excelsample.png',
                  );
                },
                child: Image.asset('assets/example.png', height: 50, width: 50),
              ),
              title: Text(
                'EXCEL Upload',
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
