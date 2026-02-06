import 'package:cached_network_image/cached_network_image.dart';
import 'package:customer_portal/constants/styles.dart';
import 'package:customer_portal/model/mobiapp.dart';
import 'package:customer_portal/model/singletons_data.dart';
import 'package:customer_portal/services/mobiapi_service.dart';
import 'package:customer_portal/shared/dialog.dart';
import 'package:customer_portal/shared/upper_case.dart';
import 'package:flutter/material.dart';

class TrackTraceForm extends StatefulWidget {
  const TrackTraceForm({
    super.key,
    required this.title,
    required this.mobiAppData,
    required this.sector,
  });
  final String title, sector;
  final MobiAppData mobiAppData;

  @override
  State<TrackTraceForm> createState() => _TrackTraceFormState();
}

class _TrackTraceFormState extends State<TrackTraceForm> {
  final _key = GlobalKey<ScaffoldState>();
  final _formKey = GlobalKey<FormState>();
  bool showQueryButton = false,
      loading = false,
      isListening = false,
      checkboxAllState = true,
      checkboxSingleState = false;
  List<TrackTraceModel> trackTraceItems = [];
  List<TrackTraceGCOSModel> trackTraceGCOSItems = [];
  List<PreAdviceModel> preAdviceItems = [];
  List<BookingReferenceModel> bookingReferenceItems = [];
  List<QueryOptionsModel> queryOptions = [];
  List<FacilityItems> facilityItems = [];
  String selectedQueryOption = "", vnlFacility = "";

  final TextEditingController vnlUnitId = TextEditingController();
  void getQueryOptions() async {
    setState(() {
      loading = true;
    });
    widget.sector == "container"
        ? queryOptions = await MobiApiService().getQueryOptions(
          widget.mobiAppData,
        )
        : queryOptions = QueryOptionsModel.fromList(
          widget.mobiAppData.queryOptions!,
          widget.sector,
        );
    if (!mounted) return;
    setState(() {
      loading = false;
      selectedQueryOption = queryOptions.first.name;
    });
  }

  Future<void> getQueryFacilities() async {
    setState(() {
      loading = true;
    });
    facilityItems =
        widget.sector == "container" && checkboxSingleState
            ? /*await MobiApiService().getFacilities(
              widget.mobiAppData,
              widget.sector,
            )*/ appData.facilitiesList
            : widget.sector != "container"
            ? appData.facilitiesList
            : [];
    if (widget.sector != 'container') {
      vnlUnitId.clear();
      trackTraceItems = [];
      trackTraceGCOSItems = [];
    }
    setState(() {
      loading = false;
    });
  }

  @override
  void setState(fn) {
    super.setState(fn);
  }

  @override
  void initState() {
    getQueryOptions();
    getQueryFacilities();
    trackTraceItems = [];
    trackTraceGCOSItems = [];
    preAdviceItems = [];
    bookingReferenceItems = [];
    widget.sector == 'container' ? facilityItems = [] : null;
    vnlUnitId.text = '';
    super.initState();
  }

