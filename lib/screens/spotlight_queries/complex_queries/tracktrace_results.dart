import 'package:cached_network_image/cached_network_image.dart';
import 'package:customer_portal/constants/styles.dart';
import 'package:customer_portal/model/mobiapp.dart';
import 'package:flutter/material.dart';

class TrackTraceResults extends StatelessWidget {
  final FlexibleTrackandTraceModel trackTraceItems;
  final MobiAppData mobiAppData;
  final List<ImageData> imageData;
  const TrackTraceResults({
    super.key,
    required this.trackTraceItems,
    required this.mobiAppData,
    required this.imageData,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      child: ListView.builder(
        physics: const ScrollPhysics(),
        shrinkWrap: true,
        itemCount:
            trackTraceItems.filter == 'PARM_CTT_UNIT_NBR'
                ? mobiAppData.tracktracefields!.length
                : trackTraceItems.filter == 'PARM_PC_UNIT_NBR'
                ? mobiAppData.preadvicefields!.length
                : mobiAppData.bookreferencefields!.length,
        itemBuilder: (BuildContext context, int index) {
          return ListTile(
            leading: SizedBox(
              height: 50,
              width: 50,
              child: CachedNetworkImage(
                errorWidget: (context, url, error) => const Icon(Icons.error),
                imageUrl:
                    imageData
                        .where((element) => element.title == 'track')
                        .first
                        .url,
                imageBuilder:
                    (context, imageProvider) => Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: imageProvider,
                          fit: BoxFit.contain,
                          alignment: Alignment.topRight,
                        ),
                      ),
                    ),
              ),
            ),
            title: Text(
              trackTraceItems.filter == 'PARM_CTT_UNIT_NBR'
                  ? mobiAppData.tracktracefields![index]
                  : trackTraceItems.filter == 'PARM_PC_UNIT_NBR'
                  ? mobiAppData.preadvicefields![index]
                  : mobiAppData.bookreferencefields![index],
              style: kListTitleTextStyle,
            ),
            subtitle: switch (trackTraceItems.filter) {
              'PARM_CTT_UNIT_NBR' => Text(
                index == 0
                    ? trackTraceItems.unitNumber
                    : index == 1
                    ? trackTraceItems.facility
                    : index == 2
                    ? trackTraceItems.inboundMode
                    : index == 3
                    ? trackTraceItems.outboundMode
                    : index == 4
                    ? trackTraceItems.tState
                    : index == 5
                    ? trackTraceItems.position
                    : index == 6
                    ? trackTraceItems.timeIn
                    : index == 7
                    ? trackTraceItems.timeOut
                    : index == 8
                    ? trackTraceItems.stopRail
                    : index == 9
                    ? trackTraceItems.stopRoad
                    : index == 10
                    ? trackTraceItems.stopVessel
                    : index == 11
                    ? trackTraceItems.holdsPermissions
                    : index == 12
                    ? trackTraceItems.impediments
                    : trackTraceItems.railTrackingPosition,
                style: kTextStyle,
              ),
              'PARM_PC_UNIT_NBR' => Text(
                index == 0
                    ? trackTraceItems.unitNumber
                    : index == 1
                    ? trackTraceItems.category ?? ''
                    : index == 2
                    ? trackTraceItems.vState ?? ''
                    : index == 3
                    ? trackTraceItems.facility
                    : index == 4
                    ? trackTraceItems.tState
                    : index == 5
                    ? trackTraceItems.timeIn
                    : index == 6
                    ? trackTraceItems.timeOut
                    : index == 7
                    ? trackTraceItems.ibActualVisit ?? ''
                    : trackTraceItems.obActualVisit ?? '',
                style: kTextStyle,
              ),
              'PARM_BOOKING_NUMBER' => Text(
                index == 0
                    ? trackTraceItems.unitNumber
                    : index == 1
                    ? trackTraceItems.facility
                    : index == 2
                    ? trackTraceItems.inboundMode
                    : index == 3
                    ? trackTraceItems.outboundMode
                    : index == 4
                    ? trackTraceItems.tState
                    : index == 5
                    ? trackTraceItems.position
                    : index == 6
                    ? trackTraceItems.timeIn
                    : index == 7
                    ? trackTraceItems.timeOut
                    : index == 8
                    ? trackTraceItems.stopRail
                    : index == 9
                    ? trackTraceItems.stopRoad
                    : index == 10
                    ? trackTraceItems.stopVessel
                    : index == 11
                    ? trackTraceItems.holdsPermissions
                    : index == 12
                    ? trackTraceItems.impediments
                    : index == 13
                    ? trackTraceItems.railTrackingPosition
                    : trackTraceItems.railAccountNumber,
                style: kTextStyle,
              ),
              _ => const SizedBox.shrink(),
            },
          );
        },
      ),
    );
  }
}
