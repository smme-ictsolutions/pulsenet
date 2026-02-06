import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:customer_portal/model/mobiapp.dart';
import 'package:customer_portal/model/singletons_data.dart';
import 'package:customer_portal/model/user.dart';
import 'package:customer_portal/screens/spotlight_queries/vessel_status/marker_input.dart';
import 'package:customer_portal/services/mobiapi_service.dart';
import 'package:customer_portal/shared/map_layout.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
import 'package:latlong2/latlong.dart';

class TerminalLayout extends StatefulWidget {
  const TerminalLayout({super.key, required this.title});
  final String title;
  @override
  State<TerminalLayout> createState() => _TerminalLayoutState();
}

class _TerminalLayoutState extends State<TerminalLayout>
    with TickerProviderStateMixin {
  final MapController _mapController = MapController();
  final PopupController _popupController = PopupController();
  static const _startedId = 'AnimatedMapController#MoveStarted';
  static const _inProgressId = 'AnimatedMapController#MoveInProgress';
  static const _finishedId = 'AnimatedMapController#MoveFinished';
  late StreamController<double?> _centerCurrentLocationStreamController;
  late StreamController<void> _turnHeadingUpStreamController;
  LatLng _currentMapPosition = LatLng(-28.48322, 24.676997);
  double _zoom = 6.0;
  List<Polyline<Object>> _polyLines = <Polyline<Object>>[];
  List<RotatedOverlayImage> _imageMarkers = <RotatedOverlayImage>[];
  List<Marker> _markers = <Marker>[];
  String _selectedFacility = '',
      _selectedLayoutSource = 'province',
      _selectedPortLayout = '';
  List<VesselStatus> _vesselStatus = [];
  Future<List<VesselStatus>> _generateVesselStatus(String facilityCode) {
    return MobiApiService().getVesselsStatus(
      appData.mobiAppData,
      facilityCode,
      '',
    );
  }

  void _animatedMapMove(LatLng destLocation, double destZoom) {
    // Create some tweens. These serve to split up the transition from one location to another.
    // In our case, we want to split the transition be<tween> our current map center and the destination.
    final camera = _mapController.camera;
    final latTween = Tween<double>(
      begin: camera.center.latitude,
      end: destLocation.latitude,
    );
    final lngTween = Tween<double>(
      begin: camera.center.longitude,
      end: destLocation.longitude,
    );
    final zoomTween = Tween<double>(begin: camera.zoom, end: destZoom);

    // Create a animation controller that has a duration and a TickerProvider.
    final controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    // The animation determines what path the animation will take. You can try different Curves values, although I found
    // fastOutSlowIn to be my favorite.
    final Animation<double> animation = CurvedAnimation(
      parent: controller,
      curve: Curves.fastOutSlowIn,
    );

    // Note this method of encoding the target destination is a workaround.
    // When proper animated movement is supported (see #1263) we should be able
    // to detect an appropriate animated movement event which contains the
    // target zoom/center.
    final startIdWithTarget =
        '$_startedId#${destLocation.latitude},${destLocation.longitude},$destZoom';
    bool hasTriggeredMove = false;

    controller.addListener(() {
      final String id;
      if (animation.value == 1.0) {
        id = _finishedId;
      } else if (!hasTriggeredMove) {
        id = startIdWithTarget;
      } else {
        id = _inProgressId;
      }

      hasTriggeredMove |= _mapController.move(
        LatLng(latTween.evaluate(animation), lngTween.evaluate(animation)),
        zoomTween.evaluate(animation),
        id: id,
      );
    });

    animation.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        controller.dispose();
      } else if (status == AnimationStatus.dismissed) {
        controller.dispose();
      }
    });

    controller.forward();
  }

  @override
  void setState(fn) {
    super.setState(fn);
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _mapController.dispose();
    _popupController.dispose();
    _centerCurrentLocationStreamController.close();
    _turnHeadingUpStreamController.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    List<ImageData> imageData = appData.imageData;
    return Scaffold(
      body: SafeArea(
        child: SizedBox(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          child: Stack(
            alignment: Alignment.topRight,
            children: [
              FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  minZoom: 6.0,
                  maxZoom: 18.0,
                  initialCenter: _currentMapPosition,
                  initialZoom: _zoom,
                  interactionOptions: InteractionOptions(
                    flags: InteractiveFlag.all,
                  ),

                  onPositionChanged: (MapCamera position, bool hasGesture) {
                    _currentMapPosition = position.center;
                    debugPrint(
                      'Map position changed: $_currentMapPosition, zoom: ${position.zoom}',
                    );
                  },
                  onTap:
                      (tapPosition, point) =>
                          debugPrint('Map tapped at $point'),
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                    tileUpdateTransformer: _animatedMoveTileUpdateTransformer,
                  ),
                  PolylineLayer(polylines: _polyLines),
                  OverlayImageLayer(overlayImages: _imageMarkers),
                  MarkerInput(
                    onPressed: (MarkerInputData value) async {
                      if (_selectedLayoutSource == 'province') {
                        //user selected a province, show port layout
                        _selectedPortLayout = value.label;
                        _selectedLayoutSource = 'port';
                        _markers = value.markers;
                        _selectedPortLayout == 'Port of Durban'
                            ? _zoom = 15.0
                            : _selectedPortLayout == 'Port of East London'
                            ? _zoom = 15.0
                            : _selectedPortLayout == 'Port Elizabeth'
                            ? _zoom = 10
                            : _zoom = 15;
                        _selectedPortLayout == 'Port of Durban'
                            ? _currentMapPosition = LatLng(
                              -29.8831775,
                              31.04374847,
                            )
                            : _selectedPortLayout == 'Port of East London'
                            ? _currentMapPosition = LatLng(-33.0239, 27.9027)
                            : _selectedPortLayout == 'Port Elizabeth'
                            ? _currentMapPosition = LatLng(
                              -33.870191,
                              25.644343,
                            )
                            : _selectedPortLayout == 'Port of Cape Town'
                            ? _currentMapPosition = LatLng(-33.9061, 18.4411)
                            : null;
                        _popupController.showPopupsAlsoFor(_markers);
                        _animatedMapMove(_currentMapPosition, _zoom);
                        setState(() {});
                      } else if (_selectedLayoutSource == 'port') {
                        //user selected a facility, show facility layout
                        _selectedFacility = value.label;
                        //get vessel status
                        await _generateVesselStatus(
                          appData.portLayoutsList
                              .where(
                                (element) =>
                                    element.terminal == _selectedFacility,
                              )
                              .first
                              .navisCode,
                        ).then((vesselstatus) {
                          _selectedFacility == 'TPT - Ngqura' ||
                                  _selectedFacility == 'TPT - CTCT'
                              ? _zoom = 16
                              : _zoom = 17.0;
                          _polyLines = generatePolylines(_selectedFacility);
                          _imageMarkers = generateImageMarkers(
                            _selectedFacility,
                            vesselstatus,
                          );
                          _selectedLayoutSource = 'facility';
                          TerminalLayoutData selectedLayout =
                              appData.portLayoutsList
                                  .where(
                                    (element) =>
                                        element.terminal == _selectedFacility,
                                  )
                                  .first;
                          _currentMapPosition = LatLng(
                            selectedLayout.latitude,
                            selectedLayout.longitude,
                          );
                          _animatedMapMove(_currentMapPosition, _zoom);

                          setState(() {
                            _vesselStatus = vesselstatus;
                          });
                        });
                      }
                    },
                    layoutSource: _selectedLayoutSource,
                    selectedFacility:
                        _selectedFacility == ''
                            ? _selectedPortLayout
                            : _selectedFacility,
                    vesselStatus: _vesselStatus,
                  ),
                ],
              ),
              CachedNetworkImage(
                errorWidget: (context, url, error) => const Icon(Icons.error),
                imageUrl:
                    imageData
                        .where((element) => element.title == 'TPTLogo')
                        .first
                        .url,
                imageBuilder:
                    (context, imageProvider) => Container(
                      width: 100,
                      height: 100,
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
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Align(
        alignment: Alignment.bottomCenter,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              icon: const Icon(Icons.home, size: 50),
              onPressed: () async {
                Navigator.pop(context);
              },
            ),
            IconButton(
              icon: const Icon(Icons.restore, size: 50),
              onPressed: () {
                _currentMapPosition = LatLng(-28.48322, 24.676997);
                _zoom = 6.0;
                _selectedLayoutSource = 'province';
                _selectedFacility = '';
                _polyLines.clear();
                _imageMarkers.clear();
                _markers.clear();
                _animatedMapMove(_currentMapPosition, _zoom);
                setState(() {});
              },
            ),
          ],
        ),
      ),
    );
  }
}

