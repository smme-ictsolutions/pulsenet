import 'package:customer_portal/constants/styles.dart';
import 'package:customer_portal/model/mobiapp.dart';
import 'package:customer_portal/model/singletons_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_math/flutter_geo_math.dart';
import 'package:latlong2/latlong.dart';

List<RotatedOverlayImage> generateImageMarkers(
  String selectedFacility,
  List<VesselStatus> vesselStatus,
) {
  final List<RotatedOverlayImage> imageMarkers = <RotatedOverlayImage>[];
  final double lengthInMeters = 200.0;
  final double heightInMeters = 60.0;
  for (var imageMarker
      in appData.portLayoutsList
          .where((element) => element.terminal == selectedFacility)
          .first
          .imageMarkers) {
    if (vesselStatus
        .where((element) => element.berth == imageMarker.label)
        .isNotEmpty) {
      imageMarkers.add(
        RotatedOverlayImage(
          topLeftCorner: FlutterMapMath.destinationPoint(
            double.parse(
              imageMarker.startcoordinates.substring(
                0,
                imageMarker.startcoordinates.indexOf(','),
              ),
            ),
            double.parse(
              imageMarker.startcoordinates.substring(
                imageMarker.startcoordinates.indexOf(',') + 1,
              ),
            ),
            heightInMeters,
            imageMarker.bearing == 'east'
                ? 0.0 // if image faces east then image height calculated bearing North
                : imageMarker.bearing == 'northwest'
                ? 180.0
                : 90, // if image faces south then image height calculated bearing East
          ),
          bottomLeftCorner: LatLng(
            double.parse(
              imageMarker.startcoordinates.substring(
                0,
                imageMarker.startcoordinates.indexOf(','),
              ),
            ),
            double.parse(
              imageMarker.startcoordinates.substring(
                imageMarker.startcoordinates.indexOf(',') + 1,
              ),
            ),
          ),
          bottomRightCorner: FlutterMapMath.destinationPoint(
            double.parse(
              imageMarker.startcoordinates.substring(
                0,
                imageMarker.startcoordinates.indexOf(','),
              ),
            ),
            double.parse(
              imageMarker.startcoordinates.substring(
                imageMarker.startcoordinates.indexOf(',') + 1,
              ),
            ),
            lengthInMeters,
            imageMarker.bearing == 'east'
                ? 77.0
                : imageMarker.bearing == 'southeast'
                ? 135
                : imageMarker.bearing == 'eastsouth'
                ? 115.0
                : imageMarker.bearing == 'northeast'
                ? 45
                : imageMarker.bearing == 'eastnorth'
                ? 129
                : imageMarker.bearing == 'northwest'
                ? 83
                : imageMarker.bearing == 'west'
                ? 155
                : 200,
          ),
          opacity: 0.8,
          imageProvider: AssetImage('assets/ship.png'),
        ),
      );
    }
  }
  return imageMarkers;
}

List<Polyline<Object>> generatePolylines(String selectedFacility) {
  final List<LatLng> points = [];
  final List<Polyline<Object>> polyLines = <Polyline<Object>>[];
  for (var point
      in appData.portLayoutsList
          .where((element) => element.terminal == selectedFacility)
          .first
          .polyLines) {
    points.add(LatLng(point.latitude, point.longitude));
  }
  for (int i = 0; i < points.length - 1; i += 2) {
    polyLines.add(
      Polyline<Object>(
        points: [points[i], points[i + 1]],
        strokeWidth: 4.0,
        color: kColorSuccess,
      ),
    );
  }
  return polyLines;
}
