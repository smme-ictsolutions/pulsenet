import 'package:customer_portal/constants/styles.dart';
import 'package:customer_portal/model/mobiapp.dart';
import 'package:customer_portal/model/singletons_data.dart';
import 'package:customer_portal/model/user.dart';
import 'package:customer_portal/shared/dialog.dart';
import 'package:flutter/material.dart';

class TappedMarker extends StatefulWidget {
  final MarkerData markerData;
  final List<VesselStatus> vesselStatus;
  const TappedMarker({
    super.key,
    required this.markerData,
    required this.vesselStatus,
  });

  @override
  State<TappedMarker> createState() => _TappedMarkerState();
}

class _TappedMarkerState extends State<TappedMarker> {
  @override
  Widget build(BuildContext context) {
    return widget.vesselStatus
            .where((element) => element.berth == widget.markerData.label)
            .isNotEmpty
        ? IconButton(
          icon: Icon(Icons.info),
          color: kColorBackground,
          onPressed: () async {
            debugPrint(widget.markerData.label);
            await DialogService(
              button: 'done',
              origin: 'Vessel Status',
            ).showVesselStatusDetail(
              berth: widget.markerData.label,
              context: context,
              vesselStatus: widget.vesselStatus,
              mobiAppData: appData.mobiAppData,
            );
          },
        )
        : Container();
  }
}
