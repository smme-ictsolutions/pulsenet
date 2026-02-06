import 'package:cached_network_image/cached_network_image.dart';
import 'package:customer_portal/constants/styles.dart';
import 'package:customer_portal/database/database_service.dart';
import 'package:customer_portal/model/mobiapp.dart';
import 'package:customer_portal/model/singletons_data.dart';
import 'package:customer_portal/model/user.dart';
import 'package:customer_portal/screens/home.dart';
import 'package:flutter/material.dart';
import 'package:multi_select_flutter/dialog/multi_select_dialog_field.dart';
import 'package:multi_select_flutter/util/multi_select_item.dart';

class SettingsForm extends StatefulWidget {
  const SettingsForm({
    super.key,
    required this.subscribeData,
    required this.imageData,
    required this.sector,
  });
  final UserSubscribeData subscribeData;
  final List<ImageData> imageData;
  final String sector;

  @override
  State<SettingsForm> createState() => _SettingsFormState();
}

class _SettingsFormState extends State<SettingsForm> {
  final _formKey = GlobalKey<FormState>();
  final _key = GlobalKey<ScaffoldState>();
  final GlobalKey<FormFieldState> _multiPortSelectKey =
          GlobalKey<FormFieldState>(),
      _multiSectorSelectKey = GlobalKey<FormFieldState>(),
      _multiModulesSelectKey = GlobalKey<FormFieldState>();
  bool loading = false, tokenRfreshed = false;
  late String nickName;
  final TextEditingController _profile = TextEditingController();
  var _myStakeholderSelection = "";
  List<String> _sectorList = [],
      _myPortSelection = [],
      _mySectorSelection = [],
      _myModulesSelection = [];
  List<LookUpData> _stakeholderList = [], _portList = [];
  List<ModuleData> _modulesList = [];

  void getLookups() async {
    _sectorList = appData.sectorList;
    _stakeholderList =
        appData.stakeholderList
            .where(
              (element) =>
                  element.sector == widget.sector ||
                  element.sector == "spotlight",
            )
            .toList();
    _portList =
        appData.portList
            .where((element) => element.sector == widget.sector)
            .toList();
    _modulesList =
        appData.modulesList
            .where(
              (element) =>
                  element.terminal == widget.subscribeData.port!.first ||
                  element.terminal == 'All Terminals',
            )
            .toList();
    //add filesystem docuemnts if present in sector
    _mySectorSelection.contains('documents')
        ? _modulesList.addAll(
          appData.modulesList.where(
            (element) => element.fileSystem == 'documents',
          ),
        )
        : null;
    if (!mounted) return;
    setState(() {});
  }

  @override
  void initState() {
    nickName = widget.subscribeData.username!;
    _profile.text = widget.subscribeData.username!;
    _mySectorSelection = widget.subscribeData.sector!;
    _myStakeholderSelection = widget.subscribeData.stakeholder!;
    _myPortSelection = widget.subscribeData.port!;
    _myModulesSelection = widget.subscribeData.modules!;
    getLookups();
    super.initState();
  }

