import 'dart:convert';
import 'package:jiffy/jiffy.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Map<String, dynamic>? weatherMap;
  Map<String, dynamic>? forcastMap;

  late Position position;
  double? latitude;
  double? longitude;

  @override
  void initState() {
    // TODO: implement initState
    _determinePosition();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
        ),
        body: forcastMap != null
            ? Container(
                width: double.infinity,
                height: double.infinity,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage("photos/back.webp"),
                    fit: BoxFit.cover,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Container(
                      child: Column(
                        children: [
                          Text(
                            "${weatherMap!["name"]}",
                            style: TextStyle(fontSize: 40, color: Colors.white),
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          Text(
                            "${Jiffy("${forcastMap!["list"][0]["dt_txt"]}").format("EEEE")},${Jiffy("${forcastMap!["list"][0]["dt_txt"]}").format("MMM do yyyy")}, ",
                            style: TextStyle(
                                fontSize: 20,
                                color: Colors.white,
                                fontWeight: FontWeight.w500),
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          Container(
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    "${forcastMap!["list"][0]["main"]["temp"]}°c",
                                    style: TextStyle(
                                        fontSize: 80,
                                        color: Colors.white,
                                        fontWeight: FontWeight.w800),
                                  ),
                                  SizedBox(
                                    height: 20,
                                  ),
                                  Text(
                                    "----------------------",
                                    style: TextStyle(
                                        fontSize: 30, color: Colors.white),
                                  ),
                                  Text(
                                    "${forcastMap!["list"][0]["weather"][0]["main"]} ",
                                    style: TextStyle(
                                        fontSize: 26, color: Colors.white),
                                  ),
                                  SizedBox(height: 10),
                                  Text(
                                    "${forcastMap!["list"][1]["main"]["temp_min"]} °c"
                                    " / ${forcastMap!["list"][1]["main"]["temp_min"]} °c",
                                    style: TextStyle(
                                        fontSize: 22, color: Colors.white),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(height: 20),
                        ],
                      ),
                    ),
                    Container(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            height: 180,
                            width: double.infinity,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: forcastMap!.length,
                              shrinkWrap: true,
                              itemBuilder: (context, index) {
                                return Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  margin: EdgeInsets.only(right: 8),
                                  width: 90,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Text(
                                        "${Jiffy("${forcastMap!["list"][index]["dt_txt"]}").format("EEE")} ,${Jiffy("${forcastMap!["list"][index]["dt_txt"]}").format("h:mm")}",
                                        style: TextStyle(
                                            fontSize: 16,
                                            color: Colors.white,
                                            fontWeight: FontWeight.w500),
                                      ),
                                      SizedBox(
                                        height: 10,
                                      ),
                                      Image.asset(
                                        "photos/cle_ky.png",
                                        height: 70,
                                        width: 70,
                                        fit: BoxFit.cover,
                                      ),
                                      SizedBox(
                                        height: 10,
                                      ),
                                      Text(
                                        "${forcastMap!["list"][index]["main"]["temp_min"]}/${forcastMap!["list"][index]["main"]["temp_max"]}",
                                        style: TextStyle(
                                            fontSize: 15,
                                            color: Colors.white,
                                            fontWeight: FontWeight.w500),
                                      ),
                                      SizedBox(
                                        height: 10,
                                      ),
                                      Text(
                                        "${forcastMap!["list"][index]["weather"][0]["main"]}",
                                        style: TextStyle(
                                            fontSize: 18, color: Colors.white),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                ) /* add child content here */,
              )
            : Center(
                child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(
                    height: 15,
                  ),
                  Text(
                    "Loading Please wait",
                    style: TextStyle(fontWeight: FontWeight.w400, fontSize: 20),
                  ),
                ],
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
      latitude = position.latitude;
      longitude = position.longitude;
    });
    fetchWeather();
    print("my location latitude  $latitude, and longitude  $longitude");
  }

  fetchWeather() async {
    var weatherResponce = await http.get(Uri.parse(
        "https://api.openweathermap.org/data/2.5/weather?lat=$latitude&lon=$longitude&exclude=hourly%2Cdaily&appid=cc93193086a048993d938d8583ede38a&fbclid=IwAR1rg9BHqDzqxJia8bplKeuzaNLUVMWNCsfmGjp1-IHI0hpsrGe7Hnq5FMI"));

    var forcastResponce = await http.get(Uri.parse(
        "https://api.openweathermap.org/data/2.5/forecast?lat=$latitude&lon=$longitude&units=metric&appid=cc93193086a048993d938d8583ede38a&fbclid=IwAR3Hr9_sSo-ju9Us4-W-MpsVaeQyp10SZvo84iTiJ7WjrqTNSkbxRURH5RQ"));
    setState(() {
      weatherMap = Map<String, dynamic>.from(jsonDecode(weatherResponce.body));
      forcastMap = Map<String, dynamic>.from(jsonDecode(forcastResponce.body));
    });
    print(weatherResponce.body);
    print(forcastResponce.body);
  }
}
