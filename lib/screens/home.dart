import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:customer_portal/authenticate/register.dart';
import 'package:customer_portal/authenticate/sign_in.dart';
import 'package:customer_portal/constants/styles.dart';
import 'package:customer_portal/database/database_service.dart';
import 'package:customer_portal/main.dart';
import 'package:customer_portal/model/menu.dart';
import 'package:customer_portal/model/mobiapp.dart';
import 'package:customer_portal/model/singletons_data.dart';
import 'package:customer_portal/model/user.dart';
import 'package:customer_portal/screens/settings.dart';
import 'package:customer_portal/screens/spotlight_queries/vessel_status/terminal_layout.dart';
import 'package:customer_portal/services/auth.dart';
import 'package:customer_portal/services/mobiapi_service.dart';
import 'package:customer_portal/services/weather_service.dart';
import 'package:customer_portal/shared/autoscroll_marquee.dart';
import 'package:customer_portal/shared/dialog.dart';
import 'package:customer_portal/shared/email.dart';
import 'package:customer_portal/shared/modal_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class Home extends StatefulWidget {
  const Home({super.key, this.mobiAppData});

  final MobiAppData? mobiAppData;
  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home>
    with WidgetsBindingObserver, TickerProviderStateMixin {
  bool loading = false, facilitiesError = false, fetchFacilities = true;
  Timer? _rootTimer = Timer(const Duration(milliseconds: 1), () {});
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();
  int currentSectorIndex = 0;
  final TextEditingController _textSector = TextEditingController();
  late StreamSubscription _subscription, _facilitiesSubscription;
  List<Approvals> _pendingApprovals = [];
  List<MenuList> _menuList = [];
  UserSubscribeData _userData = UserSubscribeData(isAdmin: false);

  Future<void> initializeTimer() async {
    if (_rootTimer != null) _rootTimer!.cancel();
    const time = Duration(hours: 1);
    _rootTimer = Timer(time, () async {
      Navigator.pop(context);
      Navigator.of(
        context,
      ).push(MaterialPageRoute(builder: (_) => const SignIn()));
      await context.read<AuthService>().signOut();
      _rootTimer!.cancel();
    });
  }

  Future<void> _handleUserInteraction() async {
    if (!_rootTimer!.isActive) {
      // This means the user has been logged out
      return;
    }
    _rootTimer!.cancel();
  }

  //get transaction data
  void getTransactionData() async {
    await DatabaseService(null).transactionListData();
    await DatabaseService(null).pendingUserApprovals().then((value) {
      _pendingApprovals = value;
      setState(() {});
    });
  }

  //get menu data
  void getMenuData() async {
    await DatabaseService(null).menuListData(_textSector.text, _userData).then((
      value,
    ) {
      _menuList = value;
      setState(() {});
    });
  }

  //get facilities data
  void getFacilitiesData() async {
    MobiAppData mobiAppData = Provider.of<MobiAppData>(context, listen: false);
    mobiAppData.productionUser == null || _textSector.text == 'documents'
        ? fetchFacilities = false
        : _facilitiesSubscription = MobiApiService()
            .streamGcosFacilitiesList(mobiAppData, _textSector.text)
            .timeout(
              const Duration(seconds: 30),
              onTimeout: (EventSink<List<FacilityItems>> sink) async {
                debugPrint('Timeout occurred');
                if (!mounted) return;
                await DialogService(
                  button: 'dismiss',
                  origin:
                      'Oops we encountered a technical issue, please restart the app or try again later.',
                ).showSnackBar(context: context);
                sink.add([]);
                _facilitiesSubscription.cancel();
                setState(() {
                  facilitiesError = true;
                  fetchFacilities = false;
                });
              },
            )
            .listen(
              (data) {
                try {
                  if (data.isNotEmpty) {
                    appData.facilitiesList = data;
                    _facilitiesSubscription.cancel();
                    setState(() {
                      facilitiesError = false;
                      fetchFacilities = false;
                    });
                  }
                } catch (e) {
                  debugPrint('Error in _sectorControllerChange: $e');
                  _facilitiesSubscription.cancel();
                  setState(() {
                    facilitiesError = true;
                    fetchFacilities = false;
                  });
                }
              },
              onError: (data) {
                debugPrint('Caught the error');
                setState(() {
                  facilitiesError = true;
                  fetchFacilities = false;
                });
              },
              cancelOnError: true,
            );
  }

  void _sectorControllerChange() {
    appData.facilitiesList = [];
    getFacilitiesData();
    if (_textSector.text == 'container') {
      return;
    }
  }

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    getTransactionData();
    _textSector.addListener(_sectorControllerChange);
    _subscription = WeatherService().createWeatherList().listen(
      (data) {
        if (data.isEmpty) {
          return;
        }
        appData.weatherData = data;
      },
      onDone: () {
        setState(() {});
      },
    );
    super.initState();
  }

  @override
  void dispose() {
    if (!mounted) return;
    _subscription.cancel();
    _facilitiesSubscription.cancel();
    _textSector.dispose();
    super.dispose();
  }

  @override
  Future<void> didChangeAppLifecycleState(AppLifecycleState state) async {
    super.didChangeAppLifecycleState(state);
    switch (state) {
      case AppLifecycleState.inactive:
        debugPrint('appLifeCycleState inactive');
        break;
      case AppLifecycleState.resumed:
        await _handleUserInteraction();
        debugPrint('appLifeCycleState resumed');
        break;
      case AppLifecycleState.paused:
        await initializeTimer();
        debugPrint('appLifeCycleState paused');
        break;
      case AppLifecycleState.detached:
        await initializeTimer();
        debugPrint('appLifeCycleState detached');

        break;
      case AppLifecycleState.hidden:
        await initializeTimer();
        debugPrint('appLifeCycleState hidden');
    }
  }

  @override
  Widget build(BuildContext context) {
    List<ImageData> imageData = appData.imageData;
    return loading || imageData.isEmpty
        ? CircularProgressIndicator(color: kColorBar)
        : StreamBuilder<MobiAppData>(
          stream: DatabaseService(null).mobiAppData,
          builder: (context, mobidata) {
            if (mobidata.hasData) {
              appData.mobiAppData = mobidata.data!;
              return StreamBuilder<UserSubscribeData>(
                stream: DatabaseService(null).subscriptionData,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    currentUserEmail = snapshot.data!.email!;
                    _textSector.text.isEmpty
                        ? _textSector.text = snapshot.data!.sector!.first
                        : null;
                    _userData = snapshot.data!;
                    getMenuData();
                    return SafeArea(
                      child: Scaffold(
                        key: _scaffoldKey,
                        extendBodyBehindAppBar: false,
                        resizeToAvoidBottomInset: false,
                        backgroundColor: kColorScaffoldBackground,
                        endDrawer: SizedBox(
                          height: MediaQuery.of(context).size.height * .95,
                          child: Drawer(
                            width: MediaQuery.of(context).size.width - 50,
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(20),
                                bottomLeft: Radius.circular(20),
                              ),
                            ),
                            child: SettingsForm(
                              sector: _textSector.text,
                              subscribeData: snapshot.data!,
                              imageData: imageData,
                            ),
                          ),
                        ),
                        body: CachedNetworkImage(
                          errorWidget:
                              (context, url, error) => const Icon(Icons.error),
                          imageUrl:
                              imageData
                                  .where(
                                    (element) =>
                                        element.title == "homebackground",
                                  )
                                  .first
                                  .url,
                          imageBuilder:
                              (context, imageProvider) => Container(
                                decoration: BoxDecoration(
                                  image: DecorationImage(
                                    opacity: .7,
                                    image: imageProvider,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.max,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Card(
                                      color: Colors.black.withValues(alpha: .7),
                                      child: Column(
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Flexible(
                                                fit: FlexFit.loose,
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                        top: 15.0,
                                                      ),
                                                  child: IconButton(
                                                    color: kColorBar,
                                                    onPressed: () {
                                                      showPopupMenu(
                                                        imageData,
                                                        mobidata.data!,
                                                        snapshot.data!.isAdmin,
                                                      );
                                                    },
                                                    icon: const Icon(
                                                      Icons.menu,
                                                      size: 30,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              Flexible(
                                                fit: FlexFit.loose,
                                                child: FittedBox(
                                                  fit: BoxFit.contain,
                                                  child: Text(
                                                    snapshot.data!.username!,
                                                    style: kHeaderHomeTextStyle,
                                                  ),
                                                ),
                                              ),
                                              Flexible(
                                                fit: FlexFit.loose,
                                                child: FittedBox(
                                                  fit: BoxFit.contain,
                                                  child: Text(
                                                    snapshot.data!.stakeholder!,
                                                    style: kHeaderHomeTextStyle,
                                                  ),
                                                ),
                                              ),
                                              Expanded(
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                        top: 8.0,
                                                      ),
                                                  child: CachedNetworkImage(
                                                    errorWidget:
                                                        (context, url, error) =>
                                                            const Icon(
                                                              Icons.error,
                                                            ),
                                                    imageUrl:
                                                        imageData
                                                            .where(
                                                              (element) =>
                                                                  element
                                                                      .title ==
                                                                  'TPTLogo',
                                                            )
                                                            .first
                                                            .url,
                                                    imageBuilder:
                                                        (
                                                          context,
                                                          imageProvider,
                                                        ) => Container(
                                                          width: 80,
                                                          height: 80,
                                                          decoration: BoxDecoration(
                                                            image: DecorationImage(
                                                              image:
                                                                  imageProvider,
                                                              fit:
                                                                  BoxFit
                                                                      .contain,
                                                              alignment:
                                                                  Alignment
                                                                      .topRight,
                                                            ),
                                                          ),
                                                        ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          if (appData.weatherData.isNotEmpty)
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Flexible(
                                                  fit: FlexFit.tight,
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                          left: 8.0,
                                                        ),
                                                    child: Column(
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .start,
                                                      children: [
                                                        FittedBox(
                                                          fit: BoxFit.contain,
                                                          child: Text(
                                                            appData.weatherData
                                                                .where(
                                                                  (element) =>
                                                                      element
                                                                          .cityName ==
                                                                      snapshot
                                                                          .data!
                                                                          .port!
                                                                          .first,
                                                                )
                                                                .first
                                                                .cityName,
                                                            style:
                                                                kHeaderHomeTextStyle,
                                                          ),
                                                        ),
                                                        Flexible(
                                                          fit: FlexFit.loose,
                                                          child: Text(
                                                            DateFormat(
                                                              "HH:mm - EEEE,dd MMM yy",
                                                            ).format(
                                                              appData
                                                                  .weatherData
                                                                  .where(
                                                                    (element) =>
                                                                        element
                                                                            .cityName ==
                                                                        snapshot
                                                                            .data!
                                                                            .port!
                                                                            .first,
                                                                  )
                                                                  .first
                                                                  .date!
                                                                  .toDate(),
                                                            ),
                                                            style:
                                                                kLabelTextStyle,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                                Row(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    Column(
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .start,
                                                      children: [
                                                        Flexible(
                                                          fit: FlexFit.loose,
                                                          child: Text(
                                                            "${appData.weatherData.where((element) => element.cityName == snapshot.data!.port!.first).first.temperature.toStringAsFixed(0)}\u2103",
                                                            style:
                                                                kHeaderHomeTextStyle,
                                                          ),
                                                        ),
                                                        Flexible(
                                                          fit: FlexFit.loose,
                                                          child: Text(
                                                            appData.weatherData
                                                                .where(
                                                                  (element) =>
                                                                      element
                                                                          .cityName ==
                                                                      snapshot
                                                                          .data!
                                                                          .port!
                                                                          .first,
                                                                )
                                                                .first
                                                                .description!,
                                                            style:
                                                                kLabelTextStyle,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    Flexible(
                                                      fit: FlexFit.loose,
                                                      child: CachedNetworkImage(
                                                        progressIndicatorBuilder: (
                                                          context,
                                                          url,
                                                          progress,
                                                        ) {
                                                          return Center(
                                                            child: CircularProgressIndicator(
                                                              value:
                                                                  progress
                                                                      .progress,
                                                            ),
                                                          );
                                                        },
                                                        errorWidget:
                                                            (
                                                              context,
                                                              url,
                                                              error,
                                                            ) => const Icon(
                                                              Icons.error,
                                                            ),
                                                        imageUrl:
                                                            "${appData.apiWeatherIcon}${appData.weatherData.where((element) => element.cityName == snapshot.data!.port!.first).first.icon}.png",
                                                        imageBuilder:
                                                            (
                                                              context,
                                                              imageProvider,
                                                            ) => Container(
                                                              width: 80,
                                                              height: 80,
                                                              decoration: BoxDecoration(
                                                                image: DecorationImage(
                                                                  image:
                                                                      imageProvider,
                                                                  fit:
                                                                      BoxFit
                                                                          .contain,
                                                                  alignment:
                                                                      Alignment
                                                                          .topRight,
                                                                ),
                                                              ),
                                                            ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          if (appData.weatherData.isNotEmpty)
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                right: 8.0,
                                              ),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.max,
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceEvenly,
                                                children: [
                                                  Flexible(
                                                    fit: FlexFit.loose,
                                                    child: CachedNetworkImage(
                                                      progressIndicatorBuilder: (
                                                        context,
                                                        url,
                                                        progress,
                                                      ) {
                                                        return Center(
                                                          child:
                                                              CircularProgressIndicator(
                                                                value:
                                                                    progress
                                                                        .progress,
                                                              ),
                                                        );
                                                      },
                                                      errorWidget:
                                                          (
                                                            context,
                                                            url,
                                                            error,
                                                          ) => const Icon(
                                                            Icons.error,
                                                          ),
                                                      imageUrl:
                                                          imageData
                                                              .where(
                                                                (element) =>
                                                                    element
                                                                        .title ==
                                                                    'windsock',
                                                              )
                                                              .first
                                                              .url,
                                                      imageBuilder:
                                                          (
                                                            context,
                                                            imageProvider,
                                                          ) => Container(
                                                            width: 40,
                                                            height: 40,
                                                            decoration: BoxDecoration(
                                                              image: DecorationImage(
                                                                image:
                                                                    imageProvider,
                                                                fit:
                                                                    BoxFit
                                                                        .contain,
                                                                alignment:
                                                                    Alignment
                                                                        .topRight,
                                                              ),
                                                            ),
                                                          ),
                                                    ),
                                                  ),
                                                  Flexible(
                                                    fit: FlexFit.loose,
                                                    flex: 0,
                                                    child: Text(
                                                      " ${appData.weatherData.where((element) => element.cityName == snapshot.data!.port!.first).first.windSpeed.toStringAsFixed(0)} km/h",
                                                      style: kButtonTextStyle,
                                                    ),
                                                  ),
                                                  Flexible(
                                                    fit: FlexFit.loose,
                                                    child: CachedNetworkImage(
                                                      progressIndicatorBuilder: (
                                                        context,
                                                        url,
                                                        progress,
                                                      ) {
                                                        return Center(
                                                          child:
                                                              CircularProgressIndicator(
                                                                value:
                                                                    progress
                                                                        .progress,
                                                              ),
                                                        );
                                                      },
                                                      errorWidget:
                                                          (
                                                            context,
                                                            url,
                                                            error,
                                                          ) => const Icon(
                                                            Icons.error,
                                                          ),
                                                      imageUrl:
                                                          imageData
                                                              .where(
                                                                (element) =>
                                                                    element
                                                                        .title ==
                                                                    'windgust',
                                                              )
                                                              .first
                                                              .url,
                                                      imageBuilder:
                                                          (
                                                            context,
                                                            imageProvider,
                                                          ) => Container(
                                                            width: 40,
                                                            height: 40,
                                                            decoration: BoxDecoration(
                                                              image: DecorationImage(
                                                                image:
                                                                    imageProvider,
                                                                fit:
                                                                    BoxFit
                                                                        .contain,
                                                                alignment:
                                                                    Alignment
                                                                        .topRight,
                                                              ),
                                                            ),
                                                          ),
                                                    ),
                                                  ),
                                                  Flexible(
                                                    fit: FlexFit.loose,
                                                    flex: 0,
                                                    child: Text(
                                                      "${appData.weatherData.where((element) => element.cityName == snapshot.data!.port!.first).first.windGust.toStringAsFixed(0)} km/h",
                                                      style: kButtonTextStyle,
                                                    ),
                                                  ),
                                                  Flexible(
                                                    fit: FlexFit.loose,
                                                    child: CachedNetworkImage(
                                                      errorWidget:
                                                          (
                                                            context,
                                                            url,
                                                            error,
                                                          ) => const Icon(
                                                            Icons.error,
                                                          ),
                                                      imageUrl:
                                                          imageData
                                                              .where(
                                                                (element) =>
                                                                    element
                                                                        .title ==
                                                                    'swell',
                                                              )
                                                              .first
                                                              .url,
                                                      imageBuilder:
                                                          (
                                                            context,
                                                            imageProvider,
                                                          ) => Container(
                                                            width: 40,
                                                            height: 40,
                                                            decoration: BoxDecoration(
                                                              image: DecorationImage(
                                                                image:
                                                                    imageProvider,
                                                                fit:
                                                                    BoxFit
                                                                        .contain,
                                                                alignment:
                                                                    Alignment
                                                                        .topRight,
                                                              ),
                                                            ),
                                                          ),
                                                    ),
                                                  ),
                                                  Flexible(
                                                    fit: FlexFit.loose,
                                                    flex: 0,
                                                    child: Text(
                                                      " ${appData.weatherData.where((element) => element.cityName == snapshot.data!.port!.first).first.sealevel - appData.weatherData.where((element) => element.cityName == snapshot.data!.port!.first).first.grndlevel} m",
                                                      style: kButtonTextStyle,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          const Divider(
                                            indent: 5,
                                            endIndent: 5,
                                            color: kColorBar,
                                          ),
                                          if (appData.weatherData.isNotEmpty)
                                            AutoScrollMarquee(
                                              items: [appData.weatherData],
                                              imageData: imageData,
                                            ),
                                        ],
                                      ),
                                    ),
                                    const Divider(
                                      thickness: 3,
                                      indent: 20,
                                      endIndent: 20,
                                      color: kColorBar,
                                    ),
                                    if (fetchFacilities)
                                      CircularProgressIndicator(
                                        color: kColorError,
                                        constraints: BoxConstraints(
                                          minHeight: 20,
                                          minWidth: 20,
                                          maxHeight: 20,
                                          maxWidth: 20,
                                        ),
                                      ),
                                    snapshot.data!.sector!.length == 1
                                        ? Padding(
                                          padding: const EdgeInsets.only(
                                            left: 8.0,
                                            right: 8.0,
                                          ),
                                          child: TextFormField(
                                            decoration: InputDecoration(
                                              enabledBorder: InputBorder.none,
                                            ),
                                            controller: _textSector,
                                            textAlign: TextAlign.center,
                                            showCursor: false,
                                            readOnly: true,
                                            style: kHeaderHomeBlackTextStyle,
                                          ),
                                        )
                                        : Expanded(
                                          flex: 0,
                                          child: Card(
                                            color: Colors.black.withValues(
                                              alpha: .7,
                                            ),
                                            child: TextFormField(
                                              controller: _textSector,
                                              textAlign: TextAlign.center,
                                              style: kButtonTextStyle,
                                              showCursor: false,
                                              readOnly: true,
                                              decoration: InputDecoration(
                                                prefixIconColor:
                                                    currentSectorIndex == 0
                                                        ? kColorText
                                                        : kColorBar,
                                                suffixIconColor:
                                                    currentSectorIndex ==
                                                            snapshot
                                                                    .data!
                                                                    .sector!
                                                                    .length -
                                                                1
                                                        ? kColorText
                                                        : kColorBar,
                                                prefixIcon: InkWell(
                                                  onTap: () {
                                                    currentSectorIndex == 0
                                                        ? null
                                                        : setState(() {
                                                          currentSectorIndex =
                                                              currentSectorIndex -
                                                              1;
                                                          _textSector.text =
                                                              snapshot
                                                                  .data!
                                                                  .sector![currentSectorIndex];
                                                        });
                                                  },
                                                  child: const Icon(
                                                    Icons.keyboard_arrow_left,
                                                    size: 40,
                                                  ),
                                                ),
                                                suffixIcon: InkWell(
                                                  onTap: () {
                                                    currentSectorIndex ==
                                                            snapshot
                                                                    .data!
                                                                    .sector!
                                                                    .length -
                                                                1
                                                        ? null
                                                        : setState(() {
                                                          currentSectorIndex =
                                                              currentSectorIndex +
                                                              1;
                                                          _textSector.text =
                                                              snapshot
                                                                  .data!
                                                                  .sector![currentSectorIndex];
                                                        });
                                                  },
                                                  child: const Icon(
                                                    Icons.keyboard_arrow_right,
                                                    size: 40,
                                                  ),
                                                ),
                                                border: InputBorder.none,
                                              ),
                                            ),
                                          ),
                                        ),
                                    const Divider(
                                      thickness: 3,
                                      indent: 20,
                                      endIndent: 20,
                                      color: kColorBar,
                                    ),
                                    Expanded(
                                      child: Card(
                                        color: Colors.black.withValues(
                                          alpha: .7,
                                        ),
                                        child:
                                            _menuList.isNotEmpty
                                                ? GridView.builder(
                                                  physics:
                                                      const ScrollPhysics(),
                                                  shrinkWrap: true,
                                                  gridDelegate:
                                                      SliverGridDelegateWithFixedCrossAxisCount(
                                                        crossAxisCount:
                                                            MediaQuery.of(
                                                                      context,
                                                                    ).orientation ==
                                                                    Orientation
                                                                        .landscape
                                                                ? 3
                                                                : 3,
                                                        mainAxisSpacing: 5.0,
                                                        crossAxisSpacing: 5.0,
                                                      ),
                                                  itemCount:
                                                      appData
                                                              .facilitiesList
                                                              .isEmpty
                                                          ? _menuList
                                                              .where(
                                                                (element) =>
                                                                    element
                                                                        .needsFacilitySelection ==
                                                                    false,
                                                              )
                                                              .length
                                                          : _menuList.length,
                                                  itemBuilder: (
                                                    context,
                                                    index,
                                                  ) {
                                                    return _cardMenuService(
                                                      context,
                                                      appData
                                                              .facilitiesList
                                                              .isEmpty
                                                          ? _menuList
                                                              .where(
                                                                (element) =>
                                                                    element
                                                                        .needsFacilitySelection ==
                                                                    false,
                                                              )
                                                              .toList()
                                                          : _menuList,
                                                      index,
                                                      imageData,
                                                      mobidata.data!,
                                                      snapshot.data!,
                                                    );
                                                  },
                                                )
                                                : Container(),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                        ),
                      ),
                    );
                  } else {
                    return Container();
                  }
                },
              );
            } else {
              return Container();
            }
          },
        );
  }

  void showPopupMenu(
    List<ImageData>? imageData,
    MobiAppData mobiAppData,
    bool isAdmin,
  ) {
    showMenu<String>(
      context: context,
      position: const RelativeRect.fromLTRB(0, 25.0, 0.0, 0.0),
      items: [
        const PopupMenuItem<String>(value: '1', child: Text('Settings')),
        const PopupMenuItem<String>(value: '2', child: Text('App Walkthrough')),
        const PopupMenuItem<String>(value: '3', child: Text('Logout')),
        PopupMenuItem<String>(
          value: '4',
          child: Text(
            'Build: ${appData.appVersion}',
            style: kSubTitleTextStyle,
          ),
        ),
        const PopupMenuItem<String>(value: '5', child: Text('Delete Account')),
        const PopupMenuItem<String>(value: '6', child: Text('Privacy Notice')),

        PopupMenuItem<String>(
          value: '7',
          child: Text(
            'Administration',
            style: !isAdmin ? TextStyle(color: Colors.transparent) : null,
          ),
        ),
        PopupMenuItem<String>(value: '8', child: Text('Contact')),
      ],
      elevation: 8.0,
    ).then((value) async {
      if (value == null) return;

      if (value == "1") {
        _scaffoldKey.currentState!.openEndDrawer();
      }
      if (value == "2") {
        if (!mounted) return;
        final Uri url = Uri.parse(
          appData.imageData
              .where((element) => element.title == 'manual')
              .first
              .url,
        );
        if (!await launchUrl(url)) {
          throw Exception('Could not launch');
        }
      }
      if (value == "3") {
        if (!mounted) return;
        await context.read<AuthService>().signOut().then((value) {
          if (!mounted) return;
          Navigator.pop(context);
          Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (_) => const SignIn()));
        });
      }
      if (value == "5") {
        if (!mounted) return;
        await DialogService(
          button:
              'If you select Yes we will delete your account and associated profile data on our server, thereafter exit and delete the app, reinstall from the store if you change your mind.',
          origin: "Confirm Account Deletion",
        ).confirmDelete(context: context).then((value) async {
          if (!mounted) return;
          value == "Yes"
              ? await context.read<AuthService>().deleteUser().then((
                value,
              ) async {
                if (value == null) {
                  if (!mounted) return;
                  Navigator.pop(context);
                  Navigator.of(
                    context,
                  ).push(MaterialPageRoute(builder: (_) => Register()));
                }
              })
              : null;
        });
      }
      if (value == "6") {
        if (!mounted) return;
        final Uri url = Uri.parse(
          appData.imageData
              .where((element) => element.title == 'privacy')
              .first
              .url,
        );
        if (!await launchUrl(url)) {
          throw Exception('Could not launch');
        }
      }
      if (value == "7" && isAdmin) {
        if (!mounted) return;
        await DialogService(
          button: value.isEmpty ? 'Cancel' : 'Done',
          origin: "User Approval Screen",
        ).approveUsers(context: context, pendingSubscribers: _pendingApprovals);
      }
      if (value == "8") {
        if (!mounted) return;
        Navigator.of(context).push(
          MaterialPageRoute(
            builder:
                (_) => EmailForm(
                  contactvalue: "",
                  email: mobiAppData.supportEmail,
                  message: '',
                  imageData: imageData!,
                ),
          ),
        );
      }
    });
  }

  Widget _cardMenuService(
    BuildContext context,
    List<MenuList> selectedItem,
    int index,
    List<ImageData> imageData,
    MobiAppData mobiAppData,
    UserSubscribeData subscribeData,
  ) {
    /*if (appData.modulesList
        .where((element) => element.module == selectedItem[index].header)
        .isEmpty) {
      return Container();
    }*/

    return Card(
      color: Colors.blueGrey.withValues(alpha: 0.4),
      shape: RoundedRectangleBorder(
        side: const BorderSide(color: kColorBar),
        borderRadius: BorderRadius.circular(15),
      ),
      elevation: 16,
      shadowColor: Colors.blueGrey,
      child: Padding(
        padding: const EdgeInsets.all(5),
        child: InkWell(
          onTap: () async {
            selectedItem[index].header == 'Vessel Status'
                ? Navigator.of(context).push(
                  MaterialPageRoute(
                    builder:
                        (_) =>
                            TerminalLayout(title: selectedItem[index].header!),
                  ),
                )
                : showModalScreen(
                  context,
                  selectedItem[index],
                  imageData,
                  "",
                  mobiAppData,
                  subscribeData,
                  _pendingApprovals,
                  _textSector.text,
                  '',
                );
          },
          child: GridTile(
            header: Center(
              child: FittedBox(
                fit: BoxFit.contain,
                child: Text(
                  selectedItem[index].header!,
                  style: kLabelTextStyle,
                ),
              ),
            ),
            footer: Center(
              child: FittedBox(
                fit: BoxFit.contain,
                child: Text(
                  selectedItem[index].footer!,
                  style: kLabelTextStyle,
                ),
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(5, 25, 5, 25),
                    child: CachedNetworkImage(
                      errorWidget:
                          (context, url, error) => const Icon(Icons.error),
                      imageUrl: selectedItem[index].image!,
                      imageBuilder:
                          (context, imageProvider) => Container(
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                image: imageProvider,
                                fit: BoxFit.contain,
                                alignment: Alignment.center,
                              ),
                            ),
                          ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
