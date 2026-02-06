import 'package:customer_portal/constants/styles.dart';
import 'package:customer_portal/model/mobiapp.dart';
import 'package:customer_portal/model/singletons_data.dart';
import 'package:customer_portal/model/user.dart';
import 'package:customer_portal/shared/hovered_marker.dart';
import 'package:customer_portal/shared/tapped_marker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
import 'package:flutter_map_marker_popup/flutter_map_marker_popup.dart';
import 'package:latlong2/latlong.dart';
import 'package:pdfrx/pdfrx.dart';

class MarkerInput extends StatelessWidget {
  final ValueChanged<MarkerInputData> onPressed;
  final String layoutSource, selectedFacility;
  final List<VesselStatus> vesselStatus;
  const MarkerInput({
    super.key,
    required this.onPressed,
    required this.layoutSource,
    required this.selectedFacility,
    required this.vesselStatus,
  });

  List<Marker> generateMarkers(String layoutSource, selectedFacility) {
    List<Marker> mapMarkers = [];
    if (layoutSource == 'province') {
      //add province markers
      mapMarkers.add(
        Marker(
          point: LatLng(-29.835921, 30.983149),
          child: const Icon(
            Icons.location_on,
            color: kColorBackground,
            size: 50,
          ),
        ),
      );
      mapMarkers.add(
        Marker(
          point: LatLng(-33.004098, 27.885005),
          child: const Icon(
            Icons.location_on,
            color: kColorBackground,
            size: 50,
          ),
        ),
      );
      mapMarkers.add(
        Marker(
          point: LatLng(-33.938843, 25.621821),
          child: const Icon(
            Icons.location_on,
            color: kColorBackground,
            size: 50,
          ),
        ),
      );
      mapMarkers.add(
        Marker(
          point: LatLng(-33.957071, 18.392817),
          child: const Icon(
            Icons.location_on,
            color: kColorBackground,
            size: 50,
          ),
          alignment: Alignment.bottomCenter,
        ),
      );

      return mapMarkers;
    }
    if (layoutSource == 'port') {
      //add facility markers
      for (var portmarker in appData.portLayoutsList.where(
        (element) => element.port == selectedFacility,
      )) {
        mapMarkers.add(
          Marker(
            point: LatLng(portmarker.latitude, portmarker.longitude),
            child: const Icon(
              Icons.location_on,
              color: kColorBackground,
              size: 50,
            ),
            alignment: Alignment.bottomCenter,
          ),
        );
      }

      return mapMarkers;
    }
    if (layoutSource == 'facility') {
      for (var marker
          in appData.portLayoutsList
              .where((element) => element.terminal == selectedFacility)
              .first
              .markers) {
        mapMarkers.add(
          Marker(
            point: LatLng(marker.latitude, marker.longitude),
            width: 40,
            height: 30,
            child: HoverableMarker(
              markerData: marker,
              vesselStatus: vesselStatus,
            ),
            alignment: Alignment.bottomCenter,
          ),
        );
        for (var marker
            in appData.portLayoutsList
                .where((element) => element.terminal == selectedFacility)
                .first
                .informationMarkers) {
          mapMarkers.add(
            Marker(
              point: LatLng(marker.latitude, marker.longitude),
              width: 200,
              height: 100,
              child: Row(
                mainAxisSize: MainAxisSize.max,
                children: [
                  if (vesselStatus
                      .where((element) => element.berth == marker.label)
                      .isNotEmpty)
                    Container(
                      padding: EdgeInsets.only(left: 2),
                      decoration: BoxDecoration(
                        color: kColorText,
                        borderRadius: BorderRadius.circular(5),
                      ),
                      width: 100,
                      height: 100,
                      child: ListView(
                        children: [
                          Text(
                            style: kLabelTextStyle,
                            vesselStatus
                                .where(
                                  (element) => element.berth == marker.label,
                                )
                                .first
                                .vesselName,
                          ),
                          Text(
                            style: kMarkerTextStyle,
                            'load plan ${vesselStatus.where((element) => element.berth == marker.label).first.outboundUnitCount}',
                          ),
                          Text(
                            style: kMarkerTextStyle,
                            'load actual ${vesselStatus.where((element) => element.berth == marker.label).first.outboundLoadCount}',
                          ),
                          Text(
                            style: kMarkerTextStyle,
                            'dischage plan ${vesselStatus.where((element) => element.berth == marker.label).first.inboundUnitCount}',
                          ),
                          Text(
                            style: kMarkerTextStyle,
                            'dischage actual ${vesselStatus.where((element) => element.berth == marker.label).first.inboundDischargeCount}',
                          ),
                        ],
                      ),
                    ),

                  Expanded(
                    child: TappedMarker(
                      markerData: marker,
                      vesselStatus: vesselStatus,
                    ),
                  ),
                ],
              ),
              alignment:
                  selectedFacility == 'TPT - PECT'
                      ? Alignment.bottomCenter
                      : Alignment.topRight,
            ),
          );
        }
      }

      return mapMarkers;
    }
    return mapMarkers;
  }

