import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:customer_portal/shared/converters.dart';

class StationList {
  String? station;
  double latitude, longitude;

  StationList({
    required this.station,
    required this.latitude,
    required this.longitude,
  });
}

class WeatherModel {
  int? id;
  final int time;
  final String? description;
  final String icon;
  final double temperature;
  final double maxTemperature;
  final double minTemperature;
  final double windSpeed;
  final double windGust;
  final int grndlevel;
  final int sealevel;
  final int? response;
  final bool? location;
  final Timestamp? date;
  final String cityName;

  WeatherModel({
    this.id,
    required this.time,
    required this.description,
    required this.icon,
    required this.temperature,
    required this.maxTemperature,
    required this.minTemperature,
    required this.windSpeed,
    required this.windGust,
    required this.grndlevel,
    required this.sealevel,
    this.response,
    required this.location,
    required this.cityName,
    required this.date,
  });

  Map<String, dynamic> toMap() => <String, dynamic>{
    'cod': response ?? 0,
    'location': location,
    'date': date ?? Timestamp.now(),
  };

  static WeatherModel fromMap(Map<String, dynamic> map) {
    String city = 'no city';
    return WeatherModel(
      time: map['dt'],
      description: map['weather'][0]['description'],
      icon: map['weather'][0]['icon'],
      temperature: intToDouble(map['main']['temp']),
      minTemperature: intToDouble(map['main']['temp_min']),
      maxTemperature: intToDouble(map['main']['temp_max']),
      windSpeed: intToDouble(map['wind']['speed']),
      windGust:
          map['wind']['gust'] == null ? 0 : intToDouble(map['wind']['gust']),
      grndlevel: map['main']['grnd_level'] ?? 0,
      sealevel: map['main']['sea_level'] ?? 0,
      response: map['cod'] ?? 0,
      location: map['location'],
      cityName: map['name'] ?? city,
      date: Timestamp.now(),
    );
  }
}
