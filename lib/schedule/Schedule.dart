import 'package:flutter/material.dart';

class Schedule extends StatefulWidget {
  Schedule({
    Key? key,
    required this.uuid,
    required this.title,
    required this.onRules,
    required this.offRules,
    required this.scheduleObject,
    required this.saveSchedule,
    required this.deleteSchedule,
  }) : super(key: key);

  final String uuid;
  final String title;
  final List<dynamic> onRules;
  final List<dynamic> offRules;
  final dynamic scheduleObject;
  final Function(dynamic) saveSchedule;
  final Function(String) deleteSchedule;

  @override
  _ScheduleState createState() => _ScheduleState();
}

class _ScheduleState extends State<Schedule> {
  String _title = '';
  List<dynamic> _onRules = [];
  List<dynamic> _offRules = [];
  dynamic _scheduleObject = {};

  bool _expanded = false;

  static const Map<String, String> daysMap = {
    '0': 'Zondag',
    '1': 'Maandag',
    '2': 'Dinsdag',
    '3': 'Woensdag',
    '4': 'Donderdag',
    '5': 'Vrijdag',
    '6': 'Zaterdag'
  };

  @override
  void initState() {
    super.initState();

    setState(() {
      _title = widget.title;
      _onRules = widget.onRules;
      _offRules = widget.offRules;
      _scheduleObject = widget.scheduleObject;
    });
  }

  _toggleEdit() {
    setState(() {
      _expanded = !_expanded;
    });
  }

