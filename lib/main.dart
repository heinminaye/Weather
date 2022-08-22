import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'api.dart';
import 'response.dart';
import 'package:geolocator/geolocator.dart';
import 'location.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Welcome? weather;
  Welcome? condition;
  var temperature;
  String? curtemperature;
  var celsius;
  var text;
  var lat;
  var long;
  List<Forecast> day = [];
  var city = '';
  var high;
  var low;
  bool buttonActive = true;

  getCityWeather() async {
    await API().getCityWeather(textController.text).then((value) {
      setState(() {
        weather = value;
        condition = value;
        day = weather!.forecasts;
        temperature = weather!.currentObservation.condition.temperature;
        celsius = ((temperature - 32) * 5 / 9);
        text = condition!.currentObservation.condition.text;
        city = weather!.location.city;
      });
    });
  }

  getLocation() async {
    Position position = await _determinePosition();
    setState(() {
      lat = position.latitude;
      long = position.longitude;
      textController.text = '';
    });
    API().getCurrentWeather(lat, long).then((value) {
      setState(() {
        weather = value;
        day = weather!.forecasts;
        temperature = weather!.currentObservation.condition.temperature;
        celsius = ((temperature - 32) * 5 / 9);
        text = weather!.currentObservation.condition.text;
        city = weather!.location.city;
      });
    });
  }

  void setClear() {
    weather = null;
    day = [];
    temperature = null;
    celsius = null;
    text = null;
    city = '';
    condition = null;
    curtemperature = null;
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    return await Geolocator.getCurrentPosition();
  }

  TextEditingController textController = TextEditingController();

  @override
  void initState() {
    textController.addListener(() {
      if (textController.text.isNotEmpty) {
        setState(() {
          buttonActive = false;
        });
      } else {
        setState(() {
          buttonActive = true;
        });
      }
    });
    getLocation();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title:
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.5,
            height: 40,
            child: TextField(
              onSubmitted: (String str) {
                setState(() {
                  getCityWeather();
                  setClear();
                });
              },
              controller: textController,
              decoration: InputDecoration(
                isDense: true,
                contentPadding: EdgeInsets.only(top: 15, bottom: 15, left: 8),
                hintText: "Search ...",
                filled: true,
                fillColor: Colors.white,
                suffixIcon: (buttonActive)
                    ? null
                    : IconButton(
                        splashRadius: 1,
                        onPressed: () {
                          getCityWeather();
                          setClear();
                        },
                        icon: const Icon(
                          Icons.search,
                          size: 18,
                        )),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: const BorderSide(
                    width: 0,
                    style: BorderStyle.none,
                  ),
                ),
              ),
            ),
          ),
          IconButton(
              splashRadius: 15,
              onPressed: () {
                getLocation();
                setClear();
              },
              icon: const Icon(
                Icons.location_on,
                color: Colors.white,
              )),
        ]),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 20, top: 40, bottom: 10),
            child: Row(
              children: [
                (city == '')
                    ? Container()
                    : const Icon(
                        Icons.location_on_outlined,
                        color: Colors.white,
                      ),
                const SizedBox(
                  width: 10,
                ),
                Text(
                  "$city",
                  style: const TextStyle(fontSize: 16, color: Colors.white),
                )
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                (temperature == null)
                    ? const CircularProgressIndicator()
                    : Text(
                        "${double.parse((celsius).toStringAsFixed(0))}°",
                        textAlign: TextAlign.start,
                        style: GoogleFonts.acme(
                            fontSize: 100, color: Colors.white),
                      ),
                (temperature == null)
                    ? const CircularProgressIndicator()
                    : RotatedBox(
                        quarterTurns: -1,
                        child: Text(
                          "It's $text",
                          style: GoogleFonts.b612(
                              fontSize: 16, color: Colors.white),
                        ),
                      )
              ],
            ),
          ),
          const SizedBox(
            height: 40,
          ),
          Expanded(
              child: Container(
            child: Column(children: [
              Expanded(
                  child: ListView.builder(
                itemCount: day.length,
                itemBuilder: (context, index) {
                  high = day[index].high;
                  var high_end = ((high - 32) * 5 / 9).toString();
                  low = day[index].low;
                  var low_end = ((low - 32) * 5 / 9).toString();
                  return ListTile(
                    leading: Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Text(
                        "${day[index].day}",
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    subtitle: Container(
                      height: 30,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage(
                            'images/clouds/${day[index].code}.png',
                          ),
                        ),
                      ),
                    ),
                    trailing: Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Text(
                        "${double.parse(high_end).toStringAsFixed(0)}°",
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  );
                },
              ))
            ]),
          ))
        ],
      ),
    );
  }
}
