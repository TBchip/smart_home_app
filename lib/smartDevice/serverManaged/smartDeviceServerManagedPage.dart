import 'package:flutter/material.dart';

class SmartDeviceServerManagedPage extends StatefulWidget {
  SmartDeviceServerManagedPage({Key? key}) : super(key: key);

  final _SmartDeviceServerManagedPageState smartDeviceStandaloneListState =
      new _SmartDeviceServerManagedPageState();

  @override
  _SmartDeviceServerManagedPageState createState() =>
      smartDeviceStandaloneListState;
}

class _SmartDeviceServerManagedPageState
    extends State<SmartDeviceServerManagedPage> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Center(
        child: Text("Under construction..."),
      ),
    );
  }
}
