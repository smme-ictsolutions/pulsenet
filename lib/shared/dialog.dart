import 'package:cached_network_image/cached_network_image.dart';
import 'package:customer_portal/authenticate/register.dart';
import 'package:customer_portal/authenticate/sign_in.dart';
import 'package:customer_portal/constants/styles.dart';
import 'package:customer_portal/database/database_service.dart';
import 'package:customer_portal/main.dart';
import 'package:customer_portal/model/menu.dart';
import 'package:customer_portal/model/mobiapp.dart';
import 'package:customer_portal/model/notification.dart';
import 'package:customer_portal/model/singletons_data.dart';
import 'package:customer_portal/model/user.dart';
import 'package:customer_portal/screens/spotlight_queries/complex_queries/tracktrace_results.dart';
import 'package:customer_portal/shared/upper_case.dart';
import 'package:flutter/material.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

String? _record = 'absent';
List<AvailableSlotsModel> _filteredAvailableSlots = [];

class DialogService {
  String? origin, source;
  String button;
  UserSubscribeData? subscriberData;

  DialogService({
    this.source,
    this.origin,
    required this.button,
    this.subscriberData,
  });

  Future<String> confirmEmail({required BuildContext context}) async {
    await Alert(
      context: context,
      title: origin,
      content: Builder(
        builder: (context) {
          return StatefulBuilder(
            builder: (context, setState) {
              return const Row(
                children: <Widget>[
                  Flexible(
                    child: Text(
                      'An email has just been sent to you, Click the link provided and follow the reset instructions',
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
      buttons: [
        DialogButton(
          onPressed: () {
            _record = 'present';
            Navigator.pop(context);
          },
          child: const Text(
            "Ok",
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
        ),
      ],
    ).show();
    return Future.value(_record);
  }

  Future<String> showNotice({
    required BuildContext context,
    required String assetPath,
  }) async {
    await Alert(
      closeFunction: () {
        _record = 'Yes';
      },
      context: context,
      title: origin,
      content: Builder(
        builder: (context) {
          return StatefulBuilder(
            builder: (context, setState) {
              return Row(
                children: <Widget>[Flexible(child: Image.asset(assetPath))],
              );
            },
          );
        },
      ),
      buttons: [
        DialogButton(
          color: kColorError,
          onPressed: () {
            _record = 'Yes';
            Navigator.pop(context);
          },
          child: Text(
            "Proceed",
            style: TextStyle(
              color: Colors.white,
              fontSize: isMobile ? kFontSizeMediumNormal : kFontSizeSuperNormal,
            ),
          ),
        ),
        DialogButton(
          color: kColorSuccess,
          onPressed: () {
            _record = 'No';
            Navigator.pop(context);
          },
          child: Text(
            "Cancel",
            style: TextStyle(
              color: Colors.white,
              fontSize: isMobile ? kFontSizeMediumNormal : kFontSizeSuperNormal,
            ),
          ),
        ),
      ],
    ).show();
    return Future.value(_record);
  }

  Future<String> confirmDelete({required BuildContext context}) async {
    await Alert(
      context: context,
      title: origin,
      content: Builder(
        builder: (context) {
          return StatefulBuilder(
            builder: (context, setState) {
              return Row(children: <Widget>[Flexible(child: Text(button))]);
            },
          );
        },
      ),
      buttons: [
        DialogButton(
          color: kColorError,
          onPressed: () {
            _record = 'Yes';
            Navigator.pop(context);
          },
          child: const Text(
            "Yes",
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
        ),
        DialogButton(
          color: kColorSuccess,
          onPressed: () {
            _record = 'No';
            Navigator.pop(context);
          },
          child: const Text(
            "No",
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
        ),
      ],
    ).show();
    return Future.value(_record);
  }

  Future<String> confirmError({required BuildContext context}) async {
    await Alert(
      context: context,
      title: origin,
      content: Builder(
        builder: (context) {
          return StatefulBuilder(
            builder: (context, setState) {
              return Row(children: <Widget>[Flexible(child: Text(button))]);
            },
          );
        },
      ),
      buttons: [
        DialogButton(
          color: kColorError,
          onPressed: () {
            _record = 'Ok';
            Navigator.pop(context);
          },
          child: const Text(
            "Ok",
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
        ),
      ],
    ).show();
    return Future.value(_record);
  }

  Future<String> showFlexibleQueryResults({
    required BuildContext context,
    required FlexibleTrackandTraceModel trackTraceItems,
    required MobiAppData mobiAppData,
    required List<ImageData> imageData,
  }) async {
    await Alert(
      context: context,
      title: origin,
      content: Builder(
        builder: (context) {
          return StatefulBuilder(
            builder: (context, setState) {
              return TrackTraceResults(
                trackTraceItems: trackTraceItems,
                mobiAppData: mobiAppData,
                imageData: imageData,
              );
            },
          );
        },
      ),
      buttons: [
        DialogButton(
          color: kColorError,
          onPressed: () {
            _record = 'Ok';
            Navigator.pop(context);
          },
          child: const Text(
            "Ok",
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
        ),
      ],
    ).show();
    return Future.value(_record);
  }

  Future<void> approveUsers({
    required BuildContext context,
    required List<Approvals> pendingSubscribers,
  }) async {
    await Alert(
      context: context,
      title: origin,
      content: Builder(
        builder: (context) {
          List<Approvals> subscribersUpdates =
              pendingSubscribers
                  .where((element) => element.modules.isNotEmpty)
                  .toList();

          return StatefulBuilder(
            builder: (context, setState) {
              return SizedBox(
                height: MediaQuery.of(context).size.height * .5,
                width: MediaQuery.of(context).size.width * .5,
                child:
                    subscribersUpdates.isEmpty
                        ? Center(
                          child: Text(
                            'No users require approval.',
                            style: kTextStyle,
                            textAlign: TextAlign.left,
                          ),
                        )
                        : Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Flexible(
                              fit: FlexFit.loose,
                              child: TextField(
                                onSubmitted: (value) {
                                  value.isEmpty
                                      ? subscribersUpdates =
                                          pendingSubscribers
                                              .where(
                                                (element) =>
                                                    element.modules.isNotEmpty,
                                              )
                                              .toList()
                                      : subscribersUpdates =
                                          pendingSubscribers
                                              .where(
                                                (element) =>
                                                    element.user == value,
                                              )
                                              .toList();
                                  setState(() {});
                                },
                                decoration: InputDecoration(
                                  hintText: 'Filter by email',
                                ),
                                keyboardType: TextInputType.emailAddress,
                              ),
                            ),
                            SizedBox(
                              height: MediaQuery.of(context).size.height * .4,
                              width: MediaQuery.of(context).size.width * .5,
                              child: ListView.builder(
                                physics: const ScrollPhysics(),
                                itemCount: subscribersUpdates.length,
                                itemBuilder: (BuildContext context, int index) {
                                  return SizedBox(
                                    height:
                                        MediaQuery.of(context).size.height * .2,
                                    width:
                                        MediaQuery.of(context).size.width * .5,
                                    child: Card(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(15),
                                        side: BorderSide(color: Colors.black),
                                      ),
                                      elevation: 16,
                                      shadowColor: Colors.red,
                                      child: ListTile(
                                        isThreeLine: true,
                                        title: Text(
                                          subscribersUpdates[index].user,
                                          style: kTextStyle,
                                          textAlign: TextAlign.left,
                                        ),
                                        subtitle: SizedBox(
                                          height: 100,
                                          width: 100,
                                          child: ListView.builder(
                                            itemCount:
                                                subscribersUpdates[index]
                                                    .modules
                                                    .length,
                                            physics: const ScrollPhysics(),
                                            itemBuilder: (
                                              BuildContext context,
                                              int i,
                                            ) {
                                              return Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Text(
                                                    subscribersUpdates[index]
                                                        .modules[i],
                                                    style: kMarkerTextStyle1,
                                                    textAlign: TextAlign.left,
                                                  ),
                                                  ElevatedButton(
                                                    style:
                                                        ElevatedButton.styleFrom(
                                                          backgroundColor:
                                                              kColorSuccess,
                                                        ),
                                                    onPressed: () async {
                                                      await DatabaseService(
                                                            null,
                                                          )
                                                          .removeApprovalsData(
                                                            subscribersUpdates[index]
                                                                .user,
                                                            subscribersUpdates[index]
                                                                .modules[i],
                                                            subscribersUpdates,
                                                          )
                                                          .then((value) {
                                                            setState(() {
                                                              subscribersUpdates =
                                                                  value;
                                                            });
                                                          });
                                                    },
                                                    child: Text(
                                                      'Approve',
                                                      style: TextStyle(
                                                        color: kColorBar,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              );
                                            },
                                          ),
                                        ),
                                        trailing: Container(
                                          decoration: BoxDecoration(
                                            color:
                                                subscribersUpdates[index]
                                                        .modules
                                                        .isEmpty
                                                    ? kColorSuccess
                                                    : kColorError,
                                          ),
                                          child: Text(
                                            subscribersUpdates[index]
                                                    .modules
                                                    .isEmpty
                                                ? 'Approved'
                                                : 'Pending',
                                            style: kTextStyle,
                                            textAlign: TextAlign.left,
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
              );
            },
          );
        },
      ),
      buttons: [
        DialogButton(
          color: kColorError,
          onPressed: () {
            Navigator.pop(context);
          },
          child: Text(
            button,
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
        ),
      ],
    ).show();
  }

  Future<TranshipmentModel> showTranshipmentDialog({
    required BuildContext context,
    required String operationType,
    sector,
  }) async {
    final formKey = GlobalKey<FormState>();
    String transhipType = "", vesselName = "", berthCode = "";
    int newVehicle = 0, heavies = 0, statics = 0, used = 0;
    TranshipmentModel transhipData = TranshipmentModel(
      transhipType: transhipType,
      vesselName: vesselName,
      newVehicle: newVehicle,
      heavies: heavies,
      statics: statics,
      used: used,
    );

    await Alert(
      style: const AlertStyle(
        titleStyle: kHeaderLabelTextStyle,
        backgroundColor: kColorNavIcon,
      ),
      context: context,
      title: origin!,
      content: Builder(
        builder: (context) {
          return StatefulBuilder(
            builder: (context, setState) {
              return Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    DropdownButtonFormField<String>(
                      hint: Text(
                        'Tap to specify transhipment type',
                        style: kLabelTextStyle,
                      ),
                      focusColor: kColorText,
                      dropdownColor: kColorText,
                      style: kLabelTextStyle,
                      validator:
                          (value) =>
                              value == null
                                  ? 'Transhipment type is required'
                                  : null,
                      iconSize: 24,
                      iconEnabledColor: kColorBar,
                      iconDisabledColor: kColorNavIcon,
                      items:
                          [
                            'PRE-CARRIER (Tranship to be Loaded)',
                            'ON-CARRIER (Tranship to be Discharged)',
                          ].map<DropdownMenuItem<String>>((item) {
                            return DropdownMenuItem<String>(
                              value: item,
                              child: Text(item),
                            );
                          }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          transhipType = newValue!;
                        });
                      },
                      decoration: InputDecoration(
                        errorStyle: TextStyle(color: kColorError),
                        hintText: "Tap to select trans type",
                        hintStyle: kLabelTextStyle,
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
                    TextFormField(
                      inputFormatters: [UpperCaseTextFormatter()],
                      textCapitalization: TextCapitalization.characters,
                      style: kButtonTextStyle,
                      keyboardType: TextInputType.name,
                      decoration: userInputDecoration.copyWith(
                        labelText: 'Vessel',
                        hintText: "enter vessel name",
                      ),
                      validator:
                          (val) => val!.isEmpty ? 'Vessel required.' : null,
                      onChanged: (value) => vesselName = (value),
                    ),
                    TextFormField(
                      initialValue: newVehicle.toString(),
                      style: kButtonTextStyle,
                      keyboardType: TextInputType.number,
                      decoration: userInputDecoration.copyWith(
                        labelText: 'New Vehicles',
                        hintText: "enter new vehicles",
                      ),
                      onChanged: (value) => newVehicle = int.parse(value),
                    ),
                    TextFormField(
                      initialValue: newVehicle.toString(),
                      style: kButtonTextStyle,
                      keyboardType: TextInputType.number,
                      decoration: userInputDecoration.copyWith(
                        hintText: "Heavies",
                        labelText: "enter heavies",
                      ),
                      onChanged: (value) => heavies = int.parse(value),
                    ),
                    TextFormField(
                      initialValue: newVehicle.toString(),
                      style: kButtonTextStyle,
                      keyboardType: TextInputType.number,
                      decoration: userInputDecoration.copyWith(
                        hintText: "Statics",
                        labelText: "enter statics",
                      ),
                      onChanged: (value) => statics = int.parse(value),
                    ),
                    TextFormField(
                      initialValue: newVehicle.toString(),
                      style: kButtonTextStyle,
                      keyboardType: TextInputType.number,
                      decoration: userInputDecoration.copyWith(
                        hintText: "Used",
                        labelText: "enter used",
                      ),
                      onChanged: (value) => newVehicle = int.parse(value),
                    ),
                    transhipType == 'PRE-CARRIER (Tranship to be Loaded)'
                        ? DropdownButtonFormField<String>(
                          hint: Text(
                            'Tap to specify berth',
                            style: kLabelTextStyle,
                          ),
                          focusColor: kColorText,
                          dropdownColor: kColorText,
                          style: kLabelTextStyle,
                          validator:
                              (value) =>
                                  value == null ? 'Berth is required' : null,
                          iconSize: 24,
                          iconEnabledColor: kColorBar,
                          iconDisabledColor: kColorNavIcon,
                          items:
                              appData.berthList
                                  .where((element) => element.sector == sector)
                                  .map<DropdownMenuItem<String>>((item) {
                                    return DropdownMenuItem<String>(
                                      value: item.name,
                                      child: Text(item.name),
                                    );
                                  })
                                  .toList(),
                          onChanged: (String? newValue) {
                            setState(() {
                              berthCode = newValue!;
                            });
                          },
                          decoration: InputDecoration(
                            hintText: "Tap to select berth",
                            hintStyle: kLabelTextStyle,
                            filled: true,
                            fillColor: kColorNavIcon.withValues(alpha: 0.4),
                            focusColor: kColorForeground,
                            floatingLabelBehavior: FloatingLabelBehavior.never,
                            prefixIcon: const Icon(
                              Icons.category,
                              color: kColorForeground,
                            ),
                          ),
                        )
                        : Container(),
                  ],
                ),
              );
            },
          );
        },
      ),

      buttons: [
        DialogButton(
          color: kColorSplash,
          onPressed: () {
            transhipData = TranshipmentModel(
              transhipType: transhipType,
              vesselName: vesselName,
              newVehicle: newVehicle,
              heavies: heavies,
              statics: statics,
              used: used,
              berthCode: berthCode,
            );
            Navigator.pop(context);
          },
          child: const Text(
            "Cancel",
            style: TextStyle(color: kColorBar, fontSize: 20),
          ),
        ),
        DialogButton(
          color: kColorSplash,
          onPressed: () {
            if (formKey.currentState!.validate()) {
              transhipData = TranshipmentModel(
                transhipType: transhipType,
                vesselName: vesselName,
                newVehicle: newVehicle,
                heavies: heavies,
                statics: statics,
                used: used,
                berthCode: berthCode,
              );
              Navigator.pop(context);
            }
          },
          child: const Text(
            "Ok",
            style: TextStyle(color: kColorBar, fontSize: 20),
          ),
        ),
      ],
    ).show();

    return Future.value(transhipData);
  }

  Future<void> showSnackBar({required BuildContext context}) async {
    final snackBar = SnackBar(
      duration: setDuration(),
      content: Text(origin!),
      backgroundColor: (Colors.black54),
      action: SnackBarAction(
        textColor: Colors.red,
        label: button,
        onPressed:
            () async => {
              button == "Yes, I accept the conditions"
                  ? await DatabaseService(
                    null,
                  ).setReadPrivacyDisclaimerPreferences().then(
                    (value) => {
                      if (source == "signin" && context.mounted)
                        {
                          Navigator.pop(context),
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => const SignIn()),
                          ),
                        }
                      else if (source == "register" && context.mounted)
                        {
                          Navigator.pop(context),
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => const Register()),
                          ),
                        },
                    },
                  )
                  : null,
            },
      ),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  Duration setDuration() {
    if (button == 'got it!') {
      return const Duration(seconds: 10);
    } else if (button == 'hint') {
      return const Duration(seconds: 10);
    } else if (button == 'Yes, I accept the conditions') {
      return const Duration(seconds: 20);
    } else {
      return const Duration(seconds: 10);
    }
  }

  Future<String> showTruckVisitsDetail({
    required BuildContext context,
    required TruckVisitsModel truckVisitDetail,
    required MobiAppData mobiAppData,
    required List<ImageData> imageData,
  }) async {
    await Alert(
      style: const AlertStyle(
        titleStyle: kHeaderLabelTextStyle,
        backgroundColor: kColorNavIcon,
      ),
      context: context,
      title: origin,
      content: Builder(
        builder: (context) {
          return StatefulBuilder(
            builder: (context, setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Flexible(
                    fit: FlexFit.loose,
                    child: SizedBox(
                      height: MediaQuery.of(context).size.height * .6,
                      width: MediaQuery.of(context).size.width,
                      child: ListView.builder(
                        physics: const ScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: mobiAppData.truckvisitfields!.length,
                        itemBuilder: (BuildContext context, int index) {
                          return ListTile(
                            leading: CachedNetworkImage(
                              errorWidget:
                                  (context, url, error) =>
                                      const Icon(Icons.error),
                              imageUrl:
                                  imageData
                                      .where(
                                        (element) => element.title == 'truck',
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
                              mobiAppData.truckvisitfields![index],
                              style: kListTitleTextStyle,
                            ),
                            subtitle: Text(
                              index == 0
                                  ? truckVisitDetail.truckLicense
                                  : index == 1
                                  ? truckVisitDetail.tripStatus
                                  : index == 2
                                  ? truckVisitDetail.timeCreated
                                  : index == 3
                                  ? truckVisitDetail.inYard
                                  : index == 4
                                  ? truckVisitDetail.outYard
                                  : truckVisitDetail.facilityGate,
                              style: kLabelTextStyle,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
      buttons: [
        DialogButton(
          color: kColorSplash,
          radius: BorderRadius.circular(5),
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text("Done", style: kLabelTextStyle),
        ),
      ],
    ).show();
    return Future.value(_record);
  }

  Future<String> showGCOSTrackTraceDetail({
    required BuildContext context,
    required TrackTraceGCOSModel trackTraceDetail,
    required MobiAppData mobiAppData,
    required List<ImageData> imageData,
  }) async {
    await Alert(
      style: const AlertStyle(
        titleStyle: kHeaderLabelTextStyle,
        backgroundColor: kColorNavIcon,
      ),
      context: context,
      title: origin,
      content: Builder(
        builder: (context) {
          return StatefulBuilder(
            builder: (context, setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Flexible(
                    fit: FlexFit.loose,
                    child: SizedBox(
                      height: MediaQuery.of(context).size.height * .6,
                      width: MediaQuery.of(context).size.width,
                      child: ListView.builder(
                        physics: const ScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: mobiAppData.gcostracktracefields!.length,
                        itemBuilder: (BuildContext context, int index) {
                          return ListTile(
                            leading: CachedNetworkImage(
                              errorWidget:
                                  (context, url, error) =>
                                      const Icon(Icons.error),
                              imageUrl:
                                  imageData
                                      .where(
                                        (element) => element.title == 'track',
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
                              mobiAppData.gcostracktracefields![index],
                              style: kListTitleTextStyle,
                            ),
                            subtitle: Text(
                              index == 0
                                  ? trackTraceDetail.cargoTag1
                                  : index == 1
                                  ? trackTraceDetail.cargoTag2
                                  : index == 2
                                  ? trackTraceDetail.facility
                                  : index == 3
                                  ? trackTraceDetail.arrivalNumber
                                  : index == 4
                                  ? trackTraceDetail.vesselName
                                  : index == 5
                                  ? trackTraceDetail.voyageIn
                                  : index == 6
                                  ? trackTraceDetail.voyageOut
                                  : index == 7
                                  ? trackTraceDetail.inboundMode
                                  : index == 8
                                  ? trackTraceDetail.outboundMode
                                  : index == 9
                                  ? trackTraceDetail.preAdvice
                                  : index == 10
                                  ? trackTraceDetail.orderNumber
                                  : index == 11
                                  ? trackTraceDetail.position
                                  : index == 12
                                  ? trackTraceDetail.receiveDate == ""
                                      ? 'Not Avaialble'
                                      : trackTraceDetail.receiveDate
                                  : index == 13
                                  ? trackTraceDetail.dispatchDate == ""
                                      ? 'Not Available'
                                      : trackTraceDetail.dispatchDate
                                  : trackTraceDetail.status,
                              style: kLabelTextStyle,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
      buttons: [
        DialogButton(
          color: kColorSplash,
          radius: BorderRadius.circular(5),
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text("Done", style: kLabelTextStyle),
        ),
      ],
    ).show();
    return Future.value(_record);
  }

  Future<String> showTrackTraceDetail({
    required BuildContext context,
    required TrackTraceModel trackTraceDetail,
    required MobiAppData mobiAppData,
    required List<ImageData> imageData,
  }) async {
    await Alert(
      style: const AlertStyle(
        titleStyle: kHeaderLabelTextStyle,
        backgroundColor: kColorNavIcon,
      ),
      context: context,
      title: origin,
      content: Builder(
        builder: (context) {
          return StatefulBuilder(
            builder: (context, setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Flexible(
                    fit: FlexFit.loose,
                    child: SizedBox(
                      height: MediaQuery.of(context).size.height * .6,
                      width: MediaQuery.of(context).size.width,
                      child: ListView.builder(
                        physics: const ScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: mobiAppData.tracktracefields!.length,
                        itemBuilder: (BuildContext context, int index) {
                          return ListTile(
                            leading: CachedNetworkImage(
                              errorWidget:
                                  (context, url, error) =>
                                      const Icon(Icons.error),
                              imageUrl:
                                  imageData
                                      .where(
                                        (element) => element.title == 'track',
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
                              mobiAppData.tracktracefields![index],
                              style: kListTitleTextStyle,
                            ),
                            subtitle: Text(
                              index == 0
                                  ? trackTraceDetail.unitNumber
                                  : index == 1
                                  ? trackTraceDetail.facility
                                  : index == 2
                                  ? trackTraceDetail.inboundMode
                                  : index == 3
                                  ? trackTraceDetail.outboundMode
                                  : index == 4
                                  ? trackTraceDetail.tState
                                  : index == 5
                                  ? trackTraceDetail.position
                                  : index == 6
                                  ? trackTraceDetail.timeIn
                                  : index == 7
                                  ? trackTraceDetail.timeOut
                                  : index == 8
                                  ? trackTraceDetail.stopRail
                                  : index == 9
                                  ? trackTraceDetail.stopRoad
                                  : index == 10
                                  ? trackTraceDetail.stopVessel
                                  : index == 11
                                  ? trackTraceDetail.holdsPermissions
                                  : index == 12
                                  ? trackTraceDetail.impediments
                                  : trackTraceDetail.railTrackingPosition,
                              style: kLabelTextStyle,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
      buttons: [
        DialogButton(
          color: kColorSplash,
          radius: BorderRadius.circular(5),
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text("Done", style: kLabelTextStyle),
        ),
      ],
    ).show();
    return Future.value(_record);
  }

  Future<String> showPreAdviceDetail({
    required BuildContext context,
    required PreAdviceModel preAdviceDetail,
    required MobiAppData mobiAppData,
    required List<ImageData> imageData,
  }) async {
    await Alert(
      style: const AlertStyle(
        titleStyle: kHeaderLabelTextStyle,
        backgroundColor: kColorNavIcon,
      ),
      context: context,
      title: origin,
      content: Builder(
        builder: (context) {
          return StatefulBuilder(
            builder: (context, setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Flexible(
                    fit: FlexFit.loose,
                    child: SizedBox(
                      height: MediaQuery.of(context).size.height * .6,
                      width: MediaQuery.of(context).size.width,
                      child: ListView.builder(
                        physics: const ScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: mobiAppData.preadvicefields!.length,
                        itemBuilder: (BuildContext context, int index) {
                          return ListTile(
                            leading: CachedNetworkImage(
                              errorWidget:
                                  (context, url, error) =>
                                      const Icon(Icons.error),
                              imageUrl:
                                  imageData
                                      .where(
                                        (element) => element.title == 'track',
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
                              mobiAppData.preadvicefields![index],
                              style: kListTitleTextStyle,
                            ),
                            subtitle: Text(
                              index == 0
                                  ? preAdviceDetail.unitNumber
                                  : index == 1
                                  ? preAdviceDetail.category
                                  : index == 2
                                  ? preAdviceDetail.vState
                                  : index == 3
                                  ? preAdviceDetail.facility
                                  : index == 4
                                  ? preAdviceDetail.tState
                                  : index == 5
                                  ? preAdviceDetail.timeIn
                                  : index == 6
                                  ? preAdviceDetail.timeOut
                                  : index == 7
                                  ? preAdviceDetail.ibActualVisit
                                  : preAdviceDetail.obActualVisit,
                              style: kLabelTextStyle,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
      buttons: [
        DialogButton(
          color: kColorSplash,
          radius: BorderRadius.circular(5),
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text("Done", style: kLabelTextStyle),
        ),
      ],
    ).show();
    return Future.value(_record);
  }

  Future<String> showBookingReferenceDetail({
    required BuildContext context,
    required BookingReferenceModel bookReferenceDetail,
    required MobiAppData mobiAppData,
    required List<ImageData> imageData,
  }) async {
    await Alert(
      style: const AlertStyle(
        titleStyle: kHeaderLabelTextStyle,
        backgroundColor: kColorNavIcon,
      ),
      context: context,
      title: origin,
      content: Builder(
        builder: (context) {
          return StatefulBuilder(
            builder: (context, setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Flexible(
                    fit: FlexFit.loose,
                    child: SizedBox(
                      height: MediaQuery.of(context).size.height * .6,
                      width: MediaQuery.of(context).size.width,
                      child: ListView.builder(
                        physics: const ScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: mobiAppData.bookreferencefields!.length,
                        itemBuilder: (BuildContext context, int index) {
                          return ListTile(
                            leading: CachedNetworkImage(
                              errorWidget:
                                  (context, url, error) =>
                                      const Icon(Icons.error),
                              imageUrl:
                                  imageData
                                      .where(
                                        (element) => element.title == 'track',
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
                              mobiAppData.bookreferencefields![index],
                              style: kListTitleTextStyle,
                            ),
                            subtitle: Text(
                              index == 0
                                  ? bookReferenceDetail.unitNumber
                                  : index == 1
                                  ? bookReferenceDetail.facility
                                  : index == 2
                                  ? bookReferenceDetail.inboundMode
                                  : index == 3
                                  ? bookReferenceDetail.outboundMode
                                  : index == 4
                                  ? bookReferenceDetail.tState
                                  : index == 5
                                  ? bookReferenceDetail.position
                                  : index == 6
                                  ? bookReferenceDetail.timeIn
                                  : index == 7
                                  ? bookReferenceDetail.timeOut
                                  : index == 8
                                  ? bookReferenceDetail.stopRail
                                  : index == 9
                                  ? bookReferenceDetail.stopRoad
                                  : index == 10
                                  ? bookReferenceDetail.stopVessel
                                  : index == 11
                                  ? bookReferenceDetail.holdsPermissions
                                  : index == 12
                                  ? bookReferenceDetail.impediments
                                  : index == 13
                                  ? bookReferenceDetail.railTrackingPosition
                                  : bookReferenceDetail.railAccountNumber,
                              style: kLabelTextStyle,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
      buttons: [
        DialogButton(
          color: kColorSplash,
          radius: BorderRadius.circular(5),
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text("Done", style: kLabelTextStyle),
        ),
      ],
    ).show();
    return Future.value(_record);
  }

  Future<List<AvailableSlotsModel>> showZoneFilter({
    required BuildContext context,
    required List<AvailableSlotsModel> availableSlots,
  }) async {
    _filteredAvailableSlots = [];
    await Alert(
      style: const AlertStyle(backgroundColor: kColorText),
      context: context,
      title: origin,
      content: Builder(
        builder: (context) {
          return StatefulBuilder(
            builder: (context, setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Flexible(
                    fit: FlexFit.loose,
                    child: Text(
                      "Zone pairs match automatically",
                      style: kMarkerTextStyle,
                    ),
                  ),
                  Flexible(
                    fit: FlexFit.loose,
                    child: SizedBox(
                      height: MediaQuery.of(context).size.height * .6,
                      width: MediaQuery.of(context).size.width,
                      child: ListView.builder(
                        physics: const ScrollPhysics(),
                        itemCount: availableSlots.length,
                        itemBuilder: (BuildContext context, int index) {
                          return CheckboxListTile(
                            contentPadding: EdgeInsets.zero,
                            controlAffinity: ListTileControlAffinity.leading,
                            title: Text(
                              '${availableSlots[index].zoneRule} - ${availableSlots[index].transactionType}',
                              style: kMarkerTextStyle,
                            ),
                            value: _filteredAvailableSlots.contains(
                              availableSlots[index],
                            ),
                            activeColor: kColorSuccess,
                            onChanged: (value) async {
                              setState(() {
                                value == true
                                    ? _filteredAvailableSlots.addAll(
                                      availableSlots
                                          .where(
                                            (element) =>
                                                element.zoneRule ==
                                                availableSlots[index].zoneRule,
                                          )
                                          .toList(),
                                    )
                                    : _filteredAvailableSlots.removeWhere(
                                      ((element) =>
                                          element.zoneRule ==
                                          availableSlots[index].zoneRule),
                                    );
                              });
                            },
                          );
                        },
                      ),
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
      buttons: [
        DialogButton(
          color: kColorSplash,
          onPressed: () {
            _record = 'cancel';
            _filteredAvailableSlots = [];
            Navigator.pop(context);
          },
          child: const Text(
            "Cancel",
            style: TextStyle(color: kColorBar, fontSize: 20),
          ),
        ),
        DialogButton(
          color: kColorSuccess,
          onPressed: () {
            _record = 'done';
            Navigator.pop(context);
          },
          child: const Text(
            "Done",
            style: TextStyle(color: kColorBar, fontSize: 20),
          ),
        ),
      ],
    ).show();
    return Future.value(_filteredAvailableSlots);
  }

  Future<String> showNotificationDetail({
    required BuildContext context,
    required NotificationItems notificationDetail,
    required MobiAppData mobiAppData,
    required List<ImageData> imageData,
  }) async {
    await Alert(
      style: const AlertStyle(
        titleStyle: kHeaderLabelTextStyle,
        backgroundColor: kColorNavIcon,
      ),
      context: context,
      title: origin,
      content: Builder(
        builder: (context) {
          return StatefulBuilder(
            builder: (context, setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Flexible(
                    fit: FlexFit.loose,
                    child: SizedBox(
                      height: MediaQuery.of(context).size.height * .6,
                      width: MediaQuery.of(context).size.width,
                      child: ListView(
                        physics: const ScrollPhysics(),
                        shrinkWrap: true,
                        children: <Widget>[
                          ListTile(
                            title: Text(
                              notificationDetail.body!,
                              style: kLabelTextStyle,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
      buttons: [
        DialogButton(
          color: kColorSplash,
          radius: BorderRadius.circular(5),
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text("Done", style: kHeaderHomeTextStyle),
        ),
      ],
    ).show();
    return Future.value(_record);
  }

  Future<String> showBerthingSequenceDetail({
    required BuildContext context,
    required BerthingSequenceModel berthingSequenceDetail,
    required MobiAppData mobiAppData,
    required List<ImageData> imageData,
  }) async {
    await Alert(
      style: const AlertStyle(
        titleStyle: kHeaderLabelTextStyle,
        backgroundColor: kColorNavIcon,
      ),
      context: context,
      title: origin,
      content: Builder(
        builder: (context) {
          return StatefulBuilder(
            builder: (context, setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Flexible(
                    fit: FlexFit.loose,
                    child: SizedBox(
                      height: MediaQuery.of(context).size.height * .6,
                      width: MediaQuery.of(context).size.width,
                      child: ListView.builder(
                        physics: const ScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: mobiAppData.berthingsequencefields!.length,
                        itemBuilder: (BuildContext context, int index) {
                          return ListTile(
                            leading: CachedNetworkImage(
                              errorWidget:
                                  (context, url, error) =>
                                      const Icon(Icons.error),
                              imageUrl:
                                  imageData
                                      .where(
                                        (element) => element.title == 'ship',
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
                              mobiAppData.berthingsequencefields![index],
                              style: kListTitleTextStyle,
                            ),
                            subtitle: Text(
                              index == 0
                                  ? berthingSequenceDetail.arrivalNumber
                                  : index == 1
                                  ? berthingSequenceDetail.vesselName
                                  : index == 2
                                  ? berthingSequenceDetail.voyageIn
                                  : index == 3
                                  ? berthingSequenceDetail.voyageOut
                                  : index == 4
                                  ? berthingSequenceDetail.agent
                                  : index == 5
                                  ? berthingSequenceDetail.shippingLine
                                  : index == 6
                                  ? berthingSequenceDetail.cutOffDate
                                  : index == 7
                                  ? berthingSequenceDetail.preplanDate
                                  : index == 8
                                  ? berthingSequenceDetail.phase4Date
                                  : index == 9
                                  ? berthingSequenceDetail.originalETA
                                  : index == 10
                                  ? berthingSequenceDetail.etaChanges
                                  : index == 11
                                  ? berthingSequenceDetail.etaPortLimits
                                  : index == 12
                                  ? berthingSequenceDetail.startOperations
                                  : index == 13
                                  ? berthingSequenceDetail.completeOperations
                                  : berthingSequenceDetail.sailingDate,
                              style: kLabelTextStyle,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
      buttons: [
        DialogButton(
          color: kColorSplash,
          radius: BorderRadius.circular(5),
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text("Done", style: kHeaderHomeTextStyle),
        ),
      ],
    ).show();
    return Future.value(_record);
  }

  Future<String> showVesselStatusDetail({
    required BuildContext context,
    required List<VesselStatus> vesselStatus,
    required MobiAppData mobiAppData,
    required String berth,
  }) async {
    VesselStatus vesselStatusDetail =
        vesselStatus.where((element) => element.berth == berth).first;
    await Alert(
      style: AlertStyle(
        titleStyle: kHeaderLabelTextStyle,
        backgroundColor: kColorNavIcon,
      ),
      context: context,
      title: origin,
      content: Builder(
        builder: (context) {
          return StatefulBuilder(
            builder: (context, setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Flexible(
                    fit: FlexFit.loose,
                    child: SizedBox(
                      height: MediaQuery.of(context).size.height * .6,
                      width: MediaQuery.of(context).size.width * .6,
                      child: ListView.builder(
                        physics: const ScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: mobiAppData.vesselstatusfields!.length,
                        itemBuilder: (BuildContext context, int index) {
                          return ListTile(
                            title: Text(
                              mobiAppData.vesselstatusfields![index],
                              style: kListTitleTextStyle,
                            ),
                            subtitle: Text(
                              index == 0
                                  ? vesselStatusDetail.visitID
                                  : index == 1
                                  ? vesselStatusDetail.facility
                                  : index == 2
                                  ? vesselStatusDetail.carrierService
                                  : index == 3
                                  ? vesselStatusDetail.vesselName
                                  : index == 4
                                  ? vesselStatusDetail.vesselClass
                                  : index == 5
                                  ? vesselStatusDetail.berth
                                  : index == 6
                                  ? vesselStatusDetail.bollardFore
                                  : index == 7
                                  ? vesselStatusDetail.bollardAft
                                  : index == 8
                                  ? vesselStatusDetail.inboundVoyage
                                  : index == 9
                                  ? vesselStatusDetail.outboundVoyage
                                  : index == 10
                                  ? vesselStatusDetail.workingPhase
                                  : index == 11
                                  ? vesselStatusDetail.estimatedArrivalTime
                                  : index == 12
                                  ? vesselStatusDetail.plannedArrivalTime
                                  : index == 13
                                  ? vesselStatusDetail.estimatedDepartedTime
                                  : index == 14
                                  ? vesselStatusDetail.plannedDepartureTime
                                  : index == 15
                                  ? vesselStatusDetail.actualArrivalTime
                                  : index == 16
                                  ? vesselStatusDetail.actualDepartureTime
                                  : index == 17
                                  ? vesselStatusDetail.beginReceive
                                  : index == 18
                                  ? vesselStatusDetail.reeferCutOff
                                  : index == 19
                                  ? vesselStatusDetail.dryCutOff
                                  : index == 20
                                  ? vesselStatusDetail.hazCutOff
                                  : index == 21
                                  ? vesselStatusDetail.outboundUnitCount
                                  : index == 22
                                  ? vesselStatusDetail.outboundLoadCount
                                  : index == 23
                                  ? vesselStatusDetail.inboundUnitCount
                                  : vesselStatusDetail.inboundDischargeCount,
                              style: kLabelTextStyle,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),

      buttons: [
        DialogButton(
          color: kColorSplash,
          radius: BorderRadius.circular(5),
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text("Done", style: kHeaderHomeTextStyle),
        ),
      ],
    ).show();
    return Future.value(_record);
  }
}
