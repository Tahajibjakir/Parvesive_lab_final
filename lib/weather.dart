import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;
import 'dart:convert';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: Text('Weather App'),
          backgroundColor: Colors.blue, // Set app bar color
        ),
        body: WeatherPage(),
        backgroundColor: Colors.grey[900], // Set background color
      ),
    );
  }
}

class WeatherPage extends StatefulWidget {
  @override
  _WeatherPageState createState() => _WeatherPageState();
}

class _WeatherPageState extends State<WeatherPage> {
  final String apiKey =
      'ce4578c0170e21bf9e2288c67427f3cd'; // Replace with your OpenWeatherMap API key
  String location = 'Rajshahi';
  double temperature = 0.0;
  String description = '';
  TextEditingController locationController = TextEditingController();

  @override
  void initState() {
    super.initState();
    locationController.text = location;
    getWeatherData();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      color: Colors.grey[800], // Set container background color
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          // Text and TextField for Location
          Text(
            'Enter Location',
            style: TextStyle(color: Colors.white, fontSize: 18),
          ),
          SizedBox(height: 8),
          TextField(
            controller: locationController,
            style: TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'Enter Location',
              hintStyle: TextStyle(color: Colors.grey),
              contentPadding: EdgeInsets.all(10),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.white),
              ),
            ),
          ),
          SizedBox(height: 16),

          // Get Weather Button
          ElevatedButton(
            onPressed: () {
              setState(() {
                location = locationController.text;
              });
              getWeatherData();
            },
            child: Text('Get Weather', style: TextStyle(color: Colors.white)),
            style: ElevatedButton.styleFrom(primary: Colors.blue),
          ),
          SizedBox(height: 16),

          // Weather Information
          Text(
            'Temperature:',
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
          Text(
            '${temperature.toStringAsFixed(2)}°C',
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
          Text(
            'Description:',
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
          Text(
            description,
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
        ],
      ),
    );
  }

  void getWeatherData() async {
    final url =
        'https://api.openweathermap.org/data/2.5/weather?q=$location&appid=$apiKey';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        temperature = data['main']['temp'] - 273.15;
        description = data['weather'][0]['description'];
      });
    } else {
      setState(() {
        temperature = 0.0;
        description = 'Error fetching data';
      });
    }
  }
}
