import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:smart_home_app/smartDevice/Device.dart';

class DevicesList extends StatefulWidget {
  DevicesList({
    Key? key,
    required this.getServerUrl,
    required this.getDevices,
    required this.getSchedules,
  }) : super(key: key);

  final String Function() getServerUrl;
  final Map<String, dynamic> Function() getDevices;
  final List<dynamic> Function() getSchedules;

  @override
  _DevicesListState createState() => _DevicesListState();
}

class _DevicesListState extends State<DevicesList> {
  _setState(String mac, int state) async {
    Map<String, String> headers = {
      'Content-Type': 'application/json',
    };
    Map<String, dynamic> body = {
      'mac': mac,
      'state': state,
    };

    var response = await http.post(
      Uri.http(widget.getServerUrl(), '/device/state'),
      headers: headers,
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      setState(() {
        widget.getDevices()[mac] = jsonDecode(response.body);
      });
    }
  }

  _setName(String mac, String newName) async {
    Map<String, String> headers = {
      'Content-Type': 'application/json',
    };
    Map<String, dynamic> body = {
      'mac': mac,
      'name': newName,
    };

    var response = await http.post(
      Uri.http(widget.getServerUrl(), '/device/name'),
      headers: headers,
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      setState(() {
        widget.getDevices()[mac] = jsonDecode(response.body);
      });
    }
  }

  _setScheduleLink(String mac, String scheduleUuid) async {
    Map<String, String> headers = {
      'Content-Type': 'application/json',
    };
    Map<String, dynamic> body = {
      'mac': mac,
      'uuid': scheduleUuid,
    };

    String url = '/schedule';
    if (scheduleUuid != 'unlinked')
      url += '/link';
    else
      url += '/unlink';

    var response = await http.post(
      Uri.http(widget.getServerUrl(), url),
      headers: headers,
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      setState(() {
        widget.getDevices()[mac]['schedule'] = response.body;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return (widget.getDevices().isEmpty)
        ? Container(
            margin: EdgeInsets.only(top: 70),
            child: Text(
              'Geen apparaten gevonden op netwerk',
              style: TextStyle(
                fontSize: 18,
              ),
            ),
          )
        : Container(
            margin: EdgeInsets.only(bottom: 30),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                ...widget.getDevices().entries.map((device) {
                  return Device(
                    mac: device.key,
                    title: device.value['name'],
                    stats: device.value['stats'],
                    schedule: device.value['schedule'],
                    setState: _setState,
                    setName: _setName,
                    getSchedules: widget.getSchedules,
                    setScheduleLink: _setScheduleLink,
                    key: ObjectKey(
                      {
                        device.value['stats']['switch'],
                        device.value['schedule'],
                      },
                    ),
                  );
                }).toList(),
              ],
            ),
          );
  }
}
