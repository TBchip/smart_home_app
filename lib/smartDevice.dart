import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class SmartDevice extends StatefulWidget {
  SmartDevice(
      {Key? key,
      required this.title,
      required this.ip,
      required this.refreshDevices})
      : super(key: key);

  final String title;
  final String ip;
  final Function() refreshDevices;

  @override
  _SmartDeviceState createState() => _SmartDeviceState();
}

class _SmartDeviceState extends State<SmartDevice> {
  String _switch = "off";
  String _startup = "on";
  bool _isOnline = false;

  int btnOn = 800;
  int btnOff = 200;

  bool _isExpanded = false;

  _setSwitch() {
    if (!_isOnline) return;

    setState(() {
      _switch = _switch == "on" ? "off" : "on";
    });
    http.get(Uri.parse(
        'https://thijsbischoff.nl/smarthome/${widget.ip}/setstate/$_switch'));
  }

  _setStartup(String value) {
    if (!_isOnline) return;

    setState(() {
      _startup = value;
    });
    http.get(Uri.parse(
        'https://thijsbischoff.nl/smarthome/${widget.ip}/setStartup/$_startup'));
  }

  _getInfo() async {
    final res;
    try {
      res = await http
          .get(
              Uri.parse('https://thijsbischoff.nl/smarthome/${widget.ip}/info'))
          .timeout(const Duration(seconds: 5));
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isOnline = false;
      });
      return;
    }

    Map<String, dynamic> jsonData = jsonDecode(res.body);
    if (jsonData["data"] == null) {
      setState(() {
        _isOnline = false;
      });
      return;
    }
    if (!mounted) return;
    setState(() {
      _switch = jsonData["data"]["switch"];
      _startup = jsonData["data"]["startup"];
      _isOnline = true;
    });
  }

  _setIsExpanded() {
    setState(() {
      _isExpanded = !_isExpanded;
    });
  }

  _deleteDeviceAreYouSure() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: new Text("Verwijder Apparaat"),
          content: new Text(
              "Weet je zeker dat je '${widget.title}' wilt verwijderen"),
          actions: <Widget>[
            new TextButton(
              child: new Text("Annuleer"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            new TextButton(
              child: new Text("Ja"),
              onPressed: () {
                Navigator.of(context).pop();
                _deleteDevice();
              },
            ),
          ],
        );
      },
    );
  }

  _deleteDevice() async {
    final prefs = await SharedPreferences.getInstance();

    final devices = prefs.getStringList('devices') ?? [];
    devices.remove(widget.title);
    prefs.setStringList('devices', devices);

    prefs.remove(widget.title);

    widget.refreshDevices();
  }

  Timer? timer;
  @override
  void initState() {
    super.initState();

    _getInfo();
    const PERIOD = const Duration(seconds: 3);
    timer = new Timer.periodic(PERIOD, (Timer t) => {_getInfo()});
  }

  @override
  void dispose() {
    super.dispose();

    timer!.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.fromLTRB(30, 30, 30, 0),
      padding: EdgeInsets.all(22),
      decoration: BoxDecoration(
        shape: BoxShape.rectangle,
        color: Colors.grey[200],
        borderRadius: BorderRadius.all(Radius.circular(20)),
      ),
      alignment: Alignment.centerLeft,
      child: Column(
        children: [
          _isOnline
              ? Container()
              : Container(
                  margin: EdgeInsets.fromLTRB(15, 0, 0, 10),
                  child: Text(
                    "offline",
                    style: TextStyle(
                      fontStyle: FontStyle.italic,
                      fontSize: 19,
                      color: Colors.grey[700],
                    ),
                  ),
                ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                height: 50.0,
                width: 50.0,
                margin: EdgeInsets.fromLTRB(0, 0, 15, 0),
                child: FittedBox(
                  child: FloatingActionButton(
                    onPressed: _setSwitch,
                    child:
                        Icon(_switch == "on" ? Icons.power : Icons.power_off),
                    backgroundColor: _switch == "on"
                        ? Colors.blue[btnOn]
                        : Colors.blue[btnOff],
                    tooltip: "aan/uit zetten",
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  widget.title,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 22,
                  ),
                ),
              ),
              IconButton(
                icon: Icon(Icons.edit),
                tooltip: "bewerk instellingen",
                onPressed: _setIsExpanded,
              ),
            ],
          ),
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            height: _isExpanded ? 205 : 0,
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Column(
                    children: [
                      Container(
                        padding: EdgeInsets.fromLTRB(0, 25, 0, 20),
                        child: Text(
                          "Opstart staat:",
                          style: TextStyle(
                            fontSize: 18,
                          ),
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Container(
                            height: 50.0,
                            width: 50.0,
                            child: FittedBox(
                              child: FloatingActionButton(
                                onPressed: () => {_setStartup("on")},
                                child: Text(
                                  "aan",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 12,
                                  ),
                                ),
                                backgroundColor: _startup == "on"
                                    ? Colors.blue[btnOn]
                                    : Colors.blue[btnOff],
                                tooltip: "aan",
                              ),
                            ),
                          ),
                          Container(
                            height: 50.0,
                            width: 50.0,
                            child: FittedBox(
                              child: FloatingActionButton(
                                onPressed: () => {_setStartup("stay")},
                                child: Text(
                                  "behoud",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 12,
                                  ),
                                ),
                                backgroundColor: _startup == "stay"
                                    ? Colors.blue[btnOn]
                                    : Colors.blue[btnOff],
                                tooltip: "behoud",
                              ),
                            ),
                          ),
                          Container(
                            height: 50.0,
                            width: 50.0,
                            child: FittedBox(
                              child: FloatingActionButton(
                                onPressed: () => {_setStartup("off")},
                                child: Text(
                                  "uit",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 12,
                                  ),
                                ),
                                backgroundColor: _startup == "off"
                                    ? Colors.blue[btnOn]
                                    : Colors.blue[btnOff],
                                tooltip: "uit",
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Container(
                    margin: EdgeInsets.fromLTRB(0, 20, 0, 0),
                    child: IconButton(
                      iconSize: 40,
                      color: Colors.red[700],
                      onPressed: _deleteDeviceAreYouSure,
                      icon: Icon(Icons.delete),
                      tooltip: "verwijder apparaat",
                    ),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
