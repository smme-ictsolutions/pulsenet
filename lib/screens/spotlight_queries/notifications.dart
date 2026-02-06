import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:customer_portal/constants/styles.dart';
import 'package:customer_portal/database/database_service.dart';
import 'package:customer_portal/model/mobiapp.dart';
import 'package:customer_portal/model/notification.dart';
import 'package:customer_portal/model/singletons_data.dart';
import 'package:customer_portal/shared/dialog.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:web/web.dart' as html;

class NotificationsForm extends StatefulWidget {
  const NotificationsForm({
    super.key,
    required this.title,
    required this.mobiAppData,
  });
  final String title;
  final MobiAppData mobiAppData;

  @override
  State<NotificationsForm> createState() => _NotificationsFormState();
}

class _NotificationsFormState extends State<NotificationsForm> {
  final _key = GlobalKey<ScaffoldState>();
  final GlobalKey<FormFieldState> _keyFormField = GlobalKey<FormFieldState>();
  bool loadingPDF = false;
  List<String> _notificationListData = [];
  List<NotificationItems> _notificationItems = [];
  dynamic _myNotificationDateSelection;
  int selectedIndex = 0;
  final DateTime startDate = DateTime(2024, 04, 25),
      endDate = DateTime.now().add(const Duration(days: 1));
  final TextEditingController _textFilterController = TextEditingController();

  @override
  void initState() {
    getNotificationLogs();
    super.initState();
  }

  void getNotificationLogs() async {
    final daysToGenerate = endDate.difference(startDate).inDays;
    _notificationListData = List.generate(
      daysToGenerate,
      (i) => DateFormat(
        "yyyy-MM-d",
      ).format(DateTime(startDate.year, startDate.month, startDate.day + (i))),
    );
    //_notificationListData = await DatabaseService(null).notificationsListData();
    if (_notificationListData.isEmpty) return;
    _notificationItems = await DatabaseService(null).notificationData(
      _myNotificationDateSelection ?? _notificationListData.last,
    );
    if (!mounted) return;
    setState(() {});
  }

  Future patternMatch(String inputString) async {
    List<NotificationItems> tempNotifications =
        _notificationItems
            .where(
              (element) => element.body!.toUpperCase().contains(
                _textFilterController.text.toUpperCase(),
              ),
            )
            .toList();

    _notificationItems = tempNotifications;
  }

  @override
  void dispose() {
    _textFilterController.dispose();
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
            _notificationListData.isEmpty || imageData.isEmpty
                ? Padding(
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
                    ],
                  ),
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
                                _notificationListData.isNotEmpty
                                    ? DropdownButtonFormField<String>(
                                      key: _keyFormField,
                                      isExpanded: true,
                                      value: _notificationListData.last,
                                      style: kTextStyle,
                                      iconSize: 24,
                                      iconEnabledColor: kColorBar,
                                      iconDisabledColor: kColorNavIcon,
                                      items:
                                          _notificationListData
                                              .map<DropdownMenuItem<String>>((
                                                item,
                                              ) {
                                                return DropdownMenuItem<String>(
                                                  alignment: Alignment.center,
                                                  value: item,
                                                  child: Text(item),
                                                );
                                              })
                                              .toList(),
                                      onChanged: (String? newValue) async {
                                        _textFilterController.clear();
                                        _notificationItems =
                                            await DatabaseService(
                                              null,
                                            ).notificationData(newValue!);
                                        setState(() {});
                                      },
                                      decoration: InputDecoration(
                                        hintText: "Tap to filter by date",
                                        hintStyle: kLabelTextStyle,
                                        filled: true,
                                        fillColor: kColorNavIcon.withValues(
                                          alpha: 0.4,
                                        ),
                                        focusColor: kColorForeground,
                                        floatingLabelBehavior:
                                            FloatingLabelBehavior.never,
                                        prefixIcon: const Icon(
                                          Icons.search,
                                          color: kColorSplash,
                                        ),
                                      ),
                                    )
                                    : Container(),
                          ),
                          Flexible(
                            fit: FlexFit.loose,
                            child: ElevatedButton(
                              onPressed: () async {
                                getNotificationLogs();
                                _textFilterController.clear();
                                _keyFormField.currentState!.reset();
                              },
                              style: ElevatedButton.styleFrom(
                                minimumSize: const Size(40, 50),
                                backgroundColor: kColorBackground,
                                foregroundColor: kColorForeground,
                                textStyle: const TextStyle(fontSize: 20),
                                elevation: 15,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(5),
                                ),
                              ),
                              child: const Text('Refresh'),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Flexible(
                            fit: FlexFit.loose,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: TextFormField(
                                controller: _textFilterController,
                                maxLines: 1,
                                style: kLabelTextStyle,
                                keyboardType: TextInputType.name,
                                decoration: InputDecoration(
                                  hintText:
                                      "Filter notifications by keyword e.g. pier 1",
                                  hintStyle: const TextStyle(color: kColorBar),
                                  suffixIcon: GestureDetector(
                                    onTap: () async {
                                      FocusScope.of(context).unfocus();
                                      _textFilterController.text.isNotEmpty
                                          ? await patternMatch(
                                            _textFilterController.text,
                                          )
                                          : null;
                                    },
                                    child: const Icon(
                                      Icons.arrow_circle_right_outlined,
                                      color: kColorError,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * .4,
                        child: ScrollConfiguration(
                          behavior: ScrollConfiguration.of(context).copyWith(
                            dragDevices: {
                              PointerDeviceKind.touch,
                              PointerDeviceKind.mouse,
                            },
                          ),
                          child: ListView.builder(
                            physics: const AlwaysScrollableScrollPhysics(),
                            scrollDirection: Axis.vertical,
                            shrinkWrap: true,
                            itemCount: _notificationItems.length,
                            itemBuilder: (context, index) {
                              return Row(
                                children: [
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: ListTile(
                                        onTap:
                                            loadingPDF
                                                ? null
                                                : () async {
                                                  if (_notificationItems[index]
                                                          .attachment !=
                                                      "") {
                                                    html.window.open(
                                                      _notificationItems[index]
                                                          .attachment!,
                                                      '_blank',
                                                    );
                                                  } else {
                                                    await DialogService(
                                                      button: 'done',
                                                      origin: widget.title,
                                                    ).showNotificationDetail(
                                                      context: context,
                                                      notificationDetail:
                                                          _notificationItems[index],
                                                      mobiAppData:
                                                          widget.mobiAppData,
                                                      imageData: imageData,
                                                    );
                                                  }
                                                },
                                        leading: Text(
                                          DateFormat("HH:mm").format(
                                            _notificationItems[index].timeSent!,
                                          ),
                                          style: kLabelTextStyle,
                                        ),
                                        title: Text(
                                          '${_notificationItems[index].title!} -attachment: ${_notificationItems[index].attachment == "" ? "No" : "Yes"}',
                                          style: kLabelTextStyle,
                                        ),
                                        subtitle: Text(
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          _notificationItems[index].body!,
                                          style: kLabelTextStyle,
                                        ),
                                        trailing:
                                            loadingPDF && selectedIndex == index
                                                ? const SizedBox(
                                                  width: 15,
                                                  height: 15,
                                                  child:
                                                      CircularProgressIndicator(
                                                        color: kColorError,
                                                      ),
                                                )
                                                : const Icon(
                                                  Icons.arrow_forward,
                                                  color: kColorBar,
                                                ),
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
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
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      ),
    );
  }
}
