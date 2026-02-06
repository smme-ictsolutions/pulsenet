import 'package:customer_portal/constants/styles.dart';
import 'package:customer_portal/model/mobiapp.dart';
import 'package:customer_portal/model/singletons_data.dart';
import 'package:customer_portal/model/user.dart';
import 'package:customer_portal/shared/dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
import 'package:flutter_map_marker_popup/flutter_map_marker_popup.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

class InformationMarkerInput extends StatelessWidget {
  final ValueChanged<InformationMarkerInputData> onPressed;
  final String layoutSource, selectedFacility;
  final List<VesselStatus> vesselStatus;
  const InformationMarkerInput({
    super.key,
    required this.onPressed,
    required this.layoutSource,
    required this.selectedFacility,
    required this.vesselStatus,
  });

  List<Marker> generateMarkers(String layoutSource, selectedFacility) {
    List<Marker> mapMarkers = [];

    if (layoutSource == 'facility') {
      for (var informationMarker
          in appData.portLayoutsList
              .where((element) => element.terminal == selectedFacility)
              .first
              .informationMarkers) {
        mapMarkers.add(
          Marker(
            point: LatLng(
              informationMarker.latitude,
              informationMarker.longitude,
            ),
            child: const Icon(Icons.info_rounded, color: kColorBackground),
            alignment: Alignment.bottomCenter,
          ),
        );
      }

      return mapMarkers;
    }
    return mapMarkers;
  }

  String getSelectedLabel(String layoutSource, Marker marker) {
    if (layoutSource == 'facility') {
      try {
        return appData.portLayoutsList
            .where((element) => element.terminal == selectedFacility)
            .first
            .informationMarkers
            .where(
              (element) =>
                  element.latitude == marker.point.latitude &&
                  element.longitude == marker.point.longitude,
            )
            .first
            .label;
      } catch (error) {
        debugPrint(marker.point.latitude.toString());
      }
    }
    return '';
  }

  @override
  Widget build(BuildContext context) {
    return PopupMarkerLayer(
      options: PopupMarkerLayerOptions(
        selectedMarkerBuilder: (context, marker) {
          debugPrint(marker.point.toString());
          return IconButton(
            color: kColorSuccess,
            onPressed: () async {
              onPressed(
                InformationMarkerInputData(
                  marker: marker,
                  label:
                      appData.portLayoutsList
                          .where(
                            (element) => element.terminal == selectedFacility,
                          )
                          .first
                          .informationMarkers
                          .where(
                            (element) =>
                                element.latitude == marker.point.latitude &&
                                element.longitude == marker.point.longitude,
                          )
                          .first
                          .label,
                ),
              );
            },
            icon: Icon(Icons.info),
          );
        },
        popupDisplayOptions: PopupDisplayOptions(
          snap: PopupSnap.markerLeft,
          animation: PopupAnimation.fade(),
          builder:
              (BuildContext context, Marker marker) => Container() /*TextButton(
                style: ElevatedButton.styleFrom(backgroundColor: kColorSuccess),
                onPressed: () async {
                  await DialogService(
                    button: 'done',
                    origin: 'Vessel Status',
                  ).showVesselStatusDetail(
                    context: context,
                    vesselStatusDetail:
                        vesselStatus
                            .where(
                              (element) =>
                                  element.berth ==
                                  getSelectedLabel(layoutSource, marker),
                            )
                            .first,
                    mobiAppData: mobiAppData,
                  );
                },
                child: Text('status', style: kLabelTextStyle),
              ),*/,
        ),
        markers: generateMarkers(layoutSource, selectedFacility),
      ),
    );
  }
}
