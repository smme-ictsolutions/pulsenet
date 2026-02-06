import 'package:cached_network_image/cached_network_image.dart';
import 'package:customer_portal/constants/styles.dart';
import 'package:customer_portal/model/mobiapp.dart';
import 'package:customer_portal/model/singletons_data.dart';
import 'package:customer_portal/services/mobiapi_service.dart';
import 'package:customer_portal/shared/dialog.dart';
import 'package:flutter/material.dart';

class BerthSequenceForm extends StatefulWidget {
  const BerthSequenceForm({
    super.key,
    required this.title,
    required this.mobiAppData,
    required this.sector,
  });
  final String title, sector;
  final MobiAppData mobiAppData;
  @override
  State<BerthSequenceForm> createState() => _BerthSequenceFormState();
}

class _BerthSequenceFormState extends State<BerthSequenceForm> {
  final _key = GlobalKey<ScaffoldState>();
  late List<VesselItems> vesselNames;
  late List<BerthItems> berthItems;
  late List<BerthingSequenceModel> berthSequenceItems;
  bool firstFacilitiesRun = true, firstVesselNamesRun = true, loading = false;
  String vnlFacility = "";

  @override
  void setState(fn) {
    super.setState(fn);
  }

  @override
  void initState() {
    vesselNames = [];
    berthItems = [];
    berthSequenceItems = [];
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
                        child: DropdownButtonFormField<String>(
                          style: kTextStyle,
                          iconSize: 24,
                          iconEnabledColor: kColorBar,
                          iconDisabledColor: kColorNavIcon,
                          items:
                              appData.facilitiesList
                                  .map<DropdownMenuItem<String>>((item) {
                                    return DropdownMenuItem<String>(
                                      value: item.facilityID,
                                      child: Text(item.facilityDescription!),
                                    );
                                  })
                                  .toList(),
                          onChanged:
                              loading
                                  ? null
                                  : (String? newValue) async {
                                    setState(() {
                                      loading = true;
                                      vnlFacility = newValue!;
                                    });
                                    await MobiApiService()
                                        .getBerths(
                                          widget.mobiAppData,
                                          newValue!,
                                        )
                                        .then((firstTry) async {
                                          if (firstTry.isEmpty) {
                                            //try query again
                                            await MobiApiService()
                                                .getBerths(
                                                  widget.mobiAppData,
                                                  newValue,
                                                )
                                                .then((secondTry) {
                                                  berthItems = secondTry;
                                                  loading = false;
                                                });
                                          } else {
                                            berthItems = firstTry;
                                            loading = false;
                                          }
                                        });
                                    setState(() {
                                      firstFacilitiesRun = false;
                                      firstVesselNamesRun = true;
                                      berthSequenceItems = [];
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
                  berthItems.isEmpty
                      ? Container()
                      : Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                            fit: FlexFit.loose,
                            child: DropdownButtonFormField<String>(
                              style: kTextStyle,
                              iconSize: 24,
                              iconEnabledColor: kColorBar,
                              iconDisabledColor: kColorNavIcon,
                              items:
                                  berthItems.map<DropdownMenuItem<String>>((
                                    item,
                                  ) {
                                    return DropdownMenuItem<String>(
                                      value: item.berthID,
                                      child: Text(item.berthName!),
                                    );
                                  }).toList(),
                              onChanged: (String? newValue) async {
                                setState(() {
                                  berthSequenceItems = [];
                                  loading = true;
                                });
                                await MobiApiService()
                                    .getBerthingSequence(
                                      widget.mobiAppData,
                                      vnlFacility,
                                      newValue!,
                                    )
                                    .then((firstTry) {
                                      if (firstTry.isEmpty) {
                                        //try query again
                                        MobiApiService()
                                            .getBerthingSequence(
                                              widget.mobiAppData,
                                              vnlFacility,
                                              newValue,
                                            )
                                            .then((secondTry) {
                                              berthSequenceItems = secondTry;
                                            });
                                      } else {
                                        berthSequenceItems = firstTry;
                                      }
                                    });
                                setState(() {
                                  loading = false;
                                });
                              },
                              decoration: InputDecoration(
                                hintText: "Tap to select berth",
                                hintStyle: kLabelTextStyle,
                                filled: true,
                                fillColor: kColorNavIcon.withValues(alpha: 0.4),
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
                  berthSequenceItems.isEmpty
                      ? loading
                          ? Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Center(
                              child: CircularProgressIndicator(
                                color: kColorBar,
                              ),
                            ),
                          )
                          : Container()
                      : SizedBox(
                        height: MediaQuery.of(context).size.height * .5,
                        width: MediaQuery.of(context).size.width * .9,
                        child: ListView.builder(
                          physics: const AlwaysScrollableScrollPhysics(),
                          scrollDirection: Axis.vertical,
                          itemCount: berthSequenceItems.length,
                          itemBuilder: (BuildContext context, int index) {
                            return ListTile(
                              leadingAndTrailingTextStyle:
                                  kHeaderLabelTextStyle,
                              leading: Text((index + 1).toString()),
                              titleTextStyle: kHeaderLabelTextStyle,
                              title: Text(
                                '${berthSequenceItems[index].vesselName} (${berthSequenceItems[index].arrivalNumber})',
                              ),
                              subtitle: Text(
                                'ETA: ${berthSequenceItems[index].originalETA}',
                              ),
                              trailing: InkWell(
                                onTap:
                                    () async => {
                                      await DialogService(
                                        button: 'done',
                                        origin: widget.title,
                                      ).showBerthingSequenceDetail(
                                        context: context,
                                        berthingSequenceDetail:
                                            berthSequenceItems[index],
                                        mobiAppData: widget.mobiAppData,
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
