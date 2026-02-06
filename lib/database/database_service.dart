import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:customer_portal/model/appointments.dart';
import 'package:customer_portal/model/menu.dart';
import 'package:customer_portal/model/mobiapp.dart';
import 'package:customer_portal/model/notification.dart';
import 'package:customer_portal/model/singletons_data.dart';
import 'package:customer_portal/model/user.dart';
import 'package:customer_portal/model/weather.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import "package:http/http.dart" as http;

final FirebaseFirestore _firestore = FirebaseFirestore.instance;
final FirebaseFirestore _firestore_1 = FirebaseFirestore.instanceFor(
  app: Firebase.app('com.transnet.spotlight-3'),
);
final CollectionReference imageCollection = _firestore.collection(
  "firestorestorage",
);
final CollectionReference userCollection = FirebaseFirestore.instance
    .collection("users");
final CollectionReference apiCollection = FirebaseFirestore.instance.collection(
  "api",
);
final CollectionReference userSpotlightCollection = _firestore_1.collection(
  "users",
);
final CollectionReference notificationsCollection = _firestore_1.collection(
  "notifications",
);
final CollectionReference lookupsCollection = FirebaseFirestore.instance
    .collection("lookups");
final CollectionReference menuCollection = FirebaseFirestore.instance
    .collection("menu");
final CollectionReference mobiAppCollection = FirebaseFirestore.instance
    .collection("mobiapp");

class DatabaseService {
  static final DatabaseService _singleton = DatabaseService._();
  static DatabaseService get instance => _singleton;
  String? uid;

  DatabaseService(this.uid);

  DatabaseService._();

  final FirebaseAuth auth = FirebaseAuth.instance;

  //user subscription data from snapshot
  UserSubscribeData _userSubscriptionDataFromSnapshot(
    DocumentSnapshot snapshot,
  ) {
    return UserSubscribeData(
      uid: auth.currentUser!.uid,
      username: (snapshot.data() as dynamic)['username'] ?? '',
      sector: List<String>.from(snapshot.get('sector') as List<dynamic>),
      stakeholder: (snapshot.data() as dynamic)['stakeholder'] ?? '',
      port: List<String>.from(snapshot.get('port') as List<dynamic>),
      modules: List<String>.from(snapshot.get('modules') as List<dynamic>),
      email: (snapshot.data() as dynamic)['email'] ?? '',
      fcmToken: (snapshot.data() as dynamic)['fcmtoken'] ?? '',
      isAdmin: (snapshot.data() as dynamic)['isadmin'] ?? false,
    );
  }

  //upload json file
  Future<String> uploadToStorage(String path, String jsonContent) async {
    String urlDownload = "";
    UploadTask? uploadTask;
    try {
      final ref = FirebaseStorage.instance.ref().child(
        'portal/${auth.currentUser!.uid}/$path.txt',
      );
      uploadTask = ref.putString(jsonContent);
      final snapshot = await uploadTask;
      urlDownload = await snapshot.ref.getDownloadURL();
    } catch (error) {
      debugPrint(error.toString());
    }

    return urlDownload;
  }

  //get user subscriber doc stream
  Stream<UserSubscribeData> get subscriptionData {
    return userCollection
        .doc(auth.currentUser?.uid ?? uid)
        .snapshots()
        .map(_userSubscriptionDataFromSnapshot);
  }

  //get spotlight user data
  Future<UserSubscribeData> spotlightUserData() {
    UserSubscribeData x = UserSubscribeData(isAdmin: false);
    return userSpotlightCollection.where("user", isEqualTo: uid).get().then((
      document,
    ) {
      for (var element in document.docs) {
        x = UserSubscribeData(
          uid: element.get('user'),
          username: element.get('username'),
          email: element.get('email'),
          isAdmin: false,
          port: List<String>.from(element.get('port') as List<dynamic>),
          sector: List<String>.from(element.get('sector') as List<dynamic>),
          stakeholder: element.get('stakeholder') ?? '',
        );
      }
      return x;
    });
  }

