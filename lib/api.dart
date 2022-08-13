import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:weather/response.dart';

class API {
  Future<dynamic> getCityWeather(var location) async {
    Map<String, String> requestHeaders = {
      'Content-type': 'application/json',
      'Accept': 'application/json',
      'x-rapidapi-host': 'yahoo-weather5.p.rapidapi.com',
      'x-rapidapi-key': 'ec3d600c8amshdc20236ecb5eb1dp148e76jsn1477b4f1c149',
    };
    var url = Uri.parse(
        'https://yahoo-weather5.p.rapidapi.com/weather?location=$location');
    http.Response response = await http.get(url, headers: requestHeaders);
    if (response.statusCode == 200) {
      return Welcome.fromRawJson(response.body);
    } else {
      throw Exception(response.statusCode);
    }
  }

  Future<dynamic> getCurrentWeather(var lat, var long) async {
    Map<String, String> requestHeaders = {
      'Content-type': 'application/json',
      'Accept': 'application/json',
      'x-rapidapi-host': 'yahoo-weather5.p.rapidapi.com',
      'x-rapidapi-key': 'ec3d600c8amshdc20236ecb5eb1dp148e76jsn1477b4f1c149',
    };
    var urlOne = Uri.parse(
        'https://yahoo-weather5.p.rapidapi.com/weather?lat=$lat&long=$long');
    http.Response response = await http.get(urlOne, headers: requestHeaders);
    if (response.statusCode == 200) {
      return Welcome.fromRawJson(response.body);
    } else {
      throw Exception(response.statusCode);
    }
  }
}
