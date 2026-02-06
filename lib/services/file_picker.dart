import 'dart:convert';
import 'dart:io';
import 'package:csv/csv.dart';
import 'package:customer_portal/model/mobiapp.dart';
import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:xml/xml.dart';

class FilePickerService {
  FilePickerService();

  Future<String?> pickFile(String fileType) async {
    if (kIsWeb) {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        allowedExtensions: [fileType],
        type: FileType.custom,
        withData: true,
      );
      if (result != null && result.files.single.bytes != null) {
        // For web, the file content is available as bytes
        final bytes = result.files.single.bytes!;
        // Decode bytes to string using appropriate encoding (e.g., utf8)
        return String.fromCharCodes(bytes);
      }
    }
    return null;
  }

  Future<FilePickerResult?> validateExcelHeaders() async {
    // 1. Define your expected headers
    const List<String> expectedHeaders = [
      'PART NUMBER',
      'PART DESCRIPTION',
      'TPT MATERIAL NUMBER',
      'STOCK ON HAND',
    ];

    // 2. Pick the Excel file
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xlsx'],
      withData: true,
    );

    if (result == null) {
      debugPrint("No file selected.");
      return result;
    }

    Uint8List? fileBytes = result.files.first.bytes;
    if (fileBytes == null) {
      // Handle cases where file bytes are not directly available (e.g., web)
      String? filePath = result.files.first.path;
      if (filePath != null) {
        fileBytes = await File(filePath).readAsBytes();
      }
    }

    if (fileBytes == null) {
      return null;
    }

    // 3. Decode the Excel file
    var excel = Excel.decodeBytes(fileBytes);
    String sheetName = excel.tables.keys.first;
    var sheet = excel.tables[sheetName];

    if (sheet == null) {
      debugPrint("Could not find the first sheet.");
      return null;
    }

    // 4. Extract headers from the first row (row index 0)
    List<String> actualHeaders =
        sheet
            .row(0)
            .map((cell) => cell?.value.toString().trim().toUpperCase() ?? '')
            .toList();

    // 5. Validate the headers
    if (actualHeaders.length != expectedHeaders.length) {
      debugPrint("Header count mismatch.");
      return null;
    }

    for (int i = 0; i < expectedHeaders.length; i++) {
      if (actualHeaders[i].toLowerCase() != expectedHeaders[i].toLowerCase()) {
        debugPrint(
          "Header mismatch: Expected '${expectedHeaders[i]}', Found '${actualHeaders[i]}'.",
        );
        return null; // Validation failed
      }
    }

    debugPrint("Excel headers are valid!");
    return result; // All headers match
  }

  Future<String> getExcelData(FilePickerResult? pickedFile) async {
    Uint8List? fileBytes = pickedFile?.files.first.bytes;
    if (fileBytes == null) {
      // Handle cases where file bytes are not directly available (e.g., web)
      String? filePath = pickedFile?.files.first.path;
      if (filePath != null) {
        fileBytes = await File(filePath).readAsBytes();
      }
    }

    if (fileBytes == null) {
      return '';
    }

    // fileBytes is already a Uint8List (List<int>), so return it directly.
    return base64Encode(fileBytes);
  }

  Future<bool> validateXML(String xmlString) async {
    List<String> cttIds = [], pcIds = [], bookingIds = [];
    List<FlexibleQueryData> parsedItems = [];
    try {
      // Attempt to parse the XML string
      final document = XmlDocument.parse(xmlString);
      // If parsing is successful, check for specific structure or elements
      if (document.findAllElements('PARM_CTT_UNIT_NBR').isNotEmpty) {
        cttIds.addAll(
          document
              .findAllElements('PARM_CTT_UNIT_NBR')
              .map((element) => element.innerText.trim().split('\n'))
              .expand((ids) => ids)
              .toList(),
        );

        parsedItems.addAll(
          cttIds.map(
            (id) => FlexibleQueryData(
              filter: 'PARM_CTT_UNIT_NBR',
              unitIds: id.trim(),
            ),
          ),
        );
      }
      if (document.findAllElements('PARM_PC_UNIT_NBR').isNotEmpty) {
        pcIds =
            document
                .findAllElements('PARM_PC_UNIT_NBR')
                .map((element) => element.innerText.trim().split('\n'))
                .expand((ids) => ids)
                .toList();
        parsedItems.addAll(
          pcIds.map(
            (id) => FlexibleQueryData(
              filter: 'PARM_PC_UNIT_NBR',
              unitIds: id.trim(),
            ),
          ),
        );
      }
      if (document.findAllElements('PARM_BOOKING_NUMBER').isNotEmpty) {
        bookingIds =
            document
                .findAllElements('PARM_BOOKING_NUMBER')
                .map((element) => element.innerText.trim().split('\n'))
                .expand((ids) => ids)
                .toList();
        parsedItems.addAll(
          bookingIds.map(
            (id) => FlexibleQueryData(
              filter: 'PARM_BOOKING_NUMBER',
              unitIds: id.trim(),
            ),
          ),
        );
      }
      if (pcIds.isNotEmpty || bookingIds.isNotEmpty || cttIds.isNotEmpty) {
        return true;
      }
    } catch (e) {
      // If an error occurs during parsing, return false
      debugPrint('Error parsing XML: $e');
    }
    return false;
  }

  Future<List<FlexibleQueryData>> extractXML(String xmlString) async {
    List<String> cttIds = [], pcIds = [], bookingIds = [];
    List<FlexibleQueryData> parsedItems = [];
    try {
      // Attempt to parse the XML string
      final document = XmlDocument.parse(xmlString);
      // If parsing is successful, check for specific structure or elements
      if (document.findAllElements('PARM_CTT_UNIT_NBR').isNotEmpty) {
        cttIds.addAll(
          document
              .findAllElements('PARM_CTT_UNIT_NBR')
              .map((element) => element.innerText.trim().split('\n'))
              .expand((ids) => ids)
              .toList(),
        );

        parsedItems.addAll(
          cttIds.map(
            (id) => FlexibleQueryData(
              filter: 'PARM_CTT_UNIT_NBR',
              unitIds: id.trim(),
            ),
          ),
        );
      }
      if (document.findAllElements('PARM_PC_UNIT_NBR').isNotEmpty) {
        pcIds =
            document
                .findAllElements('PARM_PC_UNIT_NBR')
                .map((element) => element.innerText.trim().split('\n'))
                .expand((ids) => ids)
                .toList();
        parsedItems.addAll(
          pcIds.map(
            (id) => FlexibleQueryData(
              filter: 'PARM_PC_UNIT_NBR',
              unitIds: id.trim(),
            ),
          ),
        );
      }
      if (document.findAllElements('PARM_BOOKING_NUMBER').isNotEmpty) {
        bookingIds =
            document
                .findAllElements('PARM_BOOKING_NUMBER')
                .map((element) => element.innerText.trim().split('\n'))
                .expand((ids) => ids)
                .toList();
        parsedItems.addAll(
          bookingIds.map(
            (id) => FlexibleQueryData(
              filter: 'PARM_BOOKING_NUMBER',
              unitIds: id.trim(),
            ),
          ),
        );
      }
      if (pcIds.isNotEmpty || bookingIds.isNotEmpty || cttIds.isNotEmpty) {
        return parsedItems;
      }
    } catch (e) {
      // If an error occurs during parsing, return false
      debugPrint('Error parsing XML: $e');
    }
    return [];
  }

  Future<String> validateJSON(String jsonString) async {
    List<String> cttIds = [], pcIds = [], bookingIds = [];
    final buffer = StringBuffer();
    try {
      // Attempt to parse the JSON string
      final Map<String, dynamic> jsonMap = jsonDecode(jsonString);
      // If parsing is successful, check for specific structure or elements
      if (jsonMap['CONT_TRACK_TRACE_FCL'].containsKey('PARM_CTT_UNIT_NBR')) {
        cttIds.addAll(
          List<String>.from(
            jsonMap['CONT_TRACK_TRACE_FCL']['PARM_CTT_UNIT_NBR'].map(
              (item) => item['item'],
            ),
          ),
        );
      }
      if (jsonMap['CONT_TRACK_TRACE_FCL'].containsKey('PARM_PC_UNIT_NBR')) {
        pcIds.addAll(
          List<String>.from(
            jsonMap['CONT_TRACK_TRACE_FCL']['PARM_PC_UNIT_NBR'].map(
              (item) => item['item'],
            ),
          ),
        );
      }
      if (jsonMap['CONT_TRACK_TRACE_FCL'].containsKey('PARM_BOOKING_NUMBER')) {
        bookingIds.addAll(
          List<String>.from(
            jsonMap['CONT_TRACK_TRACE_FCL']['PARM_BOOKING_NUMBER'].map(
              (item) => item['item'],
            ),
          ),
        );
      }
      if (cttIds.isNotEmpty || pcIds.isNotEmpty || bookingIds.isNotEmpty) {
        buffer.writeln('<?xml version="1.0" encoding="UTF-8"?>');
        buffer.writeln('<CONT_TRACK_TRACE_FCL>');
      }
      if (cttIds.isNotEmpty) {
        buffer.writeln(generateXMLRequest(cttIds, 'PARM_CTT_UNIT_NBR', 'json'));
      }
      if (pcIds.isNotEmpty) {
        buffer.writeln(generateXMLRequest(pcIds, 'PARM_PC_UNIT_NBR', 'json'));
      }
      if (bookingIds.isNotEmpty) {
        buffer.writeln(
          generateXMLRequest(bookingIds, 'PARM_BOOKING_NUMBER', 'json'),
        );
      }
      if (cttIds.isNotEmpty || pcIds.isNotEmpty || bookingIds.isNotEmpty) {
        buffer.writeln('</CONT_TRACK_TRACE_FCL>');
      }

      return buffer.toString();
    } catch (e) {
      // If an error occurs during parsing, return false
      debugPrint('Error parsing JSON: $e');
    }
    return '';
  }

  Future<String> validateCSV(String csvString) async {
    List<String> cttIds = [], pcIds = [], bookingIds = [];
    final buffer = StringBuffer();
    try {
      // Attempt to parse the CSV string
      final List<List<dynamic>> csvData = const CsvToListConverter().convert(
        csvString,
      );
      // If parsing is successful, check for specific structure or elements
      if (csvData.isNotEmpty) {
        for (var row in csvData) {
          if (row.isNotEmpty) {
            // Assuming the CSV has columns for CTT, PC, and Booking IDs
            // Check if PARM_CTT_UNIT_NBR
            if (row[0] != null &&
                row[0].substring(0, row[0].indexOf(';')) ==
                    'PARM_CTT_UNIT_NBR') {
              //substring list of containers

              cttIds.addAll(
                List<String>.from(
                  row[0].substring(row[0].indexOf(';') + 1).split(';'),
                ),
              );
            }
            // Check if PARM_PC_UNIT_NBR
            if (row[0] != null &&
                row[0].substring(0, row[0].indexOf(';')) ==
                    'PARM_PC_UNIT_NBR') {
              pcIds.addAll(
                List<String>.from(
                  row[0].substring(row[0].indexOf(';') + 1).split(';'),
                ),
              );
            }
            // Check if PARM_BOOKING_NUMBER
            if (row[0] != null &&
                row[0].substring(0, row[0].indexOf(';')) ==
                    'PARM_BOOKING_NUMBER') {
              bookingIds.addAll(
                List<String>.from(
                  row[0].substring(row[0].indexOf(';') + 1).split(';'),
                ),
              );
            }
          }
        }
      }
      if (cttIds.isNotEmpty || pcIds.isNotEmpty || bookingIds.isNotEmpty) {
        buffer.writeln('<?xml version="1.0" encoding="UTF-8"?>');
        buffer.writeln('<CONT_TRACK_TRACE_FCL>');
      }
      if (cttIds.isNotEmpty) {
        buffer.writeln(generateXMLRequest(cttIds, 'PARM_CTT_UNIT_NBR', 'csv'));
      }
      if (pcIds.isNotEmpty) {
        buffer.writeln(generateXMLRequest(pcIds, 'PARM_PC_UNIT_NBR', 'csv'));
      }
      if (bookingIds.isNotEmpty) {
        buffer.writeln(
          generateXMLRequest(bookingIds, 'PARM_BOOKING_NUMBER', 'csv'),
        );
      }
      if (cttIds.isNotEmpty || pcIds.isNotEmpty || bookingIds.isNotEmpty) {
        buffer.writeln('</CONT_TRACK_TRACE_FCL>');
      }

      return buffer.toString();
    } catch (e) {
      // If an error occurs during parsing, return false
      debugPrint('Error parsing CSV: $e');
    }
    return '';
  }

  String generateXMLRequest(
    List<String> unitIds,
    String selectedQueryOption,
    sourceRequest,
  ) {
    final buffer = StringBuffer();
    sourceRequest == 'manual'
        ? buffer.writeln('<?xml version="1.0" encoding="UTF-8"?>')
        : null;
    sourceRequest == 'manual' ? buffer.writeln('<CONT_TRACK_TRACE_FCL>') : null;
    buffer.writeln('  <$selectedQueryOption>');
    for (var unitId in unitIds) {
      buffer.writeln('    <item>${unitId.trim()}</item>');
    }
    buffer.writeln('  </$selectedQueryOption>');
    sourceRequest == 'manual'
        ? buffer.writeln('</CONT_TRACK_TRACE_FCL>')
        : null;
    return buffer.toString().replaceAll(RegExp(r'\s+'), '');
  }

  String generateJSONRequest(
    List<String> unitIds,
    String selectedQueryOption,
    sourceRequest,
  ) {
    final buffer = StringBuffer();
    sourceRequest == 'manual' ? buffer.writeln('{') : null;
    sourceRequest == 'manual'
        ? buffer.writeln('"CONT_TRACK_TRACE_FCL": {')
        : null;
    buffer.writeln('  "$selectedQueryOption": {');
    sourceRequest == 'manual' ? buffer.writeln('"item": [') : null;
    for (int i = 0; i < unitIds.length; i++) {
      i == unitIds.length - 1
          ? buffer.writeln('    "${unitIds[i].trim()}"')
          : buffer.writeln('    "${unitIds[i].trim()}",');
    }

    sourceRequest == 'manual' ? buffer.writeln(']') : null;
    buffer.writeln('}}}');
    return buffer.toString().replaceAll(RegExp(r'\s+'), '');
  }
}