  //mobi app data from snapshot
  MobiAppData _mobiAppDataFromSnapshot(DocumentSnapshot snapshot) {
    try {
      return MobiAppData(
        organisation: (snapshot.data() as dynamic)['organisation'] ?? '',
        supportEmail:
            (snapshot.data() as dynamic)['supportemail'] ??
            'transnetspotlight@gmail.com',
        testUsers: List<String>.from(
          snapshot.get('testusers') as List<dynamic>,
        ),
        productionPassword:
            (snapshot.data() as dynamic)['server']['productionpassword'] ?? '',
        productionPort:
            (snapshot.data() as dynamic)['server']['productionport'] ?? 7799,
        productionServer:
            (snapshot.data() as dynamic)['server']['productionserver'] ?? '',
        productionUser:
            (snapshot.data() as dynamic)['server']['productionuser'] ?? '',
        testPassword:
            (snapshot.data() as dynamic)['server']['testpassword'] ?? '',
        testPort: (snapshot.data() as dynamic)['server']['testport'] ?? 7799,
        testServer: (snapshot.data() as dynamic)['server']['testserver'] ?? '',
        distributionList: List<String>.from(
          snapshot.get('distribution') as List<dynamic>,
        ),
        exportTransactionType:
            (snapshot.data() as dynamic)['transactiontype']['export'] ?? '',
        importTransactionType:
            (snapshot.data() as dynamic)['transactiontype']['import'] ?? '',
        token: (snapshot.data() as dynamic)['sharePoint']['token'] ?? '',
        getURL: (snapshot.data() as dynamic)['sharePoint']['getURL'] ?? '',
        postURL: (snapshot.data() as dynamic)['sharePoint']['postURL'] ?? '',
        postDocumentURL:
            (snapshot.data() as dynamic)['sharePoint']['postDocumentURL'] ?? '',
        getSignature:
            (snapshot.data() as dynamic)['sharePoint']['getSignature'] ?? '',
        postSignature:
            (snapshot.data() as dynamic)['sharePoint']['postSignature'] ?? '',
        postDocumentSignature:
            (snapshot.data()
                as dynamic)['sharePoint']['postDocumentSignature'] ??
            '',
        andsenderid: (snapshot.data() as dynamic)['andsenderid'] ?? '',
        inReceiverId: (snapshot.data() as dynamic)['inReceiverId'] ?? '',
        andmobicertificate:
            (snapshot.data() as dynamic)['andmobicertificate'] ?? '',
        queryOptions: List<String>.from(
          snapshot.get('queryoptions') as List<dynamic>,
        ),
        berthingsequencefields: List<String>.from(
          snapshot.get('berthingsequencefields') as List<dynamic>,
        ),
        gcostracktracefields: List<String>.from(
          snapshot.get('gcostracktracefields') as List<dynamic>,
        ),
        vesselvisitfields: List<String>.from(
          snapshot.get('vesselvisitfields') as List<dynamic>,
        ),
        vesselstatusfields: List<String>.from(
          snapshot.get('vesselstatusfields') as List<dynamic>,
        ),
        truckvisitfields: List<String>.from(
          snapshot.get('truckvisitfields') as List<dynamic>,
        ),
        tracktracefields: List<String>.from(
          snapshot.get('tracktracefields') as List<dynamic>,
        ),
        preadvicefields: List<String>.from(
          snapshot.get('preadvicefields') as List<dynamic>,
        ),
        bookreferencefields: List<String>.from(
          snapshot.get('bookreferencefields') as List<dynamic>,
        ),
        complex: (snapshot.data() as dynamic)['complex'] ?? '',
        complexAppointments:
            (snapshot.data() as dynamic)['complexappointments'] ?? '',
      );
    } catch (error) {
      debugPrint(error.toString());
    }
    return MobiAppData();
  }

