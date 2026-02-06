import 'package:customer_portal/constants/styles.dart';
import 'package:customer_portal/model/singletons_data.dart';
import 'package:customer_portal/model/user.dart';
import 'package:flutter/material.dart';

class FacilityInput extends StatelessWidget {
  final ValueChanged<TerminalLayoutData?> onSubmitted;
  const FacilityInput({super.key, required this.onSubmitted});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topLeft,
      child: SizedBox(
        width: MediaQuery.of(context).size.width * .8,
        child: DropdownButtonFormField<String>(
          style: kTextStyle,
          iconSize: 24,
          iconEnabledColor: kColorBar,
          iconDisabledColor: kColorNavIcon,
          items:
              appData.portLayoutsList.map<DropdownMenuItem<String>>((item) {
                return DropdownMenuItem<String>(
                  value: item.terminal,
                  child: Text(item.terminal),
                );
              }).toList(),
          onChanged: (String? value) async {
            onSubmitted(
              appData.portLayoutsList
                  .where((element) => element.terminal == value)
                  .first,
            );
          },
          decoration: InputDecoration(
            hintText: "Tap to select facility",
            hintStyle: kLabelTextStyle,
            filled: true,
            fillColor: kColorNavIcon.withValues(alpha: 0.4),
            focusColor: kColorForeground,
            floatingLabelBehavior: FloatingLabelBehavior.never,
            prefixIcon: const Icon(Icons.place, color: kColorSplash),
          ),
        ),
      ),
    );
  }
}
