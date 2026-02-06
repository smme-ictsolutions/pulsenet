import 'package:customer_portal/constants/styles.dart';
import 'package:customer_portal/main.dart';
import 'package:customer_portal/model/mobiapp.dart';
import 'package:customer_portal/model/singletons_data.dart';
import 'package:customer_portal/shared/upper_case.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class VesselTab extends StatefulWidget {
  final TabController tabBar;
  final String sector;
  final List<PrePlanModel> preplanDetails;
  final bool isEdit;
  const VesselTab({
    super.key,
    required this.tabBar,
    required this.sector,
    required this.preplanDetails,
    required this.isEdit,
  });
  @override
  State<VesselTab> createState() => _VesselTabState();
}

class _VesselTabState extends State<VesselTab>
    with AutomaticKeepAliveClientMixin<VesselTab> {
  final TextEditingController _myBerthTypeSelection = TextEditingController(),
      _etaTextEditingController = TextEditingController(),
      _startOperationsTextEditingController = TextEditingController(),
      _vesselNameTextEditingController = TextEditingController(),
      _voyageTextEditingController = TextEditingController(),
      _clearMainDeckTextEditingController = TextEditingController(),
      _breakstowTextEditingController = TextEditingController(),
      _unlashingUnitsTextEditingController = TextEditingController(),
      _panelingTimeTextEditingController = TextEditingController(),
      _directRestowsTextEditingController = TextEditingController(),
      _indirectRestowsTextEditingController = TextEditingController();

  @override
  void initState() {
    _myBerthTypeSelection.text = "BERTH IS GOOD";
    appData.myBerthSuitability = "BERTH IS GOOD";
    appData.myVesselTypeSelection =
        appData.vesselTypeList
            .where((element) => element.sector == widget.sector)
            .first
            .name;
    _vesselNameTextEditingController.text = appData.myVesselNameSelection;
    _voyageTextEditingController.text = appData.myVoyageNumberSelection;
    _etaTextEditingController.text = DateFormat(
      "yyyy-MM-dd HH:mm:ss",
    ).format(appData.myVesselETASelection);
    _startOperationsTextEditingController.text = DateFormat(
      "yyyy-MM-dd HH:mm:ss",
    ).format(appData.myStartOperationsSelection);
    _clearMainDeckTextEditingController.text =
        appData.myClearMainDeckSelection.toString();
    _breakstowTextEditingController.text =
        appData.myBreakStowSelection.toString();
    _unlashingUnitsTextEditingController.text =
        appData.myunlashingUnitsSelection.toString();
    _panelingTimeTextEditingController.text =
        appData.myPanelingTimeSelection.toString();
    _directRestowsTextEditingController.text =
        appData.myDirectRestowTimeSelection.toString();
    _indirectRestowsTextEditingController.text =
        appData.myIndirectRestowTimeSelection.toString();
    super.initState();
  }

  @override
  void didUpdateWidget(VesselTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    Future.delayed(Duration.zero, () {
      if (mounted) {
        if (oldWidget.isEdit != widget.isEdit && widget.isEdit) {
          _myBerthTypeSelection.text =
              widget.preplanDetails[0].vesselDetails.berthSuitability;
          appData.myBerthSuitability =
              widget.preplanDetails[0].vesselDetails.berthSuitability;
          _vesselNameTextEditingController.text =
              widget.preplanDetails[0].vesselDetails.vesselName;
          appData.myVesselNameSelection =
              widget.preplanDetails[0].vesselDetails.vesselName;
          _voyageTextEditingController.text =
              widget.preplanDetails[0].vesselDetails.voyage;
          appData.myVoyageNumberSelection =
              widget.preplanDetails[0].vesselDetails.voyage;
          _etaTextEditingController.text = DateFormat(
            'dd-MM-yyyy HH:mm',
          ).format(widget.preplanDetails[0].vesselDetails.vesselETA);
          appData.myVesselETASelection =
              widget.preplanDetails[0].vesselDetails.vesselETA;
          _startOperationsTextEditingController.text = DateFormat(
            'dd-MM-yyyy HH:mm',
          ).format(widget.preplanDetails[0].vesselDetails.startOperations);
          appData.myStartOperationsSelection =
              widget.preplanDetails[0].vesselDetails.startOperations;
          _clearMainDeckTextEditingController.text =
              widget.preplanDetails[0].preparationDetails.clearMainDeck
                  .toString();
          appData.myClearMainDeckSelection =
              widget.preplanDetails[0].preparationDetails.clearMainDeck;
          _breakstowTextEditingController.text =
              widget.preplanDetails[0].preparationDetails.breakStow.toString();
          appData.myBreakStowSelection =
              widget.preplanDetails[0].preparationDetails.breakStow;
          _unlashingUnitsTextEditingController.text =
              widget.preplanDetails[0].preparationDetails.unlashingUnits
                  .toString();
          appData.myunlashingUnitsSelection =
              widget.preplanDetails[0].preparationDetails.unlashingUnits;
          _panelingTimeTextEditingController.text =
              widget.preplanDetails[0].preparationDetails.panelingTime
                  .toString();
          appData.myPanelingTimeSelection =
              widget.preplanDetails[0].preparationDetails.panelingTime;
          _directRestowsTextEditingController.text =
              widget.preplanDetails[0].preparationDetails.directRestow
                  .toString();
          appData.myDirectRestowTimeSelection =
              widget.preplanDetails[0].preparationDetails.directRestow;
          _indirectRestowsTextEditingController.text =
              widget.preplanDetails[0].preparationDetails.indirectRestow
                  .toString();
          appData.myIndirectRestowTimeSelection =
              widget.preplanDetails[0].preparationDetails.indirectRestow;
          setState(() {});
        }
      }
    });
  }

  @override
  void dispose() {
    _myBerthTypeSelection.dispose();
    _etaTextEditingController.dispose;
    _startOperationsTextEditingController.dispose;
    _vesselNameTextEditingController.dispose();
    _voyageTextEditingController.dispose();
    _clearMainDeckTextEditingController.dispose();
    _breakstowTextEditingController.dispose();
    _unlashingUnitsTextEditingController.dispose();
    _panelingTimeTextEditingController.dispose();
    _directRestowsTextEditingController.dispose();
    _indirectRestowsTextEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          appData.portList
                  .where((element) => element.sector == widget.sector)
                  .isNotEmpty
              ? Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value:
                          widget.preplanDetails.isEmpty
                              ? null
                              : widget.preplanDetails[0].vesselDetails.port,
                      hint: Text(
                        'Tap to select port',
                        style: isMobile ? kSmallestTextStyle : kLabelTextStyle,
                      ),
                      focusColor: kColorText,
                      dropdownColor: kColorText,
                      style: isMobile ? kSmallestTextStyle : kLabelTextStyle,
                      validator:
                          (value) => value == null ? 'Port is required' : null,
                      iconSize:
                          isMobile
                              ? kFontSizeMediumNormal
                              : kFontSizeSuperNormal,
                      iconEnabledColor: kColorBar,
                      iconDisabledColor: kColorNavIcon,
                      items:
                          appData.portList
                              .where(
                                (element) => element.sector == widget.sector,
                              )
                              .map<DropdownMenuItem<String>>((item) {
                                return DropdownMenuItem<String>(
                                  value: item.name,
                                  child: Text(item.name),
                                );
                              })
                              .toList(),
                      onChanged: (String? newValue) {
                        if (!mounted) return;
                        setState(() {
                          appData.myPortSelection = newValue!;
                        });
                      },
                      decoration: InputDecoration(
                        hintText: "Tap to select port",
                        hintStyle:
                            isMobile ? kSmallestTextStyle : kLabelTextStyle,
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
                ],
              )
              : Container(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: TextFormField(
                  controller: _vesselNameTextEditingController,
                  inputFormatters: [UpperCaseTextFormatter()],
                  textCapitalization: TextCapitalization.characters,
                  style: isMobile ? kSmallestTextStyle : kButtonTextStyle,
                  keyboardType: TextInputType.streetAddress,
                  decoration: userInputDecoration.copyWith(
                    hintText: 'Enter vessel name',
                    errorStyle: TextStyle(color: kColorError),
                  ),
                  onChanged:
                      (value) => setState(() {
                        appData.myVesselNameSelection = value;
                      }),
                  validator:
                      (val) => val!.isEmpty ? 'Vessel Name required.' : null,
                ),
              ),
              SizedBox(width: 2),
              Expanded(
                child: TextFormField(
                  controller: _voyageTextEditingController,
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.allow(RegExp("[0-9a-zA-Z ]")),
                  ],
                  textCapitalization: TextCapitalization.characters,
                  style: isMobile ? kSmallestTextStyle : kButtonTextStyle,
                  keyboardType: TextInputType.streetAddress,
                  decoration: userInputDecoration.copyWith(
                    hintText: 'Enter voyage no. (no special characters)',
                    errorStyle: TextStyle(color: kColorError),
                  ),
                  onChanged: (value) async {
                    setState(() {
                      appData.myVoyageNumberSelection = value;
                    });
                  },
                  validator: _validateVoyage,
                ),
              ),
            ],
          ),
          Row(
            children: [
              appData.stakeholderList
                      .where((element) => element.sector == widget.sector)
                      .isNotEmpty
                  ? Expanded(
                    child: DropdownButtonFormField<String>(
                      value:
                          widget.preplanDetails.isEmpty
                              ? null
                              : widget
                                  .preplanDetails[0]
                                  .vesselDetails
                                  .stakeholder,
                      hint: Text(
                        'Tap to select agent',
                        style: isMobile ? kSmallestTextStyle : kLabelTextStyle,
                      ),
                      focusColor: kColorText,
                      dropdownColor: kColorText,
                      style: isMobile ? kSmallestTextStyle : kLabelTextStyle,
                      validator:
                          (value) => value == null ? 'Agent is required' : null,
                      iconSize:
                          isMobile
                              ? kFontSizeMediumNormal
                              : kFontSizeSuperNormal,
                      iconEnabledColor: kColorBar,
                      iconDisabledColor: kColorNavIcon,
                      items:
                          appData.stakeholderList
                              .where(
                                (element) => element.sector == widget.sector,
                              )
                              .map<DropdownMenuItem<String>>((item) {
                                return DropdownMenuItem<String>(
                                  value: item.name,
                                  child: Text(item.name),
                                );
                              })
                              .toList(),
                      onChanged: (String? newValue) {
                        if (!mounted) return;
                        setState(() {
                          appData.myStakeholderSelection = newValue!;
                        });
                      },
                      decoration: InputDecoration(
                        hintText: "Tap to select agent",
                        hintStyle:
                            isMobile ? kSmallestTextStyle : kLabelTextStyle,
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
                  )
                  : Container(),
              SizedBox(width: 2),
              appData.stevedoreList
                      .where((element) => element.sector == widget.sector)
                      .isNotEmpty
                  ? Expanded(
                    child: DropdownButtonFormField<String>(
                      value:
                          widget.preplanDetails.isEmpty
                              ? null
                              : widget
                                  .preplanDetails[0]
                                  .vesselDetails
                                  .stevedore,
                      hint: Text(
                        'Tap to select stevedore',
                        style: isMobile ? kSmallestTextStyle : kLabelTextStyle,
                      ),
                      focusColor: kColorText,
                      dropdownColor: kColorText,
                      style: kLabelTextStyle,
                      validator:
                          (value) =>
                              value == null ? 'Stevedore is required' : null,
                      iconSize:
                          isMobile
                              ? kFontSizeMediumNormal
                              : kFontSizeSuperNormal,
                      iconEnabledColor: kColorBar,
                      iconDisabledColor: kColorNavIcon,
                      items:
                          appData.stevedoreList
                              .where(
                                (element) => element.sector == widget.sector,
                              )
                              .map<DropdownMenuItem<String>>((item) {
                                return DropdownMenuItem<String>(
                                  value: item.name,
                                  child: Text(item.name),
                                );
                              })
                              .toList(),
                      onChanged: (String? newValue) {
                        if (!mounted) return;
                        setState(() {
                          appData.myStevedoreSelection = newValue!;
                        });
                      },
                      decoration: InputDecoration(
                        hintText: "Tap to select stevedore",
                        hintStyle:
                            isMobile ? kSmallestTextStyle : kLabelTextStyle,
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
                  )
                  : Container(),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: TextFormField(
                  controller: _myBerthTypeSelection,
                  maxLines: null,
                  inputFormatters: [UpperCaseTextFormatter()],
                  textCapitalization: TextCapitalization.characters,
                  style: isMobile ? kSmallestTextStyle : kButtonTextStyle,
                  keyboardType: TextInputType.streetAddress,
                  decoration: userInputDecoration.copyWith(
                    hintText: 'Enter berth suitability',
                  ),
                  onChanged:
                      (value) => setState(() {
                        appData.myBerthSuitability = value;
                      }),
                  validator:
                      (val) =>
                          val!.isEmpty ? 'Berth suitability required.' : null,
                ),
              ),
              SizedBox(width: 2),
              appData.berthList
                      .where(
                        (element) =>
                            element.sector == widget.sector &&
                            element.port == appData.myPortSelection,
                      )
                      .isNotEmpty
                  ? Expanded(
                    child: DropdownButtonFormField<String>(
                      value:
                          widget.preplanDetails.isEmpty
                              ? null
                              : widget
                                  .preplanDetails[0]
                                  .vesselDetails
                                  .berthCode,
                      hint: Text(
                        'Tap to select berth',
                        style: isMobile ? kSmallestTextStyle : kLabelTextStyle,
                      ),
                      focusColor: kColorText,
                      dropdownColor: kColorText,
                      style: isMobile ? kSmallestTextStyle : kLabelTextStyle,
                      validator:
                          (value) => value == null ? 'Berth is required' : null,
                      iconSize:
                          isMobile
                              ? kFontSizeMediumNormal
                              : kFontSizeSuperNormal,
                      iconEnabledColor: kColorBar,
                      iconDisabledColor: kColorNavIcon,
                      items:
                          appData.berthList
                              .where(
                                (element) =>
                                    element.sector == widget.sector &&
                                    element.port == appData.myPortSelection,
                              )
                              .map<DropdownMenuItem<String>>((item) {
                                return DropdownMenuItem<String>(
                                  value: item.name,
                                  child: Text(item.name),
                                );
                              })
                              .toList(),
                      onChanged: (String? newValue) {
                        if (!mounted) return;
                        setState(() {
                          appData.myBerthSelection = newValue!;
                        });
                      },
                      decoration: InputDecoration(
                        hintText: "Tap to select berth",
                        hintStyle:
                            isMobile ? kSmallestTextStyle : kLabelTextStyle,
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
                  )
                  : Container(),
            ],
          ),
          Row(
            children: [
              appData.vesselTypeList
                      .where((element) => element.sector == widget.sector)
                      .isNotEmpty
                  ? Expanded(
                    child: DropdownButtonFormField<String>(
                      value:
                          widget.preplanDetails.isEmpty
                              ? appData.vesselTypeList
                                  .where(
                                    (element) =>
                                        element.sector == widget.sector,
                                  )
                                  .first
                                  .name
                              : widget
                                  .preplanDetails[0]
                                  .vesselDetails
                                  .vesselType,
                      hint: Text(
                        'Tap to select vessel type',
                        style: kLabelTextStyle,
                      ),
                      focusColor: kColorText,
                      dropdownColor: kColorText,
                      style: isMobile ? kSmallestTextStyle : kLabelTextStyle,
                      validator:
                          (value) =>
                              value == null ? 'Vessel type is required' : null,
                      iconSize:
                          isMobile
                              ? kFontSizeMediumNormal
                              : kFontSizeSuperNormal,
                      iconEnabledColor: kColorBar,
                      iconDisabledColor: kColorNavIcon,
                      items:
                          appData.vesselTypeList
                              .where(
                                (element) => element.sector == widget.sector,
                              )
                              .map<DropdownMenuItem<String>>((item) {
                                return DropdownMenuItem<String>(
                                  value: item.name,
                                  child: Text(item.name),
                                );
                              })
                              .toList(),
                      onChanged: (String? newValue) {
                        if (!mounted) return;
                        setState(() {
                          appData.myVesselTypeSelection = newValue!;
                        });
                      },
                      decoration: InputDecoration(
                        hintText: "Tap to select vessel type",
                        hintStyle:
                            isMobile ? kSmallestTextStyle : kLabelTextStyle,
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
                  )
                  : Container(),
              SizedBox(width: 2),
              appData.shippingLineList
                      .where((element) => element.sector == widget.sector)
                      .isNotEmpty
                  ? Expanded(
                    child: DropdownButtonFormField<String>(
                      value:
                          widget.preplanDetails.isEmpty
                              ? null
                              : widget
                                  .preplanDetails[0]
                                  .vesselDetails
                                  .shippingLine,
                      hint: Text(
                        'Tap to select shipping line',
                        style: isMobile ? kSmallestTextStyle : kLabelTextStyle,
                      ),
                      focusColor: kColorText,
                      dropdownColor: kColorText,
                      style: isMobile ? kSmallestTextStyle : kLabelTextStyle,
                      validator:
                          (value) =>
                              value == null
                                  ? 'Shipping Line is required'
                                  : null,
                      iconSize:
                          isMobile
                              ? kFontSizeMediumNormal
                              : kFontSizeSuperNormal,
                      iconEnabledColor: kColorBar,
                      iconDisabledColor: kColorNavIcon,
                      items:
                          appData.shippingLineList
                              .where(
                                (element) => element.sector == widget.sector,
                              )
                              .map<DropdownMenuItem<String>>((item) {
                                return DropdownMenuItem<String>(
                                  value: item.name,
                                  child: Text(item.name),
                                );
                              })
                              .toList(),
                      onChanged: (String? newValue) {
                        if (!mounted) return;
                        setState(() {
                          appData.myShippingLineSelection = newValue!;
                        });
                      },
                      decoration: InputDecoration(
                        hintText: "Tap to select shipping line",
                        hintStyle:
                            isMobile ? kSmallestTextStyle : kLabelTextStyle,
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
                  )
                  : Container(),
            ],
          ),
          Divider(color: kColorBar),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _etaTextEditingController,
                  style: isMobile ? kSmallestTextStyle : kButtonTextStyle,
                  readOnly: false,
                  decoration: InputDecoration(
                    errorBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.redAccent,
                        width: 2.0,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: kColorSuccess, width: 2.0),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.black54, width: 2.0),
                    ),

                    labelText: 'ETA',
                    labelStyle: isMobile ? kSmallestTextStyle : kLabelTextStyle,
                    errorStyle: TextStyle(color: kColorError),
                    hintText: "Tap to select vessel eta",
                    hintStyle: isMobile ? kSmallestTextStyle : kLabelTextStyle,
                    filled: true,
                    fillColor: kColorNavIcon.withValues(alpha: 0.4),
                    focusColor: kColorForeground,
                    //floatingLabelBehavior: FloatingLabelBehavior.never,
                    suffixIcon: GestureDetector(
                      onTap:
                          () async => await _showDateTimePicker(
                            context: context,
                          ).then((value) {
                            if (value != null) {
                              _etaTextEditingController.text = DateFormat(
                                'dd-MM-yyyy HH:mm',
                              ).format(value);
                              appData.myVesselETASelection = value;
                            }
                          }),
                      child: const Icon(
                        Icons.calendar_month,
                        color: kColorForeground,
                      ),
                    ),
                  ),
                  onChanged:
                      (value) => setState(() {
                        appData.myVesselETASelection = DateTime.parse(value);
                      }),
                  validator:
                      (val) => val!.isEmpty ? 'Vessel ETA required.' : null,
                ),
              ),
              Expanded(
                child: TextFormField(
                  controller: _startOperationsTextEditingController,
                  style: isMobile ? kSmallestTextStyle : kButtonTextStyle,
                  readOnly: false,
                  decoration: InputDecoration(
                    errorBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.redAccent,
                        width: 2.0,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: kColorSuccess, width: 2.0),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.black54, width: 2.0),
                    ),
                    labelText: 'Start Ops',
                    labelStyle: isMobile ? kSmallestTextStyle : kLabelTextStyle,
                    errorStyle: TextStyle(color: kColorError),
                    hintText: "Tap to select vessel starting time",
                    hintStyle: isMobile ? kSmallestTextStyle : kLabelTextStyle,
                    filled: true,
                    fillColor: kColorNavIcon.withValues(alpha: 0.4),
                    focusColor: kColorForeground,
                    //floatingLabelBehavior: FloatingLabelBehavior.never,
                    suffixIcon: GestureDetector(
                      onTap:
                          () async => await _showDateTimePicker(
                            context: context,
                          ).then((value) {
                            if (value != null) {
                              _startOperationsTextEditingController.text =
                                  DateFormat('dd-MM-yyyy HH:mm').format(value);
                              appData.myStartOperationsSelection = value;
                            }
                          }),
                      child: const Icon(
                        Icons.calendar_month,
                        color: kColorForeground,
                      ),
                    ),
                  ),
                  onChanged:
                      (value) => setState(() {
                        appData.myStartOperationsSelection = DateTime.parse(
                          value,
                        );
                      }),
                  validator:
                      (val) =>
                          val!.isEmpty
                              ? 'Vessel starting time required.'
                              : null,
                ),
              ),
            ],
          ),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _clearMainDeckTextEditingController,
                  inputFormatters: [UpperCaseTextFormatter()],
                  textCapitalization: TextCapitalization.characters,
                  style: isMobile ? kSmallestTextStyle : kMarkerTextStyle,
                  keyboardType: TextInputType.number,
                  decoration: userInputDecoration.copyWith(
                    labelText: 'Clear Main Deck(min)',

                    labelStyle:
                        isMobile ? kSmallestTextStyle : kMarkerTextStyle,
                    alignLabelWithHint: true,
                    errorStyle: TextStyle(color: kColorError),
                  ),
                  onChanged:
                      (value) => setState(() {
                        appData.myClearMainDeckSelection = int.parse(value);
                      }),
                  validator:
                      (val) =>
                          val!.isEmpty ? 'Clear main deck required.' : null,
                ),
              ),
              Expanded(
                child: TextFormField(
                  controller: _breakstowTextEditingController,
                  inputFormatters: [UpperCaseTextFormatter()],
                  textCapitalization: TextCapitalization.characters,
                  style: isMobile ? kSmallestTextStyle : kMarkerTextStyle,
                  keyboardType: TextInputType.number,
                  decoration: userInputDecoration.copyWith(
                    labelText: 'Breakstow(min)',

                    labelStyle:
                        isMobile ? kSmallestTextStyle : kMarkerTextStyle,
                    alignLabelWithHint: true,
                    errorStyle: TextStyle(color: kColorError),
                  ),
                  onChanged:
                      (value) => setState(() {
                        appData.myBreakStowSelection = int.parse(value);
                      }),
                  validator:
                      (val) => val!.isEmpty ? 'Breakstow required.' : null,
                ),
              ),
              Expanded(
                child: TextFormField(
                  controller: _unlashingUnitsTextEditingController,
                  inputFormatters: [UpperCaseTextFormatter()],
                  textCapitalization: TextCapitalization.characters,
                  style: isMobile ? kSmallestTextStyle : kMarkerTextStyle,
                  keyboardType: TextInputType.number,
                  decoration: userInputDecoration.copyWith(
                    labelText: 'Unlashing Units(min)',

                    labelStyle:
                        isMobile ? kSmallestTextStyle : kMarkerTextStyle,
                    alignLabelWithHint: true,
                    errorStyle: TextStyle(color: kColorError),
                  ),
                  onChanged:
                      (value) => setState(() {
                        appData.myunlashingUnitsSelection = int.parse(value);
                      }),
                  validator:
                      (val) =>
                          val!.isEmpty ? 'Unlashing units required.' : null,
                ),
              ),
              Expanded(
                child: TextFormField(
                  controller: _panelingTimeTextEditingController,
                  inputFormatters: [UpperCaseTextFormatter()],
                  textCapitalization: TextCapitalization.characters,
                  style: isMobile ? kSmallestTextStyle : kMarkerTextStyle,
                  keyboardType: TextInputType.number,
                  decoration: userInputDecoration.copyWith(
                    labelText: 'Paneling(min)',
                    labelStyle:
                        isMobile ? kSmallestTextStyle : kMarkerTextStyle,
                    alignLabelWithHint: true,
                    errorStyle: TextStyle(color: kColorError),
                  ),
                  onChanged:
                      (value) => setState(() {
                        appData.myPanelingTimeSelection = int.parse(value);
                      }),
                  validator:
                      (val) => val!.isEmpty ? 'Paneling time required.' : null,
                ),
              ),
              Expanded(
                child: TextFormField(
                  controller: _directRestowsTextEditingController,
                  inputFormatters: [UpperCaseTextFormatter()],
                  textCapitalization: TextCapitalization.characters,
                  style: isMobile ? kSmallestTextStyle : kMarkerTextStyle,
                  keyboardType: TextInputType.number,
                  decoration: userInputDecoration.copyWith(
                    labelText: 'Direct Restows(min)',
                    labelStyle:
                        isMobile ? kSmallestTextStyle : kMarkerTextStyle,
                    alignLabelWithHint: true,
                    errorStyle: TextStyle(color: kColorError),
                  ),
                  onChanged:
                      (value) => setState(() {
                        appData.myDirectRestowTimeSelection = int.parse(value);
                      }),
                  validator:
                      (val) =>
                          val!.isEmpty ? 'Direct restow time required.' : null,
                ),
              ),
              Expanded(
                child: TextFormField(
                  controller: _indirectRestowsTextEditingController,
                  inputFormatters: [UpperCaseTextFormatter()],
                  textCapitalization: TextCapitalization.characters,
                  style: isMobile ? kSmallestTextStyle : kMarkerTextStyle,
                  keyboardType: TextInputType.number,
                  decoration: userInputDecoration.copyWith(
                    labelText: 'Indirect Restows(min)',
                    labelStyle:
                        isMobile ? kSmallestTextStyle : kMarkerTextStyle,
                    alignLabelWithHint: true,
                    errorStyle: TextStyle(color: kColorError),
                  ),
                  onChanged:
                      (value) => setState(() {
                        appData.myIndirectRestowTimeSelection = int.parse(
                          value,
                        );
                      }),
                  validator:
                      (val) =>
                          val!.isEmpty
                              ? 'Indirect restow time required.'
                              : null,
                ),
              ),
              SizedBox(
                width: 100,
                child: DropdownButtonFormField<String>(
                  value:
                      widget.preplanDetails.isEmpty
                          ? appData.myPanelingTypeSelection
                          : widget
                              .preplanDetails[0]
                              .preparationDetails
                              .paneling,
                  focusColor: kColorText,
                  dropdownColor: kColorText,
                  style: isMobile ? kSmallestTextStyle : kLabelTextStyle,
                  validator:
                      (value) => value == null ? 'Type is required' : null,

                  iconEnabledColor: kColorBar,
                  iconDisabledColor: kColorNavIcon,
                  items:
                      ["Electronic", "Manual"].map<DropdownMenuItem<String>>((
                        item,
                      ) {
                        return DropdownMenuItem<String>(
                          value: item,
                          child: Text(item, style: kMarkerTextStyle),
                        );
                      }).toList(),
                  onChanged: (String? newValue) {
                    if (!mounted) return;
                    setState(() {
                      appData.myPanelingTypeSelection = newValue!;
                    });
                  },
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: kColorNavIcon.withValues(alpha: 0.4),
                    focusColor: kColorForeground,
                    floatingLabelBehavior: FloatingLabelBehavior.never,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<DateTime?> _showDateTimePicker({required BuildContext context}) async {
    final DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(Duration(days: 365)),
    );

    if (selectedDate == null) return null;

    if (!context.mounted) return selectedDate;

    final TimeOfDay? selectedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(DateTime.now()),
    );

    return selectedTime == null
        ? selectedDate
        : DateTime(
          selectedDate.year,
          selectedDate.month,
          selectedDate.day,
          selectedTime.hour,
          selectedTime.minute,
        );
  }

  String? _validateVoyage(String? voyage) {
    String errorMessage = '';
    // Voyage length is blank
    if (voyage == "") {
      errorMessage += 'Voyage number required.\n';
    }

    // Contains at prohibited special character

    if (!(RegExp(r'[a-zA-Z0-9]').hasMatch(voyage!))) {
      errorMessage += 'Special character is prohibited.\n';
    }
    // If there are no error messages, the password is valid
    if (errorMessage == "") {
      debugPrint('success');
      return null;
    }
    debugPrint('failed');
    return errorMessage;
  }

  @override
  bool get wantKeepAlive => true;
}
