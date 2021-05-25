import 'dart:async';
import 'dart:html';
import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter/services.dart';


class C3Page extends StatefulWidget {
  C3Page({Key? key}) : super(key: key);

  final String title = "Choice 3: S3 File Upload";

  @override
  _C3ageState createState() => _C3ageState();
}

class _C3ageState extends State<C3Page> {
  String genPutUrlAPIUrl = "https://6t29d4x40c.execute-api.us-west-2.amazonaws.com/dev";
  String genGetUrlAPIUtl = "https://emsomrmfka.execute-api.us-west-2.amazonaws.com/dev";

  bool _isUploading = false;
  ValueNotifier<int> _uploadedFileNum = ValueNotifier<int>(0);
  List<String> _uploadedFileNames = [];

  @override
  void initState() {
    super.initState();
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
            child: Column(
              children: [
                // CupertinoButton(child: Text("Test Button"), onPressed: ()=>_onUploadedFileNamePressed("example.pdf")),
                _buildUploadButton(),
                _buildUploadedFiles(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildUploadButton() {
    return CupertinoButton(
      child: _isUploading ? Text("Uploading...") : Text("Upload File"),
      onPressed: _isUploading ? null : _onUploadButtonPressed,
    );
  }

  Widget _buildUploadedFiles() {
    return ValueListenableBuilder(
      valueListenable: _uploadedFileNum,
      builder: (context, num, child) {
        if (_uploadedFileNum.value == 0) { return Column(); }

        List<Widget> uploadFileWidgets = [
          Text(
            "Uploaded Files:",
            style: TextStyle(fontSize: 20),
          )
        ];

        _uploadedFileNames.forEach((uploadedFileName) {
          uploadFileWidgets.add(CupertinoButton(
            child: Text(uploadedFileName),
            onPressed: () => _onUploadedFileNamePressed(uploadedFileName),
          ));
        });

        return Column(children: uploadFileWidgets);
      }
    );
  }

  void _onUploadButtonPressed() {
    FileUploadInputElement uploadInput = FileUploadInputElement();
    uploadInput.click();
    uploadInput.onChange.listen((event) {
      final files = uploadInput.files;
      if (files!.length == 1) {
        final file = files[0];
        final reader = FileReader();
        reader.onLoadEnd.listen((event) {
          // print('loaded: ${file.name}');
          // print('type: ${reader.result.runtimeType}');
          // print('file size = ${file.size}');

          Uint8List upFile = reader.result as Uint8List;

          setState(() { _isUploading = true; });

          // Get presigned put url
          // Make sure no repeat filename
          String fileName = DateTime.now().hashCode.toString() + "-" + file.name;
          Dio().post(genPutUrlAPIUrl, data: {"fileName": fileName}).then((res) {
            String presignedPutUrl = res.data["body"];

            // Start upload with pre-signed url
            Dio().put(presignedPutUrl, data: upFile,).then((response){
              _uploadedFileNum.value += 1;
              _uploadedFileNames.add(fileName);
              setState(() { _isUploading = false; });
            }).onError((error, stackTrace) {
              print("===== 上传失败 =====");
              print(error);
            });

          });

        });
        reader.onError.listen((event) {
          print(event);
        });
        reader.readAsArrayBuffer(file);
      }
    });
  }

  void _onUploadedFileNamePressed(String fileName) {
    // Get presigned get url
    Dio().post(genGetUrlAPIUtl, data: {"fileName": fileName}).then((res){
      String presignedGetUrl = res.data["body"];
      Dio().get(presignedGetUrl).then((value) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return new AlertDialog(
              content: Text(presignedGetUrl),
              actions: <Widget>[
                CupertinoButton(
                  child: Text("Copy"),
                  onPressed: () => Clipboard.setData(ClipboardData(text: presignedGetUrl)),
                ),
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
      });
    });
  }
}
