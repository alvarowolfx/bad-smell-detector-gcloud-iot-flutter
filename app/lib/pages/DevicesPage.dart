import 'package:app/models/Device.dart';
import 'package:app/components/DeviceTile.dart';
import 'package:app/pages/DeviceChartPage.dart';

import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class DevicesPage extends StatefulWidget {
  DevicesPage({Key key}) : super(key: key);

  @override
  _DevicesPageState createState() => new _DevicesPageState();
}

class _DevicesPageState extends State<DevicesPage> {
  DatabaseError error;
  DatabaseReference _devicesRef;
  List<Device> devices = new List();

  void initState() {
    super.initState();

    final FirebaseDatabase db = FirebaseDatabase.instance;
    _devicesRef = db.reference().child('devices');
    _devicesRef.onChildAdded.listen((Event event) {
      var device = new Device.fromSnapshot(event.snapshot);
      setState(() {
        devices.add(device);
      });
    });

    _devicesRef.onChildChanged.listen((Event event) {
      var index =
          devices.indexWhere((device) => device.name == event.snapshot.key);
      var device = new Device.fromSnapshot(event.snapshot);
      setState(() {
        devices[index] = device;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text('Bad Smell Detector'),
      ),
      body: DeviceTileList(
        devices,
        onHistoryDataTap: (Device device) {
          Navigator
              .of(context)
              .push(MaterialPageRoute(builder: (_) => DeviceChartPage(device)));
        },
      ),
    );
  }
}
