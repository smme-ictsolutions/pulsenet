import 'dart:async';
import 'dart:convert';
import 'package:customer_portal/model/mobiapp.dart';
import 'package:flutter/material.dart';
import "package:http/http.dart" as http;

class MobiApiService {
  MobiApiService();

  Future<String> fetchHTTPResponse(
    String inRequestName,
    MobiAppData mobiAppData,
    String messageType,
    Map<String, String> queryParameters,
  ) async {
    final uri = Uri(
      scheme: 'https',
      host: mobiAppData.productionServer,
      port: mobiAppData.productionPort,
      path: 'invoke/TPT_MobileApps.services/QRequest',
      queryParameters: {
        'inSenderId': mobiAppData.andsenderid,
        'inReceiverId': mobiAppData.inReceiverId,
        'inMessageType': messageType,
        'inRequestName': inRequestName,
        'inParamName1': queryParameters['inParamName1'],
        'inParamValue1': queryParameters['inParamValue1'],
        'inParamName2': queryParameters['inParamName2'],
        'inParamValue2': queryParameters['inParamValue2'],
        'inParamName3': queryParameters['inParamName3'],
        'inParamValue3': queryParameters['inParamValue3'],
        'inParamName4': queryParameters['inParamName4'],
        'inParamValue4': queryParameters['inParamValue4'],
        'inParamName5': queryParameters['inParamName5'],
        'inParamValue5': queryParameters['inParamValue5'],
      },
    );
    String username = mobiAppData.productionUser!;
    String password = mobiAppData.productionPassword!;
    try {
      String result = '';
      debugPrint('URL: $uri');
      debugPrint(base64.encode(utf8.encode('kesie38@gmail.com:Pr_123456')));
      final response = await http.get(
        Uri.parse(
          'https://worker.smmeictsolutions.co.za/?credentials=${base64.encode(utf8.encode('$username:$password'))}&url=${Uri.encodeComponent(uri.toString())}',
        ),
      );

      switch (response.statusCode) {
        case 200:
          result = convertInputStreamToString(response.body, inRequestName);
          return result;
        case 401:
          debugPrint("400 - Invalid credentials or query");
        case 404:
          debugPrint("500 - Error fetching the target URL");
        default:
          debugPrint("Unknown error");
      }
    } catch (e) {
      debugPrint(e.toString());
    }
    return "";
  }

