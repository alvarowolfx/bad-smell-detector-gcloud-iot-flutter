import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart';

class Device extends Object {
  String name;
  DateTime timestamp;
  num temperature;
  num humidity;
  num airQuality;
  num methane;
  num airQualityPPM;
  num methanePPM;

  Device(
      {this.name,
      String timestamp,
      this.temperature,
      this.humidity,
      this.airQuality,
      this.methane,
      this.airQualityPPM,
      this.methanePPM}) {
    this.timestamp = DateTime.parse(timestamp).toLocal();
  }

  String formattedDate() {
    return "${DateFormat.yMd().format(this.timestamp)} ${DateFormat.jm().format(this.timestamp)}";
  }

  factory Device.fromSnapshot(DataSnapshot snapshot) {
    return Device(
      name: snapshot.key,
      timestamp: snapshot.value['timestamp'],
      temperature: snapshot.value['temperature'],
      humidity: snapshot.value['humidity'],
      airQuality: snapshot.value['air_quality'],
      methane: snapshot.value['methane'],
      airQualityPPM: snapshot.value['air_quality_ppm'],
      methanePPM: snapshot.value['methane_ppm'],
    );
  }
}
