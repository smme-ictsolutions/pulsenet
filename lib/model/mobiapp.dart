import 'package:customer_portal/main.dart';
import 'package:customer_portal/model/singletons_data.dart';
import 'package:intl/intl.dart';
import 'package:xml/xml.dart';

class ImageData {
  final String title;
  final String url;

  ImageData({required this.title, required this.url});
}

class FlexibleQueryData {
  final String filter;
  final String unitIds;

  FlexibleQueryData({required this.filter, required this.unitIds});
}

class FacilityModel {
  final String filter;
  final List<FacilityItems> items;
  FacilityModel({required this.filter, required this.items});

  Map<String, dynamic> toMap() => <String, dynamic>{
    'filter': filter,
    'items': items.map((e) => e.toMap()).toList(growable: true),
  };

  static FacilityModel fromMap(Map<String, dynamic> map, String filter, key) {
    return FacilityModel(
      filter: filter,
      items:
          map[key]
              .map((mapping) => FacilityItems.fromMap(mapping, key))
              .toList()
              .cast<FacilityItems>(),
    );
  }
}

class FacilityItems {
  String? facilityID, facilityName, facilityDescription, sector;

  FacilityItems({
    required this.facilityID,
    required this.facilityName,
    required this.facilityDescription,
    required this.sector,
  });

  Map<String, dynamic> toMap() {
    return {
      'facilityID': facilityID,
      'facilityName': facilityName,
      'facilityDescription': facilityDescription,
    };
  }

  static FacilityItems fromMap(Map<String, dynamic> map, String key) {
    return FacilityItems(
      facilityID:
          key == 'C_CURSOR' ? map['terminals'] : map['field'][0] ?? 'default',
      facilityName:
          key == 'C_CURSOR'
              ? map['terminalsCode']
              : map['field'][1] ?? 'default',
      facilityDescription:
          key == 'C_CURSOR'
              ? map['terminalsCode']
              : map['field'][2] ?? 'default',
      sector:
          key != 'C_CURSOR'
              ? 'container'
              : appData.gcosPortMapping
                  .where((element) => element.portcode == map['terminals'])
                  .first
                  .sector,
    );
  }
}

class GcosPortMapping {
  final String sector, portcode;

  GcosPortMapping({required this.sector, required this.portcode});

  static List<GcosPortMapping> fromMap(Map<String, dynamic> map) {
    List<GcosPortMapping> items = [];

    map.forEach((key, value) {
      for (int index = 0; index < value.length; index++) {
        items.add(GcosPortMapping(sector: key, portcode: value[index]));
      }
    });

    return items;
  }
}

class AvailableSlotsModel {
  final String transactionDate, transactionType, startTime, endTime, zoneRule;
  final int? slotCapacity, slotsBooked, availableSlots;

  AvailableSlotsModel({
    required this.transactionDate,
    required this.transactionType,
    required this.startTime,
    required this.endTime,
    required this.zoneRule,
    required this.slotCapacity,
    required this.slotsBooked,
    required this.availableSlots,
  });

  static List<AvailableSlotsModel> fromMap(
    Map<String, dynamic> map,
    MobiAppData mobiAppData,
  ) {
    List<AvailableSlotsModel> items = [];

    for (int index = 0; index < map['row'].length; index++) {
      items.add(
        AvailableSlotsModel(
          transactionDate: map['row'][index]['field'][0] ?? '',
          transactionType: map['row'][index]['field'][1] ?? '',
          startTime: map['row'][index]['field'][2] ?? '',
          endTime: map['row'][index]['field'][3] ?? '',
          zoneRule: (map['row'][index]['field'][4]).toString().replaceAll(
            'amp;',
            '',
          ),
          slotCapacity:
              map['row'][index]['field'][1] == mobiAppData.importTransactionType
                  ? int.tryParse(map['row'][index]['field'][6])
                  : int.tryParse(map['row'][index]['field'][5]),
          //slotCapacity: (int.tryParse(map['row'][index]['field'][5]) ?? 0) +
          //    (int.tryParse(map['row'][index]['field'][6]) ?? 0),
          slotsBooked: int.tryParse(map['row'][index]['field'][7]) ?? 0,
          availableSlots:
              map['row'][index]['field'][1] == mobiAppData.importTransactionType
                  ? (int.tryParse(map['row'][index]['field'][6]) ?? 0) -
                      (int.tryParse(map['row'][index]['field'][7]) ?? 0)
                  : (int.tryParse(map['row'][index]['field'][5]) ?? 0) -
                      (int.tryParse(map['row'][index]['field'][7]) ?? 0),
        ),
      );
      //availableSlots: ((int.tryParse(map['row'][index]['field'][5]) ?? 0) +
      //        (int.tryParse(map['row'][index]['field'][6]) ?? 0)) -
      //    (int.tryParse(map['row'][index]['field'][7]) ?? 0)));
    }

    return items;
  }
}

class TranshipmentModel {
  final String transhipType, vesselName;
  final int newVehicle, heavies, statics, used;
  final String? berthCode;
  TranshipmentModel({
    required this.transhipType,
    required this.vesselName,
    required this.newVehicle,
    required this.heavies,
    required this.statics,
    required this.used,
    this.berthCode,
  });

  Map<String, dynamic> toMap() => <String, dynamic>{
    transhipType == 'PRE-CARRIER (Tranship to be Loaded)'
            ? 'transhiptypein'
            : 'transhiptypeout':
        transhipType,
    transhipType == 'PRE-CARRIER (Tranship to be Loaded)'
            ? 'vesselnamein'
            : 'vesselnameout':
        vesselName,
    transhipType == 'PRE-CARRIER (Tranship to be Loaded)'
            ? 'newvehiclein'
            : 'newvehicleout':
        newVehicle,
    transhipType == 'PRE-CARRIER (Tranship to be Loaded)'
            ? 'heaviesin'
            : 'heaviesout':
        heavies,
    transhipType == 'PRE-CARRIER (Tranship to be Loaded)'
            ? 'staticsin'
            : 'staticsout':
        statics,
    transhipType == 'PRE-CARRIER (Tranship to be Loaded)'
            ? 'usedin'
            : 'usedout':
        used,

    transhipType == 'PRE-CARRIER (Tranship to be Loaded)'
            ? 'berthcodein'
            : 'berthcodeout':
        transhipType == 'PRE-CARRIER (Tranship to be Loaded)'
            ? berthCode ?? ""
            : "",
  };

  static TranshipmentModel fromMap(Map<String, dynamic> map) {
    try {
      if (map['berthcodein'] != "") {
        return TranshipmentModel(
          transhipType: 'PRE-CARRIER (Tranship to be Loaded)',
          vesselName: map['vesselnamein'],
          newVehicle: map['newvehiclein'],
          heavies: map['heaviesin'],
          statics: map['staticsin'],
          used: map['usedin'],
          berthCode: map['berthcodein'],
        );
      } else {
        return TranshipmentModel(
          transhipType: 'ON-CARRIER (Tranship to be Discharged)',
          vesselName: map['vesselnameout'],
          newVehicle: map['newvehicleout'],
          heavies: map['heaviesout'],
          statics: map['staticsout'],
          used: map['usedout'],
          berthCode: "",
        );
      }
    } catch (error) {
      return TranshipmentModel(
        transhipType: 'ON-CARRIER (Tranship to be Discharged)',
        vesselName: map['vesselnameout'],
        newVehicle: map['newvehicleout'],
        heavies: map['heaviesout'],
        statics: map['staticsout'],
        used: map['usedout'],
        berthCode: "",
      );
    }
  }
}

