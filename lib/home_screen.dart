import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:jiffy/jiffy.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    _determinePosition();
    super.initState();
  }

  bool status = false;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text("Weather App"),
          elevation: 0,
          actions: [
            IconButton(onPressed: () {}, icon: Icon(Icons.search)),
            IconButton(onPressed: () {}, icon: Icon(Icons.my_location)),
          ],
        ),
        body: forcastMap != null
            ? Container(
                padding: EdgeInsets.all(20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Align(
                        alignment: Alignment.centerRight,
                        child: Row(
                          children: [
                            FlutterSwitch(
                              width: 60.0,
                              height: 35.0,
                              valueFontSize: 16.0,
                              toggleSize: 10.0,
                              value: status,
                              borderRadius: 20.0,
                              padding: 8.0,
                              showOnOff: true,
                              onToggle: (val) {
                                setState(() {
                                  status = val;
                                });
                              },
                            ),
                            Spacer(),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  "${Jiffy("${forcastMap!["list"][0]["dt_txt"]}").format("MMM do yy")}, ${Jiffy("${forcastMap!["list"][0]["dt_txt"]}").format("h:mm")}",
                                  style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.black,
                                      fontWeight: FontWeight.w400),
                                ),
                                Text(
                                  "${weatherMap!["name"]}",
                                  // "Kawran Bazar, Dhaka",
                                  style: TextStyle(
                                      fontSize: 20,
                                      color: Colors.black,
                                      fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                          ],
                        )),
                    Center(
                      child: Column(
                        children: [
                          Image.network(
                            "https://cdn-icons-png.flaticon.com/512/3208/3208756.png",
                            height: 100,
                            width: 100,
                            fit: BoxFit.cover,
                          ),
                          SizedBox(height: 10),
                          Text(
                            "${forcastMap!["list"][0]["main"]["temp"]} °",
                            style: TextStyle(
                                fontSize: 50,
                                color: Colors.black,
                                fontWeight: FontWeight.w800),
                          ),
                        ],
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Feels Like ${forcastMap!["list"][0]["main"]["feels_like"]} °",
                            style: TextStyle(
                                fontSize: 16,
                                color: Colors.black,
                                fontWeight: FontWeight.w500),
                          ),
                          Text(
                            "${forcastMap!["list"][0]["weather"][0]["description"]} °",
                            style: TextStyle(
                                fontSize: 16,
                                color: Colors.black,
                                fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    ),
                    Center(
                      child: Column(
                        children: [
                          Text(
                            "Humidity ${forcastMap!["list"][0]["main"]["humidity"]}, Pressure  ${forcastMap!["list"][0]["main"]["pressure"]}",
                            style: TextStyle(
                                fontSize: 16,
                                color: Colors.black,
                                fontWeight: FontWeight.w500),
                          ),
                          Text(
                            "Sunrise ${Jiffy("${DateTime.fromMillisecondsSinceEpoch(weatherMap!["sys"]["sunset"] * 1000)}").format("h:mm:a")}, Sunrise ${Jiffy("${DateTime.fromMillisecondsSinceEpoch(weatherMap!["sys"]["sunrise"] * 1000)}").format("h:mm:a")}",
                            style: TextStyle(
                                fontSize: 16,
                                color: Colors.black,
                                fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      height: 180,
                      width: double.infinity,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: forcastMap!.length,
                        shrinkWrap: true,
                        itemBuilder: (context, index) {
                          return Container(
                            margin: EdgeInsets.only(right: 8),
                            width: 90,
                            color: Colors.blueGrey,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Text(
                                  "${Jiffy("${forcastMap!["list"][index]["dt_txt"]}").format("EEE")} ,${Jiffy("${forcastMap!["list"][index]["dt_txt"]}").format("h:mm")}",
                                  style: TextStyle(
                                      fontSize: 14, color: Colors.white),
                                ),
                                Image.network(
                                  "https://cdn-icons-png.flaticon.com/512/3208/3208756.png",
                                  height: 70,
                                  width: 70,
                                  fit: BoxFit.cover,
                                ),
                                Text(
                                  "${forcastMap!["list"][index]["main"]["temp_min"]}/${forcastMap!["list"][index]["main"]["temp_max"]}",
                                  style: TextStyle(
                                      fontSize: 14, color: Colors.white),
                                ),
                                Text(
                                  "${forcastMap!["list"][index]["weather"][0]["description"]}",
                                  style: TextStyle(
                                      fontSize: 14, color: Colors.white),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    )
                  ],
                ),
              )
            : Container(
                alignment: Alignment.center,
                margin: EdgeInsets.only(top: 20),
                child: CircularProgressIndicator(
                  backgroundColor: Colors.grey,
                )),
      ),
    );
  }

  _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    position = await Geolocator.getCurrentPosition();
    setState(() {
      lat = position.latitude;
      lon = position.longitude;
    });
    getwether();
  }

  getwether() async {
    var forecost = await http.get(Uri.parse(
        "https://api.openweathermap.org/data/2.5/forecast?lat=$lat&lon=$lon&units=metric&appid=cc93193086a048993d938d8583ede38a"));
    var wether = await http.get(Uri.parse(
        "https://api.openweathermap.org/data/2.5/weather?lat=$lat&lon=$lon&exclude=hourly,daily&appid=cc93193086a048993d938d8583ede38a"));
    setState(() {
      weatherMap = Map<String, dynamic>.from(jsonDecode(wether.body));
      forcastMap = Map<String, dynamic>.from(jsonDecode(forecost.body));
    });
  }

  Map<String, dynamic>? weatherMap;
  Map<String, dynamic>? forcastMap;

  late Position position;
  double? lat;
  double? lon;
}