  @override
  void dispose() {
    _profile.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return loading
        ? CircularProgressIndicator(color: kColorBar)
        : SizedBox(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          child: Scaffold(
            backgroundColor: kColorNavIcon,
            key: _key,
            resizeToAvoidBottomInset: false,
            body: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Expanded(
                          child: CachedNetworkImage(
                            errorWidget:
                                (context, url, error) =>
                                    const Icon(Icons.error),
                            imageUrl:
                                widget.imageData
                                    .where(
                                      (element) => element.title == 'TPTLogo',
                                    )
                                    .first
                                    .url,
                            imageBuilder:
                                (context, imageProvider) => Container(
                                  width: 100,
                                  height: 100,
                                  decoration: BoxDecoration(
                                    image: DecorationImage(
                                      image: imageProvider,
                                      fit: BoxFit.contain,
                                      alignment: Alignment.topRight,
                                    ),
                                  ),
                                ),
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: OrientationBuilder(
                        builder: (context, orientation) {
                          return Form(
                            key: _formKey,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: SizedBox(
                                height:
                                    MediaQuery.of(context).size.height * .65,
                                child: ListView(
                                  shrinkWrap: true,
                                  children: <Widget>[
                                    const SizedBox(height: 5),
                                    TextFormField(
                                      controller: _profile,
                                      style: kButtonTextStyle,
                                      keyboardType: TextInputType.name,
                                      decoration: userInputDecoration.copyWith(
                                        hintText: 'Enter nickname',
                                      ),
                                      validator:
                                          (val) =>
                                              val!.isEmpty
                                                  ? 'Username is required'
                                                  : null,
                                      onFieldSubmitted: (val) async {
                                        if (!mounted) return;
                                        setState(() {
                                          nickName = val;
                                        });
                                      },
                                      onChanged:
                                          (value) => {
                                            setState(() {
                                              nickName = value;
                                            }),
                                          },
                                    ),
                                    const SizedBox(height: 5),
                                    _sectorList.isNotEmpty
                                        ? Padding(
                                          padding: const EdgeInsets.only(
                                            top: 8.0,
                                          ),
                                          child:
                                              _sectorList.isNotEmpty
                                                  ? MultiSelectDialogField(
                                                    initialValue:
                                                        _mySectorSelection
                                                                .isEmpty
                                                            ? widget
                                                                .subscribeData
                                                                .sector!
                                                            : _mySectorSelection,
                                                    key: _multiSectorSelectKey,
                                                    validator: (values) {
                                                      if (values == null ||
                                                          values.isEmpty) {
                                                        return "Sector is required";
                                                      }
                                                      return null;
                                                    },
                                                    items:
                                                        _sectorList
                                                            .map(
                                                              (sector) =>
                                                                  MultiSelectItem<
                                                                    String
                                                                  >(
                                                                    sector,
                                                                    sector,
                                                                  ),
                                                            )
                                                            .toList(),
                                                    selectedColor:
                                                        kColorSuccess,
                                                    decoration: BoxDecoration(
                                                      color: kColorText
                                                          .withValues(
                                                            alpha: .5,
                                                          ),
                                                      borderRadius:
                                                          const BorderRadius.only(
                                                            topRight:
                                                                Radius.circular(
                                                                  5,
                                                                ),
                                                            topLeft:
                                                                Radius.circular(
                                                                  5,
                                                                ),
                                                          ),
                                                    ),
                                                    buttonIcon: const Icon(
                                                      Icons
                                                          .arrow_drop_down_outlined,
                                                      color: kColorBar,
                                                    ),
                                                    buttonText: const Text.rich(
                                                      TextSpan(
                                                        children: [
                                                          WidgetSpan(
                                                            child: Icon(
                                                              Icons.category,
                                                              color:
                                                                  kColorForeground,
                                                            ),
                                                          ),
                                                          TextSpan(
                                                            text:
                                                                'Tap to select default sectors',
                                                            style:
                                                                kLabelTextStyle,
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    onConfirm: (results) {
                                                      results.isNotEmpty
                                                          ? _multiSectorSelectKey
                                                              .currentState!
                                                              .validate()
                                                          : null;
                                                      if (!mounted) return;
                                                      setState(() {
                                                        _mySectorSelection =
                                                            results;
                                                      });
                                                    },
                                                  )
                                                  : Container(),
                                        )
                                        : Container(),
                                    _stakeholderList.any(
                                          (map) =>
                                              map.name ==
                                              _myStakeholderSelection,
                                        )
                                        ? Padding(
                                          padding: const EdgeInsets.only(
                                            top: 8.0,
                                          ),
                                          child:
                                              _stakeholderList.isNotEmpty
                                                  ? DropdownButtonFormField<
                                                    String
                                                  >(
                                                    hint: Text(
                                                      'Tap to select stakeholder',
                                                      style: kLabelTextStyle,
                                                    ),
                                                    focusColor: kColorText,
                                                    dropdownColor: kColorText,
                                                    value:
                                                        _myStakeholderSelection,
                                                    style: kLabelTextStyle,
                                                    validator:
                                                        (value) =>
                                                            value == null
                                                                ? 'Stakeholder is required'
                                                                : null,
                                                    iconSize: 24,
                                                    iconEnabledColor: kColorBar,
                                                    iconDisabledColor:
                                                        kColorNavIcon,
                                                    items:
                                                        _stakeholderList.map<
                                                          DropdownMenuItem<
                                                            String
                                                          >
                                                        >((item) {
                                                          return DropdownMenuItem<
                                                            String
                                                          >(
                                                            value: item.name,
                                                            child: Text(
                                                              item.name,
                                                            ),
                                                          );
                                                        }).toList(),
                                                    onChanged: (
                                                      String? newValue,
                                                    ) {
                                                      if (!mounted) return;
                                                      setState(() {
                                                        _myStakeholderSelection =
                                                            newValue!;
                                                      });
                                                    },
                                                    decoration: InputDecoration(
                                                      hintText:
                                                          "Tap to select stakeholder",
                                                      hintStyle:
                                                          kLabelTextStyle,
                                                      filled: true,
                                                      fillColor: kColorNavIcon
                                                          .withValues(
                                                            alpha: 0.4,
                                                          ),
                                                      focusColor:
                                                          kColorForeground,
                                                      floatingLabelBehavior:
                                                          FloatingLabelBehavior
                                                              .never,
                                                      prefixIcon: const Icon(
                                                        Icons.category,
                                                        color: kColorForeground,
                                                      ),
                                                    ),
                                                  )
                                                  : Container(),
                                        )
                                        : Container(),
                                    Padding(
                                      padding: const EdgeInsets.only(top: 8.0),
                                      child:
                                          _portList.isNotEmpty
                                              ? MultiSelectDialogField(
                                                initialValue:
                                                    _myPortSelection.isEmpty
                                                        ? widget
                                                            .subscribeData
                                                            .port!
                                                        : _myPortSelection,
                                                key: _multiPortSelectKey,
                                                validator: (values) {
                                                  if (values == null ||
                                                      values.isEmpty) {
                                                    return "Port is required";
                                                  }
                                                  return null;
                                                },
                                                items:
                                                    _portList
                                                        .map(
                                                          (port) =>
                                                              MultiSelectItem<
                                                                String
                                                              >(
                                                                port.name,
                                                                port.name,
                                                              ),
                                                        )
                                                        .toList(),
                                                selectedColor: kColorSuccess,
                                                decoration: BoxDecoration(
                                                  color: kColorText.withValues(
                                                    alpha: .5,
                                                  ),
                                                  borderRadius:
                                                      const BorderRadius.only(
                                                        topRight:
                                                            Radius.circular(5),
                                                        topLeft:
                                                            Radius.circular(5),
                                                      ),
                                                ),
                                                buttonIcon: const Icon(
                                                  Icons
                                                      .arrow_drop_down_outlined,
                                                  color: kColorBar,
                                                ),
                                                buttonText: const Text.rich(
                                                  TextSpan(
                                                    children: [
                                                      WidgetSpan(
                                                        child: Icon(
                                                          Icons.category,
                                                          color:
                                                              kColorForeground,
                                                        ),
                                                      ),
                                                      TextSpan(
                                                        text:
                                                            'Tap to select default ports',
                                                        style: kLabelTextStyle,
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                onConfirm: (results) {
                                                  results.isNotEmpty
                                                      ? _multiPortSelectKey
                                                          .currentState!
                                                          .validate()
                                                      : null;
                                                  if (!mounted) return;
                                                  setState(() {
                                                    _myPortSelection = results;
                                                  });
                                                },
                                              )
                                              : Container(),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(top: 8.0),
                                      child:
                                          _modulesList.isNotEmpty
                                              ? MultiSelectDialogField(
                                                initialValue:
                                                    _myModulesSelection.isEmpty
                                                        ? widget
                                                            .subscribeData
                                                            .modules!
                                                        : _myModulesSelection,
                                                key: _multiModulesSelectKey,
                                                validator: (values) {
                                                  if (values == null ||
                                                      values.isEmpty) {
                                                    return "Module/s are required";
                                                  }
                                                  return null;
                                                },
                                                items:
                                                    _modulesList
                                                        .map(
                                                          (module) =>
                                                              MultiSelectItem<
                                                                String
                                                              >(
                                                                module.module,
                                                                module.module,
                                                              ),
                                                        )
                                                        .toList(),
                                                selectedColor: kColorSuccess,
                                                decoration: BoxDecoration(
                                                  color: kColorText.withValues(
                                                    alpha: .5,
                                                  ),
                                                  borderRadius:
                                                      const BorderRadius.only(
                                                        topRight:
                                                            Radius.circular(5),
                                                        topLeft:
                                                            Radius.circular(5),
                                                      ),
                                                ),
                                                buttonIcon: const Icon(
                                                  Icons
                                                      .arrow_drop_down_outlined,
                                                  color: kColorBar,
                                                ),
                                                buttonText: const Text.rich(
                                                  TextSpan(
                                                    children: [
                                                      WidgetSpan(
                                                        child: Icon(
                                                          Icons.computer,
                                                          color:
                                                              kColorForeground,
                                                        ),
                                                      ),
                                                      TextSpan(
                                                        text:
                                                            'Tap to select default module/s',
                                                        style: kLabelTextStyle,
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                onConfirm: (results) {
                                                  results.isNotEmpty
                                                      ? _multiModulesSelectKey
                                                          .currentState!
                                                          .validate()
                                                      : null;
                                                  if (!mounted) return;
                                                  setState(() {
                                                    _myModulesSelection =
                                                        results;
                                                  });
                                                },
                                              )
                                              : Container(),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
            floatingActionButton: Padding(
              padding: const EdgeInsets.all(8.0),
              child: FloatingActionButton(
                heroTag: 'btn4',
                onPressed: () async {
                  if (_formKey.currentState!.validate() &&
                      _multiSectorSelectKey.currentState!.validate() &&
                      _multiPortSelectKey.currentState!.validate()) {
                    if (!mounted) return;
                    setState(() {
                      loading = true;
                    });
                    await DatabaseService(null)
                        .updateUserData(
                          nickName,
                          _myStakeholderSelection,
                          _myPortSelection,
                          _mySectorSelection,
                          _myModulesSelection,
                        )
                        .then((value) async {
                          if (!context.mounted) return;
                          Navigator.pop(context);
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => const Home()),
                          );
                        });
                    if (!mounted) return;
                    setState(() {
                      loading = false;
                    });
                  }
                },
                backgroundColor: kColorBackground,
                elevation: 12,
                foregroundColor: kColorForeground,
                splashColor: kColorSuccess,
                child: const Icon(Icons.home, size: 50),
              ),
            ),
            floatingActionButtonLocation:
                FloatingActionButtonLocation.centerDocked,
          ),
        );
  }
}