class VesselPreparation {
  final String paneling;
  final int clearMainDeck,
      breakStow,
      unlashingUnits,
      directRestow,
      indirectRestow,
      panelingTime;
  VesselPreparation({
    required this.paneling,
    required this.clearMainDeck,
    required this.breakStow,
    required this.unlashingUnits,
    required this.directRestow,
    required this.indirectRestow,
    required this.panelingTime,
  });

  Map<String, dynamic> toMap() => <String, dynamic>{
    'paneling': paneling,
    'clearmaindeck': clearMainDeck,
    'breakstow': breakStow,
    'unlashingunits': unlashingUnits,
    'directrestowtime': directRestow,
    'indirectrestowtime': indirectRestow,
    'panelingtime': panelingTime,
  };

  static VesselPreparation fromMap(Map<String, dynamic> map) {
    return VesselPreparation(
      breakStow: map['breakstow'],
      clearMainDeck: map['clearmaindeck'],
      directRestow: map['directrestowtime'],
      indirectRestow: map['indirectrestowtime'],
      paneling: map['paneling'],
      panelingTime: map['panelingtime'],
      unlashingUnits: map['unlashingunits'],
    );
  }
}

class VolumesModel {
  final int importNew,
      exportNew,
      importRubberHeavies,
      exportRubberHeavies,
      importUsedHeavies,
      importStaticsNonMafi,
      exportStaticsNonMafi,
      importUsedStatics,
      importMafiWithCargo,
      exportMafiWithCargo,
      importStaticsMafi,
      exportStaticsMafi,
      importUsed,
      exportUsed,
      importHeaviesTracks,
      exportHeaviesTracks;
  VolumesModel({
    required this.importNew,
    required this.exportNew,
    required this.importRubberHeavies,
    required this.exportRubberHeavies,
    required this.importUsedHeavies,
    required this.importStaticsNonMafi,
    required this.exportStaticsNonMafi,
    required this.importUsedStatics,
    required this.importMafiWithCargo,
    required this.exportMafiWithCargo,
    required this.importStaticsMafi,
    required this.exportStaticsMafi,
    required this.importUsed,
    required this.exportUsed,
    required this.importHeaviesTracks,
    required this.exportHeaviesTracks,
  });
  Map<String, dynamic> toMap() => <String, dynamic>{
    'importnew': importNew,
    'exportnew': exportNew,
    'importrubberheavies': importRubberHeavies,
    'exportrubberheavies': exportRubberHeavies,
    'importusedheavies': importUsedHeavies,
    'importstaticsnonmafi': importStaticsNonMafi,
    'exportstaticsnonmafi': exportStaticsNonMafi,
    'importusedstatics': importUsedStatics,
    'importmafiwithcargo': importMafiWithCargo,
    'exportmafiwithcargo': exportMafiWithCargo,
    'importstaticsmafi': importStaticsMafi,
    'exportstaticsmafi': exportStaticsMafi,
    'importused': importUsed,
    'exportused': exportUsed,
    'importheaviestracks': importHeaviesTracks,
    'exportheaviestracks': exportHeaviesTracks,
  };

  static VolumesModel fromMap(Map<String, dynamic> map) {
    return VolumesModel(
      exportHeaviesTracks: map['exportheaviestracks'],
      exportMafiWithCargo: map['exportmafiwithcargo'],
      exportNew: map['exportnew'],
      exportRubberHeavies: map['exportrubberheavies'],
      exportStaticsMafi: map['exportstaticsmafi'],
      exportStaticsNonMafi: map['exportstaticsnonmafi'],
      exportUsed: map['exportused'],
      importHeaviesTracks: map['importheaviestracks'],
      importMafiWithCargo: map['importmafiwithcargo'],
      importNew: map['importnew'],
      importRubberHeavies: map['importrubberheavies'],
      importStaticsMafi: map['importstaticsmafi'],
      importStaticsNonMafi: map['importstaticsnonmafi'],
      importUsed: map['importused'],
      importUsedHeavies: map['importusedheavies'],
      importUsedStatics: map['importusedstatics'],
    );
  }
}

class RequirementsModel {
  final String dischargeSequence,
      loadSequence,
      volumeComments,
      mafiList,
      sideRamp;
  final int directRestows,
      indirectRestows,
      stevedoreDrivers,
      stevedorePilots,
      exportLanes,
      importLanes,
      reverseStowTime,
      secureMainDeck,
      bunkerTime;
  final bool parallelHeavies,
      parallelMafis,
      parallelStatics,
      parallelTracks,
      parallelUsed,
      parallelImportNew,
      parallelExportNew;
  RequirementsModel({
    required this.dischargeSequence,
    required this.loadSequence,
    required this.volumeComments,
    required this.mafiList,
    required this.directRestows,
    required this.indirectRestows,
    required this.stevedoreDrivers,
    required this.stevedorePilots,
    required this.exportLanes,
    required this.importLanes,
    required this.reverseStowTime,
    required this.secureMainDeck,
    required this.bunkerTime,
    required this.sideRamp,
    required this.parallelHeavies,
    required this.parallelMafis,
    required this.parallelStatics,
    required this.parallelTracks,
    required this.parallelUsed,
    required this.parallelImportNew,
    required this.parallelExportNew,
  });

  Map<String, dynamic> toMap() => <String, dynamic>{
    'dischargesequence': dischargeSequence,
    'loadsequence': loadSequence,
    'volumecomments': volumeComments,
    'mafilist': mafiList,
    'directrestows': directRestows,
    'indirectrestows': indirectRestows,
    'stevedoredrivers': stevedoreDrivers,
    'stevedorepilots': stevedorePilots,
    'exportlanes': exportLanes,
    'importlanes': importLanes,
    'reversestowtime': reverseStowTime,
    'securemaindeck': secureMainDeck,
    'bunkertime': bunkerTime,
    'sideramp': sideRamp,
    'parallelheavies': parallelHeavies,
    'parallelmafis': parallelMafis,
    'parallelstatics': parallelStatics,
    'paralleltracks': parallelTracks,
    'parallelused': parallelUsed,
    'parallelimportnew': parallelImportNew,
    'parallelexportnew': parallelExportNew,
  };

  static RequirementsModel fromMap(Map<String, dynamic> map) {
    return RequirementsModel(
      bunkerTime: map['bunkertime'],
      directRestows: map['directrestows'],
      dischargeSequence: map['dischargesequence'],
      exportLanes: map['exportlanes'],
      importLanes: map['importlanes'],
      indirectRestows: map['indirectrestows'],
      loadSequence: map['loadsequence'],
      mafiList: map['mafilist'],
      parallelExportNew: map['parallelexportnew'],
      parallelHeavies: map['parallelheavies'],
      parallelImportNew: map['parallelimportnew'],
      parallelMafis: map['parallelmafis'],
      parallelStatics: map['parallelstatics'],
      parallelTracks: map['paralleltracks'],
      parallelUsed: map['parallelused'],
      reverseStowTime: map['reversestowtime'],
      secureMainDeck: map['securemaindeck'],
      sideRamp: map['sideramp'],
      stevedoreDrivers: map['stevedoredrivers'],
      stevedorePilots: map['stevedorepilots'],
      volumeComments: map['volumecomments'],
    );
  }
}

