class NavisFacilities {
  String? port, filter, code;

  NavisFacilities(
      {required this.port, required this.filter, required this.code});
}

class MakeTruckAppointment {
  String? facility,
      yard,
      appointmentDate,
      appointmentTime,
      gateID,
      truckingCompanyID,
      transactionType,
      container;

  MakeTruckAppointment(
      {required this.facility,
      required this.yard,
      required this.appointmentDate,
      required this.appointmentTime,
      required this.gateID,
      required this.container,
      required this.transactionType,
      required this.truckingCompanyID});
}

class TruckAppointmentResult {
  String? errorCode, errorDescription, appointmentNumber;
  TruckAppointmentResult(
      {this.errorCode, this.errorDescription, this.appointmentNumber});

  static TruckAppointmentResult fromMap(
      Map<String, dynamic> map, String operation) {
    if (map.containsValue('Successful')) {
      return TruckAppointmentResult(
        errorCode: map['ns1:Status'] ?? '0',
        errorDescription: map['ns1:StatusDescription'] ?? 'Successful',
      );
    } else {
      if (operation == "Cancel") {
        return TruckAppointmentResult(
          errorCode: map['ns1:MessageCollector']['ns1:Messages']
                  ['ns1:SeverityLevel'] ??
              '0',
          errorDescription: map['ns1:MessageCollector']['ns1:Messages']
                  ['ns1:Message'] ??
              'Successful',
        );
      } else if (operation == "CREATE") {
        try {
          return TruckAppointmentResult(
            errorCode: map['ns1:MessageCollector']['ns1:Messages']
                ['ns1:SeverityLevel'],
            errorDescription: map['ns1:MessageCollector']['ns1:Messages']
                ['ns1:Message'],
          );
        } catch (e) {
          //build error list
          var errorList =
              "${map['ns1:MessageCollector']['ns1:Messages'][0]['ns1:SeverityLevel']} - Possible reasons: \n";
          errorList = errorList +
              [
                for (var data in map['ns1:MessageCollector']['ns1:Messages'])
                  data['ns1:Message']
              ].join("\n");

          return TruckAppointmentResult(
            errorCode: map['ns1:MessageCollector']['ns1:Messages'][0]
                ['ns1:SeverityLevel'],
            errorDescription: errorList,
          );
        }
      }
      return TruckAppointmentResult();
    }
  }
}

class TruckingCompany {
  String? uid, first, last, scope, creator, company;

  TruckingCompany(
      {required this.uid,
      required this.first,
      required this.last,
      required this.company,
      required this.creator,
      required this.scope});

  static TruckingCompany fromMap(Map<String, dynamic> map) {
    return TruckingCompany(
      uid: map['row']['field'][0] ?? '',
      first: map['row']['field'][1] ?? '',
      last: map['row']['field'][2] ?? '',
      scope: map['row']['field'][3] ?? '',
      creator: map['row']['field'][4] ?? '',
      company: map['row']['field'][5] ?? '',
    );
  }
}

class ZoneRuleSets {
  String? gateID;
  List<String>? zoneRules;
  ZoneRuleSets({required this.gateID, required this.zoneRules});
}

class ViewAppointments {
  String? appointmentState,
      appointmentNumber,
      appointmentDate,
      startTime,
      endTime,
      startTolerance,
      endTolerance,
      startRuleTolerance,
      endRuleTolerance,
      gateID,
      transactionType,
      truckLicense,
      truckingCompanyID,
      orderNumber,
      containerID,
      referenceNumber,
      destination;

  ViewAppointments(
      {required this.appointmentState,
      required this.appointmentNumber,
      required this.appointmentDate,
      required this.startTime,
      required this.endTime,
      this.startTolerance,
      this.endTolerance,
      required this.startRuleTolerance,
      required this.endRuleTolerance,
      required this.gateID,
      required this.transactionType,
      required this.truckLicense,
      required this.truckingCompanyID,
      this.orderNumber,
      required this.containerID,
      this.referenceNumber,
      this.destination});

  static List<ViewAppointments> fromMap(
      Map<String, dynamic> map, String rowCount) {
    List<ViewAppointments> items = [];
    if (rowCount == "1") {
      items.add(ViewAppointments(
          appointmentState: map['row']['field'][0] ?? '',
          appointmentNumber: map['row']['field'][1] ?? '',
          appointmentDate: map['row']['field'][2]
              .toString()
              .substring(0, map['row']['field'][2].toString().indexOf(" ")),
          startTime: map['row']['field'][3] ?? '',
          endTime: map['row']['field'][4] ?? '',
          startTolerance: map['row']['field'][5] ?? '',
          endTolerance: map['row']['field'][6] ?? '',
          startRuleTolerance: map['row']['field'][7] ?? '',
          endRuleTolerance: map['row']['field'][8] ?? '',
          gateID: map['row']['field'][9] ?? '',
          transactionType: map['row']['field'][10] ?? '',
          truckLicense: map['row']['field'][11] ?? '',
          truckingCompanyID: map['row']['field'][12] ?? '',
          orderNumber: map['row']['field'][13] ?? '',
          containerID: map['row']['field'][14] ?? '',
          referenceNumber: map['row']['field'][15] ?? '',
          destination: map['row']['field'][16] ?? ''));
    } else {
      for (int index = 0; index < map['row'].length; index++) {
        items.add(ViewAppointments(
            appointmentState: map['row'][index]['field'][0] ?? '',
            appointmentNumber: map['row'][index]['field'][1] ?? '',
            appointmentDate: map['row'][index]['field'][2].toString().substring(
                0, map['row'][index]['field'][2].toString().indexOf(" ")),
            startTime: map['row'][index]['field'][3] ?? '',
            endTime: map['row'][index]['field'][4] ?? '',
            startTolerance: map['row'][index]['field'][5] ?? '',
            endTolerance: map['row'][index]['field'][6] ?? '',
            startRuleTolerance: map['row'][index]['field'][7] ?? '',
            endRuleTolerance: map['row'][index]['field'][8] ?? '',
            gateID: map['row'][index]['field'][9] ?? '',
            transactionType: map['row'][index]['field'][10] ?? '',
            truckLicense: map['row'][index]['field'][11] ?? '',
            truckingCompanyID: map['row'][index]['field'][12] ?? '',
            orderNumber: map['row'][index]['field'][13] ?? '',
            containerID: map['row'][index]['field'][14] ?? '',
            referenceNumber: map['row'][index]['field'][15] ?? '',
            destination: map['row'][index]['field'][16] ?? ''));
      }
    }

    return items;
  }
}
