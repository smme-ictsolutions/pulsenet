import 'dart:ui';
import 'package:customer_portal/authenticate/authenticate_wrapper.dart';
import 'package:customer_portal/database/database_service.dart';
import 'package:customer_portal/model/mobiapp.dart';
import 'package:customer_portal/model/singletons_data.dart';
import 'package:customer_portal/model/user.dart';
import 'package:customer_portal/services/auth.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

String currentUserEmail = "";
bool isMobile = false;

Future<bool> isMobileDevice() async {
  isMobile =
      kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.iOS ||
          defaultTargetPlatform == TargetPlatform.android);
  return isMobile;
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: "AIzaSyAbqs-Aml-rmfddZtDA5du5rQZbtc6-eVU",
      authDomain: "transnet-customer-portal.firebaseapp.com",
      projectId: "transnet-customer-portal",
      storageBucket: "transnet-spotlight-3.appspot.com",
      messagingSenderId: "285298464791",
      appId: "1:285298464791:web:639b36478d6df1aaafe452",
      measurementId: "G-3J0F02RDJ6",
    ),
  );
  await Firebase.initializeApp(
    name: "com.transnet.spotlight-3",
    options: const FirebaseOptions(
      apiKey: "AIzaSyDbaRkjBbYrEFwwtmthFr5godffgzeMw7o",
      authDomain: "transnet-spotlight-3.firebaseapp.com",
      projectId: "transnet-spotlight-3",
      storageBucket: "transnet-spotlight-3.appspot.com",
      messagingSenderId: "962836608276",
      appId: "1:962836608276:web:23569a85edad977dde7e01",
      measurementId: "G-JXER7ZQQSP",
    ),
  );

  if (!kIsWeb) {
    if (kDebugMode) {
      await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(false);
    } else {
      await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true);
      FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;
    }
  }

  //get firestore spotlight master data
  Future<void> getMasterData() async {
    appData.imageData = await DatabaseService(null).imageListData();
    await DatabaseService(null).lookupListData("");
    appData.stationListData = await DatabaseService(null).stationListData();
    appData.activeNavisUser = NavisSubscribeData(connected: false);
  }

  await getMasterData().then((value) {
    runApp(const MyApp());
  });
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<AuthService>(
          create: (_) => AuthService(FirebaseAuth.instance),
        ),
        StreamProvider(
          create: (context) => context.read<AuthService>().authState,
          initialData: null,
        ),
        StreamProvider<MobiAppData>(
          create: (context) => DatabaseService(null).mobiAppData,
          initialData: MobiAppData(),
        ),
      ],
      child: MaterialApp(
        scrollBehavior: const MaterialScrollBehavior().copyWith(
          dragDevices: {PointerDeviceKind.mouse},
        ),
        debugShowCheckedModeBanner: false,
        title: 'TPT Pulsenet',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueGrey),
        ),
        home: StreamBuilder(
          stream: DatabaseService(null).mobiAppData,
          builder: (context, mobidata) {
            if (mobidata.hasData) {
              appData.mobiAppData = mobidata.data!;
              return authenticate_wrapper();
            }
            return Container();
          },
        ),
      ),
    );
  }
}