class VesselModel {
  final String berthCode,
      vesselName,
      voyage,
      port,
      stakeholder,
      stevedore,
      vesselType,
      shippingLine,
      berthSuitability;
  final DateTime vesselETA, startOperations, endOperations, departureTime;
  VesselModel({
    required this.berthCode,
    required this.vesselName,
    required this.voyage,
    required this.port,
    required this.stakeholder,
    required this.stevedore,
    required this.vesselType,
    required this.shippingLine,
    required this.vesselETA,
    required this.startOperations,
    required this.endOperations,
    required this.departureTime,
    required this.berthSuitability,
  });

  Map<String, dynamic> toMap() => <String, dynamic>{
    'berthcode': berthCode,
    'vesselname': vesselName,
    'voyagenumber': voyage,
    'port': port,
    'stakeholder': stakeholder,
    'stevedore': stevedore,
    'vesseltype': vesselType,
    'shippingline': shippingLine,
    'vesseleta': DateFormat("yyyy-MM-dd HH:mm:ss").format(vesselETA),
    'startoperations': DateFormat(
      "yyyy-MM-dd HH:mm:ss",
    ).format(startOperations),
    'endoperations': DateFormat("yyyy-MM-dd HH:mm:ss").format(startOperations),
    'departure': DateFormat("yyyy-MM-dd HH:mm:ss").format(startOperations),
    'berthsuitability': berthSuitability,
  };

  static VesselModel fromMap(Map<String, dynamic> map) {
    return VesselModel(
      berthCode: map['berthcode'],
      vesselName: map['vesselname'],
      voyage: map['voyagenumber'],
      port: map['port'],
      stakeholder: map['stakeholder'],
      stevedore: map['stevedore'],
      vesselType: map['vesseltype'],
      shippingLine: map['shippingline'],
      vesselETA: DateTime.parse(map['vesseleta']),
      startOperations: DateTime.parse(map['startoperations']),
      endOperations: DateTime.parse(map['endoperations']),
      departureTime: DateTime.parse(map['departure']),
      berthSuitability: map["berthsuitability"],
    );
  }
}

class PrePlanTansactionModel {
  final String vesselName, voyageNumber;
  PrePlanTansactionModel({
    required this.vesselName,
    required this.voyageNumber,
  });

  static PrePlanTansactionModel fromMap(Map<String, dynamic> map) {
    return PrePlanTansactionModel(
      vesselName: map['vesselname'] ?? 'default',
      voyageNumber: map['voyage'] ?? 'default',
    );
  }
}

class PrePlanModel {
  final String filesystem, filename, fileURL, userEmail;
  final VesselModel vesselDetails;
  final VesselPreparation preparationDetails;
  final VolumesModel volumeDetails;
  final RequirementsModel requirementDetails;
  final List<TranshipmentModel> transhipmentPreCarrier;
  final List<TranshipmentModel> transhipmentOnCarrier;
  PrePlanModel({
    required this.filename,
    required this.filesystem,
    required this.fileURL,
    required this.userEmail,
    required this.vesselDetails,
    required this.preparationDetails,
    required this.volumeDetails,
    required this.requirementDetails,
    required this.transhipmentPreCarrier,
    required this.transhipmentOnCarrier,
  });

  Map<String, dynamic> toMap() => <String, dynamic>{
    'vesselname': filename,
    'filesystem': filesystem,
    'fileurl': fileURL,
    'useremail': userEmail,
    'vesseldetails': vesselDetails.toMap(),
    'volumedetails': volumeDetails.toMap(),
    'requirementdetails': requirementDetails.toMap(),
    'vesselpreparation': preparationDetails.toMap(),
    'transhipmentdetailsin': transhipmentPreCarrier
        .map((e) => e.toMap())
        .toList(growable: true),
    'transhipmentdetailsout': transhipmentOnCarrier
        .map((e) => e.toMap())
        .toList(growable: true),
  };

  static PrePlanModel fromMap(Map<String, dynamic> map) {
    return PrePlanModel(
      filename: map['filename'] ?? 'default',
      filesystem: map['filesystem'] ?? 'default',
      fileURL: map['fileurl'] ?? 'default',
      userEmail: map['useremail'] ?? currentUserEmail,
      vesselDetails: VesselModel.fromMap(map["vesseldetails"]),
      requirementDetails: RequirementsModel.fromMap(map["requirementdetails"]),
      volumeDetails: VolumesModel.fromMap(map["volumedetails"]),
      preparationDetails: VesselPreparation.fromMap(map["vesselpreparation"]),
      transhipmentPreCarrier:
          map["transhipmentdetailsin"]
              .map((mapping) => TranshipmentModel.fromMap(mapping))
              .toList()
              .cast<TranshipmentModel>(),
      transhipmentOnCarrier:
          map["transhipmentdetailsout"]
              .map((mapping) => TranshipmentModel.fromMap(mapping))
              .toList()
              .cast<TranshipmentModel>(),
    );
  }
}

class MobiAppData {
  final String? organisation;
  final String? supportEmail;
  final List<String>? testUsers;
  final String? productionPassword;
  final String? testPassword;
  final int? productionPort;
  final int? testPort;
  final String? productionServer;
  final String? testServer;
  final String? productionUser;
  final String? testUser;
  final List<String>? distributionList;
  final String? token,
      getURL,
      postURL,
      getSignature,
      postSignature,
      postDocumentURL,
      postDocumentSignature;
  final String? andsenderid;
  final String? inReceiverId;
  final String? andmobicertificate;
  final List<String>? vesselvisitfields;
  final List<String>? vesselstatusfields;
  final List<String>? truckvisitfields;
  final List<String>? queryOptions;
  final List<String>? gcostracktracefields;
  final List<String>? tracktracefields;
  final List<String>? preadvicefields;
  final List<String>? bookreferencefields;
  final String? complex;
  final String? complexAppointments;
  final String? importTransactionType;
  final String? exportTransactionType;
  final List<String>? berthingsequencefields;

  MobiAppData({
    this.importTransactionType,
    this.exportTransactionType,
    this.organisation,
    this.supportEmail,
    this.testUsers,
    this.testPassword,
    this.testPort,
    this.testServer,
    this.testUser,
    this.productionPassword,
    this.productionPort,
    this.productionServer,
    this.productionUser,
    this.distributionList,
    this.getURL,
    this.postURL,
    this.token,
    this.getSignature,
    this.postSignature,
    this.postDocumentSignature,
    this.postDocumentURL,
    this.andsenderid,
    this.inReceiverId,
    this.andmobicertificate,
    this.vesselvisitfields,
    this.vesselstatusfields,
    this.truckvisitfields,
    this.queryOptions,
    this.gcostracktracefields,
    this.tracktracefields,
    this.preadvicefields,
    this.bookreferencefields,
    this.complex,
    this.complexAppointments,
    this.berthingsequencefields,
  });
}

