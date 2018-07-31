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

  Device(this.name, String timestamp, this.temperature, this.humidity,
      this.airQuality, this.methane, this.airQualityPPM, this.methanePPM) {
    this.timestamp = DateTime.parse(timestamp).toLocal();
  }

  String formattedDate() {
    return "${DateFormat.yMd().format(this.timestamp)} ${DateFormat.jm().format(this.timestamp)}";
  }

  Device.fromSnapshot(DataSnapshot snapshot) {
    this.name = snapshot.key;
    this.timestamp = DateTime.parse(snapshot.value['timestamp']).toLocal();
    this.temperature = snapshot.value['temperature'];
    this.humidity = snapshot.value['humidity'];
    this.airQuality = snapshot.value['air_quality'];
    this.methane = snapshot.value['methane'];
    this.airQualityPPM = snapshot.value['air_quality_ppm'];
    this.methanePPM = snapshot.value['methane_ppm'];
  }
}
