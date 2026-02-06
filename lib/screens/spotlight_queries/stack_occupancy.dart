import 'package:cached_network_image/cached_network_image.dart';
import 'package:customer_portal/constants/styles.dart';
import 'package:customer_portal/model/mobiapp.dart';
import 'package:customer_portal/model/singletons_data.dart';
import 'package:customer_portal/services/mobiapi_service.dart';
import 'package:customer_portal/shared/dialog.dart';
import 'package:flutter/material.dart';

class StackOccupancyForm extends StatefulWidget {
  const StackOccupancyForm({
    super.key,
    required this.title,
    required this.mobiAppData,
    required this.sector,
  });
  final String title, sector;
  final MobiAppData mobiAppData;
  @override
  State<StackOccupancyForm> createState() => _StackOccupancyFormState();
}

class _StackOccupancyFormState extends State<StackOccupancyForm> {
  final _key = GlobalKey<ScaffoldState>();
  late List<StackOccupancyModel> stackOccupancyItems;
  bool firstFacilitiesRun = true, loading = false;
  int currentIndex = 0;
  String vnlFacility = "";

  @override
  void setState(fn) {
    super.setState(fn);
  }

  @override
  void initState() {
    stackOccupancyItems = [];
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
            body:
                loading
                    ? Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Center(
                          child: const CircularProgressIndicator(
                            color: kColorBar,
                          ),
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
                                            (element) =>
                                                element.title == 'TPTLogo',
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
                                  value: vnlFacility == "" ? null : vnlFacility,
                                  style: kTextStyle,
                                  iconSize: 24,
                                  iconEnabledColor: kColorBar,
                                  iconDisabledColor: kColorNavIcon,
                                  items:
                                      appData.facilitiesList
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
                                  onChanged:
                                      loading
                                          ? null
                                          : (String? newValue) async {
                                            setState(() {
                                              loading = true;
                                              vnlFacility = newValue!;
                                            });
                                            await MobiApiService()
                                                .getStackOccupancy(
                                                  widget.mobiAppData,
                                                  newValue!,
                                                )
                                                .then((value) {
                                                  stackOccupancyItems = value;
                                                  setState(() {
                                                    loading = false;
                                                  });
                                                });

                                            if (!context.mounted) {
                                              return;
                                            }
                                            stackOccupancyItems.isEmpty
                                                ? await DialogService(
                                                  button: 'dismiss',
                                                  origin: 'No data available.',
                                                ).showSnackBar(context: context)
                                                : null;
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
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 5),
                          stackOccupancyItems.isEmpty
                              ? Container()
                              : SizedBox(
                                height: MediaQuery.of(context).size.height * .6,
                                width: MediaQuery.of(context).size.width * .9,
                                child: ListView.builder(
                                  physics:
                                      const AlwaysScrollableScrollPhysics(),
                                  scrollDirection: Axis.vertical,
                                  shrinkWrap: true,
                                  itemCount: stackOccupancyItems.length,
                                  itemBuilder: (context, index) {
                                    return ListTile(
                                      title: Text(
                                        stackOccupancyItems[index].zoneCode,
                                        style: kLabelTextStyle,
                                      ),
                                      subtitle: Text(
                                        'Capacity: ${stackOccupancyItems[index].zoneCapacity} Planned: ${stackOccupancyItems[index].zonePlanned} Used: ${stackOccupancyItems[index].zoneOccupied} Available: ${stackOccupancyItems[index].zoneAvailable}',
                                        style: kLabelTextStyle,
                                      ),
                                      leading: TweenAnimationBuilder(
                                        tween: Tween<double>(
                                          begin: 0,
                                          end:
                                              double.parse(
                                                stackOccupancyItems[index]
                                                    .zoneOccupied,
                                              ) /
                                              double.parse(
                                                stackOccupancyItems[index]
                                                    .zoneCapacity,
                                              ),
                                        ),
                                        duration: Duration(seconds: 10),
                                        builder:
                                            (context, value, _) => Stack(
                                              alignment: Alignment.center,
                                              children: [
                                                Text(
                                                  '${(value * 100).round().toString()}%',
                                                  style: TextStyle(
                                                    color: kColorBar,
                                                  ),
                                                ),
                                                CircularProgressIndicator(
                                                  value: value,
                                                  backgroundColor:
                                                      kColorSuccess,
                                                  color: kColorError,
                                                ),
                                              ],
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
