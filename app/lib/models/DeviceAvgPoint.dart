import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart';

class DeviceAvgPoint extends Object {
  DateTime timestamp;
  num avgTemperature;
  num avgHumidity;
  num avgAirQuality;
  num avgMethane;

  DeviceAvgPoint(
      {int timestamp,
      this.avgTemperature,
      this.avgHumidity,
      this.avgAirQuality,
      this.avgMethane}) {
    this.timestamp = DateTime.fromMillisecondsSinceEpoch(timestamp).toLocal();
  }

  String formattedDate() {
    return "${DateFormat.yMd().format(this.timestamp)} ${DateFormat.jm().format(this.timestamp)}";
  }

  factory DeviceAvgPoint.fromJson(Map<String, dynamic> json) {
    return DeviceAvgPoint(
      timestamp: json['date_time'],
      avgAirQuality: json['avg_air_quality'],
      avgMethane: json['avg_methane'],
      avgHumidity: json['avg_humidity'],
      avgTemperature: json['avg_temperature'],
    );
  }
}
