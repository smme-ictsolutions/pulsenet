import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:customer_portal/constants/styles.dart';
import 'package:customer_portal/database/database_service.dart';
import 'package:customer_portal/model/mobiapp.dart';
import 'package:customer_portal/model/singletons_data.dart';
import 'package:customer_portal/model/user.dart';
import 'package:customer_portal/screens/spotlight_queries/complex_queries/complex_results_form.dart';
import 'package:customer_portal/screens/spotlight_queries/complex_queries/tracktrace_input.dart';
import 'package:customer_portal/screens/spotlight_queries/complex_queries/tracktrace_input_buttons.dart';
import 'package:customer_portal/screens/spotlight_queries/complex_queries/upload_input_buttons.dart';
import 'package:customer_portal/services/file_picker.dart';
import 'package:customer_portal/services/mobiapi_service.dart';
import 'package:customer_portal/shared/dialog.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ComplexQueryForm extends StatefulWidget {
  const ComplexQueryForm({
    super.key,
    required this.title,
    required this.mobiAppData,
    required this.sector,
    this.subscribeData,
  });
  final String title, sector;
  final MobiAppData mobiAppData;
  final UserSubscribeData? subscribeData;
  @override
  State<ComplexQueryForm> createState() => _ComplexQueryFormState();
}

class _ComplexQueryFormState extends State<ComplexQueryForm> {
  final _key = GlobalKey<ScaffoldState>();
  final _formQueryInputKey = GlobalKey<FormState>();
  String _queryType = '';
  List<QueryOptionsModel> _queryOptions = [];
  List<FacilityItems> _facilityItems = [];
  String _vnlFacility = "", _selectedQueryOption = "", _fileContent = "";
  bool _queryOptionsError = false, _fetchQueryOptions = false;
  List<String> _vnlUnitIds = [];
  final List<String> _vnlInvalidUnitIds = [], _vnlDuplicateUnitIds = [];
  final TextEditingController _vnlUnitId = TextEditingController();
  FilePickerResult? _pickedFile;
  List<FlexibleQueryData> _flexibleQueryData = [];
  final List<FlexibleQueryData> _vnlValidUnitIds = [];
  late StreamSubscription _subscription;

  void _getQueryOptions(MobiAppData mobiAppData) async {
    late StreamSubscription queryOptionsSubscription;
    setState(() {
      _fetchQueryOptions = true;
    });
    mobiAppData.productionUser == null
        ? null
        : queryOptionsSubscription = MobiApiService()
            .streamQueryOptions(mobiAppData)
            .timeout(
              const Duration(seconds: 30),
              onTimeout: (EventSink<List<QueryOptionsModel>> sink) async {
                debugPrint('Timeout occurred');
                if (!mounted) return;
                await DialogService(
                  button: 'dismiss',
                  origin:
                      'Oops we encountered a technical issue, please restart the app or try again later.',
                ).showSnackBar(context: context);
                sink.add([]);
                queryOptionsSubscription.cancel();
                setState(() {
                  _queryOptionsError = true;
                  _fetchQueryOptions = false;
                });
              },
            )
            .listen((data) {
              try {
                if (data.isNotEmpty) {
                  _queryOptions = data;
                  queryOptionsSubscription.cancel();
                  setState(() {
                    _queryOptionsError = false;
                    _fetchQueryOptions = false;
                  });
                }
              } catch (e) {
                debugPrint('Error in _fetch query options: $e');
                queryOptionsSubscription.cancel();
                setState(() {
                  _queryOptionsError = true;
                  _fetchQueryOptions = false;
                });
              }
            });
  }

  Future<void> _getQueryFacilities() async {
    _facilityItems =
        widget.sector == "container"
            ? /*await MobiApiService().getFacilities(
              widget.mobiAppData,
              widget.sector,
            )*/ appData.facilitiesList
            : widget.sector != "container"
            ? appData.facilitiesList
            : [];
    if (widget.sector != 'container') {
      _vnlUnitId.clear();
    }
  }