  @override
  void dispose() {
    if (!mounted) return;

    vnlUnitId.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    List<ImageData> imageData = appData.imageData;

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
            loading
                ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Center(
                      child: CircularProgressIndicator(color: kColorBar),
                    ),
                    Center(
                      child: Text(
                        "Complex query, longer waiting time, please be patient..",
                        style: kMarkerTextStyle,
                      ),
                    ),
                  ],
                )
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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                            fit: FlexFit.loose,
                            child:
                                queryOptions.isNotEmpty
                                    ? DropdownButtonFormField<String>(
                                      isExpanded: true,
                                      value:
                                          selectedQueryOption.isEmpty
                                              ? queryOptions.first.name
                                              : selectedQueryOption,
                                      style: kTextStyle,
                                      iconSize: 24,
                                      iconEnabledColor: kColorBar,
                                      iconDisabledColor: kColorNavIcon,
                                      items:
                                          queryOptions
                                              .map<DropdownMenuItem<String>>((
                                                item,
                                              ) {
                                                return DropdownMenuItem<String>(
                                                  alignment: Alignment.center,
                                                  value: item.name,
                                                  child: Text(item.description),
                                                );
                                              })
                                              .toList(),
                                      onChanged: (String? newValue) async {
                                        if (checkboxSingleState &&
                                            newValue == "PARM_BOOKING_NUMBER") {
                                          checkboxAllState = !checkboxAllState;
                                          checkboxSingleState =
                                              !checkboxSingleState;
                                        }
                                        if (!mounted) return;
                                        setState(() {
                                          selectedQueryOption = newValue!;
                                        });
                                      },
                                      decoration: InputDecoration(
                                        hintText: "Tap to select query option",
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
                      widget.sector == 'container'
                          ? Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Expanded(
                                child: CheckboxListTile(
                                  enabled:
                                      widget.sector == 'container'
                                          ? true
                                          : false,
                                  contentPadding: EdgeInsets.zero,
                                  controlAffinity:
                                      ListTileControlAffinity.leading,
                                  title: const Text(
                                    'All facilities',
                                    style: kLabelTextStyle,
                                  ),
                                  value:
                                      widget.sector == 'container'
                                          ? checkboxAllState
                                          : false,
                                  activeColor: kColorSuccess,
                                  onChanged: (value) async {
                                    if (!mounted) return;
                                    setState(() {
                                      checkboxAllState = !checkboxAllState;
                                      checkboxSingleState =
                                          !checkboxSingleState;
                                      vnlUnitId.clear();
                                      trackTraceItems = [];
                                      trackTraceGCOSItems = [];
                                    });
                                  },
                                ),
                              ),
                              Expanded(
                                child: CheckboxListTile(
                                  enabled:
                                      widget.sector == 'container'
                                          ? true
                                          : false,
                                  contentPadding: EdgeInsets.zero,
                                  controlAffinity:
                                      ListTileControlAffinity.leading,
                                  title: const Text(
                                    'Single facility',
                                    style: kLabelTextStyle,
                                  ),
                                  value:
                                      widget.sector == 'container'
                                          ? checkboxSingleState
                                          : true,
                                  activeColor: kColorSuccess,
                                  onChanged: (value) async {
                                    if (selectedQueryOption ==
                                            "PARM_BOOKING_NUMBER" &&
                                        value == true) {
                                      await DialogService(
                                        button: 'dismiss',
                                        origin:
                                            'Single Facility is not supported for selected query option',
                                      ).showSnackBar(context: context);
                                      return;
                                    }
                                    checkboxAllState = !checkboxAllState;
                                    checkboxSingleState = !checkboxSingleState;
                                    facilityItems.isEmpty
                                        ? await getQueryFacilities().then((
                                          value,
                                        ) {
                                          if (!mounted) return;
                                          setState(() {
                                            vnlUnitId.clear();
                                            trackTraceItems = [];
                                            trackTraceGCOSItems = [];
                                          });
                                        })
                                        : setState(() {});
                                  },
                                ),
                              ),
                            ],
                          )
                          : Container(),
                      Row(
                        children: [
                          Flexible(
                            fit: FlexFit.loose,
                            child:
                                facilityItems.isNotEmpty &&
                                        (checkboxSingleState ||
                                            widget.sector != 'container')
                                    ? DropdownButtonFormField<String>(
                                      value:
                                          vnlFacility.isEmpty
                                              ? null
                                              : vnlFacility,
                                      style: kTextStyle,
                                      iconSize: 24,
                                      iconEnabledColor: kColorBar,
                                      iconDisabledColor: kColorNavIcon,
                                      items:
                                          facilityItems
                                              .map<DropdownMenuItem<String>>((
                                                item,
                                              ) {
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
                                          vnlFacility = newValue!;
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
                                    )
                                    : Container(),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Form(
                            key: _formKey,
                            child: Expanded(
                              child: TextFormField(
                                inputFormatters: [UpperCaseTextFormatter()],
                                textCapitalization:
                                    TextCapitalization.characters,
                                textAlign: TextAlign.center,
                                controller: vnlUnitId,
                                onChanged: (val) {
                                  if (!mounted) return;
                                  setState(() {
                                    if (val.isEmpty) {
                                      trackTraceItems.clear();
                                      trackTraceGCOSItems.clear();
                                      showQueryButton = false;
                                    } else {
                                      showQueryButton = true;
                                    }
                                  });
                                },
                                style: kButtonTextStyle,
                                keyboardType: TextInputType.streetAddress,
                                decoration: userInputDecoration.copyWith(
                                  hintText: 'Enter query criteria',
                                ),
                                validator:
                                    (val) =>
                                        val!.isEmpty
                                            ? 'Query criteria required'
                                            : null,
                              ),
                            ),
                          ),
                        ],
                      ),
                      trackTraceGCOSItems
                              .isNotEmpty //show gcos result
                          ? Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 60.0),
                              child: ListView.builder(
                                physics: const ScrollPhysics(),
                                shrinkWrap: true,
                                itemCount: trackTraceGCOSItems.length,
                                itemBuilder: (BuildContext context, int index) {
                                  return Column(
                                    children: [
                                      index == 0
                                          ? Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceEvenly,
                                            children: [
                                              Flexible(
                                                fit: FlexFit.loose,
                                                child: Text(
                                                  'RECEIVED: ${trackTraceGCOSItems.where((element) => element.receiveQuantity > 0).fold(0, (value, element) => value + element.receiveQuantity).toString()}',
                                                ),
                                              ),
                                              Flexible(
                                                fit: FlexFit.loose,
                                                child: Text(
                                                  'DISPATCHED: ${trackTraceGCOSItems.where((element) => element.dispatchQuantity > 0).fold(0, (value, element) => value + element.dispatchQuantity).toString()}',
                                                ),
                                              ),
                                            ],
                                          )
                                          : Container(),
                                      ListTile(
                                        leading: SizedBox(
                                          width: 50,
                                          height: 50,
                                          child: CachedNetworkImage(
                                            errorWidget:
                                                (context, url, error) =>
                                                    const Icon(Icons.error),
                                            imageUrl:
                                                imageData
                                                    .where(
                                                      (element) =>
                                                          element.title ==
                                                          'track',
                                                    )
                                                    .first
                                                    .url,
                                            imageBuilder:
                                                (context, imageProvider) =>
                                                    Container(
                                                      width: 50,
                                                      height: 50,
                                                      decoration: BoxDecoration(
                                                        image: DecorationImage(
                                                          image: imageProvider,
                                                          fit: BoxFit.contain,
                                                          alignment:
                                                              Alignment
                                                                  .topRight,
                                                        ),
                                                      ),
                                                    ),
                                          ),
                                        ),
                                        title: Text(
                                          '${trackTraceGCOSItems[index].cargoTag1} (${trackTraceGCOSItems[index].cargoTag2})',
                                          style: kListTitleTextStyle,
                                        ),
                                        subtitle: Text(
                                          '${trackTraceGCOSItems[index].vesselName} (${trackTraceGCOSItems[index].voyageIn}/${trackTraceGCOSItems[index].voyageOut})',
                                          style: kLabelTextStyle,
                                        ),
                                        trailing: InkWell(
                                          onTap:
                                              () async => {
                                                await DialogService(
                                                  button: 'done',
                                                  origin: widget.title,
                                                ).showGCOSTrackTraceDetail(
                                                  context: context,
                                                  trackTraceDetail:
                                                      trackTraceGCOSItems[index],
                                                  mobiAppData:
                                                      widget.mobiAppData,
                                                  imageData: imageData,
                                                ),
                                              },
                                          splashColor: kColorSplash,
                                          child: const Icon(
                                            Icons.arrow_forward,
                                            color: kColorBar,
                                          ),
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              ),
                            ),
                          )
                          : (trackTraceItems.isEmpty &&
                                  selectedQueryOption == "PARM_CTT_UNIT_NBR") ||
                              (preAdviceItems.isEmpty &&
                                  selectedQueryOption == "PARM_PC_UNIT_NBR") ||
                              (bookingReferenceItems.isEmpty &&
                                  selectedQueryOption == "PARM_BOOKING_NUMBER")
                          ? Container()
                          : Expanded(
                            //show navis results
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 60.0),
                              child: ListView.builder(
                                physics: const ScrollPhysics(),
                                shrinkWrap: true,
                                itemCount:
                                    selectedQueryOption == "PARM_CTT_UNIT_NBR"
                                        ? trackTraceItems.length
                                        : selectedQueryOption ==
                                            "PARM_PC_UNIT_NBR"
                                        ? preAdviceItems.length
                                        : selectedQueryOption ==
                                            "PARM_BOOKING_NUMBER"
                                        ? bookingReferenceItems.length
                                        : 0,
                                itemBuilder: (BuildContext context, int index) {
                                  return ListTile(
                                    leading: SizedBox(
                                      width: 50,
                                      height: 50,
                                      child: CachedNetworkImage(
                                        errorWidget:
                                            (context, url, error) =>
                                                const Icon(Icons.error),
                                        imageUrl:
                                            imageData
                                                .where(
                                                  (element) =>
                                                      element.title == 'track',
                                                )
                                                .first
                                                .url,
                                        imageBuilder:
                                            (context, imageProvider) =>
                                                Container(
                                                  width: 50,
                                                  height: 50,
                                                  decoration: BoxDecoration(
                                                    image: DecorationImage(
                                                      image: imageProvider,
                                                      fit: BoxFit.contain,
                                                      alignment:
                                                          Alignment.topRight,
                                                    ),
                                                  ),
                                                ),
                                      ),
                                    ),
                                    title: Text(
                                      selectedQueryOption == "PARM_CTT_UNIT_NBR"
                                          ? trackTraceItems[index].unitNumber
                                          : selectedQueryOption ==
                                              "PARM_PC_UNIT_NBR"
                                          ? preAdviceItems[index].unitNumber
                                          : selectedQueryOption ==
                                              "PARM_BOOKING_NUMBER"
                                          ? bookingReferenceItems[index]
                                              .unitNumber
                                          : "",
                                      style: kListTitleTextStyle,
                                    ),
                                    subtitle: Text(
                                      selectedQueryOption == "PARM_CTT_UNIT_NBR"
                                          ? 'Facility: ${trackTraceItems[index].facility}'
                                          : selectedQueryOption ==
                                              "PARM_PC_UNIT_NBR"
                                          ? 'Category: ${preAdviceItems[index].category}'
                                          : selectedQueryOption ==
                                              "PARM_BOOKING_NUMBER"
                                          ? 'Facility: ${bookingReferenceItems[index].facility}'
                                          : "",
                                      style: kLabelTextStyle,
                                    ),
                                    trailing: InkWell(
                                      onTap:
                                          () async => {
                                            selectedQueryOption ==
                                                    "PARM_CTT_UNIT_NBR"
                                                ? await DialogService(
                                                  button: 'done',
                                                  origin: widget.title,
                                                ).showTrackTraceDetail(
                                                  context: context,
                                                  trackTraceDetail:
                                                      trackTraceItems[index],
                                                  mobiAppData:
                                                      widget.mobiAppData,
                                                  imageData: imageData,
                                                )
                                                : selectedQueryOption ==
                                                    "PARM_PC_UNIT_NBR"
                                                ? await DialogService(
                                                  button: 'done',
                                                  origin: widget.title,
                                                ).showPreAdviceDetail(
                                                  context: context,
                                                  preAdviceDetail:
                                                      preAdviceItems[index],
                                                  mobiAppData:
                                                      widget.mobiAppData,
                                                  imageData: imageData,
                                                )
                                                : await DialogService(
                                                  button: 'done',
                                                  origin: widget.title,
                                                ).showBookingReferenceDetail(
                                                  context: context,
                                                  bookReferenceDetail:
                                                      bookingReferenceItems[index],
                                                  mobiAppData:
                                                      widget.mobiAppData,
                                                  imageData: imageData,
                                                ),
                                          },
                                      splashColor: kColorSplash,
                                      child: const Icon(
                                        Icons.arrow_forward,
                                        color: kColorBar,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                    ],
                  ),
                ),
        floatingActionButton: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Visibility(
              visible: MediaQuery.of(context).viewInsets.bottom == 0.0,
              child: Padding(
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
            ),
            Visibility(
              visible: MediaQuery.of(context).viewInsets.bottom == 0.0,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: FloatingActionButton(
                  heroTag: 'btn2',
                  onPressed: () async {
                    if (widget.sector != 'container' &&
                        (vnlFacility.isEmpty && facilityItems.isEmpty)) {
                      return;
                    }
                    if (showQueryButton == true) {
                      setState(() {
                        loading = true;
                      });
                      selectedQueryOption == "PARM_CTT_UNIT_NBR" &&
                              widget.sector == 'container'
                          ? trackTraceItems = await MobiApiService()
                              .getTrackTrace(
                                widget.mobiAppData,
                                vnlUnitId.text,
                                vnlFacility,
                                checkboxSingleState,
                                selectedQueryOption,
                              )
                          : selectedQueryOption == "PARM_PC_UNIT_NBR" &&
                              widget.sector == 'container'
                          ? preAdviceItems = await MobiApiService()
                              .getPreAdvice(
                                widget.mobiAppData,
                                vnlUnitId.text,
                                vnlFacility,
                                checkboxSingleState,
                                selectedQueryOption,
                              )
                          : selectedQueryOption == "PARM_BOOKING_NUMBER" &&
                              widget.sector == 'container'
                          ? bookingReferenceItems = await MobiApiService()
                              .getBookingReference(
                                widget.mobiAppData,
                                vnlUnitId.text,
                                vnlFacility,
                                checkboxSingleState,
                                selectedQueryOption,
                              )
                          : widget.sector != 'container'
                          ? trackTraceGCOSItems = await MobiApiService()
                              .getGCOSTrackTrace(
                                widget.mobiAppData,
                                vnlUnitId.text,
                                vnlFacility,
                                checkboxSingleState,
                                selectedQueryOption,
                              )
                          : null;
                      if (!context.mounted) return;
                      setState(() {
                        loading = false;
                      });
                      if (widget.sector == 'container') {
                        if ((trackTraceItems.isEmpty &&
                                selectedQueryOption == "PARM_CTT_UNIT_NBR") ||
                            (preAdviceItems.isEmpty &&
                                selectedQueryOption == "PARM_PC_UNIT_NBR") ||
                            (bookingReferenceItems.isEmpty &&
                                selectedQueryOption == "PARM_BOOKING_NUMBER")) {
                          await DialogService(
                            button: 'dismiss',
                            origin: 'No Data Returned',
                          ).showSnackBar(context: context);
                        }
                      } else {
                        if (trackTraceGCOSItems.isEmpty) {
                          await DialogService(
                            button: 'dismiss',
                            origin: 'No Data Returned',
                          ).showSnackBar(context: context);
                        }
                      }
                    } else {
                      await DialogService(
                        button: 'dismiss',
                        origin: 'Query criteria Required',
                      ).showSnackBar(context: context);
                    }
                  },
                  backgroundColor: showQueryButton ? kColorSuccess : kColorText,
                  elevation: 12,
                  foregroundColor: kColorForeground,
                  splashColor: kColorBackground,
                  child: const Icon(Icons.search, size: 50),
                ),
              ),
            ),
          ],
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      ),
    );
  }
}
