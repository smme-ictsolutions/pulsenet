import 'package:customer_portal/constants/styles.dart';
import 'package:customer_portal/main.dart';
import 'package:customer_portal/model/mobiapp.dart';
import 'package:customer_portal/model/singletons_data.dart';
import 'package:customer_portal/shared/dialog.dart';
import 'package:customer_portal/shared/upper_case.dart';
import 'package:flutter/material.dart';

class RequirementsTab extends StatefulWidget {
  final TabController tabBar;
  final String sector;
  final List<PrePlanModel> preplanDetails;
  final bool isEdit;
  const RequirementsTab({
    super.key,
    required this.tabBar,
    required this.sector,
    required this.preplanDetails,
    required this.isEdit,
  });
  @override
  State<RequirementsTab> createState() => _RequirementsTabState();
}

class _RequirementsTabState extends State<RequirementsTab>
    with AutomaticKeepAliveClientMixin<RequirementsTab> {
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return SingleChildScrollView(
      child: Table(
        border: TableBorder.all(color: kColorForeground),
        columnWidths: const <int, TableColumnWidth>{0: FlexColumnWidth()},
        defaultVerticalAlignment: TableCellVerticalAlignment.middle,
        children: <TableRow>[
          TableRow(
            children: <Widget>[
              TableCell(
                verticalAlignment: TableCellVerticalAlignment.top,
                child: TextFormField(
                  initialValue:
                      widget.isEdit
                          ? widget
                              .preplanDetails[0]
                              .requirementDetails
                              .dischargeSequence
                          : "",
                  inputFormatters: [UpperCaseTextFormatter()],
                  textCapitalization: TextCapitalization.characters,
                  maxLines: null,
                  style: isMobile ? kSmallestTextStyle : kButtonTextStyle,
                  keyboardType: TextInputType.multiline,
                  decoration: userInputDecoration.copyWith(
                    labelText: 'Discharge Sequence',
                    hintText: 'multi input',
                    alignLabelWithHint: true,
                  ),
                  onChanged:
                      (value) => setState(() {
                        appData.myDischargeSequenceSelection = value;
                      }),
                ),
              ),
              TableCell(
                verticalAlignment: TableCellVerticalAlignment.top,
                child: TextFormField(
                  initialValue:
                      widget.isEdit
                          ? widget
                              .preplanDetails[0]
                              .requirementDetails
                              .loadSequence
                          : "",
                  inputFormatters: [UpperCaseTextFormatter()],
                  textCapitalization: TextCapitalization.characters,
                  maxLines: null,
                  style: isMobile ? kSmallestTextStyle : kButtonTextStyle,
                  keyboardType: TextInputType.multiline,
                  decoration: userInputDecoration.copyWith(
                    labelText: 'Load Sequence',
                    hintText: 'multi input',
                    alignLabelWithHint: true,
                  ),
                  onChanged:
                      (value) => setState(() {
                        appData.myLoadSequenceSelection = value;
                      }),
                ),
              ),
            ],
          ),
          TableRow(
            children: <Widget>[
              TableCell(
                verticalAlignment: TableCellVerticalAlignment.top,
                child: TextFormField(
                  initialValue:
                      widget.isEdit
                          ? widget
                              .preplanDetails[0]
                              .requirementDetails
                              .directRestows
                              .toString()
                          : "",
                  inputFormatters: [UpperCaseTextFormatter()],
                  textCapitalization: TextCapitalization.characters,
                  style: isMobile ? kSmallestTextStyle : kButtonTextStyle,
                  keyboardType: TextInputType.number,
                  decoration: userInputDecoration.copyWith(
                    labelText: 'Direct Restows',
                  ),
                  onChanged:
                      (value) => setState(() {
                        appData.myDirectRestowSelection = int.parse(value);
                      }),
                ),
              ),
              TableCell(
                verticalAlignment: TableCellVerticalAlignment.top,
                child: TextFormField(
                  initialValue:
                      widget.isEdit
                          ? widget
                              .preplanDetails[0]
                              .requirementDetails
                              .indirectRestows
                              .toString()
                          : "",
                  inputFormatters: [UpperCaseTextFormatter()],
                  textCapitalization: TextCapitalization.characters,
                  style: isMobile ? kSmallestTextStyle : kButtonTextStyle,
                  keyboardType: TextInputType.number,
                  decoration: userInputDecoration.copyWith(
                    labelText: 'Indirect Restows',
                  ),
                  onChanged:
                      (value) => setState(() {
                        appData.myIndirectRestowSelection = int.parse(value);
                      }),
                ),
              ),
            ],
          ),
          TableRow(
            children: <Widget>[
              TableCell(
                verticalAlignment: TableCellVerticalAlignment.top,
                child: TextFormField(
                  initialValue:
                      widget.isEdit
                          ? widget
                              .preplanDetails[0]
                              .requirementDetails
                              .volumeComments
                          : "",
                  inputFormatters: [UpperCaseTextFormatter()],
                  textCapitalization: TextCapitalization.characters,
                  maxLines: null,
                  style: isMobile ? kSmallestTextStyle : kButtonTextStyle,
                  keyboardType: TextInputType.multiline,
                  decoration: userInputDecoration.copyWith(
                    labelText: 'Volume Comments',
                    hintText: 'multi input',
                    alignLabelWithHint: true,
                  ),
                  onChanged:
                      (value) => setState(() {
                        appData.myVolumeCommentsSelection = value;
                      }),
                ),
              ),
              TableCell(
                verticalAlignment: TableCellVerticalAlignment.top,
                child: TextFormField(
                  initialValue:
                      widget.isEdit
                          ? widget.preplanDetails[0].requirementDetails.mafiList
                          : "",
                  inputFormatters: [UpperCaseTextFormatter()],
                  textCapitalization: TextCapitalization.characters,
                  maxLines: null,
                  style: isMobile ? kSmallestTextStyle : kButtonTextStyle,
                  keyboardType: TextInputType.multiline,
                  decoration: userInputDecoration.copyWith(
                    labelText: 'Mafi List',
                    hintText: 'multi input',
                    alignLabelWithHint: true,
                  ),
                  onChanged:
                      (value) => setState(() {
                        appData.myMafiListSelection = value;
                      }),
                ),
              ),
            ],
          ),
          TableRow(
            children: <Widget>[
              TableCell(
                verticalAlignment: TableCellVerticalAlignment.top,
                child: TextFormField(
                  initialValue:
                      widget.isEdit
                          ? widget
                              .preplanDetails[0]
                              .requirementDetails
                              .stevedoreDrivers
                              .toString()
                          : "",
                  inputFormatters: [UpperCaseTextFormatter()],
                  textCapitalization: TextCapitalization.characters,
                  style: isMobile ? kSmallestTextStyle : kButtonTextStyle,
                  keyboardType: TextInputType.number,
                  decoration: userInputDecoration.copyWith(
                    labelText: 'Stevedore Drivers',
                    errorStyle: TextStyle(color: kColorError),
                  ),
                  onChanged:
                      (value) => setState(() {
                        appData.myStevedoreDriversSelection = int.parse(value);
                      }),
                  validator:
                      (val) =>
                          val!.isEmpty ? 'Stevedore Drivers required.' : null,
                ),
              ),
              TableCell(
                verticalAlignment: TableCellVerticalAlignment.top,
                child: TextFormField(
                  initialValue:
                      widget.isEdit
                          ? widget
                              .preplanDetails[0]
                              .requirementDetails
                              .stevedorePilots
                              .toString()
                          : "",
                  inputFormatters: [UpperCaseTextFormatter()],
                  textCapitalization: TextCapitalization.characters,
                  style: isMobile ? kSmallestTextStyle : kButtonTextStyle,
                  keyboardType: TextInputType.number,
                  decoration: userInputDecoration.copyWith(
                    labelText: 'Stevedore Pilots',
                    errorStyle: TextStyle(color: kColorError),
                  ),
                  onChanged:
                      (value) => setState(() {
                        appData.myStevedorePilotsSelection = int.parse(value);
                      }),
                  validator:
                      (val) =>
                          val!.isEmpty ? 'Stevedore Pilots required.' : null,
                ),
              ),
            ],
          ),
          TableRow(
            children: <Widget>[
              TableCell(
                verticalAlignment: TableCellVerticalAlignment.top,
                child: TextFormField(
                  initialValue:
                      widget.isEdit
                          ? widget
                              .preplanDetails[0]
                              .requirementDetails
                              .exportLanes
                              .toString()
                          : "",
                  inputFormatters: [UpperCaseTextFormatter()],
                  textCapitalization: TextCapitalization.characters,
                  style: isMobile ? kSmallestTextStyle : kButtonTextStyle,
                  keyboardType: TextInputType.number,
                  decoration: userInputDecoration.copyWith(
                    labelText: 'Export Lanes',
                    errorStyle: TextStyle(color: kColorError),
                  ),
                  onChanged:
                      (value) => setState(() {
                        appData.myExportLanesSelection = int.parse(value);
                      }),
                  validator:
                      (val) =>
                          val!.isEmpty && appData.myImportLanesSelection == 0
                              ? 'Enter either export and/or import lanes.'
                              : null,
                ),
              ),
              TableCell(
                verticalAlignment: TableCellVerticalAlignment.top,
                child: TextFormField(
                  initialValue:
                      widget.isEdit
                          ? widget
                              .preplanDetails[0]
                              .requirementDetails
                              .importLanes
                              .toString()
                          : "",
                  inputFormatters: [UpperCaseTextFormatter()],
                  textCapitalization: TextCapitalization.characters,
                  style: isMobile ? kSmallestTextStyle : kButtonTextStyle,
                  keyboardType: TextInputType.number,
                  decoration: userInputDecoration.copyWith(
                    labelText: 'Import Lanes',
                    errorStyle: TextStyle(color: kColorError),
                  ),
                  onChanged:
                      (value) => setState(() {
                        appData.myImportLanesSelection = int.parse(value);
                      }),
                  validator:
                      (val) =>
                          val!.isEmpty && appData.myExportLanesSelection == 0
                              ? 'Enter either export and/or import lanes.'
                              : null,
                ),
              ),
            ],
          ),
          TableRow(
            children: <Widget>[
              TableCell(
                verticalAlignment: TableCellVerticalAlignment.top,
                child: TextFormField(
                  initialValue:
                      widget.isEdit
                          ? widget
                              .preplanDetails[0]
                              .requirementDetails
                              .reverseStowTime
                              .toString()
                          : "",
                  inputFormatters: [UpperCaseTextFormatter()],
                  textCapitalization: TextCapitalization.characters,
                  style: isMobile ? kSmallestTextStyle : kButtonTextStyle,
                  keyboardType: TextInputType.number,
                  decoration: userInputDecoration.copyWith(
                    labelText: 'Reverse Stow Time',
                    hintText: 'enter in minutes',
                    alignLabelWithHint: true,
                  ),
                  onChanged:
                      (value) => setState(() {
                        appData.myReverseStowTimeSelection = int.parse(value);
                      }),
                ),
              ),
              TableCell(
                verticalAlignment: TableCellVerticalAlignment.top,
                child: TextFormField(
                  initialValue:
                      widget.isEdit
                          ? widget
                              .preplanDetails[0]
                              .requirementDetails
                              .secureMainDeck
                              .toString()
                          : "",
                  inputFormatters: [UpperCaseTextFormatter()],
                  textCapitalization: TextCapitalization.characters,
                  style: isMobile ? kSmallestTextStyle : kButtonTextStyle,
                  keyboardType: TextInputType.number,
                  decoration: userInputDecoration.copyWith(
                    labelText: 'Secure Main Deck',
                    hintText: 'enter in minutes',
                    alignLabelWithHint: true,
                    errorStyle: TextStyle(color: kColorError),
                  ),
                  onChanged:
                      (value) => setState(() {
                        appData.mySecureMainDeckSelection = int.parse(value);
                      }),
                  validator:
                      (val) =>
                          val!.isEmpty ? 'Secure Main Deck required.' : null,
                ),
              ),
            ],
          ),
          TableRow(
            children: <Widget>[
              TableCell(
                verticalAlignment: TableCellVerticalAlignment.top,
                child: DropdownButtonFormField<String>(
                  value:
                      widget.isEdit
                          ? widget.preplanDetails[0].requirementDetails.sideRamp
                          : appData.mySideRampSelection,
                  hint: Text(
                    'Tap to specify side ramp',
                    style: kLabelTextStyle,
                  ),
                  focusColor: kColorText,
                  dropdownColor: kColorText,
                  style: isMobile ? kSmallestTextStyle : kLabelTextStyle,
                  validator:
                      (value) => value == null ? 'Side ramp is required' : null,
                  iconSize: 24,
                  iconEnabledColor: kColorBar,
                  iconDisabledColor: kColorNavIcon,
                  items:
                      ['Yes', 'No'].map<DropdownMenuItem<String>>((item) {
                        return DropdownMenuItem<String>(
                          value: item,
                          child: Text(item),
                        );
                      }).toList(),
                  onChanged: (String? newValue) {
                    if (!mounted) return;
                    setState(() {
                      appData.mySideRampSelection = newValue!;
                    });
                  },
                  decoration: InputDecoration(
                    hintText: "Tap to select side ramp",
                    hintStyle: isMobile ? kSmallestTextStyle : kLabelTextStyle,
                    filled: true,
                    fillColor: kColorNavIcon.withValues(alpha: 0.4),
                    focusColor: kColorForeground,
                    floatingLabelBehavior: FloatingLabelBehavior.never,
                    prefixIcon: const Icon(
                      Icons.category,
                      color: kColorForeground,
                    ),
                  ),
                ),
              ),
              TableCell(
                verticalAlignment: TableCellVerticalAlignment.top,
                child: TextFormField(
                  initialValue:
                      widget.isEdit
                          ? widget
                              .preplanDetails[0]
                              .requirementDetails
                              .bunkerTime
                              .toString()
                          : "",
                  inputFormatters: [UpperCaseTextFormatter()],
                  textCapitalization: TextCapitalization.characters,
                  style: isMobile ? kSmallestTextStyle : kButtonTextStyle,
                  keyboardType: TextInputType.number,
                  decoration: userInputDecoration.copyWith(
                    labelText: 'Bunker Time',
                    hintText: "enter in minutes",
                    errorStyle: TextStyle(color: Colors.red),
                  ),
                  onChanged:
                      (value) => setState(() {
                        appData.myBunkerTimeSelection = int.parse(value);
                      }),
                  validator: (val) => val!.isEmpty ? 'Value required.' : null,
                ),
              ),
            ],
          ),

          TableRow(
            children: <Widget>[
              TableCell(
                verticalAlignment: TableCellVerticalAlignment.top,
                child: CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  controlAffinity: ListTileControlAffinity.leading,
                  title: Text(
                    'PARALLEL ACTIVITIES (HEAVIES)',
                    style: isMobile ? kSmallestTextStyle : kLabelTextStyle,
                  ),
                  value:
                      /* widget.isEdit
                          ? widget
                              .preplanDetails[0]
                              .requirementDetails
                              .parallelHeavies
                          :*/
                      appData.checkboxHeavies,
                  activeColor: kColorSuccess,
                  onChanged: (value) async {
                    appData.myImportRubberHeaviesSelection == 0 &&
                            appData.myExportRubberHeaviesSelection == 0 &&
                            appData.myImportUsedHeaviesSelection == 0
                        ? await DialogService(
                          button: 'No volumes declared for heavies cargo...',
                          origin: "Error",
                        ).confirmError(context: context)
                        : setState(() {
                          appData.checkboxHeavies = !appData.checkboxHeavies;
                        });
                  },
                ),
              ),
              TableCell(
                verticalAlignment: TableCellVerticalAlignment.top,
                child: CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  controlAffinity: ListTileControlAffinity.leading,
                  title: Text(
                    'PARALLEL ACTIVITIES (MAFI)',
                    style: isMobile ? kSmallestTextStyle : kLabelTextStyle,
                  ),
                  value:
                      /*widget.isEdit
                          ? widget
                              .preplanDetails[0]
                              .requirementDetails
                              .parallelHeavies
                          :*/
                      appData.checkboxMafi,
                  activeColor: kColorSuccess,
                  onChanged: (value) async {
                    appData.myImportMafiWithCargoSelection == 0 &&
                            appData.myExportMafiWithCargoSelection == 0
                        ? await DialogService(
                          button: 'No volumes declared for mafi cargo...',
                          origin: "Error",
                        ).confirmError(context: context)
                        : setState(() {
                          appData.checkboxMafi = !appData.checkboxMafi;
                        });
                  },
                ),
              ),
            ],
          ),
          TableRow(
            children: <Widget>[
              TableCell(
                verticalAlignment: TableCellVerticalAlignment.top,
                child: CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  controlAffinity: ListTileControlAffinity.leading,
                  title: Text(
                    'PARALLEL ACTIVITIES (STATICS)',
                    style: isMobile ? kSmallestTextStyle : kLabelTextStyle,
                  ),
                  value:
                      /*widget.isEdit
                          ? widget
                              .preplanDetails[0]
                              .requirementDetails
                              .parallelStatics
                          :*/
                      appData.checkboxStatics,
                  activeColor: kColorSuccess,
                  onChanged: (value) async {
                    appData.myImportStaticsNonMafiSelection == 0 &&
                            appData.myImportUsedStaticsSelection == 0 &&
                            appData.myExportStaticsNonMafiSelection == 0
                        ? await DialogService(
                          button: 'No volumes declared for static cargo...',
                          origin: "Error",
                        ).confirmError(context: context)
                        : setState(() {
                          appData.checkboxStatics = !appData.checkboxStatics;
                        });
                  },
                ),
              ),
              TableCell(
                verticalAlignment: TableCellVerticalAlignment.top,
                child: CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  controlAffinity: ListTileControlAffinity.leading,
                  title: Text(
                    'PARALLEL ACTIVITIES (TRACKS)',
                    style: isMobile ? kSmallestTextStyle : kLabelTextStyle,
                  ),
                  value:
                      /*widget.isEdit
                          ? widget
                              .preplanDetails[0]
                              .requirementDetails
                              .parallelTracks
                          :*/
                      appData.checkboxTracks,
                  activeColor: kColorSuccess,
                  onChanged: (value) async {
                    appData.myImportHeaviesTracksSelection == 0 &&
                            appData.myExportHeaviesTracksSelection == 0
                        ? await DialogService(
                          button: 'No volumes declared for static cargo...',
                          origin: "Error",
                        ).confirmError(context: context)
                        : setState(() {
                          appData.checkboxTracks = !appData.checkboxTracks;
                        });
                  },
                ),
              ),
            ],
          ),

          TableRow(
            children: <Widget>[
              TableCell(
                verticalAlignment: TableCellVerticalAlignment.top,
                child: CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  controlAffinity: ListTileControlAffinity.leading,
                  title: Text(
                    'PARALLEL ACTIVITIES (USED)',
                    style: isMobile ? kSmallestTextStyle : kLabelTextStyle,
                  ),
                  value:
                      /*widget.isEdit
                          ? widget
                              .preplanDetails[0]
                              .requirementDetails
                              .parallelUsed
                          : */
                      appData.checkboxUsed,
                  activeColor: kColorSuccess,
                  onChanged: (value) async {
                    appData.myExportUsedSelection == 0 &&
                            appData.myImportUsedSelection == 0
                        ? await DialogService(
                          button: 'No volumes declared for used cargo...',
                          origin: "Error",
                        ).confirmError(context: context)
                        : setState(() {
                          appData.checkboxUsed = !appData.checkboxUsed;
                        });
                  },
                ),
              ),
              TableCell(
                verticalAlignment: TableCellVerticalAlignment.top,
                child: CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  controlAffinity: ListTileControlAffinity.leading,
                  title: Text(
                    'PARALLEL ACTIVITIES (IMPORT NEW)',
                    style: isMobile ? kSmallestTextStyle : kLabelTextStyle,
                  ),
                  value:
                      /* widget.isEdit
                          ? widget
                              .preplanDetails[0]
                              .requirementDetails
                              .parallelImportNew
                          :*/
                      appData.checkboxNewImports,
                  activeColor: kColorSuccess,
                  onChanged: (value) async {
                    appData.myImportNewSelection == 0
                        ? await DialogService(
                          button: 'No volumes declared for import new cargo...',
                          origin: "Error",
                        ).confirmError(context: context)
                        : setState(() {
                          appData.checkboxNewImports =
                              !appData.checkboxNewImports;
                        });
                  },
                ),
              ),
            ],
          ),

          TableRow(
            children: <Widget>[
              TableCell(
                verticalAlignment: TableCellVerticalAlignment.top,
                child: CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  controlAffinity: ListTileControlAffinity.leading,
                  title: Text(
                    'PARALLEL ACTIVITIES (EXPORT NEW)',
                    style: isMobile ? kSmallestTextStyle : kLabelTextStyle,
                  ),
                  value:
                      /*widget.isEdit
                          ? widget
                              .preplanDetails[0]
                              .requirementDetails
                              .parallelExportNew
                          :*/
                      appData.checkboxNewExports,
                  activeColor: kColorSuccess,
                  onChanged: (value) async {
                    appData.myExportNewSelection == 0
                        ? await DialogService(
                          button: 'No volumes declared for export new cargo...',
                          origin: "Error",
                        ).confirmError(context: context)
                        : setState(() {
                          appData.checkboxNewExports =
                              !appData.checkboxNewExports;
                        });
                  },
                ),
              ),
              TableCell(
                verticalAlignment: TableCellVerticalAlignment.top,
                child: Container(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
