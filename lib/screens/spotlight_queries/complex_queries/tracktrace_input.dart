import 'package:customer_portal/constants/styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class TrackTraceInput extends StatelessWidget {
  final ValueChanged<List<String?>> onChanged;
  final String? sector;
  final TextEditingController controller;
  const TrackTraceInput({
    super.key,
    required this.onChanged,
    this.sector,
    required this.controller,
  });
  Future<String?> _getClipboardData() async {
    ClipboardData? data = await Clipboard.getData(Clipboard.kTextPlain);
    return data?.text;
  }

  List<String> parseInput(String input) {
    return input.split(RegExp(r'[\n, ]+')).where((e) => e.isNotEmpty).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: kColorNavIcon,
      child: Stack(
        alignment: Alignment.topRight,
        children: [
          TextFormField(
            controller: controller,
            inputFormatters: <TextInputFormatter>[
              FilteringTextInputFormatter.allow(RegExp("[0-9a-zA-Z\n]")),
            ],
            textCapitalization: TextCapitalization.characters,
            keyboardType: TextInputType.multiline,
            decoration: userInputDecoration.copyWith(
              hintText: 'Enter query data. (iso standard, max 10)',
              errorStyle: TextStyle(color: kColorError),
            ),
            minLines: 10,
            maxLines: 10,
            validator:
                (value) =>
                    value == null || value.isEmpty
                        ? 'Please enter at least 1 query element.'
                        : null,
            onSaved: (value) => controller.text = value ?? '',
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton.icon(
                onPressed: () async {
                  String? clipboardData = await _getClipboardData();
                  if (clipboardData != null) {
                    controller.text = clipboardData;
                  }
                },
                label: const Text('Clipboard Paste'),
                icon: Icon(Icons.paste, color: kColorSuccess),
              ),
              TextButton(
                onPressed:
                    () =>
                        onChanged(parseInput(controller.text).cast<String?>()),
                child: const Text('Submit'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
