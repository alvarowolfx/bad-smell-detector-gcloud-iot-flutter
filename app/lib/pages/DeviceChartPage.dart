import 'package:app/models/Device.dart';
import 'package:flutter/material.dart';

import 'package:flutter_sparkline/flutter_sparkline.dart';

class DeviceChartPage extends StatefulWidget {
  DeviceChartPage(this.device, {Key key}) : super(key: key);
  final Device device;

  @override
  _DeviceChartPageState createState() => new _DeviceChartPageState();
}

class _DeviceChartPageState extends State<DeviceChartPage> {
  final List<List<double>> charts = [
    [
      0.0,
      0.3,
      0.7,
      0.6,
      0.55,
      0.8,
      1.2,
      1.3,
      1.35,
      0.9,
      1.5,
      1.7,
      1.8,
      1.7,
      1.2,
      0.8,
      1.9,
      2.0,
      2.2,
      1.9,
      2.2,
      2.1,
      2.0,
      2.3,
      2.4,
      2.45,
      2.6,
      3.6,
      2.6,
      2.7,
      2.9,
      2.8,
      3.4
    ],
    [
      0.0,
      0.3,
      0.7,
      0.6,
      0.55,
      0.8,
      1.2,
      1.3,
      1.35,
      0.9,
      1.5,
      1.7,
      1.8,
      1.7,
      1.2,
      0.8,
      1.9,
      2.0,
      2.2,
      1.9,
      2.2,
      2.1,
      2.0,
      2.3,
      2.4,
      2.45,
      2.6,
      3.6,
      2.6,
      2.7,
      2.9,
      2.8,
      3.4,
      0.0,
      0.3,
      0.7,
      0.6,
      0.55,
      0.8,
      1.2,
      1.3,
      1.35,
      0.9,
      1.5,
      1.7,
      1.8,
      1.7,
      1.2,
      0.8,
      1.9,
      2.0,
      2.2,
      1.9,
      2.2,
      2.1,
      2.0,
      2.3,
      2.4,
      2.45,
      2.6,
      3.6,
      2.6,
      2.7,
      2.9,
      2.8,
      3.4,
    ],
    [
      0.0,
      0.3,
      0.7,
      0.6,
      0.55,
      0.8,
      1.2,
      1.3,
      1.35,
      0.9,
      1.5,
      1.7,
      1.8,
      1.7,
      1.2,
      0.8,
      1.9,
      2.0,
      2.2,
      1.9,
      2.2,
      2.1,
      2.0,
      2.3,
      2.4,
      2.45,
      2.6,
      3.6,
      2.6,
      2.7,
      2.9,
      2.8,
      3.4,
      0.0,
      0.3,
      0.7,
      0.6,
      0.55,
      0.8,
      1.2,
      1.3,
      1.35,
      0.9,
      1.5,
      1.7,
      1.8,
      1.7,
      1.2,
      0.8,
      1.9,
      2.0,
      2.2,
      1.9,
      2.2,
      2.1,
      2.0,
      2.3,
      2.4,
      2.45,
      2.6,
      3.6,
      2.6,
      2.7,
      2.9,
      2.8,
      3.4,
      0.0,
      0.3,
      0.7,
      0.6,
      0.55,
      0.8,
      1.2,
      1.3,
      1.35,
      0.9,
      1.5,
      1.7,
      1.8,
      1.7,
      1.2,
      0.8,
      1.9,
      2.0,
      2.2,
      1.9,
      2.2,
      2.1,
      2.0,
      2.3,
      2.4,
      2.45,
      2.6,
      3.6,
      2.6,
      2.7,
      2.9,
      2.8,
      3.4
    ]
  ];

  void initState() {
    super.initState();

    // TODO: Fetch from cloud function
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

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text(this.widget.device.name),
      ),
      body: new ListView(
        children: <Widget>[
          _buildSparklineDataCard(
              'Methane', this.widget.device.methane, 'ppm', charts[2]),
          _buildSparklineDataCard(
              'Air Quality', this.widget.device.airQuality, 'ppm', charts[1]),
          _buildSparklineDataCard(
              'Humidity', this.widget.device.humidity, '%', charts[0]),
          _buildSparklineDataCard(
              'Temperature', this.widget.device.temperature, 'Cº', charts[1]),
        ],
      ),
    );
  }
}
