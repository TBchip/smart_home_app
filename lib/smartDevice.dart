import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

class SmartDevice extends StatefulWidget {
  SmartDevice({Key? key, required this.title, required this.ip})
      : super(key: key);

  final String title;
  final String ip;

  @override
  _SmartDeviceState createState() => _SmartDeviceState();
}

class _SmartDeviceState extends State<SmartDevice> {
  String _switch = "off";
  String _startup = "on";

  int btnOn = 800;
  int btnOff = 200;

  bool _isExpanded = false;

  _setSwitch() {
    setState(() {
      _switch = _switch == "on" ? "off" : "on";
    });
    http.get(Uri.parse(
        'https://thijsbischoff.nl/smarthome/${widget.ip}/setstate/$_switch'));
  }

  _setStartup(String value) {
    setState(() {
      _startup = value;
    });
    http.get(Uri.parse(
        'https://thijsbischoff.nl/smarthome/${widget.ip}/setStartup/$_startup'));
  }

  _getInfo() async {
    final res = await http
        .get(Uri.parse('https://thijsbischoff.nl/smarthome/${widget.ip}/info'));

    Map<String, dynamic> jsonData = jsonDecode(res.body);
    setState(() {
      _switch = jsonData["data"]["switch"];
      _startup = jsonData["data"]["startup"];
    });
  }

  _setIsExpanded() {
    setState(() {
      _isExpanded = !_isExpanded;
    });
  }

  Timer? timer;
  @override
  void initState() {
    super.initState();

    _getInfo();
    const PERIOD = const Duration(seconds: 3);
    new Timer.periodic(PERIOD, (Timer t) => {_getInfo()});
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                height: 50.0,
                width: 50.0,
                child: FittedBox(
                  child: FloatingActionButton(
                    onPressed: _setSwitch,
                    child:
                        Icon(_switch == "on" ? Icons.power : Icons.power_off),
                    backgroundColor: _switch == "on"
                        ? Colors.blue[btnOn]
                        : Colors.blue[btnOff],
                    tooltip: "turn on/off",
                  ),
                ),
              ),
              Text(
                widget.title,
                style: TextStyle(
                  fontSize: 22,
                ),
              ),
              IconButton(
                icon: Icon(Icons.edit),
                tooltip: "edit settings",
                onPressed: _setIsExpanded,
              ),
            ],
          ),
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            height: _isExpanded ? 150 : 0,
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Column(
                    children: [
                      Container(
                        padding: EdgeInsets.fromLTRB(0, 25, 0, 20),
                        child: Text(
                          "Startup state:",
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
                                  "On",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 12,
                                  ),
                                ),
                                backgroundColor: _startup == "on"
                                    ? Colors.blue[btnOn]
                                    : Colors.blue[btnOff],
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
                                  "Stay",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 12,
                                  ),
                                ),
                                backgroundColor: _startup == "stay"
                                    ? Colors.blue[btnOn]
                                    : Colors.blue[btnOff],
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
                                  "Off",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 12,
                                  ),
                                ),
                                backgroundColor: _startup == "off"
                                    ? Colors.blue[btnOn]
                                    : Colors.blue[btnOff],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
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
