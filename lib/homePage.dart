import 'dart:convert';
import 'dart:math';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'package:smart_home_app/smartDevice/DevicesList.dart';
import 'package:smart_home_app/schedule/ScheduleList.dart';

class HomePage extends StatefulWidget {
  HomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _adminModeCounter = 0;
  bool _adminMode = false;

  Map<String, dynamic> _devices = {};
  List<dynamic> _schedules = [];
//2a02:a442:20ef:1:6af7:128d:25e2:f885
  late String _serverIp = '';
  final serverIpController = TextEditingController();

  var _loading = true;

  int _pageIdx = 0;

  Timer? adminModeUpdateTimer;
  @override
  void initState() {
    super.initState();

    initApp();
  }

  initApp() async {
    _loading = true;

    await _getServerIp();
    serverIpController.text = _serverIp;

    await _refreshAll();

    const PERIOD = const Duration(seconds: 1);
    adminModeUpdateTimer = new Timer.periodic(PERIOD, (Timer t) => {_decreaseAdminModeCounter()});

    _loading = false;
  }

  _increaseAdminModeCounter() {
    setState(() {
      _adminModeCounter = min(20, _adminModeCounter + 1);
    });
  }

  _decreaseAdminModeCounter() {
    setState(() {
      _adminModeCounter = max(0, _adminModeCounter - 1);
    });
  }

  _updateAdminMode() {
    _increaseAdminModeCounter();
    if (_adminModeCounter == 20) {
      setState(() {
        _adminMode = true;
      });
    }
  }

  _getServerIp() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _serverIp = prefs.getString('serverIp') ?? '';
    });
  }

  _updateServerIp() async {
    _serverIp = serverIpController.text;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('serverIp', _serverIp);
  }

  _refreshAll() async {
    // if server ip is invalid gives error
    try {
      await _refreshDevices();
      await _refreshSchedules();
    } catch (e) {
      print(e);
    }
  }

  _refreshDevices() async {
    var response = await http.get(
      Uri.http(_getServerUrl(), '/device/getall'),
    );

    setState(() {
      _devices = jsonDecode(response.body);
    });
  }

  _refreshSchedules() async {
    var response = await http.get(
      Uri.http(_getServerUrl(), '/schedule/getall'),
    );

    setState(() {
      _schedules = jsonDecode(response.body);
    });
  }

  Map<String, dynamic> _getDevices() {
    return _devices;
  }

  _setDevice(String mac, dynamic device) {
    setState(() {
      _devices[mac] = device;
    });
  }

  List<dynamic> _getSchedules() {
    return _schedules;
  }

  _setSchedules(dynamic schedules) {
    setState(() {
      _schedules = schedules;
    });
  }

  String _getServerUrl() {
    return '[' + _serverIp + ']:51310';
  }

  _changePage(int newIdx) {
    setState(() {
      _pageIdx = newIdx;
    });
  }

  Future<void> _refresh() async {
    await _refreshAll();
    return Future.delayed(Duration(seconds: 0));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextButton(
          onPressed: _updateAdminMode,
          child: Text(
            widget.title,
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
            ),
            softWrap: false,
          ),
        ),
        backgroundColor: Colors.blue,
        actions: [
          if (_adminMode)
            TextButton(
              onPressed: () async {
                setState(() {
                  _adminMode = false;
                });
                await _updateServerIp();
                await _refreshAll();
              },
              child: Icon(
                Icons.check,
                color: Colors.black,
              ),
            ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: ListView(
          children: [
            Center(
              child: Column(
                children: [
                  if (_adminMode)
                    Column(
                      children: [
                        Container(
                          margin: EdgeInsets.fromLTRB(50, 30, 50, 30),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    "Server ip adress:",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Flexible(
                                    child: Container(
                                      margin: EdgeInsets.fromLTRB(6, 0, 6, 0),
                                      child: TextField(
                                        controller: serverIpController,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Divider(
                          height: 40,
                          thickness: 1,
                          indent: 0,
                          endIndent: 0,
                          color: Colors.grey,
                        ),
                      ],
                    ),
                  (_serverIp != '')
                      ? _loading
                          ? Container(
                              margin: EdgeInsets.only(top: 70),
                              child: Text(
                                'Laden...',
                                style: TextStyle(
                                  fontSize: 18,
                                ),
                              ),
                            )
                          : <Widget>[
                              DevicesList(
                                getServerUrl: _getServerUrl,
                                getDevices: _getDevices,
                                setDevice: _setDevice,
                                getSchedules: _getSchedules,
                                key: ObjectKey({_devices, _schedules}),
                              ),
                              ScheduleList(
                                getServerUrl: _getServerUrl,
                                getSchedules: _getSchedules,
                                setSchedules: _setSchedules,
                                key: ObjectKey({_schedules}),
                              ),
                            ].elementAt(_pageIdx)
                      : Container(
                          margin: EdgeInsets.only(top: 70),
                          child: Text(
                            'Geen server IP',
                            style: TextStyle(
                              fontSize: 18,
                            ),
                          ),
                        ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.device_hub),
            label: 'Apparaten',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.access_time),
            label: 'Schemas',
          ),
        ],
        currentIndex: _pageIdx,
        onTap: _changePage,
      ),
    );
  }
}