  //get zone rule sets for selected facility
  Future<List<ZoneRuleSets>> getZoneRuleSets(String facilityID) async {
    List<ZoneRuleSets> zoneRuleSets = [];
    await _firestore_1.collection('rulesets').doc(facilityID).get().then((
      document,
    ) {
      Map data = (document.data() as Map);
      data.forEach((key, zoneRules) {
        zoneRuleSets.add(
          ZoneRuleSets(
            gateID: key,
            zoneRules: List<String>.from(zoneRules as List<dynamic>),
          ),
        );
      });
    });
    return zoneRuleSets;
  }

  //get mobi app doc stream
  Stream<MobiAppData> get mobiAppData {
    return mobiAppCollection
        .doc('params')
        .snapshots()
        .map(_mobiAppDataFromSnapshot);
  }

  //set read privacy and dislaimer
  Future<void> setReadPrivacyDisclaimerPreferences() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();

      prefs.setBool("isReadPrivacy", true);
      prefs.setBool("isReadDisclaimer", true);
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  //set read privacy
  Future<void> setReadPrivacyPreferences() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();

      prefs.setBool("isReadPrivacy", true);
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  //set read disclaimer
  Future<void> setReadDisclaimerPreferences() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();

      prefs.setBool("isReadDisclaimer", true);
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  //get weather station coordinates list
  Future<List<StationList>> stationListData() async {
    List<StationList> x = [];
    await lookupsCollection.doc('coordinates').get().then((
      DocumentSnapshot doc,
    ) {
      for (Map data in doc['stations']) {
        x.add(
          StationList(
            station: data['station'] ?? '',
            latitude: data['latitude'] ?? 0.00,
            longitude: data['longitude'] ?? 0.00,
          ),
        );
      }
    });

    return x;
  }

  //get image list
  Future<List<ImageData>> imageListData() {
    List<ImageData> x = [];
    return imageCollection.doc('storage').get().then((document) {
      Map data = (document.data() as Map);
      data.forEach((key, value) {
        x.add(ImageData(title: value['title'], url: value['url']));
      });
      return x;
    });
  }

  //get weather station
  Future<int> weatherStationData(String portName) async {
    return lookupsCollection
        .doc('stations')
        .get()
        .then((value) => value.get(portName));
  }

  Future<List<String>> lookupListData(String type) {
    return lookupsCollection.doc('values').get().then((value) {
      Map data = (value.data() as Map);
      data.forEach((key, value) {
        if (key == "sector") {
          for (final sector in value) {
            appData.sectorList.add(sector);
          }
        } else if (key == "port") {
          for (final port in value) {
            appData.portList.add(
              LookUpData(name: port["name"], sector: port["sector"]),
            );
          }
        } else if (key == "stakeholder") {
          for (final stakeholder in value) {
            appData.stakeholderList.add(
              LookUpData(
                name: stakeholder["name"],
                sector: stakeholder["sector"],
              ),
            );
          }
        } else if (key == "shippinglines") {
          for (final shippingline in value) {
            appData.shippingLineList.add(
              LookUpData(
                name: shippingline["name"],
                sector: shippingline["sector"],
              ),
            );
          }
        } else if (key == "stevedores") {
          for (final stevedore in value) {
            appData.stevedoreList.add(
              LookUpData(name: stevedore["name"], sector: stevedore["sector"]),
            );
          }
        } else if (key == "berths") {
          for (final berth in value) {
            appData.berthList.add(
              LookUpData(
                name: berth["name"],
                sector: berth["sector"],
                port: berth["port"] ?? '',
              ),
            );
          }
        } else if (key == "vesseltype") {
          for (final vesseltype in value) {
            appData.vesselTypeList.add(
              LookUpData(
                name: vesseltype["name"],
                sector: vesseltype["sector"],
              ),
            );
          }
        } else if (key == "complexquery") {
          for (final querytype in value) {
            appData.complexQueryList.add(
              LookUpData(name: querytype["name"], sector: querytype["sector"]),
            );
          }
        } else if (key == "modules") {
          for (final module in value) {
            appData.modulesList.add(
              ModuleData(
                module: module["module"],
                fileSystem: module["filesystem"],
                requiresApproval: module["requiresApproval"],
                admin: module["admin"],
                terminal: module["terminal"],
                api: module["api"],
              ),
            );
          }
        } else if (key == "vesselpreparation") {
          appData.myClearMainDeckSelection = value["clearmaindeck"];
          appData.myBreakStowSelection = value["breakstow"];
          appData.myPanelingTimeSelection = value["panelingtime"];
          appData.myunlashingUnitsSelection = value["unlashingunits"];
        } else if (key == "portmapping") {
          appData.gcosPortMapping = GcosPortMapping.fromMap(value);
        } else if (key == "navisfacilities") {
          for (final facility in value) {
            appData.navisFacilitiesList.add(
              NavisFacilities(
                port: facility["port"],
                filter: facility["filter"],
                code: facility["code"],
              ),
            );
          }
        } else if (key == "portlayouts") {
          for (final portlayout in value) {
            appData.portLayoutsList.add(
              TerminalLayoutData.fromMap(portlayout, key),
            );
          }
        }
      });
      return [];
    });
  }