class TruckVisitsModel {
  final String truckLicense,
      tripStatus,
      timeCreated,
      inYard,
      outYard,
      facilityGate;

  TruckVisitsModel({
    required this.truckLicense,
    required this.tripStatus,
    required this.timeCreated,
    required this.inYard,
    required this.outYard,
    required this.facilityGate,
  });

  static List<TruckVisitsModel> fromMap(Map<String, dynamic> map) {
    List<TruckVisitsModel> items = [];

    for (int index = 0; index < map['row'].length; index++) {
      items.add(
        TruckVisitsModel(
          truckLicense: map['row'][index]['field'][0] ?? 'default',
          tripStatus: map['row'][index]['field'][1] ?? 'default',
          timeCreated: map['row'][index]['field'][2] ?? 'default',
          inYard: map['row'][index]['field'][3] ?? 'default',
          outYard: map['row'][index]['field'][4] ?? 'default',
          facilityGate: map['row'][index]['field'][5] ?? 'default',
        ),
      );
    }

    return items;
  }
}

class TrackTraceModel {
  final String unitNumber,
      facility,
      inboundMode,
      outboundMode,
      tState,
      position,
      timeIn,
      timeOut,
      stopRail,
      stopRoad,
      stopVessel,
      holdsPermissions,
      impediments,
      railTrackingPosition;

  TrackTraceModel({
    required this.unitNumber,
    required this.facility,
    required this.inboundMode,
    required this.outboundMode,
    required this.tState,
    required this.position,
    required this.timeIn,
    required this.timeOut,
    required this.stopRail,
    required this.stopRoad,
    required this.stopVessel,
    required this.holdsPermissions,
    required this.impediments,
    required this.railTrackingPosition,
  });

  static List<TrackTraceModel> fromMap(Map<String, dynamic> map) {
    List<TrackTraceModel> items = [];

    for (int index = 0; index < map['row'].length; index++) {
      items.add(
        TrackTraceModel(
          unitNumber: map['row'][index]['field'][0] ?? '',
          facility: map['row'][index]['field'][1] ?? '',
          inboundMode: map['row'][index]['field'][2] ?? '',
          outboundMode: map['row'][index]['field'][3] ?? '',
          tState: map['row'][index]['field'][4] ?? '',
          position: map['row'][index]['field'][5] ?? '',
          timeIn: map['row'][index]['field'][6] ?? '',
          timeOut: map['row'][index]['field'][7] ?? '',
          stopRail: map['row'][index]['field'][8] ?? '',
          stopRoad: map['row'][index]['field'][9] ?? '',
          stopVessel: map['row'][index]['field'][10] ?? '',
          holdsPermissions: map['row'][index]['field'][11] ?? '',
          impediments: map['row'][index]['field'][12] ?? '',
          railTrackingPosition: map['row'][index]['field'][13] ?? '',
        ),
      );
    }

    return items;
  }

  static List<TrackTraceModel> fromXmlElement(List<XmlElement> element) {
    List<TrackTraceModel> items = [];
    for (int index = 0; index < element.length; index++) {
      items.add(
        TrackTraceModel(
          unitNumber:
              element[index].findAllElements('field').toList()[0].innerText,
          facility:
              element[index].findAllElements('field').toList()[1].innerText,
          inboundMode:
              element[index].findAllElements('field').toList()[2].innerText,
          outboundMode:
              element[index].findAllElements('field').toList()[3].innerText,
          tState: element[index].findAllElements('field').toList()[4].innerText,
          position:
              element[index].findAllElements('field').toList()[5].innerText,
          timeIn: element[index].findAllElements('field').toList()[6].innerText,
          timeOut:
              element[index].findAllElements('field').toList()[7].innerText,
          stopRail:
              element[index].findAllElements('field').toList()[8].innerText,
          stopRoad:
              element[index].findAllElements('field').toList()[9].innerText,
          stopVessel:
              element[index].findAllElements('field').toList()[10].innerText,
          holdsPermissions:
              element[index].findAllElements('field').toList()[11].innerText,
          impediments:
              element[index].findAllElements('field').toList()[12].innerText,
          railTrackingPosition:
              element[index].findAllElements('field').toList()[13].innerText,
        ),
      );
    }
    return items;
  }
}

class TrackTraceGCOSModel {
  final String cargoTag1,
      cargoTag2,
      facility,
      arrivalNumber,
      vesselName,
      voyageIn,
      voyageOut,
      inboundMode,
      outboundMode,
      preAdvice,
      orderNumber,
      position,
      receiveDate,
      dispatchDate,
      status;
  final int receiveQuantity, dispatchQuantity;

  TrackTraceGCOSModel({
    required this.cargoTag1,
    required this.cargoTag2,
    required this.facility,
    required this.arrivalNumber,
    required this.vesselName,
    required this.voyageIn,
    required this.voyageOut,
    required this.inboundMode,
    required this.outboundMode,
    required this.preAdvice,
    required this.orderNumber,
    required this.position,
    required this.receiveDate,
    required this.dispatchDate,
    required this.status,
    required this.receiveQuantity,
    required this.dispatchQuantity,
  });

