import 'package:customer_portal/constants/styles.dart';
import 'package:customer_portal/main.dart';
import 'package:customer_portal/model/mobiapp.dart';
import 'package:customer_portal/model/singletons_data.dart';
import 'package:customer_portal/shared/upper_case.dart';
import 'package:flutter/material.dart';

class VolumeTab extends StatefulWidget {
  final TabController tabBar;
  final String sector;
  final List<PrePlanModel> preplanDetails;
  final bool isEdit;
  const VolumeTab({
    super.key,
    required this.tabBar,
    required this.sector,
    required this.preplanDetails,
    required this.isEdit,
  });
  @override
  State<VolumeTab> createState() => _VolumeTabState();
}

class _VolumeTabState extends State<VolumeTab>
    with AutomaticKeepAliveClientMixin<VolumeTab> {
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
                          ? widget.preplanDetails[0].volumeDetails.importNew
                              .toString()
                          : "0",
                  inputFormatters: [UpperCaseTextFormatter()],
                  textCapitalization: TextCapitalization.characters,
                  style: isMobile ? kSmallestTextStyle : kButtonTextStyle,
                  keyboardType: TextInputType.number,
                  decoration: userInputDecoration.copyWith(
                    labelText: 'Import New',
                    alignLabelWithHint: true,
                    errorStyle: TextStyle(color: kColorError),
                  ),
                  onChanged:
                      (value) => setState(() {
                        appData.myImportNewSelection = int.parse(value);
                      }),
                  validator:
                      (val) => val!.isEmpty ? 'Import new required.' : null,
                ),
              ),
              TableCell(
                verticalAlignment: TableCellVerticalAlignment.top,
                child: TextFormField(
                  initialValue:
                      widget.isEdit
                          ? widget.preplanDetails[0].volumeDetails.exportNew
                              .toString()
                          : "0",
                  inputFormatters: [UpperCaseTextFormatter()],
                  textCapitalization: TextCapitalization.characters,
                  style: isMobile ? kSmallestTextStyle : kButtonTextStyle,
                  keyboardType: TextInputType.number,
                  decoration: userInputDecoration.copyWith(
                    alignLabelWithHint: true,
                    labelText: 'Export New',
                    errorStyle: TextStyle(color: kColorError),
                  ),
                  onChanged:
                      (value) => setState(() {
                        appData.myExportNewSelection = int.parse(value);
                      }),
                  validator:
                      (val) => val!.isEmpty ? 'Export new required.' : null,
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
                              .volumeDetails
                              .importRubberHeavies
                              .toString()
                          : "0",
                  inputFormatters: [UpperCaseTextFormatter()],
                  textCapitalization: TextCapitalization.characters,
                  style: isMobile ? kSmallestTextStyle : kButtonTextStyle,
                  keyboardType: TextInputType.number,
                  decoration: userInputDecoration.copyWith(
                    labelText: 'Import Rubber Heavies',
                    errorStyle: TextStyle(color: kColorError),
                  ),
                  onChanged:
                      (value) => setState(() {
                        appData.myImportRubberHeaviesSelection = int.parse(
                          value,
                        );
                      }),
                  validator:
                      (val) =>
                          val!.isEmpty
                              ? 'Import rubber heavies required.'
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
                              .volumeDetails
                              .exportRubberHeavies
                              .toString()
                          : "0",
                  inputFormatters: [UpperCaseTextFormatter()],
                  textCapitalization: TextCapitalization.characters,
                  style: isMobile ? kSmallestTextStyle : kButtonTextStyle,
                  keyboardType: TextInputType.number,
                  decoration: userInputDecoration.copyWith(
                    labelText: 'Export Rubber Heavies',
                    errorStyle: TextStyle(color: kColorError),
                  ),
                  onChanged:
                      (value) => setState(() {
                        appData.myExportRubberHeaviesSelection = int.parse(
                          value,
                        );
                      }),
                  validator:
                      (val) =>
                          val!.isEmpty
                              ? 'Export rubber heavies required.'
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
                              .volumeDetails
                              .importUsedHeavies
                              .toString()
                          : "0",
                  inputFormatters: [UpperCaseTextFormatter()],
                  textCapitalization: TextCapitalization.characters,
                  style: isMobile ? kSmallestTextStyle : kButtonTextStyle,
                  keyboardType: TextInputType.number,
                  decoration: userInputDecoration.copyWith(
                    labelText: 'Import Used Heavies',
                    errorStyle: TextStyle(color: kColorError),
                  ),
                  onChanged:
                      (value) => setState(() {
                        appData.myImportUsedHeaviesSelection = int.parse(value);
                      }),
                  validator:
                      (val) =>
                          val!.isEmpty ? 'Import used heavies required.' : null,
                ),
              ),
              TableCell(
                verticalAlignment: TableCellVerticalAlignment.top,
                child: Container(),
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
                              .volumeDetails
                              .importStaticsNonMafi
                              .toString()
                          : "0",
                  inputFormatters: [UpperCaseTextFormatter()],
                  textCapitalization: TextCapitalization.characters,
                  style: isMobile ? kSmallestTextStyle : kButtonTextStyle,
                  keyboardType: TextInputType.number,
                  decoration: userInputDecoration.copyWith(
                    labelText: 'Import Statics (non-mafi)',
                    errorStyle: TextStyle(color: kColorError),
                  ),
                  onChanged:
                      (value) => setState(() {
                        appData.myImportStaticsNonMafiSelection = int.parse(
                          value,
                        );
                      }),
                  validator: (val) => val!.isEmpty ? 'Value required.' : null,
                ),
              ),
              TableCell(
                verticalAlignment: TableCellVerticalAlignment.top,
                child: TextFormField(
                  initialValue:
                      widget.isEdit
                          ? widget
                              .preplanDetails[0]
                              .volumeDetails
                              .exportStaticsNonMafi
                              .toString()
                          : "0",
                  inputFormatters: [UpperCaseTextFormatter()],
                  textCapitalization: TextCapitalization.characters,
                  style: isMobile ? kSmallestTextStyle : kButtonTextStyle,
                  keyboardType: TextInputType.number,
                  decoration: userInputDecoration.copyWith(
                    labelText: 'Export Statics (non-mafi)',
                    errorStyle: TextStyle(color: kColorError),
                  ),
                  onChanged:
                      (value) => setState(() {
                        appData.myExportStaticsNonMafiSelection = int.parse(
                          value,
                        );
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
                child: TextFormField(
                  initialValue:
                      widget.isEdit
                          ? widget
                              .preplanDetails[0]
                              .volumeDetails
                              .importUsedStatics
                              .toString()
                          : "0",
                  inputFormatters: [UpperCaseTextFormatter()],
                  textCapitalization: TextCapitalization.characters,
                  style: isMobile ? kSmallestTextStyle : kButtonTextStyle,
                  keyboardType: TextInputType.number,
                  decoration: userInputDecoration.copyWith(
                    labelText: 'Import Used Statics',
                    errorStyle: TextStyle(color: kColorError),
                  ),
                  onChanged:
                      (value) => setState(() {
                        appData.myImportUsedStaticsSelection = int.parse(value);
                      }),
                  validator:
                      (val) =>
                          val!.isEmpty ? 'Import used statics required.' : null,
                ),
              ),
              TableCell(
                verticalAlignment: TableCellVerticalAlignment.top,
                child: Container(),
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
                              .volumeDetails
                              .importMafiWithCargo
                              .toString()
                          : "0",
                  inputFormatters: [UpperCaseTextFormatter()],
                  textCapitalization: TextCapitalization.characters,
                  style: isMobile ? kSmallestTextStyle : kButtonTextStyle,
                  keyboardType: TextInputType.number,
                  decoration: userInputDecoration.copyWith(
                    labelText: '# of IMPORT MAFIs with Cargo',
                    errorStyle: TextStyle(color: kColorError),
                  ),
                  onChanged:
                      (value) => setState(() {
                        appData.myImportMafiWithCargoSelection = int.parse(
                          value,
                        );
                      }),
                  validator: (val) => val!.isEmpty ? 'Value required.' : null,
                ),
              ),
              TableCell(
                verticalAlignment: TableCellVerticalAlignment.top,
                child: TextFormField(
                  initialValue:
                      widget.isEdit
                          ? widget
                              .preplanDetails[0]
                              .volumeDetails
                              .exportMafiWithCargo
                              .toString()
                          : "0",
                  inputFormatters: [UpperCaseTextFormatter()],
                  textCapitalization: TextCapitalization.characters,
                  style: isMobile ? kSmallestTextStyle : kButtonTextStyle,
                  keyboardType: TextInputType.number,
                  decoration: userInputDecoration.copyWith(
                    labelText: '# of EXPORT MAFIs with Cargo',
                    errorStyle: TextStyle(color: kColorError),
                  ),
                  onChanged:
                      (value) => setState(() {
                        appData.myExportMafiWithCargoSelection = int.parse(
                          value,
                        );
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
                child: TextFormField(
                  initialValue:
                      widget.isEdit
                          ? widget
                              .preplanDetails[0]
                              .volumeDetails
                              .importStaticsMafi
                              .toString()
                          : "0",
                  inputFormatters: [UpperCaseTextFormatter()],
                  textCapitalization: TextCapitalization.characters,
                  style: isMobile ? kSmallestTextStyle : kButtonTextStyle,
                  keyboardType: TextInputType.number,
                  decoration: userInputDecoration.copyWith(
                    labelText: '# of IMPORT STATICS on MAFI',
                    errorStyle: TextStyle(color: kColorError),
                  ),
                  onChanged:
                      (value) => setState(() {
                        appData.myImportStaticsMafiSelection = int.parse(value);
                      }),
                  validator: (val) => val!.isEmpty ? 'Value required.' : null,
                ),
              ),
              TableCell(
                verticalAlignment: TableCellVerticalAlignment.top,
                child: TextFormField(
                  initialValue:
                      widget.isEdit
                          ? widget
                              .preplanDetails[0]
                              .volumeDetails
                              .exportStaticsMafi
                              .toString()
                          : "0",
                  inputFormatters: [UpperCaseTextFormatter()],
                  textCapitalization: TextCapitalization.characters,
                  style: isMobile ? kSmallestTextStyle : kButtonTextStyle,
                  keyboardType: TextInputType.number,
                  decoration: userInputDecoration.copyWith(
                    labelText: '# of EXPORT STATICS on MAFI',
                    errorStyle: TextStyle(color: kColorError),
                  ),
                  onChanged:
                      (value) => setState(() {
                        appData.myExportStaticsMafiSelection = int.parse(value);
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
                child: TextFormField(
                  initialValue:
                      widget.isEdit
                          ? widget.preplanDetails[0].volumeDetails.importUsed
                              .toString()
                          : "0",
                  inputFormatters: [UpperCaseTextFormatter()],
                  textCapitalization: TextCapitalization.characters,
                  style: isMobile ? kSmallestTextStyle : kButtonTextStyle,
                  keyboardType: TextInputType.number,
                  decoration: userInputDecoration.copyWith(
                    labelText: 'Import Used',
                    errorStyle: TextStyle(color: kColorError),
                  ),
                  onChanged:
                      (value) => setState(() {
                        appData.myImportUsedSelection = int.parse(value);
                      }),
                  validator:
                      (val) => val!.isEmpty ? 'Import used required.' : null,
                ),
              ),
              TableCell(
                verticalAlignment: TableCellVerticalAlignment.top,
                child: TextFormField(
                  initialValue:
                      widget.isEdit
                          ? widget.preplanDetails[0].volumeDetails.exportUsed
                              .toString()
                          : "0",
                  inputFormatters: [UpperCaseTextFormatter()],
                  textCapitalization: TextCapitalization.characters,
                  style: isMobile ? kSmallestTextStyle : kButtonTextStyle,
                  keyboardType: TextInputType.number,
                  decoration: userInputDecoration.copyWith(
                    labelText: 'Export Used',
                    errorStyle: TextStyle(color: kColorError),
                  ),
                  onChanged:
                      (value) => setState(() {
                        appData.myExportUsedSelection = int.parse(value);
                      }),
                  validator:
                      (val) => val!.isEmpty ? 'Export used required.' : null,
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
                              .volumeDetails
                              .importHeaviesTracks
                              .toString()
                          : "0",
                  inputFormatters: [UpperCaseTextFormatter()],
                  textCapitalization: TextCapitalization.characters,
                  style: isMobile ? kSmallestTextStyle : kButtonTextStyle,
                  keyboardType: TextInputType.number,
                  decoration: userInputDecoration.copyWith(
                    labelText: 'Import Heavies Tracks',
                    errorStyle: TextStyle(color: kColorError),
                  ),
                  onChanged:
                      (value) => setState(() {
                        appData.myImportHeaviesTracksSelection = int.parse(
                          value,
                        );
                      }),
                  validator:
                      (val) =>
                          val!.isEmpty
                              ? 'Import heavies tracks required.'
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
                              .volumeDetails
                              .exportHeaviesTracks
                              .toString()
                          : "0",
                  inputFormatters: [UpperCaseTextFormatter()],
                  textCapitalization: TextCapitalization.characters,
                  style: isMobile ? kSmallestTextStyle : kButtonTextStyle,
                  keyboardType: TextInputType.number,
                  decoration: userInputDecoration.copyWith(
                    labelText: 'Export Heavies Tracks',
                    errorStyle: TextStyle(color: kColorError),
                  ),
                  onChanged:
                      (value) => setState(() {
                        appData.myExportHeaviesTracksSelection = int.parse(
                          value,
                        );
                      }),
                  validator:
                      (val) =>
                          val!.isEmpty
                              ? 'Export heavies tracks required.'
                              : null,
                ),
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
