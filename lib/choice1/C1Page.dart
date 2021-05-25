import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

import 'LatencyData.dart';


class C1Page extends StatefulWidget {
  C1Page({Key? key}) : super(key: key);

  final String title = "Choice 1: Monitor Network Latency";

  @override
  _C1ageState createState() => _C1ageState();
}

class _C1ageState extends State<C1Page> {
  late LatencyData _latencyData;
  late Timer _timer;
  ValueNotifier<int> _recordNum = ValueNotifier<int>(0);
  ValueNotifier<double> _avgLatency = ValueNotifier<double>(0);

  @override
  void initState() {
    super.initState();

    _getAvgLatency();

    _latencyData = LatencyData();

    // Start a timer to constantly update latency data
    _timer = Timer.periodic(Duration(seconds: 2), (timer) {
      var startTime = DateTime.now(); // Start timing
      Dio().get('https://www.amazon.com').then((response) {
        var deltaTime = DateTime.now().difference(startTime);
        _latencyData.append(deltaTime);
      }).onError((error, stackTrace) {
        var deltaTime = DateTime.now().difference(startTime);
        _latencyData.append(deltaTime);
      });
      _recordNum.value += 1;
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    _recordNum.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Image.asset("assets/images/aws_logo.jpeg"),
        title: Text(widget.title),
        actions: [
          Container(
            width: 100,
            child: Center(
              child: Text("Pan Yitao", style: TextStyle(fontSize: 16),),
            ),
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(height: 20,),
            Text('Current latency to amazom.com:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Container(height: 20,),
            ValueListenableBuilder(
                valueListenable: _recordNum,
                builder: _buildLatencyData
            ),

            Container(height: 20,),
            _buildSaveButton(),
            Text("Average of saved latency data:",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Container(height: 5,),
            ValueListenableBuilder(
                valueListenable: _avgLatency,
                builder: _buildAvgLatency
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSaveButton() {
    return CupertinoButton(
        child: Text("Save"),
        onPressed: _onSavePressed
    );
  }

  Widget _buildLatencyData(BuildContext context, int num, Widget? child) {
    List<Widget> children = [];
    _latencyData.latencyQueue.forEach((item) {
      children.add(
          Row(
            children: [
              Container(
                width: 180,
                child: Text(item.time.toString().substring(0, 19)),
              ),
              Container(
                width: 60,
                child: Text(item.latency.inMilliseconds.toString() + " ms"),
              ),
            ],
          )
      );
    });
    return Container(
      width: 240,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: children,
      ),
    );
  }

  Widget _buildAvgLatency(BuildContext context, double avg, Widget? child) {
    return Text(avg.toStringAsFixed(2) + " ms");
  }

  void _onSavePressed() {
    if (_latencyData.isFull()) {
      _saveLatency(_latencyData);
    } else {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return new AlertDialog(
            content: Text('Wait till there are three items before save'),
            actions: <Widget>[
              CupertinoButton(
                child: Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }
  }

  void _getAvgLatency() {
    String url = "https://f5edewul3j.execute-api.us-west-2.amazonaws.com/dev";
    Dio().get(url).then((response) {
      _avgLatency.value = response.data["body"];
    });
  }

  void _saveLatency(LatencyData latencyData) {
    String url = "https://f5edewul3j.execute-api.us-west-2.amazonaws.com/dev";
    _latencyData.latencyQueue.forEach((item) {
      Dio().post(url, data: {
        "time": item.time.toString(),
        "latency": item.latency.inMilliseconds
      }).then((value) => _getAvgLatency());
    });
  }

  void _incrementCounter() async {
    // POST
    // String apiUrl = "https://7ff9a63nw5.execute-api.us-west-2.amazonaws.com/dev/";
    // Dio().post(apiUrl, data: {"firstName": "flutterFirst", "lastName": "flutterLast"});

    var startTime = DateTime.now(); // Start timing
    Dio().get('https://www.amazon.com').then((response) {
      var deltaTime = DateTime.now().difference(startTime);
      print(deltaTime.inMilliseconds);
      // setState(() { text = response.toString(); });
    }).onError((error, stackTrace) {
      var deltaTime = DateTime.now().difference(startTime);
      print(deltaTime.inMilliseconds);
      // setState(() { text = deltaTime.toString(); });
    });
  }
}