  //app image data from snapshot
  List<ImageData> _imagesFromSnapshot(QuerySnapshot snapshot) {
    return snapshot.docs.map((doc) {
      return ImageData(
        title: (doc.data() as dynamic)['title'] ?? '',
        url: (doc.data() as dynamic)['url'] ?? '',
      );
    }).toList();
  }

  //get app image data doc stream
  Stream<List<ImageData>>? get imageData {
    return imageCollection.snapshots().map(_imagesFromSnapshot);
  }

  //create logged on user collection
  Future createUserData(
    String username,
    email,
    stakeHolder,
    fcmToken,
    List<String> port,
    List<String> sector,
    List<String> modules,
    bool acceptedTCs,
  ) async {
    await userCollection.doc(auth.currentUser!.uid).set({
      'user': auth.currentUser!.uid,
      'username': username,
      'email': email,
      'sector': FieldValue.arrayUnion(sector),
      'port': FieldValue.arrayUnion(port),
      'stakeholder': stakeHolder,
      'fcmtoken': fcmToken,
      'modules': modules,
      'acceptedTCs': acceptedTCs,
      'isadmin': false,
    }, SetOptions(merge: true));
  }

  //create logged on user api collection
  Future createApiUserData(
    String username,
    email,
    stakeHolder,
    fcmToken,
    List<ModuleData> modules,
    bool acceptedTCs,
  ) async {
    Map<String, dynamic> item = {
      email: {
        'stakeholder': stakeHolder,
        'modules': modules.map((e) => e.toMap()).toList(growable: true),
        'acceptedTCs': acceptedTCs,
      },
    };
    await apiCollection.doc('subscriptions').set(item, SetOptions(merge: true));
  }

  //save preplan data
  Future createPrePlan(String vesselName, voyageNumber) async {
    await userCollection.doc(auth.currentUser!.uid).update({
      'transactions': FieldValue.arrayUnion([
        {"vesselname": vesselName, "voyage": voyageNumber},
      ]),
    });
  }

  //get transaction list
  Future<void> transactionListData() async {
    appData.transactionData = [];
    try {
      await userCollection.doc(auth.currentUser?.uid ?? uid).get().then((
        DocumentSnapshot doc,
      ) {
        for (Map data in doc['transactions']) {
          appData.transactionData.add(
            PrePlanTansactionModel.fromMap(data as Map<String, dynamic>),
          );
        }
      });
    } catch (error) {
      debugPrint("no transactions");
    }
  }

