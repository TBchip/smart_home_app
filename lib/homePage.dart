import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'smartDevice.dart';

class HomePage extends StatefulWidget {
  HomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  var _devices = [];

  _refreshDevices() async {
    final prefs = await SharedPreferences.getInstance();

    final devices = prefs.getStringList('devices') ?? [];

    var deviceConfig = [];
    for (var device in devices) {
      deviceConfig.add([device, prefs.getString(device)]);
    }

    setState(() {
      _devices = deviceConfig;
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

    final devices = prefs.getStringList('devices') ?? [];
    devices.add(deviceName);
    prefs.setStringList('devices', devices);

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
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: Colors.blue,
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              for (var device in _devices)
                SmartDevice(
                    title: device[0],
                    ip: device[1],
                    refreshDevices: _refreshDevices),
              if (_devices.length == 0)
                Container(
                  margin: EdgeInsets.fromLTRB(50, 200, 50, 0),
                  child: Text(
                    "Geen apparaten, voeg er een toe met de knop rechtonder in je scherm",
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
      floatingActionButton: FloatingActionButton(
        onPressed: _addDeviceDialog,
        tooltip: 'Increment',
        child: Icon(Icons.add),
        backgroundColor: Colors.blue,
      ),
    );
  }
}
