import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_home_app/smartDevice/serverManaged/smartDeviceServerManagedPage.dart';
import 'package:smart_home_app/smartDevice/standalone/smartDeviceStandalonePage.dart';

class HomePage extends StatefulWidget {
  HomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _adminModeCounter = 0;
  bool _adminMode = false;

  bool _serverManaged = false;
  List<bool> _adminModeSelections = List.generate(1, (_) => false);

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

  _confirmModeSelection() async {
    setState(() {
      _adminMode = false;
      _adminModeCounter = 0;
      _serverManaged = _adminModeSelections[0];
    });

    final prefs = await SharedPreferences.getInstance();
    prefs.setBool('serverManaged', _serverManaged);
  }

  _loadServerManaged() async {
    final prefs = await SharedPreferences.getInstance();

    var target = prefs.getBool('serverManaged');
    setState(() {
      _serverManaged = target == null ? false : target;
    });
  }

  Timer? adminModeUpdateTimer;
  @override
  void initState() {
    super.initState();

    _loadServerManaged();

    const PERIOD = const Duration(seconds: 1);
    adminModeUpdateTimer =
        new Timer.periodic(PERIOD, (Timer t) => {_decreaseAdminModeCounter()});
  }

  @override
  void dispose() {
    super.dispose();

    adminModeUpdateTimer!.cancel();
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
          _adminMode
              ? Container(
                  margin: EdgeInsets.all(8),
                  child: Row(
                    children: [
                      ToggleButtons(
                        borderRadius: BorderRadius.circular(20),
                        fillColor: Colors.blue[700],
                        color: Colors.black,
                        selectedColor: Colors.black,
                        isSelected: _adminModeSelections,
                        children: [
                          Icon(Icons.groups),
                        ],
                        onPressed: (int index) {
                          setState(() {
                            _adminModeSelections[index] =
                                !_adminModeSelections[index];
                          });
                        },
                      ),
                      TextButton(
                        onPressed: _confirmModeSelection,
                        child: Icon(
                          Icons.check,
                          color: Colors.black,
                        ),
                      )
                    ],
                  ),
                )
              : Container(),
        ],
      ),
      body: _serverManaged
          ? SmartDeviceServerManagedPage()
          : SmartDeviceStandalonePage(),
    );
  }
}
