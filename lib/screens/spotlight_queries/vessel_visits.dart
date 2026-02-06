import 'package:cached_network_image/cached_network_image.dart';
import 'package:customer_portal/constants/styles.dart';
import 'package:customer_portal/model/mobiapp.dart';
import 'package:customer_portal/model/singletons_data.dart';
import 'package:customer_portal/services/mobiapi_service.dart';
import 'package:customer_portal/shared/dialog.dart';
import 'package:flutter/material.dart';
import 'package:multi_select_flutter/chip_display/multi_select_chip_display.dart';
import 'package:multi_select_flutter/dialog/multi_select_dialog_field.dart';
import 'package:multi_select_flutter/util/multi_select_item.dart';

class VesselVisitsForm extends StatefulWidget {
  const VesselVisitsForm({
    super.key,
    required this.title,
    required this.mobiAppData,
    required this.sector,
  });
  final String title, sector;
  final MobiAppData mobiAppData;
  @override
  State<VesselVisitsForm> createState() => _VesselVisitsFormState();
}

class _VesselVisitsFormState extends State<VesselVisitsForm> {
  final _key = GlobalKey<ScaffoldState>();
  late List<VesselItems> vesselNames;
  List<String> vesselVisitsItems = [], _myVesselSelection = [];
  bool firstFacilitiesRun = true, firstVesselNamesRun = true, _loading = false;
  String vnlFacility = "";
  final GlobalKey<FormFieldState> _multiVesselSelectKey =
      GlobalKey<FormFieldState>();

  @override
  void setState(fn) {
    super.setState(fn);
  }