  Future<String> fetchQAHTTPResponse(
    String inRequestName,
    //MobiAppData mobiAppData,
    String messageType,
    Map<String, String> queryParameters,
  ) async {
    final uri = Uri(
      scheme: 'http',
      host: '10.10.41.64', //mobiAppData.testServer,
      port: 5555, //mobiAppData.testPort,
      path: 'invoke/TPT_MobileApps.services/QRequest',
      queryParameters: {
        'inSenderId': 'SPOTLIGHT_AND', // mobiAppData.andsenderid,
        'inReceiverId': 'TPT', //mobiAppData.inReceiverId,
        'inMessageType': messageType,
        'inRequestName': inRequestName,
        'inParamName1': queryParameters['inParamName1'],
        'inParamValue1': queryParameters['inParamValue1'],
        'inParamName2': queryParameters['inParamName2'],
        'inParamValue2': queryParameters['inParamValue2'],
        'inParamName3': queryParameters['inParamName3'],
        'inParamValue3': queryParameters['inParamValue3'],
        'inParamName4': queryParameters['inParamName4'],
        'inParamValue4': queryParameters['inParamValue4'],
        'inParamName5': queryParameters['inParamName5'],
        'inParamValue5': queryParameters['inParamValue5'],
      },
    );
    String username = 'Administrator'; //mobiAppData.testUser!;
    String password = 'manage'; //mobiAppData.testPassword!;
    try {
      String response = '';

      var headers = {
        'Authorization':
            'Basic ${base64.encode(utf8.encode('$username:$password'))}',
      };

      var request = http.Request('GET', uri);
      request.headers.addAll(headers);
      var streamedResponse = await request.send().timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          // Return an empty StreamedResponse with status code 408
          return http.StreamedResponse(
            const Stream<List<int>>.empty(),
            408,
            reasonPhrase: 'Request Timeout',
          );
        },
      );
      if (streamedResponse.statusCode == 200) {
        await http.Response.fromStream(streamedResponse).then((value) {
          response = convertInputStreamToString(value.body, inRequestName);
        });
        return response;
      } else {
        debugPrint(streamedResponse.reasonPhrase);
      }
    } catch (e) {
      debugPrint(e.toString());
    }
    return "";
  }

  Future<String> postHTTPRequest(
    String inRequestName,
    MobiAppData mobiAppData,
    String messageType,
    Map<String, String> queryParameters,
    String jsonData,
  ) async {
    final uri = Uri(
      scheme: 'http',
      host: '10.10.41.64',
      port: 5555,
      path:
          'restv2/TPT_MobileApps.TPT_MobileApps.MobileApps_Customer_Portal:Customer_Portal_API/getContainers/',
      queryParameters: {
        'inSenderId': mobiAppData.andsenderid,
        'inReceiverId': mobiAppData.inReceiverId,
        'inMessageType': messageType,
        'inRequestName': inRequestName,
        'inParamName1': queryParameters['inParamName1'],
        'inParamValue1': queryParameters['inParamValue1'],
        'inParamName2': queryParameters['inParamName2'],
        'inParamValue2': queryParameters['inParamValue2'],
        'inParamName3': queryParameters['inParamName3'],
        'inParamValue3': queryParameters['inParamValue3'],
        'inParamName4': queryParameters['inParamName4'],
        'inParamValue4': queryParameters['inParamValue4'],
      },
    );
    String username = 'Administrator';
    String password = 'manage';
    final request = http.StreamedRequest('POST', uri);
    request.headers['Content-Type'] = 'application/json';
    request.headers['Authorization'] =
        'Basic ${base64.encode(utf8.encode('$username:$password'))}';
    request.sink.add(utf8.encode(jsonData));
    request.sink.close();
    final http.StreamedResponse response = await request.send();

    switch (response.statusCode) {
      case 200:
        //listen to the response stream
        response.stream.listen(
          (chunk) {
            debugPrint('Received chunk: $chunk');
            String encodedData = utf8.decode(chunk);
            encodedData = encodedData.replaceAll('''{"bytes":''', '');
            encodedData = encodedData.replaceAll('"}', '');
            encodedData = encodedData.replaceAll('"', '');
            //Decode bytes to a string
            //Uint8List decodedBytes = base64.decode(encodedData);
            //If the original data was text, you can convert the bytes to a String using UTF-8 decoding
            //String decodedText = utf8.decode(decodedBytes);

            debugPrint(json.decode(encodedData));
            //debugPrint('Decoded: $decodedText');
            /*result = convertInputStreamToString(
                utf8.decode(chunk),
                inRequestName,
              );*/
          },
          onDone: () {
            debugPrint('Stream finished');
          },
          onError: (error) {
            debugPrint('Error: $error');
          },
          cancelOnError: false,
        );
      case 401:
        debugPrint("400 - Invalid credentials or query");
      case 404:
        debugPrint("404 - Error fetching the target URL from client");
      default:
        debugPrint("Unknown error");
    }

    return "";
  }

  Stream<List<FlexibleTrackandTraceModel>> getFlexibleTrackandTrace(
    MobiAppData mobiAppData,
    List<FlexibleQueryData> vnlValidUnitIds,
    String facilityId,
  ) async* {
    List<FlexibleTrackandTraceModel> results = [];

    for (var i = 0; i < vnlValidUnitIds.length; i++) {
      switch (vnlValidUnitIds[i].filter) {
        case 'PARM_CTT_UNIT_NBR':
          final trackTraceResult = await getTrackTrace(
            mobiAppData,
            vnlValidUnitIds[i].unitIds,
            facilityId,
            true,
            vnlValidUnitIds[i].filter,
          );
          if (trackTraceResult.isNotEmpty) {
            results.add(
              FlexibleTrackandTraceModel(
                filter: vnlValidUnitIds[i].filter,
                unitNumber: trackTraceResult[0].unitNumber,
                facility: trackTraceResult[0].facility,
                inboundMode: trackTraceResult[0].inboundMode,
                outboundMode: trackTraceResult[0].outboundMode,
                tState: trackTraceResult[0].tState,
                position: trackTraceResult[0].position,
                timeIn: trackTraceResult[0].timeIn,
                timeOut: trackTraceResult[0].timeOut,
                stopRail: trackTraceResult[0].stopRail,
                stopRoad: trackTraceResult[0].stopRoad,
                stopVessel: trackTraceResult[0].stopVessel,
                holdsPermissions: trackTraceResult[0].holdsPermissions,
                impediments: trackTraceResult[0].impediments,
                railTrackingPosition: trackTraceResult[0].railTrackingPosition,
                railAccountNumber: '',
              ),
            );
          } else {
            results.add(
              FlexibleTrackandTraceModel(
                filter: vnlValidUnitIds[i].filter,
                unitNumber: vnlValidUnitIds[i].unitIds,
                facility: facilityId,
                inboundMode: '',
                outboundMode: '',
                tState: 'No data found',
                position: '',
                timeIn: '',
                timeOut: '',
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
        case 'PARM_PC_UNIT_NBR':
          final preAdviceResult = await getPreAdvice(
            mobiAppData,
            vnlValidUnitIds[i].unitIds,
            facilityId,
            true,
            vnlValidUnitIds[i].filter,
          );
          if (preAdviceResult.isNotEmpty) {
            results.add(
              FlexibleTrackandTraceModel(
                filter: vnlValidUnitIds[i].filter,
                unitNumber: preAdviceResult[0].unitNumber,
                facility: preAdviceResult[0].facility,
                category: preAdviceResult[0].category,
                vState: preAdviceResult[0].vState,
                tState: preAdviceResult[0].tState,
                timeIn: preAdviceResult[0].timeIn,
                timeOut: preAdviceResult[0].timeOut,
                ibActualVisit: preAdviceResult[0].ibActualVisit,
                obActualVisit: preAdviceResult[0].obActualVisit,
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
          } else {
            results.add(
              FlexibleTrackandTraceModel(
                filter: vnlValidUnitIds[i].filter,
                unitNumber: vnlValidUnitIds[i].unitIds,
                facility: facilityId,
                category: '',
                vState: '',
                tState: 'No data found',
                timeIn: '',
                timeOut: '',
                ibActualVisit: '',
                obActualVisit: '',
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
        case 'PARM_BOOKING_NUMBER':
          final bookingResult = await getBookingReference(
            mobiAppData,
            vnlValidUnitIds[i].unitIds,
            "",
            false,
            vnlValidUnitIds[i].filter,
          );
          if (bookingResult.isNotEmpty) {
            results.add(
              FlexibleTrackandTraceModel(
                filter: vnlValidUnitIds[i].filter,
                unitNumber: bookingResult[0].unitNumber,
                facility: bookingResult[0].facility,
                inboundMode: bookingResult[0].inboundMode,
                outboundMode: bookingResult[0].outboundMode,
                tState: bookingResult[0].tState,
                position: bookingResult[0].position,
                timeIn: bookingResult[0].timeIn,
                timeOut: bookingResult[0].timeOut,
                stopRail: bookingResult[0].stopRail,
                stopRoad: bookingResult[0].stopRoad,
                stopVessel: bookingResult[0].stopVessel,
                holdsPermissions: bookingResult[0].holdsPermissions,
                impediments: bookingResult[0].impediments,
                railTrackingPosition: bookingResult[0].railTrackingPosition,
                railAccountNumber: bookingResult[0].railAccountNumber,
              ),
            );
          } else {
            results.add(
              FlexibleTrackandTraceModel(
                filter: vnlValidUnitIds[i].filter,
                unitNumber: vnlValidUnitIds[i].unitIds,
                facility: facilityId,
                category: '',
                vState: '',
                tState: 'No data found',
                timeIn: '',
                timeOut: '',
                ibActualVisit: '',
                obActualVisit: '',
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
      }
      yield results;
      await Future.delayed(const Duration(seconds: 5));
    }
  }

  Future<List<BerthItems>> getBerths(
    MobiAppData mobiAppData,
    String facilityID,
  ) async {
    List<BerthItems> result = [];
    Map<String, String> queryParameters = {
      'inParamName1': 'FACILITY_ID',
      'inParamValue1': facilityID,
      'inParamName2': 'ACTIVE',
      'inParamValue2': 'Y',
      'inParamName3': '',
      'inParamValue3': '',
      'inParamName4': '',
      'inParamValue4': '',
      'inParamName5': '--',
      'inParamValue5': '--',
    };

    try {
      await fetchHTTPResponse(
        'BERTHS',
        mobiAppData,
        'MOBI_WM_QUERY_GCOS',
        queryParameters,
      ).then(
        (value) => {
          result = BerthModel.fromMap(json.decode(value), 'getBerths').items,
        },
      );
    } catch (e) {
      debugPrint(e.toString());
    }
    return result;
  }

  Future<List<BerthingSequenceModel>> getBerthingSequence(
    MobiAppData mobiAppData,
    String vnlFacility,
    berthCode,
  ) async {
    List<BerthingSequenceModel> result = [];

    Map<String, String> queryParameters = {
      'inParamName1': 'FACILITY_ID',
      'inParamValue1': vnlFacility,
      'inParamName2': 'BERTH_CODE',
      'inParamValue2': berthCode,
      'inParamName3': '--',
      'inParamValue3': '--',
      'inParamName4': '--',
      'inParamValue4': '--',
      'inParamName5': '--',
      'inParamValue5': '--',
    };
    try {
      await fetchHTTPResponse(
        'BERTHINGSEQUENCE',
        mobiAppData,
        'MOBI_WM_QUERY_GCOS',
        queryParameters,
      ).then(
        (value) => {result = BerthingSequenceModel.fromMap(json.decode(value))},
      );
    } catch (e) {
      debugPrint(e.toString());
    }

    return result;
  }

  Stream<List<FacilityItems>> streamGcosFacilitiesList(
    MobiAppData mobiAppData,
    String sector,
  ) async* {
    for (int i = 0; i < 3; i++) {
      yield await getFacilities(mobiAppData, sector);
    }
    await Future.delayed(const Duration(seconds: 1));
  }

  Future<List<FacilityItems>> getFacilities(
    MobiAppData mobiAppData,
    String sector,
  ) async {
    List<FacilityItems> result = [];

    Map<String, String> queryParameters = {
      'inParamName1': sector == 'container' ? 'ACTIVE' : '',
      'inParamValue1': sector == 'container' ? 'Y' : '',
      'inParamName2': '',
      'inParamValue2': '',
      'inParamName3': '',
      'inParamValue3': '',
      'inParamName4': '',
      'inParamValue4': '',
      'inParamName5': '--',
      'inParamValue5': '--',
    };

    try {
      await fetchHTTPResponse(
        sector == 'container' ? 'GET_FACILITIES' : 'FACILITIES',
        mobiAppData,
        sector == 'container' ? 'MOBI_WM_QUERY' : 'MOBI_WM_QUERY_GCOS',
        queryParameters,
      ).then(
        (value) => {
          if (sector == 'container')
            {
              result =
                  FacilityModel.fromMap(
                    json.decode(
                      value,
                    )['outResponseDoc']['outResponseDocList']['query-response']['data-table']['rows'],
                    json.decode(
                      value,
                    )['outResponseDoc']['outResponseDocList']['query-response']['data-table']['filter'],
                    'row',
                  ).items,
            }
          else if (sector == 'automotive' ||
              sector == 'breakbulk' ||
              sector == 'agriculture')
            {
              result =
                  FacilityModel.fromMap(
                    json.decode(value),
                    '',
                    'C_CURSOR',
                  ).items.where((element) => element.sector == sector).toList(),
            },
        },
      );
    } catch (e) {
      debugPrint(e.toString());
      return [];
    }

    return result;
  }

  Stream<List<QueryOptionsModel>> streamQueryOptions(
    MobiAppData mobiAppData,
  ) async* {
    for (int i = 0; i < 3; i++) {
      yield await getQueryOptions(mobiAppData);
    }
    await Future.delayed(const Duration(seconds: 1));
  }

  Future<List<QueryOptionsModel>> getQueryOptions(
    MobiAppData mobiAppData,
  ) async {
    List<QueryOptionsModel> result = [];
    Map<String, String> queryParameters = {
      'inParamName1': '',
      'inParamValue1': '',
      'inParamName2': '',
      'inParamValue2': '',
      'inParamName3': '',
      'inParamValue3': '',
      'inParamName4': '',
      'inParamValue4': '',
      'inParamName5': '--',
      'inParamValue5': '--',
    };

    try {
      await fetchHTTPResponse(
        'GET_TNT_QUERYOPTIONS',
        mobiAppData,
        'MOBI_WM_QUERY',
        queryParameters,
      ).then(
        (value) => {
          result = QueryOptionsModel.fromMap(
            json.decode(
              value,
            )['outResponseDoc']['outResponseDocList']['query-response']['data-table']['rows'],
          ),
        },
      );
    } catch (e) {
      debugPrint(e.toString());
    }
    return result;
  }

  Future<List<TrackTraceModel>> getTrackTrace(
    MobiAppData mobiAppData,
    String vnlUnitId,
    String facilityId,
    bool isFacilityQuery,
    String queryType,
  ) async {
    List<TrackTraceModel> result = [];

    Map<String, String> queryParameters = {
      'inParamName1': 'operatorId',
      'inParamValue1': mobiAppData.organisation!,
      'inParamName2': 'complexId',
      'inParamValue2': mobiAppData.complex!,
      'inParamName3': 'facilityId',
      'inParamValue3': '--',
      'inParamName4': isFacilityQuery ? 'PARM_CTT_FACILITYID' : queryType,
      'inParamValue4': isFacilityQuery ? facilityId : vnlUnitId,
      'inParamName5': isFacilityQuery ? queryType : '--',
      'inParamValue5': isFacilityQuery ? vnlUnitId : '--',
    };
    try {
      await fetchHTTPResponse(
        isFacilityQuery ? 'CONT_TRACK_TRACE_FCL' : 'CONT_TRACK_TRACE',
        mobiAppData,
        'MOBI_NAVIS_QAPI',
        queryParameters,
      ).then(
        (value) => {
          debugPrint(value),
          if (json.decode(
                value,
              )['outResponseDoc']['outResponseDocList']['query-response']['data-table']['rows'] ==
              "")
            {
              result = [
                TrackTraceModel(
                  unitNumber: vnlUnitId,
                  facility: facilityId,
                  inboundMode: "",
                  outboundMode: "",
                  tState: "Unit not found or error occurred in fetching.",
                  position: "",
                  timeIn: "",
                  timeOut: "",
                  stopRail: "",
                  stopRoad: "",
                  stopVessel: "",
                  holdsPermissions: "",
                  impediments: "",
                  railTrackingPosition: "",
                ),
              ],
            }
          else
            {
              result = TrackTraceModel.fromMap(
                json.decode(
                  value,
                )['outResponseDoc']['outResponseDocList']['query-response']['data-table']['rows'],
              ),
            },
        },
      );
    } catch (e) {
      debugPrint(e.toString());
    }
    return result;
  }

  Future<List<TrackTraceModel>> postTrackTrace(
    MobiAppData mobiAppData,
    String facilityId,
    String queryType,
    String xmlData,
  ) async {
    List<TrackTraceModel> result = [];

    Map<String, String> queryParameters = {
      'inParamName1': 'operatorId',
      'inParamValue1': mobiAppData.organisation!,
      'inParamName2': 'complexId',
      'inParamValue2': mobiAppData.complex!,
      'inParamName3': 'facilityId',
      'inParamValue3': '--',
      'inParamName4': 'PARM_CTT_FACILITYID',
      'inParamValue4': facilityId,
      'inParamName5': queryType,
      'inParamValue5': xmlData,
    };
    try {
      await postHTTPRequest(
        'CONT_TRACK_TRACE_FCL',
        mobiAppData,
        'MOBI_NAVIS_QAPI',
        queryParameters,
        xmlData,
      ).then(
        (value) => {
          debugPrint(value),
          result = TrackTraceModel.fromMap(
            json.decode(
              value,
            )['outResponseDoc']['outResponseDocList']['query-response']['data-table']['rows'],
          ),
        },
      );
    } catch (e) {
      debugPrint(e.toString());
    }
    return result;
  }

  Future<List<PreAdviceModel>> getPreAdvice(
    MobiAppData mobiAppData,
    String vnlUnitId,
    String facilityId,
    bool isFacilityQuery,
    String queryType,
  ) async {
    List<PreAdviceModel> result = [];

    Map<String, String> queryParameters = {
      'inParamName1': 'operatorId',
      'inParamValue1': mobiAppData.organisation!,
      'inParamName2': 'complexId',
      'inParamValue2': mobiAppData.complex!,
      'inParamName3': 'facilityId',
      'inParamValue3': '--',
      'inParamName4': isFacilityQuery ? 'PARM_CTT_FACILITYID' : queryType,
      'inParamValue4': isFacilityQuery ? facilityId : vnlUnitId,
      'inParamName5': isFacilityQuery ? queryType : '--',
      'inParamValue5': isFacilityQuery ? vnlUnitId : '--',
    };
    try {
      await fetchHTTPResponse(
        isFacilityQuery ? 'CONT_TRACK_TRACE_FCL' : 'CONT_TRACK_TRACE',
        mobiAppData,
        'MOBI_NAVIS_QAPI',
        queryParameters,
      ).then(
        (value) => {
          debugPrint(value),
          result = PreAdviceModel.fromMap(
            json.decode(
              value,
            )['outResponseDoc']['outResponseDocList']['query-response']['data-table']['rows'],
          ),
        },
      );
    } catch (e) {
      debugPrint(e.toString());
    }
    return result;
  }

  Future<List<BookingReferenceModel>> getBookingReference(
    MobiAppData mobiAppData,
    String vnlUnitId,
    String facilityId,
    bool isFacilityQuery,
    String queryType,
  ) async {
    List<BookingReferenceModel> result = [];

    Map<String, String> queryParameters = {
      'inParamName1': 'operatorId',
      'inParamValue1': mobiAppData.organisation!,
      'inParamName2': 'complexId',
      'inParamValue2': mobiAppData.complex!,
      'inParamName3': 'facilityId',
      'inParamValue3': '--',
      'inParamName4': isFacilityQuery ? 'PARM_CTT_FACILITYID' : queryType,
      'inParamValue4': isFacilityQuery ? facilityId : vnlUnitId,
      'inParamName5': isFacilityQuery ? queryType : '--',
      'inParamValue5': isFacilityQuery ? vnlUnitId : '--',
    };
    try {
      await fetchHTTPResponse(
        isFacilityQuery ? 'CONT_TRACK_TRACE_FCL' : 'CONT_TRACK_TRACE',
        mobiAppData,
        'MOBI_NAVIS_QAPI',
        queryParameters,
      ).then(
        (value) => {
          debugPrint(value),
          result = BookingReferenceModel.fromMap(
            json.decode(
              value,
            )['outResponseDoc']['outResponseDocList']['query-response']['data-table']['rows'],
          ),
        },
      );
    } catch (e) {
      debugPrint(e.toString());
    }
    return result;
  }

  Future<List<TrackTraceGCOSModel>> getGCOSTrackTrace(
    MobiAppData mobiAppData,
    String vnlUnitId,
    String facilityId,
    bool isFacilityQuery,
    String queryType,
  ) async {
    List<TrackTraceGCOSModel> result = [];

    Map<String, String> queryParameters = {
      'inParamName1': 'FACILITY_ID',
      'inParamValue1': facilityId,
      'inParamName2':
          queryType == "Cargo Tag"
              ? 'VIN_No'
              : queryType == "Order Number"
              ? 'DocumentNo'
              : 'DOCUMENT_ID',
      'inParamValue2': vnlUnitId,
      'inParamName3': '--',
      'inParamValue3': '--',
      'inParamName4': '--',
      'inParamValue4': '--',
      'inParamName5': '--',
      'inParamValue5': '--',
    };
    try {
      await fetchHTTPResponse(
        queryType == "Cargo Tag"
            ? 'TRACKANDTRACE'
            : queryType == "Order Number"
            ? 'TRACKANDTRACEORD'
            : 'TRACKANDTRACEDOC',
        mobiAppData,
        'MOBI_WM_QUERY_GCOS',
        queryParameters,
      ).then(
        (value) => {
          debugPrint(value),
          result = TrackTraceGCOSModel.fromMap(json.decode(value), queryType),
        },
      );
    } catch (e) {
      debugPrint(e.toString());
    }
    return result;
  }

  Future<List<VesselItems>> getVesselNames(
    MobiAppData mobiAppData,
    String vnlFacility,
    String sector,
  ) async {
    List<VesselItems> result = [];

    Map<String, String> queryParameters = {
      'inParamName1': sector == 'container' ? 'operatorId' : 'FACILITY_ID',
      'inParamValue1':
          sector == 'container' ? mobiAppData.organisation! : vnlFacility,
      'inParamName2': sector == 'container' ? 'complexId' : '',
      'inParamValue2': sector == 'container' ? mobiAppData.complex! : '',
      'inParamName3': sector == 'container' ? 'facilityId' : '',
      'inParamValue3': '--',
      'inParamName4': sector == 'container' ? 'PARM_VNL_FACILITY' : '',
      'inParamValue4': sector == 'container' ? vnlFacility : '',
      'inParamName5': '--',
      'inParamValue5': '--',
    };
    try {
      await fetchHTTPResponse(
        sector == 'container' ? 'VESSEL_NAMES_LOV_FCL' : 'VESSELVISITS',
        mobiAppData,
        sector == 'container' ? 'MOBI_NAVIS_QAPI' : 'MOBI_WM_QUERY_GCOS',
        queryParameters,
      ).then(
        (value) => {
          debugPrint('vessels$value'),
          if (sector == 'container')
            {
              result =
                  json.decode(
                            value,
                          )['outResponseDoc']['outResponseDocList']['query-response']['data-table']['rows'] !=
                          ""
                      ? VesselSpotlightModel.fromMap(
                        json.decode(
                          value,
                        )['outResponseDoc']['outResponseDocList']['query-response']['data-table']['rows'],
                        json.decode(
                          value,
                        )['outResponseDoc']['outResponseDocList']['query-response']['data-table']['filter'],
                        'row',
                      ).items
                      : result = [],
            }
          else if (sector == 'automotive' ||
              sector == 'breakbulk' ||
              sector == 'agriculture')
            {
              result =
                  VesselSpotlightModel.fromMap(
                    json.decode(value),
                    '',
                    'C_CURSOR',
                  ).items,
            },
        },
      );
    } catch (e) {
      debugPrint(e.toString());
    }
    return result;
  }

  Future<List<VesselStatus>> getVesselsStatus(
    MobiAppData mobiAppData,
    String vnlFacility,
    String sector,
  ) async {
    List<VesselStatus> result = [];
    Map<String, String> queryParameters = {
      'inParamName1': 'FACILITY_ID',
      'inParamValue1': vnlFacility,
      'inParamName2': '--',
      'inParamValue2': '--',
      'inParamName3': '--',
      'inParamValue3': '--',
      'inParamName4': '--',
      'inParamValue4': '--',
      'inParamName5': '--',
      'inParamValue5': '--',
    };
    try {
      await fetchQAHTTPResponse(
        'VESSELSTATUS',
        'MOBI_PULSENET',
        queryParameters,
      ).then((value) {
        result =
            VesselStatusModel.fromMap(json.decode(value), 'Vessel_Visit').items;
      });
    } catch (e) {
      debugPrint(e.toString());
    }
    return result;
  }

  Future<List<String>> getVesselVisits(
    MobiAppData mobiAppData,
    String vnlVesselId,
    String vnlFacility,
    String sector,
  ) async {
    List<String> result = [];

    Map<String, String> queryParameters = {
      'inParamName1': sector == 'container' ? 'operatorId' : 'FACILITY_ID',
      'inParamValue1':
          sector == 'container' ? mobiAppData.organisation! : vnlFacility,
      'inParamName2': sector == 'container' ? 'complexId' : 'VESSEL_ID',
      'inParamValue2':
          sector == 'container' ? mobiAppData.complex! : vnlVesselId,
      'inParamName3': sector == 'container' ? 'facilityId' : '--',
      'inParamValue3': '--',
      'inParamName4': sector == 'container' ? 'PARM_VV_VISIT_REF' : '--',
      'inParamValue4': sector == 'container' ? vnlVesselId : '--',
      'inParamName5': '--',
      'inParamValue5': '--',
    };
    try {
      await fetchHTTPResponse(
        sector == 'container' ? 'VESSEL_VISITS' : 'VIEWVESSELVISIT',
        mobiAppData,
        sector == 'container' ? 'MOBI_NAVIS_QAPI' : 'MOBI_WM_QUERY_GCOS',
        queryParameters,
      ).then(
        (value) => {
          debugPrint('vesselvisits$value'),
          if (sector == 'container')
            {
              result = VesselVisitsModel.fromMap(
                json.decode(
                  value,
                )['outResponseDoc']['outResponseDocList']['query-response']['data-table']['rows'],
                '',
              ),
            }
          else if (sector == 'automotive' ||
              sector == 'breakbulk' ||
              sector == 'agriculture')
            {
              result = VesselVisitsModel.fromMap(
                json.decode(value),
                'C_CURSOR',
              ),
            },
        },
      );
    } catch (e) {
      debugPrint(e.toString());
    }

    return result;
  }

  Future<List<TruckVisitsModel>> getTruckVisits(
    MobiAppData mobiAppData,
    String vnlTruckId,
  ) async {
    List<TruckVisitsModel> result = [];

    Map<String, String> queryParameters = {
      'inParamName1': 'operatorId',
      'inParamValue1': mobiAppData.organisation!,
      'inParamName2': 'complexId',
      'inParamValue2': mobiAppData.complex!,
      'inParamName3': 'facilityId',
      'inParamValue3': '--',
      'inParamName4': 'PARM_TV_TRUCK_LICENSE',
      'inParamValue4': vnlTruckId,
      'inParamName5': '--',
      'inParamValue5': '--',
    };
    try {
      await fetchHTTPResponse(
        'TRUCK_VISITS',
        mobiAppData,
        'MOBI_NAVIS_QAPI',
        queryParameters,
      ).then(
        (value) => {
          result = TruckVisitsModel.fromMap(
            json.decode(
              value,
            )['outResponseDoc']['outResponseDocList']['query-response']['data-table']['rows'],
          ),
        },
      );
    } catch (e) {
      debugPrint(e.toString());
    }

    return result;
  }

  Future<List<AvailableSlotsModel>> getAvailableSlots(
    MobiAppData mobiAppData,
    String facilityFilter,
  ) async {
    List<AvailableSlotsModel> result = [];

    Map<String, String> queryParameters = {
      'inParamName1': 'operatorId',
      'inParamValue1': mobiAppData.organisation!,
      'inParamName2': 'complexId',
      'inParamValue2': mobiAppData.complexAppointments!,
      'inParamName3': '--',
      'inParamValue3': '--',
      'inParamName4': '--',
      'inParamValue4': '--',
      'inParamName5': '--',
      'inParamValue5': '--',
    };
    try {
      await fetchHTTPResponse(
        facilityFilter,
        mobiAppData,
        'MOBI_WM_QUERY',
        queryParameters,
      ).then(
        (value) => {
          debugPrint(value),
          result = AvailableSlotsModel.fromMap(
            json.decode(value)['query-response']['data-table']['rows'],
            mobiAppData,
          ),
        },
      );
    } catch (e) {
      debugPrint(e.toString());
    }

    return result;
  }

  Future<List<StackOccupancyModel>> getStackOccupancy(
    MobiAppData mobiAppData,
    String vnlFacility,
  ) async {
    List<StackOccupancyModel> result = [];

    Map<String, String> queryParameters = {
      'inParamName1': 'FACILITY_ID',
      'inParamValue1': vnlFacility,
      'inParamName2': '',
      'inParamValue2': '',
      'inParamName3': '--',
      'inParamValue3': '--',
      'inParamName4': '--',
      'inParamValue4': '--',
      'inParamName5': '--',
      'inParamValue5': '--',
    };
    try {
      await fetchHTTPResponse(
        'STACKOCCUPANCY',
        mobiAppData,
        'MOBI_WM_QUERY_GCOS',
        queryParameters,
      ).then(
        (value) => {
          result = StackOccupancyModel.fromMap(json.decode(value), 'C_CURSOR'),
        },
      );
    } catch (e) {
      debugPrint(e.toString());
    }

    return result;
  }

  String convertInputStreamToString(String inputStream, inRequestName) {
    String result = "";
    try {
      LineSplitter.split(inputStream).forEach((line) {
        result += line;
      });
    } catch (e) {
      debugPrint("THE_EXCEPTION: $e");
    }

    result = result.replaceAll("&quot;", "\"");
    result = result.replaceAll("&lt;", "<");
    result = result.replaceAll("&gt;", ">");
    result = result.replaceAll("@", "");
    result = result.substring(result.indexOf("<TD>{") + 4);
    result = result.substring(0, result.indexOf("</TD>")); //removed </TR>
    if (result.contains("\"count\" : \"1\"") &&
        (inRequestName != "MOBIAPP_USER" &&
            inRequestName != "MOBIAPP_TC" &&
            inRequestName != "MOBIAPP_UNIT")) {
      result = result.replaceFirst(" \"row\" : {", " \"row\" : [ {");
      result = result.replaceFirst(
        "}          }        }      }    }  }}",
        "}            ]          }        }      }    }  }}",
      );
    }

    return result;
  }
}