  static List<TrackTraceGCOSModel> fromMap(
    Map<String, dynamic> map,
    String queryType,
  ) {
    List<TrackTraceGCOSModel> items = [];

    if (queryType == "Cargo Tag") {
      if (map["C_CURSOR"].length > 1) {
        try {
          items.add(
            TrackTraceGCOSModel(
              cargoTag1: map['C_CURSOR'][0]['CargoTag1'] ?? '',
              cargoTag2: map['C_CURSOR'][0]['CargoTag2'] ?? '',
              facility: map['C_CURSOR'][0]['Terminal'] ?? '',
              arrivalNumber: map['C_CURSOR'][0]['Arrival_Number'] ?? '',
              vesselName: map['C_CURSOR'][0]['Vessel_Name'] ?? '',
              voyageIn: map['C_CURSOR'][0]['Voyage_In'] ?? '',
              voyageOut: map['C_CURSOR'][0]['Voyage_Out'] ?? '',
              inboundMode: map['C_CURSOR'][0]['Inbound_Mode'] ?? '',
              outboundMode: map['C_CURSOR'][0]['Outbound_Mode'] ?? '',
              preAdvice: map['C_CURSOR'][0]['Pre-Advice'] ?? '',
              orderNumber: map['C_CURSOR'][0]['Order_Number'] ?? '',
              position: map['C_CURSOR'][0]['Position'] ?? '',
              receiveDate: map['C_CURSOR'][0]['Received_Date'] ?? '',
              dispatchDate: map['C_CURSOR'][0]['Dispatch_Date'] ?? '',
              status: map['C_CURSOR'][0]['Status'] ?? '',
              receiveQuantity: int.parse(
                map['C_CURSOR'][0]['Received_quantity'] == ""
                    ? "0"
                    : map['C_CURSOR'][0]['Received_quantity'],
              ),
              dispatchQuantity: int.parse(
                map['C_CURSOR'][0]['Dispatched_Quantity'] == ""
                    ? "0"
                    : map['C_CURSOR'][0]['Dispatched_Quantity'],
              ),
            ),
          );
        } catch (error) {
          items.add(
            TrackTraceGCOSModel(
              cargoTag1: map['C_CURSOR']['CargoTag1'] ?? '',
              cargoTag2: map['C_CURSOR']['CargoTag2'] ?? '',
              facility: map['C_CURSOR']['Terminal'] ?? '',
              arrivalNumber: map['C_CURSOR']['Arrival_Number'] ?? '',
              vesselName: map['C_CURSOR']['Vessel_Name'] ?? '',
              voyageIn: map['C_CURSOR']['Voyage_In'] ?? '',
              voyageOut: map['C_CURSOR']['Voyage_Out'] ?? '',
              inboundMode: map['C_CURSOR']['Inbound_Mode'] ?? '',
              outboundMode: map['C_CURSOR']['Outbound_Mode'] ?? '',
              preAdvice: map['C_CURSOR']['Pre-Advice'] ?? '',
              orderNumber: map['C_CURSOR']['Order_Number'] ?? '',
              position: map['C_CURSOR']['Position'] ?? '',
              receiveDate: map['C_CURSOR']['Received_Date'] ?? '',
              dispatchDate: map['C_CURSOR']['Dispatch_Date'] ?? '',
              status: map['C_CURSOR']['Status'] ?? '',
              receiveQuantity: int.parse(
                map['C_CURSOR']['Received_quantity'] == ""
                    ? "0"
                    : map['C_CURSOR']['Received_quantity'],
              ),
              dispatchQuantity: int.parse(
                map['C_CURSOR']['Dispatched_Quantity'] == ""
                    ? "0"
                    : map['C_CURSOR']['Dispatched_Quantity'],
              ),
            ),
          );
        }
      } else {
        items.add(
          TrackTraceGCOSModel(
            cargoTag1: map['C_CURSOR']['CargoTag1'] ?? '',
            cargoTag2: map['C_CURSOR']['CargoTag2'] ?? '',
            facility: map['C_CURSOR']['Terminal'] ?? '',
            arrivalNumber: map['C_CURSOR']['Arrival_Number'] ?? '',
            vesselName: map['C_CURSOR']['Vessel_Name'] ?? '',
            voyageIn: map['C_CURSOR']['Voyage_In'] ?? '',
            voyageOut: map['C_CURSOR']['Voyage_Out'] ?? '',
            inboundMode: map['C_CURSOR']['Inbound_Mode'] ?? '',
            outboundMode: map['C_CURSOR']['Outbound_Mode'] ?? '',
            preAdvice: map['C_CURSOR']['Pre-Advice'] ?? '',
            orderNumber: map['C_CURSOR']['Order_Number'] ?? '',
            position: map['C_CURSOR']['Position'] ?? '',
            receiveDate: map['C_CURSOR']['Received_Date'] ?? '',
            dispatchDate: map['C_CURSOR']['Dispatch_Date'] ?? '',
            status: map['C_CURSOR']['Status'] ?? '',
            receiveQuantity: int.parse(
              map['C_CURSOR']['Received_quantity'] == ""
                  ? "0"
                  : map['C_CURSOR']['Received_quantity'],
            ),
            dispatchQuantity: int.parse(
              map['C_CURSOR']['Dispatched_Quantity'] == ""
                  ? "0"
                  : map['C_CURSOR']['Dispatched_Quantity'],
            ),
          ),
        );
      }
    } else {
      try {
        for (int index = 0; index < map['C_CURSOR'].length; index++) {
          items.add(
            TrackTraceGCOSModel(
              cargoTag1: map['C_CURSOR'][index]['CargoTag1'] ?? '',
              cargoTag2: map['C_CURSOR'][index]['CargoTag2'] ?? '',
              facility: map['C_CURSOR'][index]['Terminal'] ?? '',
              arrivalNumber:
                  map['C_CURSOR'][index]['Arrival_Number'] ??
                  map['C_CURSOR'][index]['Arrival_No'] ??
                  '',
              vesselName: map['C_CURSOR'][index]['Vessel_Name'] ?? '',
              voyageIn:
                  map['C_CURSOR'][index]['Voyage_In'] ??
                  map['C_CURSOR'][index]['Voyage_in'] ??
                  '',
              voyageOut:
                  map['C_CURSOR'][index]['Voyage_Out'] ??
                  map['C_CURSOR'][index]['Voyage_out'] ??
                  '',
              inboundMode:
                  map['C_CURSOR'][index]['Inbound_Mode'] ??
                  map['C_CURSOR'][index]['Inbound_mode'] ??
                  '',
              outboundMode:
                  map['C_CURSOR'][index]['Outbound_Mode'] ??
                  map['C_CURSOR'][index]['Outbound_mode'] ??
                  '',
              preAdvice:
                  map['C_CURSOR'][index]['Pre-Advice'] ??
                  map['C_CURSOR'][index]['PreAdvise'] ??
                  '',
              orderNumber:
                  map['C_CURSOR'][index]['Order_Number'] ??
                  map['C_CURSOR'][index]['order_no'] ??
                  '',
              position: map['C_CURSOR'][index]['Position'] ?? '',
              receiveDate:
                  map['C_CURSOR'][index]['Received_Date'] ??
                  map['C_CURSOR'][index]['Received_date'] ??
                  '',
              dispatchDate:
                  map['C_CURSOR'][index]['Dispatch_Date'] ??
                  map['C_CURSOR'][index]['Dispatch_Date'] ??
                  '',
              status: map['C_CURSOR'][index]['Status'] ?? '',
              receiveQuantity:
                  queryType == 'Order Number'
                      ? int.parse(
                        map['C_CURSOR'][index]['Received_Quantity'] == ""
                            ? "0"
                            : map['C_CURSOR'][index]['Received_Quantity'],
                      )
                      : int.parse(
                        map['C_CURSOR'][index]['Received_quantity'] == ""
                            ? "0"
                            : map['C_CURSOR'][index]['Received_quantity'],
                      ),
              dispatchQuantity: int.parse(
                map['C_CURSOR'][index]['Dispatched_Quantity'] == ""
                    ? "0"
                    : map['C_CURSOR'][index]['Dispatched_Quantity'],
              ),
            ),
          );
        }
      } catch (error) {
        items.add(
          TrackTraceGCOSModel(
            cargoTag1: map['C_CURSOR']['CargoTag1'] ?? '',
            cargoTag2: map['C_CURSOR']['CargoTag2'] ?? '',
            facility: map['C_CURSOR']['Terminal'] ?? '',
            arrivalNumber:
                map['C_CURSOR']['Arrival_Number'] ??
                map['C_CURSOR']['Arrival_No'] ??
                '',
            vesselName: map['C_CURSOR']['Vessel_Name'] ?? '',
            voyageIn:
                map['C_CURSOR']['Voyage_In'] ??
                map['C_CURSOR']['Voyage_in'] ??
                '',
            voyageOut:
                map['C_CURSOR']['Voyage_Out'] ??
                map['C_CURSOR']['Voyage_out'] ??
                '',
            inboundMode:
                map['C_CURSOR']['Inbound_Mode'] ??
                map['C_CURSOR']['Inbound_mode'] ??
                '',
            outboundMode:
                map['C_CURSOR']['Outbound_Mode'] ??
                map['C_CURSOR']['Outbound_mode'] ??
                '',
            preAdvice:
                map['C_CURSOR']['Pre-Advice'] ??
                map['C_CURSOR']['Preadvise'] ??
                '',
            orderNumber:
                map['C_CURSOR']['Order_Number'] ??
                map['C_CURSOR']['order_no'] ??
                '',
            position: map['C_CURSOR']['Position'] ?? '',
            receiveDate:
                map['C_CURSOR']['Received_Date'] ??
                map['C_CURSOR']['Received_date'] ??
                '',
            dispatchDate:
                map['C_CURSOR']['Dispatch_Date'] ??
                map['C_CURSOR']['Dispatch_date'] ??
                '',
            status: map['C_CURSOR']['Status'] ?? '',
            receiveQuantity:
                queryType == 'Order Number'
                    ? int.parse(
                      map['C_CURSOR']['Received_Quantity'] == ""
                          ? "0"
                          : map['C_CURSOR']['Received_Quantity'],
                    )
                    : int.parse(
                      map['C_CURSOR']['Received_quantity'] == ""
                          ? "0"
                          : map['C_CURSOR']['Received_quantity'],
                    ),
            dispatchQuantity: int.parse(
              map['C_CURSOR']['Dispatched_Quantity'] == ""
                  ? "0"
                  : map['C_CURSOR']['Dispatched_Quantity'],
            ),
          ),
        );
        return items;
      }
    }

    return items;
  }
}

