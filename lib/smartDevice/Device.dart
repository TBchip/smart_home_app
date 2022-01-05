import 'package:flutter/material.dart';

class Device extends StatefulWidget {
  Device({
    Key? key,
    required this.mac,
    required this.title,
    required this.stats,
    required this.schedule,
    required this.setState,
    required this.setName,
    required this.getSchedules,
    required this.setScheduleLink,
  }) : super(key: key);

  final String mac;
  final String title;
  final dynamic stats;
  final String schedule;
  final Function(String, int) setState;
  final Function(String, String) setName;
  final List<dynamic> Function() getSchedules;
  final Function(String, String) setScheduleLink;

  @override
  _DeviceState createState() => _DeviceState();
}

class _DeviceState extends State<Device> with SingleTickerProviderStateMixin {
  String _title = "";
  dynamic _stats = {};
  String _schedule = "";

  int btnOn = 800;
  int btnOff = 200;

  final nameController = TextEditingController();

  @override
  void initState() {
    super.initState();

    setState(() {
      _title = widget.title;
      _stats = widget.stats;
      _schedule = widget.schedule;
    });

    nameController.text = _title;
  }

  _toggleState() {
    setState(() {
      _stats['switch'] = _stats['switch'] == 'off' ? 'on' : 'off';
    });
    int stateInt = _stats['switch'] == 'off' ? 0 : 1;
    widget.setState(widget.mac, stateInt);
  }

  _editDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: Text("Wijzig apparaat"),
              content: Container(
                child: SingleChildScrollView(
                  child: Column(
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
                                  "Schema:",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                Container(
                                  margin: EdgeInsets.fromLTRB(4, 0, 4, 0),
                                  child: DropdownButton<String>(
                                    value: _schedule,
                                    icon: Icon(Icons.keyboard_arrow_down),
                                    onChanged: (String? newSchedule) {
                                      setState(() {
                                        _schedule = newSchedule!;
                                      });
                                    },
                                    items: [
                                      ...widget.getSchedules().map((schedule) {
                                        return DropdownMenuItem<String>(
                                          value: schedule['uuid'],
                                          child: Text(schedule['name']),
                                        );
                                      }).toList(),
                                      DropdownMenuItem(
                                        value: 'unlinked',
                                        child: Text('Geen Schema'),
                                      )
                                    ],
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
              ),
              actions: <Widget>[
                TextButton(
                  child: Text(
                    "Annuleren",
                    style: TextStyle(color: Colors.red),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                TextButton(
                  child: Text("Opslaan"),
                  onPressed: () {
                    widget.setName(widget.mac, nameController.text);
                    widget.setScheduleLink(widget.mac, _schedule);
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      },
    );
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
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            height: 50.0,
            width: 50.0,
            margin: EdgeInsets.fromLTRB(0, 0, 15, 0),
            child: FittedBox(
              child: FloatingActionButton(
                onPressed: _toggleState,
                child: Icon(_stats['switch'] == "on" ? Icons.power : Icons.power_off),
                backgroundColor: _stats['switch'] == "on" ? Colors.blue[btnOn] : Colors.blue[btnOff],
                tooltip: "aan/uit zetten",
              ),
            ),
          ),
          Expanded(
            child: Text(
              _title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 22,
              ),
            ),
          ),
          IconButton(
            icon: Icon(Icons.edit),
            tooltip: "bewerk instellingen",
            onPressed: _editDialog,
            iconSize: 25,
          ),
        ],
      ),
    );
  }
}