  //update logged on user collection
  Future updateUserData(
    String username,
    stakeHolder,
    List<String> port,
    List<String> sector,
    List<String> modules,
  ) async {
    await userCollection.doc(auth.currentUser!.uid).update({
      'username': username,
      'sector': sector,
      'stakeholder': stakeHolder,
      'port': port,
      'modules': modules,
    });
  }

  //get mobiapp server certificate data
  Future<String> mobiAppCertificateData(String certificateURL) async {
    try {
      var request = await HttpClient().getUrl(Uri.parse(certificateURL));
      var response = await request.close();
      var bytes = await consolidateHttpClientResponseBytes(response);
      return utf8.decode(bytes);
    } catch (e) {
      debugPrint(e.toString());
    }
    return "";
  }

  //send sharepoint preplan data
  Future<String> postSharePointData(
    String jsonData,
    MobiAppData mobiAppData,
  ) async {
    try {
      String response = "";
      var headers = {'Content-Type': 'application/json'};

      var request = http.Request(
        'POST',
        Uri.parse(
          '${mobiAppData.postURL}${mobiAppData.token}?api-version=1&sp=%2Ftriggers%2Fmanual%2Frun&sv=1.0&sig=${mobiAppData.postSignature}',
        ),
      );
      request.headers.addAll(headers);
      request.body = jsonData;
      var streamedResponse = await request.send();
      await http.Response.fromStream(streamedResponse).then((value) {
        response = value.body;
      });
      if (streamedResponse.statusCode == 200) {
        return '${streamedResponse.statusCode} $response';
      } else if (streamedResponse.statusCode == 500) {
        return 'An error has occurred, preplan maybe locked already. Please consult the terminal planners.';
      } else {
        return '${streamedResponse.statusCode} $response';
      }
    } catch (e) {
      debugPrint(e.toString());
    }
    return "";
  }

  //send document data to sharepoint
  Future<String> postDocumentSharePointData(
    MobiAppData mobiAppData,
    String documentData,
    String user,
  ) async {
    try {
      var headers = {'content-type': 'application/octet-stream', 'user': user};

      var request = http.Request(
        'POST',
        Uri.parse(
          '${mobiAppData.postDocumentURL}${mobiAppData.token}?api-version=1&sp=%2Ftriggers%2Fmanual%2Frun&sv=1.0&sig=${mobiAppData.postDocumentSignature}',
        ),
      );

      request.headers.addAll(headers);
      request.bodyBytes = base64Decode(documentData);
      var response = await request.send();

      if (response.statusCode == 200) {
        return '${response.statusCode} Document uploaded successfully';
      } else {
        return '${response.statusCode} $response';
      }
    } catch (e) {
      debugPrint(e.toString());
    }
    return "";
  }

  //retrieve sharepoint data
  Future<String> getSharePointData(
    String jsonData,
    MobiAppData mobiAppData,
  ) async {
    try {
      String response = "";
      var headers = {'Content-Type': 'application/json'};

      var request = http.Request(
        'POST',
        Uri.parse(
          '${mobiAppData.getURL}${mobiAppData.token}?api-version=1&sp=%2Ftriggers%2Fmanual%2Frun&sv=1.0&sig=${mobiAppData.getSignature}',
        ),
      );
      request.headers.addAll(headers);
      request.body = jsonData;
      var streamedResponse = await request.send();
      if (streamedResponse.statusCode == 401) {
        return streamedResponse.reasonPhrase!;
      }
      await http.Response.fromStream(streamedResponse).then((value) {
        response = value.body;
      });
      if (streamedResponse.statusCode == 200) {
        return response;
      } else {
        return '${streamedResponse.statusCode} $response';
      }
    } catch (e) {
      debugPrint(e.toString());
    }
    return "";
  }

  //delete user profile
  Future deleteProfileData() async {
    return userCollection
        .doc(auth.currentUser?.uid ?? uid)
        .delete()
        .then((_) => debugPrint('Deleted'))
        .catchError((error) => debugPrint('Delete failed: $error'));
  }

