import 'dart:async';
import 'dart:convert';

import 'package:aws_interview_proj/choice2/SnapshotWidget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

class C2Page extends StatefulWidget {
  C2Page({Key? key}) : super(key: key);

  final String title = "Choice 2: EC2 Snapshot";

  @override
  _C2PageState createState() => _C2PageState();
}

class _C2PageState extends State<C2Page> {
  String createSnapshotAPIURL = "https://irmgqxbfaa.execute-api.us-west-2.amazonaws.com/dev";
  bool _callingAPI = false;
  ValueNotifier<int> _snapshotNum = ValueNotifier<int>(0);
  List<Widget> _snapshotWidgets = [];

  @override
  void initState() {
    super.initState();

    _snapshotNum.value = 0;
  }

  @override
  void dispose() {
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
        child: Center(
          child: Container(
            constraints: BoxConstraints(maxWidth: 600),
            child: Column(
              children: [
                _buildCreateButton(),
                ValueListenableBuilder(
                    valueListenable: _snapshotNum,
                    builder: (context, num, child) {
                      return Column(children: _snapshotWidgets,);
                    }
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCreateButton() {
    return CupertinoButton(
      child: _callingAPI ? Text("Creating...") : Text("Create Snapshot"),
      onPressed: _callingAPI ? null : _onCreateButtonPressed,
    );
  }

  void _onCreateButtonPressed() {
    setState(() { _callingAPI = true; });
    Dio().get(createSnapshotAPIURL).then((response) {
      jsonDecode(response.data["body"]).forEach((snapshotItem){
        _snapshotNum.value += 1;
        _snapshotWidgets.add(SnapshotWidget(snapshotItem));
      });
      setState(() { _callingAPI = false; });
    }).onError((error, stackTrace) {
      String retryError = "Expected a value of type 'String', but got one of type 'Null'";
      if (error.toString() == retryError) {
        print("Retry");
        _onCreateButtonPressed();
      } else {
        print("===== C2 API called Error =====");
        print(error);
        setState(() { _callingAPI = false; });
      }
    });
  }
}
