import 'package:flutter/material.dart';
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
  bool _state = true;

  _onStateChange() {
    setState(() {
      _state = !_state;
    });
  }

  _getInfo() {}

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
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            widget.title,
            style: TextStyle(
              fontSize: 20,
            ),
          ),
          FloatingActionButton(
            onPressed: _onStateChange,
            child: Icon(_state ? Icons.lightbulb : Icons.lightbulb_outline),
            backgroundColor: Colors.blue,
          )
        ],
      ),
    );
  }
}