  String getSelectedLabel(String layoutSource, Marker marker) {
    if (layoutSource == 'province') {
      return marker.point.latitude == -33.004098
          ? 'Port of East London'
          : marker.point.latitude == -33.938843
          ? 'Port Elizabeth'
          : marker.point.latitude == -33.957071
          ? 'Port of Cape Town'
          : 'Port of Durban';
    }
    if (layoutSource == 'port') {
      try {
        return appData.portLayoutsList
            .where(
              (element) =>
                  element.latitude == marker.point.latitude &&
                  element.longitude == marker.point.longitude,
            )
            .first
            .terminal;
      } catch (e) {
        return '';
      }
    }
    if (layoutSource == 'facility') {
      return appData.portLayoutsList
          .where(
            (element) =>
                element.latitude == marker.point.latitude &&
                element.longitude == marker.point.longitude,
          )
          .first
          .terminal;
    }
    return '';
  }

  @override
  Widget build(BuildContext context) {
    if (layoutSource == 'facility') {
      return MarkerLayer(
        markers: generateMarkers(layoutSource, selectedFacility),
      );
    }

    return PopupMarkerLayer(
      options: PopupMarkerLayerOptions(
        popupDisplayOptions: PopupDisplayOptions(
          snap: PopupSnap.markerRight,
          animation: PopupAnimation.fade(),
          builder:
              (BuildContext context, Marker marker) => Padding(
                padding: const EdgeInsets.only(left: 12.0),
                child:
                    getSelectedLabel(layoutSource, marker) == ''
                        ? Container()
                        : layoutSource == 'port'
                        ? Column(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Flexible(
                              fit: FlexFit.loose,
                              child: TextButton(
                                style: TextButton.styleFrom(
                                  backgroundColor: kColorSuccess,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 5,
                                  ),
                                ),

                                child: Text(
                                  getSelectedLabel(layoutSource, marker),
                                  style: kChatTextStyle,
                                ),
                                onPressed: () {
                                  onPressed(
                                    MarkerInputData(
                                      markers: generateMarkers(
                                        layoutSource,
                                        selectedFacility,
                                      ),
                                      label: getSelectedLabel(
                                        layoutSource,
                                        marker,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                            if (getSelectedLabel(layoutSource, marker) ==
                                    'TPT - CTCT' ||
                                getSelectedLabel(layoutSource, marker) ==
                                    'TPT - PECT' ||
                                getSelectedLabel(layoutSource, marker) ==
                                    'TPT - Ngqura')
                              SizedBox(
                                height:
                                    MediaQuery.of(context).size.height * .88,
                                width: MediaQuery.of(context).size.width * .6,
                                child: PdfViewer.asset(
                                  'assets/${getSelectedLabel(layoutSource, marker)}.pdf',
                                  initialPageNumber: 2,
                                ),
                              ),
                          ],
                        )
                        : Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Flexible(
                              fit: FlexFit.loose,
                              child: TextButton(
                                style: TextButton.styleFrom(
                                  backgroundColor: kColorSuccess,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 5,
                                  ),
                                ),

                                child: Text(
                                  getSelectedLabel(layoutSource, marker),
                                  style: kChatTextStyle,
                                ),
                                onPressed: () {
                                  onPressed(
                                    MarkerInputData(
                                      markers: generateMarkers(
                                        layoutSource,
                                        selectedFacility,
                                      ),
                                      label: getSelectedLabel(
                                        layoutSource,
                                        marker,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                            SizedBox(height: 5),
                            if (layoutSource == 'province')
                              Flexible(
                                fit: FlexFit.loose,
                                child: Image.asset(
                                  'assets/${getSelectedLabel(layoutSource, marker)}.jpg',
                                ),
                              ),
                          ],
                        ),
              ),
        ),
        markers: generateMarkers(layoutSource, selectedFacility),
      ),
    );
  }
}
