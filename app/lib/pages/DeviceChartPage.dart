import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:app/models/Device.dart';
import 'package:app/models/DeviceAvgPoint.dart';
import 'package:flutter/material.dart';

import 'package:flutter_sparkline/flutter_sparkline.dart';

class DeviceChartPage extends StatefulWidget {
  DeviceChartPage(this.device, {Key key}) : super(key: key);
  final Device device;

  @override
  _DeviceChartPageState createState() => new _DeviceChartPageState();
}

class _DeviceChartPageState extends State<DeviceChartPage> {
  Future<List<DeviceAvgPoint>> fetchPoints() async {
    var deviceId = this.widget.device.name;
    var url =
        "https://us-central1-iot-cat-poop-detector.cloudfunctions.net/query_history_data?deviceId=" +
            deviceId;
    print(url);
    var response = await http.get(url);
    if (response.statusCode == 200) {
      // If server returns an OK response, parse the JSON
      List items = json.decode(response.body);
      List<DeviceAvgPoint> points =
          items.map((item) => DeviceAvgPoint.fromJson(item)).toList();
      return points;
    } else {
      // If that response was not OK, throw an error.
      throw Exception('Failed to load post');
    }
  }

  Widget _buildCard(Widget child, {Function() onTap}) {
    return Container(
      margin: EdgeInsets.all(2.0),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Material(
          elevation: 4.0,
          borderRadius: BorderRadius.circular(12.0),
          shadowColor: Colors.black,
          child: InkWell(child: child),
        ),
      ),
    );
  }

  Widget _buildSparklineDataCard(
      String metricName, num value, String metric, List<double> data) {
    return _buildCard(
      Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(metricName, style: TextStyle(color: Colors.green)),
                      Text("$value $metric",
                          style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.w700,
                              fontSize: 24.0)),
                    ],
                  ),
                ],
              ),
              Padding(padding: EdgeInsets.only(bottom: 4.0)),
              Sparkline(
                data: data,
                lineWidth: 3.0,
                pointColor: Colors.black,
                pointSize: 8.0,
                pointsMode: PointsMode.last,
                lineColor: Colors.green,
              )
            ],
          )),
    );
  }

  Widget buildBody() {
    return FutureBuilder<List<DeviceAvgPoint>>(
      future: fetchPoints(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          if (snapshot.data.length == 0) {
            return Center(
              child: Text('No history data.'),
            );
          }

          var points = snapshot.data;
          var methanePoints =
              points.map((point) => point.avgMethane.toDouble()).toList();
          var airQualityPoints =
              points.map((point) => point.avgAirQuality.toDouble()).toList();
          var temperaturePoints =
              points.map((point) => point.avgTemperature.toDouble()).toList();
          var humidityPoints =
              points.map((point) => point.avgHumidity.toDouble()).toList();
          return new ListView(
            children: <Widget>[
              _buildSparklineDataCard(
                  'Methane', this.widget.device.methane, 'ppm', methanePoints),
              _buildSparklineDataCard('Air Quality',
                  this.widget.device.airQuality, 'ppm', airQualityPoints),
              _buildSparklineDataCard(
                  'Humidity', this.widget.device.humidity, '%', humidityPoints),
              _buildSparklineDataCard('Temperature',
                  this.widget.device.temperature, 'Cº', temperaturePoints),
            ],
          );
        } else if (snapshot.hasError) {
          return Text("${snapshot.error}");
        }
        return Center(child: CircularProgressIndicator());
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text(this.widget.device.name),
      ),
      body: buildBody(),
    );
  }
}
