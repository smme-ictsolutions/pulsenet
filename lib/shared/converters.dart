import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

/// converts values of type int to double
/// intended to use while parsing json values where type will be dynamic
/// returns value of type double
dynamic intToDouble(dynamic val) {
  if (val.runtimeType == double) {
    return val;
  } else if (val.runtimeType == int) {
    return val.toDouble();
  } else {
    throw Exception(
      "value is not of type 'int' or 'double' got type '${val.runtimeType}'",
    );
  }
}

List<String> parseInput(String input) {
  return input.split(RegExp(r'[\n, ]+')).where((e) => e.isNotEmpty).toList();
}

enum TemperatureUnit { kelvin, celsius, fahrenheit }

class Temperature {
  final double _kelvin;

  Temperature(this._kelvin);

  double get kelvin => _kelvin;

  double get celsius => _kelvin - 273.15;

  double get fahrenheit => _kelvin * (9 / 5) - 459.67;

  double as(TemperatureUnit unit) {
    switch (unit) {
      case TemperatureUnit.kelvin:
        return kelvin;
      case TemperatureUnit.celsius:
        return celsius;
      case TemperatureUnit.fahrenheit:
        return fahrenheit;
    }
  }
}

Color getTextColor(String inputString) {
  switch (inputString) {
    case 'groceries':
      return Colors.green;
    case 'clothing':
      return Colors.yellow;
    case 'beauty':
      return Colors.blue;
    case 'health':
      return Colors.purple;
    case 'appliances':
      return Colors.orange;
    case 'other':
      return Colors.indigo;
    case '':
      return Colors.transparent;
  }
  return Colors.grey;
}

bool isAfterToday(Timestamp timestamp) {
  return DateTime.now().microsecondsSinceEpoch <
      timestamp.microsecondsSinceEpoch;
}
