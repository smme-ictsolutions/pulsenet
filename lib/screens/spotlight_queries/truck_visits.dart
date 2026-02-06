import 'package:cached_network_image/cached_network_image.dart';
import 'package:customer_portal/constants/styles.dart';
import 'package:customer_portal/model/mobiapp.dart';
import 'package:customer_portal/model/singletons_data.dart';
import 'package:customer_portal/services/mobiapi_service.dart';
import 'package:customer_portal/shared/dialog.dart';
import 'package:customer_portal/shared/upper_case.dart';
import 'package:flutter/material.dart';

class TruckVisitsForm extends StatefulWidget {
  const TruckVisitsForm({
    super.key,
    required this.title,
    required this.mobiAppData,
  });
  final String title;
  final MobiAppData mobiAppData;

  @override
  State<TruckVisitsForm> createState() => _TruckVisitsFormState();
}

class _TruckVisitsFormState extends State<TruckVisitsForm> {
  final _key = GlobalKey<ScaffoldState>();
  final _formKey = GlobalKey<FormState>();
  bool showQueryButton = false, loading = false, isListening = false;
  List<TruckVisitsModel> truckVisitsItems = [];

  final TextEditingController vnlTruckId = TextEditingController();

  @override
  void initState() {
    truckVisitsItems = [];
    super.initState();
  }

  @override
  void dispose() {
    vnlTruckId.dispose();
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
                ? const Align(
                  alignment: Alignment.center,
                  child: CircularProgressIndicator(color: kColorBar),
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
                        children: [
                          Form(
                            key: _formKey,
                            child: Expanded(
                              child: TextFormField(
                                inputFormatters: [UpperCaseTextFormatter()],
                                textCapitalization:
                                    TextCapitalization.characters,
                                controller: vnlTruckId,
                                onChanged: (val) {
                                  if (!mounted) return;
                                  setState(() {
                                    if (val.isEmpty) {
                                      truckVisitsItems.clear();
                                      showQueryButton = false;
                                    } else {
                                      showQueryButton = true;
                                    }
                                  });
                                },
                                style: kButtonTextStyle,
                                keyboardType: TextInputType.name,
                                decoration: userInputDecoration.copyWith(
                                  hintText: 'Enter truck registration',
                                ),
                                validator:
                                    (val) =>
                                        val!.isEmpty
                                            ? 'Truck registration required'
                                            : null,
                              ),
                            ),
                          ),
                        ],
                      ),
                      truckVisitsItems.isEmpty
                          ? Container()
                          : Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 60.0),
                              child: ListView.builder(
                                physics: const ScrollPhysics(),
                                shrinkWrap: true,
                                itemCount: truckVisitsItems.length,
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
                                                    element.title == 'truck',
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
                                      'Gate: ${truckVisitsItems[index].facilityGate}',
                                      style: kListTitleTextStyle,
                                    ),
                                    subtitle: Text(
                                      'Gate: ${truckVisitsItems[index].timeCreated}',
                                      style: kLabelTextStyle,
                                    ),
                                    trailing: InkWell(
                                      onTap:
                                          () async => {
                                            await DialogService(
                                              button: 'done',
                                              origin: widget.title,
                                            ).showTruckVisitsDetail(
                                              context: context,
                                              truckVisitDetail:
                                                  truckVisitsItems[index],
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
                    if (showQueryButton == true) {
                      setState(() {
                        loading = true;
                      });
                      truckVisitsItems = await MobiApiService().getTruckVisits(
                        widget.mobiAppData,
                        vnlTruckId.text,
                      );
                      if (!context.mounted) return;
                      setState(() {
                        loading = false;
                      });
                      if (truckVisitsItems.isEmpty) {
                        await DialogService(
                          button: 'dismiss',
                          origin: 'No Data Returned',
                        ).showSnackBar(context: context);
                      }
                    } else {
                      await DialogService(
                        button: 'dismiss',
                        origin: 'Truck Registration Required',
                      ).showSnackBar(context: context);
                    }
                  },
                  backgroundColor: showQueryButton ? kColorSuccess : kColorText,
                  elevation: 12,
                  disabledElevation: 0,
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
