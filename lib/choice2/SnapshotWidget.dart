import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'dart:async';

import 'package:flutter/material.dart';

class SnapshotWidget extends StatefulWidget {
  var responseData;

  SnapshotWidget(this.responseData);

  @override
  _SnapshotWidgetState createState() => _SnapshotWidgetState();
}

class _SnapshotWidgetState extends State<SnapshotWidget> {
  Color awsThemeColor = Color(0xFF252F3D);
  String checkSnapshotAPIURL = "https://x9idg4gkdh.execute-api.us-west-2.amazonaws.com/dev";
  late Timer _timer;

  // region Initializing volume data
  late String _availabilityZone;
  late String _createTime;
  late int _size;
  late String _volumeState;
  late String _volumeId;
  // endregion
  // region Initializing snapshot data
  late String _snapshotId;
  late String _startTime;
  late String _snapshotState;
  late String _progress;
  // endregion

  @override
  void initState() {
    super.initState();

    // region Obtaining initial volume and snapshot data
    _availabilityZone = widget.responseData["volume"]["AvailabilityZone"];
    _createTime = widget.responseData["volume"]["CreateTime"];
    _size = widget.responseData["volume"]["Size"];
    _volumeState = widget.responseData["volume"]["State"];
    _volumeId = widget.responseData["volume"]["VolumeId"];
    _snapshotId = widget.responseData["snapshot"]["SnapshotId"];
    _startTime = widget.responseData["snapshot"]["StartTime"];
    _snapshotState = widget.responseData["snapshot"]["State"];
    _progress = "0%";
    // endregion

    // Start a timer to constantly update snapshot data
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      Dio().post(checkSnapshotAPIURL, data: {
        "snapshot_id": _snapshotId,
      }).then((response) {
        String newSnapshotState = jsonDecode(response.data["body"])["state"];
        String newProgress = jsonDecode(response.data["body"])["progress"];
        setState(() {
          _snapshotState = newSnapshotState;
          _progress = newProgress;
        });
        if (newSnapshotState == "completed" && newProgress == "100%") {
          _timer.cancel();
        }
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10),
      child: Container(
        decoration: (_progress == "100%" && _snapshotState == "completed") ?
        BoxDecoration(color: Colors.green[50],) :
        BoxDecoration(color: Colors.grey[100],),
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 5),
          child: Column(
            children: [
              _buildSnapshotInfo(),
              Container(height: 20,),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildSnapshotStatus(),
                  _buildVolumeData(),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSnapshotInfo() {
    return Column(
      children: [
        Text(
          "SnapshotID: " + _snapshotId,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        Text(
          "Start Time: " + _startTime,
          style: TextStyle(fontWeight: FontWeight.bold),
        )
      ],
    );
  }

  Widget _buildSnapshotStatus() {
    return Container(
      constraints: BoxConstraints(),
      child: Column(
        children: [
          Text("State:", style: TextStyle(fontWeight: FontWeight.bold),),
          Text(_snapshotState),
          Container(height: 5,),
          Text("Progress:", style: TextStyle(fontWeight: FontWeight.bold),),
          Text(_progress)
        ],
      ),
    );
  }
  
  Widget _buildVolumeData() {
    return Container(
      constraints: BoxConstraints(maxWidth: 400),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Volume ID: " + _volumeId),
          Text("Volume State: " + _volumeState),
          Text("Availability Zone: " + _availabilityZone),
          Text("Create Time: " + _createTime),
          Text("Size: " + _size.toString()),
        ],
      ),
    );
  }

}