  _deleteRulePopUp(int ruleType, int ruleIdx) {
    String ruleString = '';
    if (ruleType == 0) {
      ruleString = _getTimeString(_onRules[ruleIdx]);
    } else if (ruleType == 1) {
      ruleString = _getTimeString(_offRules[ruleIdx]);
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Verwijder Regel'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Weet je zeker dat je de volgende regel wilt verwijderen:'),
                Text(''),
                Text('Type:\n ' + (ruleType == 0 ? 'Aan' : 'Uit')),
                Text(''),
                Text('Regel:\n ' + ruleString),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Annuleer'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text(
                'Verwijder',
                style: TextStyle(color: Colors.red),
              ),
              onPressed: () {
                Navigator.of(context).pop();
                _deleteRule(ruleType, ruleIdx);
              },
            ),
          ],
        );
      },
    );
  }

  _addRulePopUp() {
    String _ruleType = 'on';
    List<String> _newRule = ['00', '00', '0'];

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: Text('Regel Toevoegen'),
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
                                'Type:',
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
                                  value: _ruleType,
                                  icon: Icon(Icons.keyboard_arrow_down),
                                  onChanged: (String? newRuleType) {
                                    setState(() {
                                      _ruleType = newRuleType!;
                                    });
                                  },
                                  items: [
                                    DropdownMenuItem<String>(
                                      value: 'on',
                                      child: Text('Aan'),
                                    ),
                                    DropdownMenuItem<String>(
                                      value: 'off',
                                      child: Text('Uit'),
                                    ),
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
                      margin: EdgeInsets.fromLTRB(6, 0, 6, 6),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                'Dag:',
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
                                  value: _newRule[2],
                                  icon: Icon(Icons.keyboard_arrow_down),
                                  onChanged: (String? newDay) {
                                    setState(() {
                                      _newRule[2] = newDay!;
                                    });
                                  },
                                  items: [
                                    for (var day in daysMap.entries)
                                      DropdownMenuItem<String>(
                                        value: day.key,
                                        child: Text(day.value),
                                      ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.fromLTRB(6, 0, 6, 6),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                'Uur:',
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
                                  value: _newRule[1],
                                  icon: Icon(Icons.keyboard_arrow_down),
                                  onChanged: (String? newHour) {
                                    setState(() {
                                      _newRule[1] = newHour!;
                                    });
                                  },
                                  items: [
                                    for (var i = 0; i < 24; i++)
                                      DropdownMenuItem<String>(
                                        value: i < 10 ? '0' + i.toString() : i.toString(),
                                        child: Text(i.toString()),
                                      ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
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
                                'Minuut:',
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
                                  value: _newRule[0],
                                  icon: Icon(Icons.keyboard_arrow_down),
                                  onChanged: (String? newMinute) {
                                    setState(() {
                                      _newRule[0] = newMinute!;
                                    });
                                  },
                                  items: [
                                    for (var i = 0; i < 60; i++)
                                      DropdownMenuItem<String>(
                                        value: i < 10 ? '0' + i.toString() : i.toString(),
                                        child: Text(i.toString()),
                                      ),
                                  ],
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
                    _addRule(_ruleType, _newRule.join(' '));
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  _deleteSchedulePopUp() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Verwijder Schema'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Weet je zeker dat je \'' + _title + '\' wilt verwijderen'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Annuleer'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text(
                'Verwijder',
                style: TextStyle(color: Colors.red),
              ),
              onPressed: () {
                Navigator.of(context).pop();
                _deleteSchedule();
              },
            ),
          ],
        );
      },
    );
  }

  _deleteRule(int ruleType, int ruleIdx) {
    if (ruleType == 0) {
      setState(() {
        _scheduleObject['on'].remove(_onRules[ruleIdx]);
      });
    } else if (ruleType == 1) {
      setState(() {
        _scheduleObject['off'].remove(_offRules[ruleIdx]);
      });
    }
  }

  _addRule(String ruleType, String rule) {
    setState(() {
      _scheduleObject[ruleType].add(rule);
    });
  }

  _deleteSchedule() {
    widget.deleteSchedule(widget.uuid);
  }

  String _getTimeString(String rule) {
    List<String> ruleList = rule.split(' ');
    return daysMap[ruleList[2]]! + ' - ' + ruleList[1] + ':' + ruleList[0];
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
                tooltip: 'Bewerk schema',
                onPressed: _toggleEdit,
                iconSize: 25,
              ),
              IconButton(
                icon: Icon(Icons.delete),
                tooltip: 'Verwijder schema',
                onPressed: _deleteSchedulePopUp,
                color: Colors.red,
                iconSize: 25,
              ),
            ],
          ),
          AnimatedCrossFade(
            crossFadeState: _expanded ? CrossFadeState.showFirst : CrossFadeState.showSecond,
            duration: Duration(milliseconds: 500),
            sizeCurve: Curves.easeInOut,
            secondChild: Container(),
            firstChild: SingleChildScrollView(
              child: Container(
                margin: EdgeInsets.fromLTRB(10, 10, 10, 10),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: EdgeInsets.fromLTRB(0, 0, 0, 15),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          TextButton.icon(
                            icon: Icon(Icons.add, size: 22),
                            label: Text(
                              'Regel Toevoegen',
                              style: TextStyle(fontSize: 18),
                            ),
                            onPressed: () {
                              _addRulePopUp();
                            },
                          )
                        ],
                      ),
                    ),
                    Column(
                      children: [
                        Row(
                          children: [
                            Text(
                              'Aan regels:',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 20,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          margin: EdgeInsets.fromLTRB(0, 10, 5, 20),
                          child: _onRules.length == 0
                              ? Container(
                                  child: Text(
                                    'Nog geen aan regels toegevoegd',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                )
                              : Column(
                                  children: [
                                    for (var i = 0; i < _onRules.length; i++)
                                      Row(
                                        children: [
                                          IconButton(
                                            onPressed: () {
                                              _deleteRulePopUp(0, i);
                                            },
                                            tooltip: 'Verwijder regel',
                                            icon: Icon(Icons.delete),
                                            color: Colors.red,
                                            padding: EdgeInsets.only(right: 20),
                                          ),
                                          Text(
                                            _getTimeString(_onRules[i]),
                                            style: TextStyle(
                                              fontSize: 18,
                                            ),
                                          ),
                                        ],
                                      ),
                                  ],
                                ),
                        ),
                        Row(
                          children: [
                            Text(
                              'Uit regels:',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 20,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          margin: EdgeInsets.fromLTRB(0, 10, 5, 20),
                          child: _offRules.length == 0
                              ? Container(
                                  child: Text(
                                    'Nog geen uit regels toegevoegd',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                )
                              : Column(
                                  children: [
                                    for (var i = 0; i < _offRules.length; i++)
                                      Row(
                                        children: [
                                          IconButton(
                                            onPressed: () {
                                              _deleteRulePopUp(1, i);
                                            },
                                            tooltip: 'Verwijder regel',
                                            icon: Icon(Icons.delete),
                                            color: Colors.red,
                                            padding: EdgeInsets.only(right: 20),
                                          ),
                                          Text(
                                            _getTimeString(_offRules[i]),
                                            style: TextStyle(
                                              fontSize: 18,
                                            ),
                                          ),
                                        ],
                                      ),
                                  ],
                                ),
                        ),
                      ],
                    ),
                    Container(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          TextButton(
                            child: Text(
                              'Annuleren',
                              style: TextStyle(
                                color: Colors.red,
                                fontSize: 16,
                              ),
                            ),
                            onPressed: () {
                              _toggleEdit();
                            },
                          ),
                          TextButton(
                            child: Text(
                              'Opslaan',
                              style: TextStyle(
                                fontSize: 16,
                              ),
                            ),
                            onPressed: () async {
                              _toggleEdit();
                              await Future.delayed(Duration(milliseconds: 500)); // wait for container to close
                              widget.saveSchedule(_scheduleObject);
                            },
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