  bool _isValidContainerNumber(
    String containerNumber,
    FlexibleQueryData queryData,
  ) {
    //if not unit id return true
    if (queryData.filter != 'PARM_CTT_UNIT_NBR') {
      return true;
    }
    //if already in valid list return true
    if (_vnlValidUnitIds
        .where((element) => element.unitIds.trim() == containerNumber.trim())
        .toList()
        .isNotEmpty) {
      _vnlDuplicateUnitIds.add(containerNumber);

      return true;
    }
    // Normalize and validate the format
    String normalizedNumber = containerNumber.replaceAll(' ', '').toUpperCase();
    if (normalizedNumber.length != 11) {
      return false;
    }

    if (!RegExp(r'^[A-Z]{4}\d{7}$').hasMatch(normalizedNumber)) {
      return false;
    }

    // Perform the check digit calculation
    int sum = 0;
    List<int> weights = [1, 2, 4, 8, 16, 32, 64, 128, 256, 512];

    // Character-to-value mapping, skipping 11, 22, 33
    Map<String, int> letterValues = {
      'A': 10,
      'B': 12,
      'C': 13,
      'D': 14,
      'E': 15,
      'F': 16,
      'G': 17,
      'H': 18,
      'I': 19,
      'J': 20,
      'K': 21,
      'L': 23,
      'M': 24,
      'N': 25,
      'O': 26,
      'P': 27,
      'Q': 28,
      'R': 29,
      'S': 30,
      'T': 31,
      'U': 32,
      'V': 34,
      'W': 35,
      'X': 36,
      'Y': 37,
      'Z': 38,
    };

    // Calculate the weighted sum of the first 10 characters
    for (int i = 0; i < 10; i++) {
      int value;
      String char = normalizedNumber[i];
      if (letterValues.containsKey(char)) {
        value = letterValues[char]!;
      } else {
        value = int.parse(char);
      }
      sum += value * weights[i];
    }

    // Calculate the check digit
    int remainder = sum % 11;
    int checkDigit = (remainder == 10) ? 0 : remainder;
    //add to valid list if valid
    //checkDigit == int.parse(normalizedNumber[10])
    //    ? _vnlValidUnitIds.contains(containerNumber)
    //        ? null
    //       : _vnlValidUnitIds.add(containerNumber)
    //   : null;
    // Compare the calculated check digit with the provided one
    return checkDigit == int.parse(normalizedNumber[10]);
  }

  @override
  void setState(fn) {
    super.setState(fn);
  }

  @override
  void initState() {
    _getQueryFacilities();
    widget.sector == 'container'
        ? _facilityItems = appData.facilitiesList
        : null;
    _vnlUnitId.text = '';
    super.initState();
  }