class PreAdviceModel {
  final String unitNumber,
      category,
      vState,
      facility,
      tState,
      timeIn,
      timeOut,
      ibActualVisit,
      obActualVisit;

  PreAdviceModel({
    required this.unitNumber,
    required this.category,
    required this.vState,
    required this.facility,
    required this.tState,
    required this.timeIn,
    required this.timeOut,
    required this.ibActualVisit,
    required this.obActualVisit,
  });

  static List<PreAdviceModel> fromMap(Map<String, dynamic> map) {
    List<PreAdviceModel> items = [];

    for (int index = 0; index < map['row'].length; index++) {
      map['row'][index]['field'].length == 8
          ? items.add(
            PreAdviceModel(
              unitNumber: map['row'][index]['field'][0] ?? '',
              category: map['row'][index]['field'][1] ?? '',
              vState: map['row'][index]['field'][2] ?? '',
              facility: '',
              tState: map['row'][index]['field'][3] ?? '',
              timeIn: map['row'][index]['field'][4] ?? '',
              timeOut: map['row'][index]['field'][5] ?? '',
              ibActualVisit: map['row'][index]['field'][6] ?? '',
              obActualVisit: map['row'][index]['field'][7] ?? '',
            ),
          )
          : items.add(
            PreAdviceModel(
              unitNumber: map['row'][index]['field'][0] ?? '',
              category: map['row'][index]['field'][1] ?? '',
              vState: map['row'][index]['field'][2] ?? '',
              facility: map['row'][index]['field'][3] ?? '',
              tState: map['row'][index]['field'][4] ?? '',
              timeIn: map['row'][index]['field'][5] ?? '',
              timeOut: map['row'][index]['field'][6] ?? '',
              ibActualVisit: map['row'][index]['field'][7] ?? '',
              obActualVisit: map['row'][index]['field'][8] ?? '',
            ),
          );
    }

    return items;
  }
}

class BookingReferenceModel {
  final String unitNumber,
      facility,
      inboundMode,
      outboundMode,
      tState,
      position,
      timeIn,
      timeOut,
      stopRail,
      stopRoad,
      stopVessel,
      holdsPermissions,
      impediments,
      railTrackingPosition,
      railAccountNumber;

  BookingReferenceModel({
    required this.unitNumber,
    required this.facility,
    required this.inboundMode,
    required this.outboundMode,
    required this.tState,
    required this.position,
    required this.timeIn,
    required this.timeOut,
    required this.stopRail,
    required this.stopRoad,
    required this.stopVessel,
    required this.holdsPermissions,
    required this.impediments,
    required this.railTrackingPosition,
    required this.railAccountNumber,
  });

  static List<BookingReferenceModel> fromMap(Map<String, dynamic> map) {
    List<BookingReferenceModel> items = [];

    for (int index = 0; index < map['row'].length; index++) {
      items.add(
        BookingReferenceModel(
          unitNumber: map['row'][index]['field'][0] ?? '',
          facility: map['row'][index]['field'][1] ?? '',
          inboundMode: map['row'][index]['field'][2] ?? '',
          outboundMode: map['row'][index]['field'][3] ?? '',
          tState: map['row'][index]['field'][4] ?? '',
          position: map['row'][index]['field'][5] ?? '',
          timeIn: map['row'][index]['field'][6] ?? '',
          timeOut: map['row'][index]['field'][7] ?? '',
          stopRail: map['row'][index]['field'][8] ?? '',
          stopRoad: map['row'][index]['field'][9] ?? '',
          stopVessel: map['row'][index]['field'][10] ?? '',
          holdsPermissions: map['row'][index]['field'][11] ?? '',
          impediments: map['row'][index]['field'][12] ?? '',
          railTrackingPosition: map['row'][index]['field'][13] ?? '',
          railAccountNumber: map['row'][index]['field'][14] ?? '',
        ),
      );
    }

    return items;
  }
}

class QueryOptionsModel {
  final String name;
  final String description;
  QueryOptionsModel({required this.name, required this.description});

  static List<QueryOptionsModel> fromMap(Map<String, dynamic> map) {
    List<QueryOptionsModel> items = [];

    for (int index = 0; index < map['row'].length; index++) {
      items.add(
        QueryOptionsModel(
          name: map['row'][index]['field'][0] ?? 'default',
          description: map['row'][index]['field'][1] ?? 'default',
        ),
      );
    }

    return items;
  }

  static List<QueryOptionsModel> fromList(List<String> options, String sector) {
    List<QueryOptionsModel> items = [];

    for (int index = 0; index < options.length; index++) {
      items.add(
        QueryOptionsModel(
          name: options[index],
          description:
              sector == 'automotive' && options[index] == 'Cargo Tag'
                  ? 'Vin Number'
                  : options[index],
        ),
      );
    }

    return items;
  }
}

class VesselSpotlightModel {
  final String filter;
  final List<VesselItems> items;
  VesselSpotlightModel({required this.filter, required this.items});

  Map<String, dynamic> toMap() => <String, dynamic>{
    'filter': filter,
    'items': items.map((e) => e.toMap()).toList(growable: true),
  };

  static VesselSpotlightModel fromMap(
    Map<String, dynamic> map,
    String filter,
    key,
  ) {
    return VesselSpotlightModel(
      filter: filter,
      items:
          map[key]
              .map((mapping) => VesselItems.fromMap(mapping, key))
              .toList()
              .cast<VesselItems>(),
    );
  }
}

class VesselItems {
  String? visitID, vesselName, callDirection;

  VesselItems({
    required this.visitID,
    required this.vesselName,
    required this.callDirection,
  });

