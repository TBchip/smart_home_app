import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'smartDeviceStandalone.dart';

class SmartDeviceStandalonePage extends StatefulWidget {
  SmartDeviceStandalonePage({Key? key}) : super(key: key);

  final _SmartDeviceStandalonePageState smartDeviceStandaloneListState =
      new _SmartDeviceStandalonePageState();

  @override
  _SmartDeviceStandalonePageState createState() =>
      smartDeviceStandaloneListState;

  void refreshDevices() {
    smartDeviceStandaloneListState._refreshDevices();
  }
}

class _SmartDeviceStandalonePageState extends State<SmartDeviceStandalonePage> {
  var _devices = [];

  _refreshDevices() async {
    final prefs = await SharedPreferences.getInstance();

    final devices = prefs.getStringList('standaloneDevices') ?? [];

    var deviceConfig = [];
    for (var device in devices) {
      deviceConfig.add([device, prefs.getString(device)]);
    }

    WidgetsBinding.instance!.addPostFrameCallback((_) {
      setState(() {
        _devices = deviceConfig;
      });
    });
  }

  _addDeviceDialog() {
    final nameController = TextEditingController();
    final ipController = TextEditingController();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Apparaat toevoegen"),
          content: Container(
            height: 120,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: 'Apparaatnaam:',
                  ),
                ),
                TextField(
                  controller: ipController,
                  decoration: InputDecoration(
                    labelText: 'Ip:',
                  ),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            new TextButton(
              child: new Text("Annuleer"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            new TextButton(
              child: new Text("Toevoegen"),
              onPressed: () {
                Navigator.of(context).pop();
                _addDevice(nameController.text, ipController.text);
              },
            ),
          ],
        );
      },
    );
  }

  _addDevice(String deviceName, String deviceIp) async {
    final prefs = await SharedPreferences.getInstance();

    final devices = prefs.getStringList('standaloneDevices') ?? [];
    devices.add(deviceName);
    prefs.setStringList('standaloneDevices', devices);

    prefs.setString(deviceName, deviceIp);

    _refreshDevices();
  }

  @override
  void initState() {
    super.initState();

    _refreshDevices();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Center(
        child: Container(
          margin: EdgeInsets.fromLTRB(0, 30, 0, 30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              FloatingActionButton(
                onPressed: _addDeviceDialog,
                tooltip: 'Apparaat toevoegen',
                child: Icon(Icons.add),
                backgroundColor: Colors.blue,
              ),
              for (var device in _devices)
                SmartDeviceStandalone(
                  title: device[0],
                  ip: device[1],
                  refreshDevices: _refreshDevices,
                ),
              if (_devices.length == 0)
                Container(
                  margin: EdgeInsets.fromLTRB(50, 200, 50, 0),
                  child: Text(
                    "Geen apparaten, voeg er een toe met de knop bovenin je scherm!",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 20,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
