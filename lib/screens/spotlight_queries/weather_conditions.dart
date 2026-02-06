import 'package:cached_network_image/cached_network_image.dart';
import 'package:customer_portal/constants/styles.dart';
import 'package:customer_portal/database/database_service.dart';
import 'package:customer_portal/model/mobiapp.dart';
import 'package:customer_portal/model/singletons_data.dart';
import 'package:customer_portal/model/user.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class WeatherForm extends StatefulWidget {
  const WeatherForm({
    super.key,
    required this.imageData,
    required this.facilityCode,
    required this.sector,
  });
  final List<ImageData> imageData;
  final String facilityCode, sector;

  @override
  State<WeatherForm> createState() => _WeatherFormState();
}

class _WeatherFormState extends State<WeatherForm> {
  final _key = GlobalKey<ScaffoldState>();
  var weatherURL = 'https://iweathar.co.za/';
  var loadingPercentage = 0;
  final Set<Factory<DragGestureRecognizer>> gestureRecognizers = {
    Factory(() => VerticalDragGestureRecognizer()),
  };
  List<LookUpData> _portList = [];
  InAppWebViewController? _webViewController;

  void getLookups() async {
    _portList =
        appData.portList
            .where((element) => element.sector == widget.sector)
            .toList();
    if (!mounted) return;
    setState(() {});
  }

  Future<void> getWeatherBot() async {
    await DatabaseService(null)
        .weatherStationData(widget.facilityCode)
        .then(
          (value) => setState(() {
            weatherURL = 'https://iweathar.co.za/display?s_id=$value';
          }),
        );
  }

  @override
  void initState() {
    widget.facilityCode == "" ? getLookups() : getWeatherBot();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.85,
      width: MediaQuery.of(context).size.width,
      child: Scaffold(
        extendBody: true,
        extendBodyBehindAppBar: true,
        backgroundColor: Colors.transparent,
        key: _key,
        resizeToAvoidBottomInset: false,
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              widget.facilityCode != ""
                  ? Container()
                  : Padding(
                    padding: const EdgeInsets.all(8.0),
                    child:
                        _portList.isEmpty
                            ? const CircularProgressIndicator(
                              color: kColorError,
                            )
                            : Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Expanded(
                                  flex: 1,
                                  child: DropdownButtonFormField<String>(
                                    style: kTextStyle,
                                    iconSize: 24,
                                    iconEnabledColor: kColorBar,
                                    iconDisabledColor: kColorNavIcon,
                                    items:
                                        _portList.map<DropdownMenuItem<String>>(
                                          (item) {
                                            return DropdownMenuItem<String>(
                                              value: item.name,
                                              child: Text(item.name),
                                            );
                                          },
                                        ).toList(),
                                    onChanged: (String? newValue) async {
                                      await DatabaseService(null)
                                          .weatherStationData(newValue!)
                                          .then(
                                            (
                                              value,
                                            ) => _webViewController!.loadUrl(
                                              urlRequest: URLRequest(
                                                url: WebUri(
                                                  'https://iweathar.co.za/display?s_id=$value',
                                                ),
                                              ),
                                            ),
                                          );
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
                                CachedNetworkImage(
                                  errorWidget:
                                      (context, url, error) =>
                                          const Icon(Icons.error),
                                  imageUrl:
                                      widget.imageData
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
                              ],
                            ),
                  ),
              Flexible(
                fit: FlexFit.loose,
                child: Stack(
                  children: [
                    inAppWebViewWidget(context),
                    if (loadingPercentage < 100)
                      LinearProgressIndicator(
                        color: kColorBar,
                        value: loadingPercentage / 100.0,
                      ),
                  ],
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

  Widget inAppWebViewWidget(BuildContext context) {
    return InAppWebView(
      initialUrlRequest: URLRequest(url: WebUri(weatherURL)),
      onWebViewCreated: (InAppWebViewController controller) {
        _webViewController = controller;
      },
      onLoadStart: (controller, url) {
        debugPrint('Page started loading: $url');

        if (!mounted) return;
        setState(() {
          loadingPercentage = 0;
        });
      },
      onProgressChanged: (controller, progress) {
        if (!mounted) return;
        setState(() {
          loadingPercentage = progress;
        });
      },
      onLoadStop: (controller, url) {
        debugPrint('Page finished loading: $url');
        if (!mounted) return;
        setState(() {
          loadingPercentage = 100;
        });
      },
      shouldOverrideUrlLoading: (controller, action) async {
        final Uri url;
        if (action.request.url != null) {
          url = action.request.url!;
        } else {
          return NavigationActionPolicy.CANCEL;
        }
        if (url.toString().contains('iweathar')) {
          return NavigationActionPolicy.ALLOW;
        }
        return NavigationActionPolicy.CANCEL;
      },
    );
  }
}