  Map<String, dynamic> toMap() {
    return {
      'visitID': visitID,
      'vesselName': vesselName,
      'callDirection': callDirection,
    };
  }

  static VesselItems fromMap(Map<String, dynamic> map, String key) {
    return VesselItems(
      visitID: map['field'][0] ?? 'default',
      vesselName: map['field'][1] ?? 'default',
      callDirection: map['field'][2] ?? 'default',
    );
  }
}

class VesselStatusModel {
  final List<VesselStatus> items;
  VesselStatusModel({required this.items});

  static VesselStatusModel fromMap(Map<String, dynamic> map, key) {
    return VesselStatusModel(
      items:
          map[key]
              .map((mapping) => VesselStatus.fromMap(mapping, key))
              .toList()
              .cast<VesselStatus>(),
    );
  }
}

class VesselStatus {
  String visitID,
      vesselName,
      vesselClass,
      carrierService,
      inboundVoyage,
      outboundVoyage,
      facility,
      estimatedArrivalTime,
      estimatedDepartedTime,
      plannedArrivalTime,
      plannedDepartureTime,
      actualArrivalTime,
      actualDepartureTime,
      quay,
      berth,
      bollardFore,
      bollardAft,
      workingPhase,
      beginReceive,
      reeferCutOff,
      dryCutOff,
      hazCutOff,
      outboundUnitCount,
      outboundLoadCount,
      inboundUnitCount,
      inboundDischargeCount;
  VesselStatus({
    required this.visitID,
    required this.vesselName,
    required this.vesselClass,
    required this.carrierService,
    required this.inboundVoyage,
    required this.outboundVoyage,
    required this.facility,
    required this.estimatedArrivalTime,
    required this.estimatedDepartedTime,
    required this.plannedArrivalTime,
    required this.plannedDepartureTime,
    required this.actualArrivalTime,
    required this.actualDepartureTime,
    required this.quay,
    required this.berth,
    required this.bollardFore,
    required this.bollardAft,
    required this.workingPhase,
    required this.beginReceive,
    required this.reeferCutOff,
    required this.dryCutOff,
    required this.hazCutOff,
    required this.outboundUnitCount,
    required this.outboundLoadCount,
    required this.inboundUnitCount,
    required this.inboundDischargeCount,
  });

  static VesselStatus fromMap(Map<String, dynamic> map, String key) {
    return VesselStatus(
      visitID: map['VISIT'] ?? 'default',
      facility: map['FACILITY'] ?? 'default',
      vesselName: map['VESSEL_NAME'] ?? 'default',
      vesselClass: map['VSL_CLASS'] ?? 'default',
      carrierService: map['LINE'] ?? 'default',
      quay: map['QUAY'] ?? 'default',
      berth: map['BERTH'] ?? 'default',
      bollardFore: map['BOLLARD_FORE'] ?? 'default',
      bollardAft: map['BOLLARD_AFT'] ?? 'default',
      inboundVoyage: map['IB_VYG'] ?? 'default',
      outboundVoyage: map['OB_VYG'] ?? 'default',
      workingPhase: map['PHASE'] ?? 'default',
      estimatedArrivalTime: map['ETA'] ?? 'default',
      estimatedDepartedTime: map['ETD'] ?? 'default',
      plannedArrivalTime: map['PETA'] ?? 'default',
      plannedDepartureTime: map['PETD'] ?? 'default',
      actualArrivalTime: map['ATA'] ?? 'default',
      actualDepartureTime: map['ATD'] ?? 'default',
      beginReceive: map['BEGIN_RECEIVE'] ?? 'default',
      reeferCutOff: map['REEFER_CUTOFF'] ?? 'default',
      dryCutOff: map['DRY_CUTOFF'] ?? 'default',
      hazCutOff: map['HAZ_CUTOFF'] ?? 'default',
      outboundUnitCount: map['OUTBOUND_UNIT_COUNT'] ?? '0',
      outboundLoadCount: map['OUTBOUND_LOAD_COUNT'] ?? '0',
      inboundUnitCount: map['INBOUND_UNIT_COUNT'] ?? '0',
      inboundDischargeCount: map['INBOUND_DISCHARGE_COUNT'] ?? '0',
    );
  }
}

class VesselVisitsModel {
  final String items;
  VesselVisitsModel({required this.items});

  static List<String> fromMap(Map<String, dynamic> map, String key) {
    List<String> items = [];

    if (key == 'C_CURSOR') {
      items.add(map[key]['vesselid'] ?? 'default');
      items.add(map[key]['vesselname'] ?? 'default');
      items.add(map[key]['vesseloperator'] ?? 'default');
      items.add(map[key]['vesselcarrier'] ?? 'default');
      items.add(map[key]['inboundvoyage'] ?? 'default');
      items.add(map[key]['outboundvoyage'] ?? 'default');
      items.add(map[key]['facility'] ?? 'default');
      items.add(map[key]['estimatedarrivaltime'] ?? 'default');
      items.add(map[key]['estimateddeparturetime'] ?? 'default');
      items.add(map[key]['outsideportarrivaltime'] ?? 'default');
      items.add(map[key]['actualarrivaltime'] ?? 'default');
      items.add(map[key]['actualdeparturetime'] ?? 'default');
      items.add(map[key]['startofwork'] ?? 'default');
      items.add(map[key]['endofwork'] ?? 'default');
    } else {
      for (int index = 0; index < map['row'][0]['field'].length; index++) {
        items.add(map['row'][0]['field'][index] ?? 'default');
      }
    }

    return items;
  }
}

class BerthModel {
  final List<BerthItems> items;
  BerthModel({required this.items});

  Map<String, dynamic> toMap() => <String, dynamic>{
    'items': items.map((e) => e.toMap()).toList(growable: true),
  };

  static BerthModel fromMap(Map<String, dynamic> map, String key) {
    return BerthModel(
      items:
          map[key]
              .map((mapping) => BerthItems.fromMap(mapping))
              .toList()
              .cast<BerthItems>(),
    );
  }
}

class BerthItems {
  String? berthID, berthName, berthDescription;

  BerthItems({
    required this.berthID,
    required this.berthName,
    required this.berthDescription,
  });

  Map<String, dynamic> toMap() {
    return {
      'berthID': berthID,
      'berthName': berthName,
      'berthDescription': berthDescription,
    };
  }

  static BerthItems fromMap(Map<String, dynamic> map) {
    return BerthItems(
      berthID: map['berthID'] ?? 'default',
      berthName: map['berthName'] ?? 'default',
      berthDescription: map['berthDescription'] ?? 'default',
    );
  }
}

class BerthingSequenceModel {
  final String arrivalNumber,
      vesselName,
      voyageIn,
      voyageOut,
      agent,
      shippingLine,
      cutOffDate,
      preplanDate,
      phase4Date,
      originalETA,
      etaChanges,
      etaPortLimits,
      startOperations,
      completeOperations,
      sailingDate;

  BerthingSequenceModel({
    required this.arrivalNumber,
    required this.vesselName,
    required this.voyageIn,
    required this.voyageOut,
    required this.agent,
    required this.shippingLine,
    required this.cutOffDate,
    required this.preplanDate,
    required this.phase4Date,
    required this.originalETA,
    required this.etaChanges,
    required this.etaPortLimits,
    required this.startOperations,
    required this.completeOperations,
    required this.sailingDate,
  });