/// Causes tiles to be prefetched at the target location and disables pruning
/// whilst animating movement. When proper animated movement is added (see
/// #1263) we should just detect the appropriate AnimatedMove events and
/// use their target zoom/center.
final _animatedMoveTileUpdateTransformer = TileUpdateTransformer.fromHandlers(
  handleData: (updateEvent, sink) {
    final mapEvent = updateEvent.mapEvent;

    final id = mapEvent is MapEventMove ? mapEvent.id : null;
    if (id?.startsWith(_TerminalLayoutState._startedId) ?? false) {
      final parts = id!.split('#')[2].split(',');
      final lat = double.parse(parts[0]);
      final lon = double.parse(parts[1]);
      final zoom = double.parse(parts[2]);

      // When animated movement starts load tiles at the target location and do
      // not prune. Disabling pruning means existing tiles will remain visible
      // whilst animating.
      sink.add(
        updateEvent.loadOnly(
          loadCenterOverride: LatLng(lat, lon),
          loadZoomOverride: zoom,
        ),
      );
    } else if (id == _TerminalLayoutState._inProgressId) {
      // Do not prune or load whilst animating so that any existing tiles remain
      // visible. A smarter implementation may start pruning once we are close to
      // the target zoom/location.
    } else if (id == _TerminalLayoutState._finishedId) {
      // We already prefetched the tiles when animation started so just prune.
      sink.add(updateEvent.pruneOnly());
    } else {
      sink.add(updateEvent);
    }
  },
);
