import 'package:flutter_map/flutter_map.dart';
import 'package:scoped_model/scoped_model.dart';

class MyUser extends Model {
  final String uid;

  MyUser({required this.uid});
}

class UserSubscribeData {
  final String? uid;
  final String? username;
  final List<String>? sector;
  final String? stakeholder;
  final List<String>? port;
  final List<String>? modules;
  final String? email;
  final String? fcmToken;
  final bool isAdmin;

  UserSubscribeData({
    this.uid,
    this.username,
    this.sector,
    this.stakeholder,
    this.port,
    this.modules,
    this.email,
    this.fcmToken,
    required this.isAdmin,
  });
}

class LookUpData {
  final String name, sector;
  final String? port;

  LookUpData({required this.name, required this.sector, this.port});
}

class ModuleData {
  final String module, fileSystem, admin, terminal, api;
  final bool requiresApproval;

  ModuleData({
    required this.module,
    required this.fileSystem,
    required this.requiresApproval,
    required this.admin,
    required this.terminal,
    required this.api,
  });

  Map<String, dynamic> toMap() => <String, dynamic>{
    'api': api,
    'module': module,
  };

  static List<String> fromMap(List<ModuleData> map) {
    List<String> x = [];
    for (int i = 0; i < map.length; i++) {
      x.add(map[i].module);
    }
    return x;
  }
}

class NavisSubscribeData {
  final String? username, password, facility, truckingCompanyID;
  final bool? connected;

  NavisSubscribeData({
    this.username,
    this.password,
    this.facility,
    this.connected,
    this.truckingCompanyID,
  });
}

class TerminalLayoutData {
  final String terminal, port, abbreviation, navisCode;
  final double latitude, longitude;
  List<PolylineData> polyLines;
  List<MarkerData> markers;
  List<ImageMarkerData> imageMarkers;
  List<MarkerData> informationMarkers;

  TerminalLayoutData({
    required this.abbreviation,
    required this.navisCode,
    required this.port,
    required this.terminal,
    required this.latitude,
    required this.longitude,
    required this.polyLines,
    required this.markers,
    required this.imageMarkers,
    required this.informationMarkers,
  });
  static TerminalLayoutData fromMap(Map<String, dynamic> map, String key) {
    return TerminalLayoutData(
      abbreviation: map['abbreviation'],
      navisCode: map['naviscode'],
      port: map['port'],
      terminal: map['terminal'],
      latitude: map['latitude'],
      longitude: map['longitude'],
      polyLines:
          (map['polypoints'] as List)
              .map((polypoint) => PolylineData.fromMap(polypoint))
              .toList(),
      markers:
          (map['markers'] as List)
              .map((marker) => MarkerData.fromMap(marker))
              .toList(),
      imageMarkers:
          (map['imagemarkers'] as List)
              .map((imagemarker) => ImageMarkerData.fromMap(imagemarker))
              .toList(),
      informationMarkers:
          (map['informationmarkers'] as List)
              .map((informationmarker) => MarkerData.fromMap(informationmarker))
              .toList(),
    );
  }
}

class PolylineData {
  final double latitude, longitude;

  PolylineData({required this.latitude, required this.longitude});

  static PolylineData fromMap(Map<String, dynamic> map) {
    return PolylineData(latitude: map['latitude'], longitude: map['longitude']);
  }
}

class MarkerData {
  final double latitude, longitude;
  String label;

  MarkerData({
    required this.latitude,
    required this.longitude,
    required this.label,
  });

  static MarkerData fromMap(Map<String, dynamic> map) {
    return MarkerData(
      latitude: map['latitude'],
      longitude: map['longitude'],
      label: map['label'],
    );
  }
}

class ImageMarkerData {
  String label, bearing, startcoordinates;

  ImageMarkerData({
    required this.label,
    required this.bearing,
    required this.startcoordinates,
  });

  static ImageMarkerData fromMap(Map<String, dynamic> map) {
    return ImageMarkerData(
      bearing: map['bearing'],
      startcoordinates: map['startcoordinates'],
      label: map['label'],
    );
  }
}

class MarkerInputData {
  final List<Marker> markers;
  String label;

  MarkerInputData({required this.markers, required this.label});
}

class InformationMarkerInputData {
  final Marker marker;
  String label;

  InformationMarkerInputData({required this.marker, required this.label});
}
