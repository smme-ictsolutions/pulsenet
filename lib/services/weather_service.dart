import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:customer_portal/model/singletons_data.dart';
import 'package:customer_portal/model/weather.dart';
import 'package:flutter/material.dart';
import "package:http/http.dart" as http;

class WeatherService {
  WeatherService();

  Future<WeatherModel> getOpenWeatherData(
    double latitude,
    double longitude,
  ) async {
    try {
      final response = await http.get(
        Uri.parse(
          'https://worker.smmeictsolutions.co.za/?credentials=not required&url=${Uri.encodeComponent('https://api.openweathermap.org/data/2.5/weather?lat=$latitude&lon=$longitude&appid=${appData.apiWeatherKey}&units=metric')}',
        ),
      );

      switch (response.statusCode) {
        case 200:
          final Map<String, dynamic> decodedJson = json.decode(response.body);
          return WeatherModel.fromMap(decodedJson);

        case 401:
          debugPrint("401 - Invalid API exception");
        case 404:
          debugPrint("404 - City not found exception");
        default:
          debugPrint("Unknown error");
      }
    } on SocketException catch (_) {
      debugPrint("Unknown error");
    }

    return WeatherModel(
      time: DateTime.now().add(const Duration(days: 0)).microsecondsSinceEpoch,
      description: 'no description',
      icon: '10d',
      temperature: 0.0,
      maxTemperature: 0.0,
      minTemperature: 0.0,
      windSpeed: 0.0,
      windGust: 0.0,
      sealevel: 0,
      grndlevel: 0,
      response: 0,
      location: true,
      date: Timestamp.now(),
      cityName: 'no city',
    );
  }

  Stream<List<WeatherModel>> createWeatherList() async* {
    List<WeatherModel> x = [];
    if (appData.weatherData.isNotEmpty) {
      appData.weatherData = [];
    }
    try {
      for (var i = 0; i < appData.stationListData.length; i++) {
        await getOpenWeatherData(
          appData.stationListData[i].latitude,
          appData.stationListData[i].longitude,
        ).then(
          (value) => x.add(
            WeatherModel(
              time: value.time,
              description: value.description,
              icon: value.icon,
              temperature: value.temperature,
              maxTemperature: value.maxTemperature,
              minTemperature: value.minTemperature,
              windSpeed: value.windSpeed,
              windGust: value.windGust,
              grndlevel: value.grndlevel,
              sealevel: value.sealevel,
              location: value.location,
              cityName: appData.stationListData[i].station!,
              date: value.date,
            ),
          ),
        );
      }
    } on TimeoutException catch (e) {
      debugPrint('Timeout Error: $e');
    } on SocketException catch (e) {
      debugPrint('Socket Error: $e');
    } on Error catch (e) {
      debugPrint('General Error: $e');
    }

    //appData.weatherData.isEmpty ? appData.weatherData = x : null;

    yield x;
  }

  Future<bool> getLocationPermissions() async {
    return true;
  }
}