  @override
  void initState() {
    vesselNames = [];
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    List<ImageData> imageData = appData.imageData;

    return imageData.isEmpty
        ? const CircularProgressIndicator(color: kColorBar)
        : SizedBox(
          height: MediaQuery.of(context).size.height * .9,
          width: MediaQuery.of(context).size.width,
          child: Scaffold(
            extendBody: true,
            extendBodyBehindAppBar: true,
            backgroundColor: kColorNavIcon,
            key: _key,
            resizeToAvoidBottomInset: false,
            body: Padding(
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
                              (context, url, error) => const Icon(Icons.error),
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
                        /*widget.sector == 'container'
                                ? FutureBuilder(
                                  future:
                                      firstFacilitiesRun
                                          ? MobiApiService().getFacilities(
                                            widget.mobiAppData,
                                            widget.sector,
                                          )
                                          : null,
                                  builder: (
                                    BuildContext context,
                                    AsyncSnapshot facilities,
                                  ) {
                                    return facilities.hasData
                                        ? DropdownButtonFormField<String>(
                                          style: kTextStyle,
                                          iconSize: 24,
                                          iconEnabledColor: kColorBar,
                                          iconDisabledColor: kColorNavIcon,
                                          items:
                                              facilities.data.map<
                                                DropdownMenuItem<String>
                                              >((item) {
                                                return DropdownMenuItem<String>(
                                                  value:
                                                      widget.sector ==
                                                              'container'
                                                          ? item.facilityName
                                                          : item.facilityID,
                                                  child: Text(
                                                    item.facilityDescription!,
                                                  ),
                                                );
                                              }).toList(),
                                          onChanged: (String? newValue) async {
                                            setState(() {
                                              firstFacilitiesRun = false;
                                              firstVesselNamesRun = true;
                                              vnlFacility = newValue!;
                                              vesselVisitsItems = [];
                                            });
                                          },
                                          decoration: InputDecoration(
                                            hintText: "Tap to select port",
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
                                        : const Center(
                                          child: CircularProgressIndicator(
                                            color: kColorBar,
                                          ),
                                        );
                                  },
                                )
                                :*/
                        DropdownButtonFormField<String>(
                          style: kTextStyle,
                          iconSize: 24,
                          iconEnabledColor: kColorBar,
                          iconDisabledColor: kColorNavIcon,
                          items:
                              appData.facilitiesList
                                  .map<DropdownMenuItem<String>>((item) {
                                    return DropdownMenuItem<String>(
                                      value:
                                          widget.sector == 'container'
                                              ? item.facilityName
                                              : item.facilityID,
                                      child: Text(item.facilityDescription!),
                                    );
                                  })
                                  .toList(),
                          onChanged: (String? newValue) async {
                            setState(() {
                              firstFacilitiesRun = false;
                              firstVesselNamesRun = true;
                              vnlFacility = newValue!;
                              vesselVisitsItems = [];
                            });
                          },
                          decoration: InputDecoration(
                            hintText: "Tap to select port",
                            hintStyle: kLabelTextStyle,
                            filled: true,
                            fillColor: kColorNavIcon.withValues(alpha: 0.4),
                            focusColor: kColorForeground,
                            floatingLabelBehavior: FloatingLabelBehavior.never,
                            prefixIcon: const Icon(
                              Icons.place,
                              color: kColorSplash,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  vnlFacility.isEmpty
                      ? Container()
                      : Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                            fit: FlexFit.loose,
                            child: FutureBuilder(
                              future:
                                  firstVesselNamesRun
                                      ? MobiApiService().getVesselNames(
                                        widget.mobiAppData,
                                        vnlFacility,
                                        widget.sector,
                                      )
                                      : null,
                              builder: (
                                BuildContext context,
                                AsyncSnapshot vessels,
                              ) {
                                if ((vessels.connectionState ==
                                            ConnectionState.done ||
                                        vessels.connectionState ==
                                            ConnectionState.none) &&
                                    vessels.hasData &&
                                    vessels.data.length > 0) {
                                  return MultiSelectDialogField(
                                    title: Text(
                                      "Click icon to filter",
                                      style: kMarkerTextStyle1,
                                    ),
                                    chipDisplay: MultiSelectChipDisplay.none(),
                                    searchable: true,
                                    key: _multiVesselSelectKey,
                                    validator: (values) {
                                      if (values == null || values.isEmpty) {
                                        return "Vessel is required";
                                      }
                                      if (values.length > 1) {
                                        return "Select 1 vessel at a time.";
                                      }
                                      return null;
                                    },
                                    items:
                                        vessels.data
                                            .map(
                                              (vessel) =>
                                                  MultiSelectItem<String>(
                                                    vessel.visitID,
                                                    vessel.vesselName,
                                                  ),
                                            )
                                            .whereType<MultiSelectItem>()
                                            .toList(),
                                    selectedColor: kColorSuccess,
                                    decoration: BoxDecoration(
                                      color: kColorText.withValues(alpha: .5),
                                      borderRadius: const BorderRadius.only(
                                        topRight: Radius.circular(5),
                                        topLeft: Radius.circular(5),
                                      ),
                                    ),
                                    buttonIcon: const Icon(
                                      Icons.arrow_drop_down_outlined,
                                      color: kColorBar,
                                    ),
                                    buttonText: const Text.rich(
                                      TextSpan(
                                        children: [
                                          WidgetSpan(
                                            child: Icon(
                                              Icons.category,
                                              color: kColorForeground,
                                            ),
                                          ),
                                          TextSpan(
                                            text: 'Tap to select vessels',
                                            style: kLabelTextStyle,
                                          ),
                                        ],
                                      ),
                                    ),
                                    onConfirm: (results) async {
                                      if (results.isNotEmpty) {
                                        if (_multiVesselSelectKey.currentState!
                                            .validate()) {
                                          setState(() {
                                            _myVesselSelection =
                                                results
                                                    .map(
                                                      (vessel) =>
                                                          vessel as String,
                                                    )
                                                    .toList();

                                            _loading = true;
                                          });

                                          await MobiApiService()
                                              .getVesselVisits(
                                                widget.mobiAppData,
                                                _myVesselSelection[0],
                                                widget.sector == 'container'
                                                    ? ''
                                                    : vnlFacility,
                                                widget.sector,
                                              )
                                              .then((firstTry) async {
                                                //try gain if no data
                                                if (firstTry.isEmpty) {
                                                  await MobiApiService()
                                                      .getVesselVisits(
                                                        widget.mobiAppData,
                                                        _myVesselSelection[0],
                                                        widget.sector ==
                                                                'container'
                                                            ? ''
                                                            : vnlFacility,
                                                        widget.sector,
                                                      )
                                                      .then((secondTry) {
                                                        vesselVisitsItems =
                                                            secondTry;
                                                      });
                                                } else {
                                                  vesselVisitsItems = firstTry;
                                                }
                                              });
                                          if (!context.mounted) return;
                                          vesselVisitsItems.isEmpty
                                              ? await DialogService(
                                                button: 'dismiss',
                                                origin: 'No vessel visit found',
                                              ).showSnackBar(context: context)
                                              : null;
                                          setState(() {
                                            firstVesselNamesRun = false;
                                            _loading = false;
                                          });
                                        }
                                      }
                                    },
                                  );
                                } else if (vessels.connectionState ==
                                    ConnectionState.waiting) {
                                  return const Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: Align(
                                      alignment: Alignment.center,
                                      child: CircularProgressIndicator(
                                        color: kColorBar,
                                      ),
                                    ),
                                  );
                                } else {
                                  debugPrint('no data');
                                  return const Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: Center(
                                      child: Text(
                                        'No vessels for terminal',
                                        style: kListTitleTextStyle,
                                      ),
                                    ),
                                  );
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                  _loading
                      ? Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Align(
                          alignment: Alignment.center,
                          child: CircularProgressIndicator(color: kColorBar),
                        ),
                      )
                      : vesselVisitsItems.isNotEmpty
                      ? Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 60.0),
                          child: ListView.builder(
                            physics: const ScrollPhysics(),
                            shrinkWrap: true,
                            itemCount:
                                widget.mobiAppData.vesselvisitfields!.length,
                            itemBuilder: (BuildContext context, int index) {
                              return ListTile(
                                leading: CachedNetworkImage(
                                  errorWidget:
                                      (context, url, error) =>
                                          const Icon(Icons.error),
                                  imageUrl:
                                      imageData
                                          .where(
                                            (element) =>
                                                element.title == 'ship',
                                          )
                                          .first
                                          .url,
                                  imageBuilder:
                                      (context, imageProvider) => Container(
                                        width: 50,
                                        height: 50,
                                        decoration: BoxDecoration(
                                          image: DecorationImage(
                                            image: imageProvider,
                                            fit: BoxFit.contain,
                                            alignment: Alignment.topRight,
                                          ),
                                        ),
                                      ),
                                ),
                                title: Text(
                                  widget.mobiAppData.vesselvisitfields![index],
                                  style: kListTitleTextStyle,
                                ),
                                subtitle: Text(
                                  vesselVisitsItems[index] == 'default'
                                      ? ''
                                      : vesselVisitsItems[index],
                                  style: kListValueTextStyle,
                                ),
                              );
                            },
                          ),
                        ),
                      )
                      : Container(),
                ],
              ),
            ),
            floatingActionButton: Padding(
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
            floatingActionButtonLocation:
                FloatingActionButtonLocation.centerDocked,
          ),
        );
  }
}