  static List<BerthingSequenceModel> fromMap(Map<String, dynamic> map) {
    List<BerthingSequenceModel> items = [];

    for (int index = 0; index < map['getBerthSequence'].length; index++) {
      items.add(
        BerthingSequenceModel(
          arrivalNumber:
              map['getBerthSequence'][index]['ArrivalNumber'] ?? 'default',
          vesselName: map['getBerthSequence'][index]['VesselName'] ?? 'default',
          voyageIn: map['getBerthSequence'][index]['VoyageIn'] ?? 'default',
          voyageOut: map['getBerthSequence'][index]['VoyageOut'] ?? 'default',
          agent: map['getBerthSequence'][index]['Agent'] ?? 'default',
          shippingLine:
              map['getBerthSequence'][index]['ShippingLine'] ?? 'default',
          cutOffDate: map['getBerthSequence'][index]['CutOffdate'] ?? 'default',
          preplanDate:
              map['getBerthSequence'][index]['PreplanDate'] ?? 'default',
          phase4Date: map['getBerthSequence'][index]['Phase4date'] ?? 'default',
          originalETA:
              map['getBerthSequence'][index]['OriginalETA'] ?? 'default',
          etaChanges: map['getBerthSequence'][index]['ETAChanges'] ?? 'default',
          etaPortLimits:
              map['getBerthSequence'][index]['ETAPortLimits'] ?? 'default',
          startOperations:
              map['getBerthSequence'][index]['StartOperations'] ?? 'default',
          completeOperations:
              map['getBerthSequence'][index]['CompleteOperations'] ?? 'default',
          sailingDate:
              map['getBerthSequence'][index]['SailingDate'] ?? 'default',
        ),
      );
    }

    return items;
  }
}

class StackOccupancyModel {
  final String areaCode,
      zoneCode,
      zoneCapacity,
      zoneOccupied,
      zonePlanned,
      zoneAvailable;

  StackOccupancyModel({
    required this.areaCode,
    required this.zoneCode,
    required this.zoneCapacity,
    required this.zoneOccupied,
    required this.zonePlanned,
    required this.zoneAvailable,
  });

  static List<StackOccupancyModel> fromMap(
    Map<String, dynamic> map,
    String key,
  ) {
    List<StackOccupancyModel> items = [];

    for (int index = 0; index < map[key].length; index++) {
      items.add(
        StackOccupancyModel(
          areaCode: map[key][index]['Area'] ?? 'default',
          zoneCode: map[key][index]['Zone'] ?? 'default',
          zoneCapacity: map[key][index]['Capacity'] ?? 'default',
          zoneOccupied: map[key][index]['Occupied'] ?? 'default',
          zonePlanned: map[key][index]['Planned'] ?? 'default',
          zoneAvailable: map[key][index]['Available'] ?? 'default',
        ),
      );
    }

    return items;
  }
}

class FlexibleTrackandTraceModel extends BookingReferenceModel {
  final String? category, vState, ibActualVisit, obActualVisit, filter;

  FlexibleTrackandTraceModel({
    this.category,
    this.vState,
    this.ibActualVisit,
    this.obActualVisit,
    required this.filter,
    required super.unitNumber,
    required super.facility,
    required super.inboundMode,
    required super.outboundMode,
    required super.tState,
    required super.position,
    required super.timeIn,
    required super.timeOut,
    required super.stopRail,
    required super.stopRoad,
    required super.stopVessel,
    required super.holdsPermissions,
    required super.impediments,
    required super.railTrackingPosition,
    required super.railAccountNumber,
  });

  static List<FlexibleTrackandTraceModel> fromMap(
    Map<String, dynamic> map,
    String filter,
  ) {
    List<FlexibleTrackandTraceModel> items = [];
    switch (filter) {
      case 'PARM_CTT_UNIT_NBR':
        for (int index = 0; index < map['row'].length; index++) {
          items.add(
            FlexibleTrackandTraceModel(
              filter: filter,
              unitNumber: map['row'][index]['field'][0] ?? '',
              facility: map['row'][index]['field'][1] ?? '',
              inboundMode: map['row'][index]['field'][2] ?? '',
              outboundMode: map['row'][index]['field'][3] ?? '',
              tState: map['row'][index]['field'][4] ?? '',
              position: map['row'][index]['field'][5] ?? '',
              timeIn: map['row'][index]['field'][6] ?? '',
              timeOut: map['row'][index]['field'][7] ?? '',
              stopRail: map['row'][index]['field'][8] ?? '',
              stopRoad: map['row'][index]['field'][9] ?? '',
              stopVessel: map['row'][index]['field'][10] ?? '',
              holdsPermissions: map['row'][index]['field'][11] ?? '',
              impediments: map['row'][index]['field'][12] ?? '',
              railTrackingPosition: map['row'][index]['field'][13] ?? '',
              railAccountNumber: '',
            ),
          );
        }
        break;
      case 'PARM_PC_UNIT_NBR':
        for (int index = 0; index < map['row'].length; index++) {
          items.add(
            FlexibleTrackandTraceModel(
              filter: filter,
              unitNumber: map['row'][index]['field'][0] ?? '',
              facility: map['row'][index]['field'][1] ?? '',
              category: map['row'][index]['field'][2] ?? '',
              vState: map['row'][index]['field'][3] ?? '',
              tState: map['row'][index]['field'][4] ?? '',
              timeIn: map['row'][index]['field'][5] ?? '',
              timeOut: map['row'][index]['field'][6] ?? '',
              ibActualVisit: map['row'][index]['field'][7] ?? '',
              obActualVisit: map['row'][index]['field'][8] ?? '',
              inboundMode: '',
              outboundMode: '',
              position: '',
              stopRail: '',
              stopRoad: '',
              stopVessel: '',
              holdsPermissions: '',
              impediments: '',
              railTrackingPosition: '',
              railAccountNumber: '',
            ),
          );
        }
        break;
      case 'PARM_BOOKING_NUMBER':
        for (int index = 0; index < map['row'].length; index++) {
          items.add(
            FlexibleTrackandTraceModel(
              filter: filter,
              unitNumber: map['row'][index]['field'][0] ?? '',
              facility: map['row'][index]['field'][1] ?? '',
              inboundMode: map['row'][index]['field'][2] ?? '',
              outboundMode: map['row'][index]['field'][3] ?? '',
              tState: map['row'][index]['field'][4] ?? '',
              position: map['row'][index]['field'][5] ?? '',
              timeIn: map['row'][index]['field'][6] ?? '',
              timeOut: map['row'][index]['field'][7] ?? '',
              stopRail: map['row'][index]['field'][8] ?? '',
              stopRoad: map['row'][index]['field'][9] ?? '',
              stopVessel: map['row'][index]['field'][10] ?? '',
              holdsPermissions: map['row'][index]['field'][11] ?? '',
              impediments: map['row'][index]['field'][12] ?? '',
              railTrackingPosition: map['row'][index]['field'][13] ?? '',
              railAccountNumber: map['row'][index]['field'][14] ?? '',
            ),
          );
        }
        break;
      default:
    }

    return items;
  }
}
