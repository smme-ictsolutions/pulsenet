import 'package:customer_portal/model/menu.dart';
import 'package:customer_portal/model/mobiapp.dart';
import 'package:customer_portal/model/user.dart';
import 'package:customer_portal/screens/spotlight_queries/berth_sequence.dart';
import 'package:customer_portal/screens/spotlight_queries/complex_queries/complex_query_form.dart';
import 'package:customer_portal/screens/spotlight_queries/notifications.dart';
import 'package:customer_portal/screens/spotlight_queries/stack_occupancy.dart';
import 'package:customer_portal/screens/spotlight_queries/track_trace.dart';
import 'package:customer_portal/screens/spotlight_queries/truck_visits.dart';
import 'package:customer_portal/screens/spotlight_queries/vessel_visits.dart';
import 'package:customer_portal/screens/spotlight_queries/view_slots.dart';
import 'package:customer_portal/screens/spotlight_queries/weather_conditions.dart';
import 'package:customer_portal/screens/vessel_preplan/vessel_preplan.dart';
import 'package:flutter/material.dart';

void showModalScreen(
  BuildContext context,
  MenuList? operation,
  List<ImageData> imageData,
  String notice,
  MobiAppData? mobiAppData,
  UserSubscribeData? subscribeData,
  List<Approvals> pendingApprovals,
  String sector,
  facilityCode,
) {
  showModalBottomSheet<dynamic>(
    constraints: BoxConstraints(
      maxWidth: MediaQuery.of(context).size.width * 0.70,
      minWidth: MediaQuery.of(context).size.width * 0.50,
    ),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.only(
        topRight: Radius.circular(50),
        topLeft: Radius.circular(50),
      ),
    ),
    isScrollControlled: true,
    isDismissible: true,
    useRootNavigator: true,
    context: context,
    builder: (context) {
      return Wrap(
        children: [
          Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child:
                operation!.header == "Vessel Preplan"
                    ? VesselPreplanForm(
                      pendingApprovals: pendingApprovals,
                      mobiAppData: mobiAppData!,
                      subscribeData: subscribeData!,
                      imageData: imageData,
                      sector: sector,
                      title: operation.header!,
                    )
                    : operation.header == "Search"
                    ? TrackTraceForm(
                      title: operation.footer!,
                      mobiAppData: mobiAppData!,
                      sector: sector,
                    )
                    : operation.header == "Vessel"
                    ? VesselVisitsForm(
                      title: operation.footer!,
                      mobiAppData: mobiAppData!,
                      sector: sector,
                    )
                    : operation.header == "Road"
                    ? TruckVisitsForm(
                      title: operation.footer!,
                      mobiAppData: mobiAppData!,
                    )
                    : operation.header == "Weather"
                    ? WeatherForm(
                      imageData: imageData,
                      facilityCode: facilityCode,
                      sector: sector,
                    )
                    : operation.header == "View Available Slots"
                    ? ViewSlotsForm(
                      title: operation.footer!,
                      mobiAppData: mobiAppData!,
                    )
                    : operation.header == "Notifications"
                    ? NotificationsForm(
                      title: operation.footer!,
                      mobiAppData: mobiAppData!,
                    )
                    : operation.header == "Berthing"
                    ? BerthSequenceForm(
                      title: operation.footer!,
                      mobiAppData: mobiAppData!,
                      sector: sector,
                    )
                    : operation.header == "Occupancy"
                    ? StackOccupancyForm(
                      title: operation.footer!,
                      mobiAppData: mobiAppData!,
                      sector: sector,
                    )
                    : operation.header == "Flexible Queries"
                    ? ComplexQueryForm(
                      title: operation.footer!,
                      mobiAppData: mobiAppData!,
                      sector: sector,
                    ) //Container()
                    : operation.header == "OEM Inventory Management"
                    ? ComplexQueryForm(
                      title: operation.footer!,
                      mobiAppData: mobiAppData!,
                      sector: sector,
                      subscribeData: subscribeData,
                    )
                    : Container(),
          ),
        ],
      );
    },
  );
}