  //get menu list
  Future<List<MenuList>> menuListData(
    String type,
    UserSubscribeData userData,
  ) async {
    List<MenuList> x = [];
    await menuCollection.doc(type).get().then((DocumentSnapshot doc) {
      if (doc['items'].isNotEmpty) {
        for (Map data in doc['items']) {
          if (userData.modules != null &&
              userData.modules!
                  .where((element) => element == data['header'])
                  .isNotEmpty) {
            x.add(
              MenuList(
                header: data['header'] ?? '',
                image: data['image'] ?? '',
                footer: data['footer'] ?? '',
                needsFacilitySelection: false,
              ),
            );
          }
        }
      }

      for (Map data in doc['spotlight']) {
        if (data['active'] == true) {
          x.add(
            MenuList(
              header: data['header'] ?? '',
              image: data['image'] ?? '',
              footer: data['footer'] ?? '',
              needsFacilitySelection: true,
            ),
          );
        }
      }
    });

    return x;
  }

  //get pending users for approval
  Future<List<Approvals>> pendingUserApprovals() {
    List<Approvals> x = [];
    return menuCollection.doc('approvals').get().then((DocumentSnapshot doc) {
      for (var element in doc['item']) {
        x.add(
          Approvals(
            user: element['user'],
            modules: List<String>.from(element['modules'] as List<dynamic>),
          ),
        );
      }

      return x;
    });
  }

  //add new approval
  Future updateApprovalsData(String user, module) async {
    List<Approvals> itemList = [];
    itemList = await pendingUserApprovals();
    //check if user is already in pending list
    int indexToUpdate =
        itemList.where((element) => element.user == user).isEmpty
            ? -1
            : itemList.indexOf(
              itemList.where((element) => element.user == user).first,
            );
    if (indexToUpdate != -1) {
      //check if module already exists in pending list
      if (itemList[indexToUpdate].modules
          .where((element) => element == module)
          .isEmpty) {
        itemList[indexToUpdate].modules.add(module);
      } else {
        return;
      }
    } else {
      itemList.add(Approvals(user: user, modules: [module]));
    }

    await menuCollection.doc('approvals').update({
      'item': itemList.map((e) => e.toMap()).toList(growable: true),
    });
  }

  //remove record admin approved
  Future<List<Approvals>> removeApprovalsData(
    String user,
    String module,
    List<Approvals> approvalList,
  ) async {
    List<Approvals> itemList = [];
    itemList = approvalList;
    String approvedModule = module;

    itemList
        .where((element) => element.user == user)
        .first
        .modules
        .removeWhere((module) => module == approvedModule);

    await menuCollection.doc('approvals').update({
      'item': itemList.map((e) => e.toMap()).toList(growable: true),
    });
    return itemList;
  }

  //get notifications data doc stream
  Future<List<String>> notificationsListData() {
    return notificationsCollection
        .orderBy("notificationdate", descending: false)
        .get()
        .then((value) => value.docs.map((doc) => doc.id).toList());
  }

  //get notification Items doc stream
  Future<List<NotificationItems>> notificationData(
    String notificationDate,
  ) async {
    List<NotificationItems> x = [];
    await _firestore_1
        .collection('notifications')
        .doc(notificationDate)
        .get()
        .then((value) {
          final doc = value.data()!;
          for (Map data in doc['messages']) {
            x.add(
              NotificationItems(
                title: data['title'] ?? '',
                body: data['body'] ?? '',
                status: List<String>.from(data['status'] as List<dynamic>),
                recipients: data['recipients'] ?? '',
                timeSent: ((data as dynamic)['timesent']).toDate() ?? '',
                attachment: data['attachment'] ?? '',
              ),
            );
          }
        });
    x.sort((b, a) => a.timeSent!.compareTo(b.timeSent!));
    return x;
  }
}
