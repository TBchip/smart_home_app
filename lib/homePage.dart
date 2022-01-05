import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:smart_home_app/smartDevice/DevicesList.dart';
import 'package:smart_home_app/schedule/ScheduleList.dart';

class HomePage extends StatefulWidget {
  HomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Map<String, dynamic> _devices = {};
  List<dynamic> _schedules = [];

  var _serverUrl = '[2a02:a442:20ef:1:b8ed:6c1b:2e11:f8e9]:51310';

  var _loading = true;

  int _pageIdx = 0;

  @override
  void initState() {
    super.initState();

    _loading = true;
    _refreshAll();
  }

  _refreshAll() async {
    await _refreshDevices();
    await _refreshSchedules();
    _loading = false;
  }

  _refreshDevices() async {
    var response = await http.get(
      Uri.http(_serverUrl, '/device/getall'),
    );

    setState(() {
      _devices = jsonDecode(response.body);
    });
  }

  _refreshSchedules() async {
    var response = await http.get(
      Uri.http(_serverUrl, '/schedule/getall'),
    );

    setState(() {
      _schedules = jsonDecode(response.body);
    });
  }

  Map<String, dynamic> _getDevices() {
    return _devices;
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
    return _serverUrl;
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
        title: Text(
          widget.title,
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
          ),
          softWrap: false,
        ),
        backgroundColor: Colors.blue,
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: ListView(
          children: [
            Center(
              child: _loading
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
                        getSchedules: _getSchedules,
                        key: ObjectKey({_devices, _schedules}),
                      ),
                      ScheduleList(
                        getServerUrl: _getServerUrl,
                        getSchedules: _getSchedules,
                        setSchedules: _setSchedules,
                        key: ObjectKey({_schedules}),
                      ),
                    ].elementAt(_pageIdx),
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