  @override
  void dispose() {
    _vnlUnitId.dispose();
    _subscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    List<ImageData> imageData = appData.imageData;
    MobiAppData mobiAppData = Provider.of<MobiAppData>(context, listen: false);
    return SizedBox(
      height: MediaQuery.of(context).size.height * .9,
      width: MediaQuery.of(context).size.width,
      child: Scaffold(
        extendBody: true,
        extendBodyBehindAppBar: true,
        backgroundColor: kColorNavIcon,
        key: _key,
        resizeToAvoidBottomInset: false,
        body:
            _queryOptionsError
                ? Text('Error loading query options')
                : Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              widget.title,
                              style: kHeaderLabelTextStyle,
                              textAlign: TextAlign.center,
                            ),
                          ),
                          Expanded(
                            child: CachedNetworkImage(
                              errorWidget:
                                  (context, url, error) =>
                                      const Icon(Icons.error),
                              imageUrl:
                                  imageData
                                      .where(
                                        (element) => element.title == 'TPTLogo',
                                      )
                                      .first
                                      .url,
                              imageBuilder:
                                  (context, imageProvider) => Container(
                                    width: 80,
                                    height: 80,
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
                      //if ( _trackTraceItems.isEmpty || widget.sector == 'documents')
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Flexible(
                            fit: FlexFit.loose,
                            child: DropdownButtonFormField<String>(
                              value: _queryType == '' ? null : _queryType,
                              style: kTextStyle,
                              iconSize: 24,
                              iconEnabledColor: kColorBar,
                              iconDisabledColor: kColorNavIcon,
                              items:
                                  appData.complexQueryList
                                      .where(
                                        (element) =>
                                            element.sector == widget.sector,
                                      )
                                      .map<DropdownMenuItem<String>>((item) {
                                        return DropdownMenuItem<String>(
                                          value: item.name,
                                          child: Text(item.name),
                                        );
                                      })
                                      .toList(),
                              onChanged: (String? newValue) async {
                                setState(() {
                                  _queryType = newValue ?? '';
                                });
                              },
                              decoration: InputDecoration(
                                hintText: "Tap to select query type",
                                hintStyle: kLabelTextStyle,
                                filled: true,
                                fillColor: kColorNavIcon.withValues(alpha: 0.4),
                                focusColor: kColorForeground,
                                floatingLabelBehavior:
                                    FloatingLabelBehavior.never,
                                prefixIcon: const Icon(
                                  Icons.category,
                                  color: kColorSplash,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (_queryType ==
                          'Track and Trace' /*&& _trackTraceItems.isEmpty*/ )
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Flexible(
                              fit: FlexFit.loose,
                              child: DropdownButtonFormField<String>(
                                style: kTextStyle,
                                iconSize: 24,
                                iconEnabledColor: kColorBar,
                                iconDisabledColor: kColorNavIcon,
                                items:
                                    _facilityItems
                                        .map<DropdownMenuItem<String>>((item) {
                                          return DropdownMenuItem<String>(
                                            value: item.facilityID,
                                            child: Text(
                                              item.facilityDescription!,
                                            ),
                                          );
                                        })
                                        .toList(),
                                onChanged: (String? newValue) async {
                                  if (!mounted) return;
                                  setState(() {
                                    _vnlFacility = newValue!;
                                  });
                                },
                                decoration: InputDecoration(
                                  hintText: "Tap to select facility",
                                  hintStyle: kLabelTextStyle,
                                  filled: true,
                                  fillColor: kColorNavIcon.withValues(
                                    alpha: 0.4,
                                  ),
                                  focusColor: kColorForeground,
                                  floatingLabelBehavior:
                                      FloatingLabelBehavior.never,
                                  prefixIcon: const Icon(
                                    Icons.place,
                                    color: kColorSplash,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      if ((_fetchQueryOptions /*&& _trackTraceItems.isEmpty*/ ) ||
                          (_fetchQueryOptions &&
                              widget.sector == 'documents' &&
                              _fileContent == "loaded"))
                        CircularProgressIndicator(
                          color: kColorError,
                          constraints: BoxConstraints(
                            minHeight: 20,
                            minWidth: 20,
                            maxHeight: 20,
                            maxWidth: 20,
                          ),
                        ),
                      if (_queryType == 'Upload OEM Inventory Data')
                        UploadInputButtons(
                          onSubmitted: (FilePickerResult result) {
                            result.files.isNotEmpty
                                ? setState(() {
                                  _pickedFile = result;
                                  _fileContent = 'loaded';
                                })
                                : setState(() {
                                  _fileContent = "";
                                });
                          },
                        ),
                      if (_vnlFacility != "" &&
                          _queryType ==
                              'Track and Trace' /*&&
                  _trackTraceItems.isEmpty*/ )
                        Flexible(
                          fit: FlexFit.loose,
                          child: TrackTraceInputButtons(
                            onSubmitted: (List<String?> value) async {
                              if (value.first == 'manual') {
                                _getQueryOptions(mobiAppData);
                                setState(() {
                                  _vnlUnitIds =
                                      value.whereType<String>().toList();
                                  _vnlValidUnitIds.clear();
                                });
                              } else {
                                await FilePickerService()
                                    .extractXML(value.first ?? '')
                                    .then((extractedData) {
                                      if (extractedData.isNotEmpty) {
                                        _flexibleQueryData = extractedData;
                                        _vnlUnitIds =
                                            extractedData
                                                .map((e) => e.unitIds)
                                                .toList();
                                        for (
                                          var index = 0;
                                          index < _vnlUnitIds.length;
                                          index++
                                        ) {
                                          if (_isValidContainerNumber(
                                            _vnlUnitIds[index].trim(),
                                            _flexibleQueryData.firstWhere(
                                              (element) =>
                                                  element.unitIds ==
                                                  _vnlUnitIds[index].trim(),
                                            ),
                                          )) {
                                            _vnlValidUnitIds
                                                    .where(
                                                      (element) =>
                                                          element.unitIds ==
                                                          _vnlUnitIds[index]
                                                              .trim(),
                                                    )
                                                    .isNotEmpty
                                                ? null
                                                : _vnlValidUnitIds.add(
                                                  FlexibleQueryData(
                                                    filter:
                                                        _flexibleQueryData[index]
                                                            .filter,
                                                    unitIds:
                                                        _vnlUnitIds[index]
                                                            .trim(),
                                                  ),
                                                );
                                          } else {
                                            _vnlInvalidUnitIds.contains(
                                                  _vnlUnitIds[index].trim(),
                                                )
                                                ? null
                                                : _vnlInvalidUnitIds.add(
                                                  _vnlUnitIds[index].trim(),
                                                );
                                          }
                                        }
                                        setState(() {});
                                      }
                                    });
                              }
                            },
                          ),
                        ),
                      if (_vnlUnitIds
                          .isNotEmpty /*&& _trackTraceItems.isEmpty*/ )
                        if (_vnlUnitIds.first == 'manual')
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Flexible(
                                fit: FlexFit.loose,
                                child:
                                    _queryOptions.isNotEmpty
                                        ? DropdownButtonFormField<String>(
                                          isExpanded: true,
                                          style: kTextStyle,
                                          iconSize: 24,
                                          iconEnabledColor: kColorBar,
                                          iconDisabledColor: kColorNavIcon,
                                          items:
                                              _queryOptions.map<
                                                DropdownMenuItem<String>
                                              >((item) {
                                                return DropdownMenuItem<String>(
                                                  alignment: Alignment.center,
                                                  value: item.name,
                                                  child: Text(item.description),
                                                );
                                              }).toList(),
                                          onChanged: (String? newValue) async {
                                            setState(() {
                                              _selectedQueryOption = newValue!;
                                            });
                                          },
                                          decoration: InputDecoration(
                                            hintText:
                                                "Tap to select query option",
                                            hintStyle: kLabelTextStyle,
                                            filled: true,
                                            fillColor: kColorNavIcon.withValues(
                                              alpha: 0.4,
                                            ),
                                            focusColor: kColorForeground,
                                            floatingLabelBehavior:
                                                FloatingLabelBehavior.never,
                                            prefixIcon: const Icon(
                                              Icons.query_stats,
                                              color: kColorSplash,
                                            ),
                                          ),
                                        )
                                        : Container(),
                              ),
                            ],
                          ),
                      if (_vnlUnitIds
                          .isNotEmpty /*&& _trackTraceItems.isEmpty*/ )
                        if (_vnlUnitIds.first == 'manual' &&
                            _selectedQueryOption != "")
                          Form(
                            key: _formQueryInputKey,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Flexible(
                                  fit: FlexFit.loose,
                                  child: TrackTraceInput(
                                    controller: _vnlUnitId,
                                    sector: widget.sector,
                                    onChanged: (List<String?> value) {
                                      if (_formQueryInputKey.currentState!
                                          .validate()) {
                                        _formQueryInputKey.currentState!.save();
                                        setState(() {
                                          _vnlUnitIds =
                                              value
                                                  .whereType<String>()
                                                  .toList()
                                                  .where(
                                                    (element) =>
                                                        element != 'manual',
                                                  )
                                                  .toList();
                                        });
                                      }
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          if (_vnlInvalidUnitIds.isNotEmpty &&
                              //_trackTraceItems.isEmpty &&
                              _vnlUnitIds.first != 'manual')
                            Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8.0),
                                  border: Border.all(
                                    color: kColorError,
                                    width: 2.0,
                                  ),
                                ),
                                height:
                                    MediaQuery.of(context).size.height * .10,
                                width: MediaQuery.of(context).size.width * .3,
                                child: ListView(
                                  scrollDirection: Axis.horizontal,
                                  children: [
                                    ...[
                                      ...List.generate(
                                        _vnlInvalidUnitIds
                                            .where(
                                              (element) => element != 'manual',
                                            )
                                            .length,
                                        (index) {
                                          return Card(
                                            margin: const EdgeInsets.symmetric(
                                              vertical: 8.0,
                                              horizontal: 5.0,
                                            ), // Spacing between cards
                                            elevation:
                                                5.0, // Controls the "raised" effect (shadow depth)
                                            child: SizedBox(
                                              width: 200,
                                              child: ListTile(
                                                title: Text(
                                                  _vnlInvalidUnitIds[index]
                                                      .trim(),
                                                ),
                                                subtitle: Text(
                                                  'Invalid',
                                                  style: kErrorTextStyle,
                                                ),
                                                trailing: const Icon(
                                                  Icons.error,
                                                  color: kColorError,
                                                ),
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ),
                          if (_vnlDuplicateUnitIds.isNotEmpty &&
                              //_trackTraceItems.isEmpty &&
                              _vnlUnitIds.first != 'manual')
                            Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8.0),
                                  border: Border.all(
                                    color: kColorError,
                                    width: 2.0,
                                  ),
                                ),
                                height:
                                    MediaQuery.of(context).size.height * .10,
                                width: MediaQuery.of(context).size.width * .3,
                                child: ListView(
                                  scrollDirection: Axis.horizontal,
                                  children: [
                                    ...[
                                      ...List.generate(
                                        _vnlDuplicateUnitIds
                                            .where(
                                              (element) => element != 'manual',
                                            )
                                            .length,
                                        (index) {
                                          return Card(
                                            margin: const EdgeInsets.symmetric(
                                              vertical: 8.0,
                                              horizontal: 5.0,
                                            ), // Spacing between cards
                                            elevation:
                                                5.0, // Controls the "raised" effect (shadow depth)
                                            child: SizedBox(
                                              width: 200,
                                              child: ListTile(
                                                title: Text(
                                                  _vnlDuplicateUnitIds[index]
                                                      .trim(),
                                                ),
                                                subtitle: Text(
                                                  'Duplicate',
                                                  style: kErrorTextStyle,
                                                ),
                                                trailing: const Icon(
                                                  Icons.error,
                                                  color: kColorError,
                                                ),
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ),
                        ],
                      ),
                      if (_vnlValidUnitIds.isNotEmpty &&
                          //_trackTraceItems.isEmpty &&
                          _vnlUnitIds.first != 'manual')
                        ComplexResultsForm(
                          mobiAppData: mobiAppData,
                          vnlValidUnitIds: _vnlValidUnitIds,
                          flexibleQueryData: _flexibleQueryData,
                          vnlFacility: _vnlFacility,
                          onResults: (value) {},
                        ),
                      if (_fileContent != "") ...[
                        Text(
                          'File content loaded. Ready to send.',
                          style: kButtonTextStyle,
                        ),
                      ],
                    ],
                  ),
                ),
        floatingActionButton: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: FloatingActionButton(
                heroTag: 'btn1',
                onPressed: () async {
                  Navigator.pop(context);
                },
                backgroundColor: kColorBackground,
                elevation: 12,
                foregroundColor: kColorForeground,
                splashColor: kColorSuccess,
                child: const Icon(Icons.home, size: 50),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: FloatingActionButton(
                heroTag: 'btn2',
                onPressed:
                    widget.sector == 'container'
                        ? null
                        : () async {
                          switch (widget.sector) {
                            case 'documents':
                              await FilePickerService()
                                  .getExcelData(_pickedFile)
                                  .then((result) async {
                                    setState(() {
                                      _fetchQueryOptions = true;
                                      _queryType = "";
                                      _fileContent = "";
                                    });
                                    await DatabaseService(null)
                                        .postDocumentSharePointData(
                                          mobiAppData,
                                          result,
                                          widget.subscribeData!.username!,
                                        )
                                        .then((response) {
                                          setState(() {
                                            _fetchQueryOptions = false;
                                          });
                                          if (!context.mounted) return;
                                          DialogService(
                                            button: 'dismiss',
                                            origin:
                                                'Response from server: $response',
                                          ).showSnackBar(context: context);
                                        });
                                  });
                              break;
                            default:
                          }
                        },
                backgroundColor:
                    _vnlValidUnitIds.isEmpty && _fileContent.isEmpty
                        ? kColorNavIcon.withValues(alpha: 0.4)
                        : kColorSuccess,
                elevation: 12,
                foregroundColor: kColorForeground,
                splashColor: kColorSuccess,
                child: const Icon(Icons.search, size: 50),
              ),
            ),
          ],
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      ),
    );
  }
}
