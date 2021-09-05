import 'package:flutter/material.dart';
import 'smartDevice.dart';

class HomePage extends StatefulWidget {
  HomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: Colors.blue,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            SmartDevice(title: 'stekkerdoos', ip: "192.168.2.17"),
            //SmartDevice(title: 'lamp schuur', ip: "192.168.2.17"),
            //SmartDevice(title: 'lamp woonkamer', ip: "192.168.2.17"),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => {},
        tooltip: 'Increment',
        child: Icon(Icons.add),
        backgroundColor: Colors.blue,
      ),
    );
  }
}
