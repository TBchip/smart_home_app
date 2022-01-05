import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:smart_home_app/schedule/Schedule.dart';

class ScheduleList extends StatefulWidget {
  ScheduleList({
    Key? key,
    required this.getServerUrl,
    required this.getSchedules,
    required this.setSchedules,
  }) : super(key: key);

  final String Function() getServerUrl;
  final List<dynamic> Function() getSchedules;
  final Function(dynamic) setSchedules;

  @override
  _ScheduleListState createState() => _ScheduleListState();
}

class _ScheduleListState extends State<ScheduleList> {
  _setSchedule(dynamic schedule) async {
    Map<String, String> headers = {
      'Content-Type': 'application/json',
    };
    Map<String, dynamic> body = {
      'schedule': schedule,
    };

    var response = await http.post(
      Uri.http(widget.getServerUrl(), '/schedule/save'),
      headers: headers,
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      setState(() {
        widget.setSchedules(jsonDecode(response.body));
      });
    }
  }

  _deleteSchedule(String uuid) async {
    Map<String, String> headers = {
      'Content-Type': 'application/json',
    };
    Map<String, dynamic> body = {
      'uuid': uuid,
    };

    var response = await http.post(
      Uri.http(widget.getServerUrl(), '/schedule/delete'),
      headers: headers,
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      setState(() {
        widget.setSchedules(jsonDecode(response.body));
      });
    }
  }

  _createSchedulePopUp() {
    final nameController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: Text('Schema Toevoegen'),
              content: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: EdgeInsets.fromLTRB(6, 0, 6, 0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                "Naam:",
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
                                  margin: EdgeInsets.fromLTRB(4, 0, 4, 0),
                                  child: TextField(
                                    controller: nameController,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: Text(
                    'Annuleer',
                    style: TextStyle(color: Colors.red),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                TextButton(
                  child: Text(
                    'Toevoegen',
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                    _createSchedule(nameController.text);
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  _createSchedule(String name) async {
    Map<String, String> headers = {
      'Content-Type': 'application/json',
    };
    Map<String, dynamic> body = {
      'schedule': {
        'name': name,
        'on': [],
        'off': [],
      },
    };

    var response = await http.post(
      Uri.http(widget.getServerUrl(), '/schedule/save'),
      headers: headers,
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      setState(() {
        widget.setSchedules(jsonDecode(response.body));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        (widget.getSchedules().isEmpty)
            ? Container(
                margin: EdgeInsets.fromLTRB(0, 70, 0, 60),
                child: Text(
                  'Geen schemas gevonden',
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
                    for (dynamic schedule in widget.getSchedules())
                      Schedule(
                        uuid: schedule['uuid'],
                        title: schedule['name'],
                        onRules: schedule['on'],
                        offRules: schedule['off'],
                        scheduleObject: schedule,
                        saveSchedule: _setSchedule,
                        deleteSchedule: _deleteSchedule,
                      ),
                  ],
                ),
              ),
        FloatingActionButton(
          onPressed: () {
            _createSchedulePopUp();
          },
          child: Icon(
            Icons.add,
            size: 32,
          ),
        ),
      ],
    );
  }
}
