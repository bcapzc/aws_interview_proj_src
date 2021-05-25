import 'package:aws_interview_proj/choice1/C1Page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'choice2/C2Page.dart';
import 'choice3/C3Page.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.

  Color awsThemeColor = Color(0xFF252F3D);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'AWS Interview Project',
      theme: ThemeData(primaryColor: awsThemeColor),
      home: MyHomePage(title: 'AWS Interview Project'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String intro1 = """
HTML 页面文件显示用户本地到 amazon.com 的延时:
    1.  不断获取到 amazon.com 的延时数据（如编写类似于 ping 等工具）
    2.  将最近 3 次的延时信息写入到 Amazon DynamoDB 中
    3.  写另外一个程序，不断获取 DynamoDB 表中的延时信息，计算平均值，然后返回给客户端显示。
  """;
  String intro2 = """
HTML 页面文件，用户通过访问该文件，页面上有一个 button，鼠标点击 button 之后，会创建自己 AWS 环境中 EC2 的快照，并在前端页面显示 EC2 快照创建中的各个状态，以及快照创建完成时的信息。
  """;
  String intro3 = """
HTML 页面文件，访问该文件，从页面选择本地的一个文件，点击“上传”的 button，将文件（Multi-part 方式）上传到自己 AWS 环境中 S3 上，点击另一个 button “查看”，在 HTML 页面中显示该文件的下载地址（是一个 HTTP 的地址）。如果上传有进度条加分，需要说明进度条的实现细节。
  """;

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
                _buildChoice1Button(),
                _buildIntroText(intro1),
                _buildChoice2Button(),
                _buildIntroText(intro2),
                _buildChoice3Button(),
                _buildIntroText(intro3),
              ],
            ),
          ),
        )
      ),
    );
  }

  Widget _buildChoice1Button() {
    return CupertinoButton(
        child: Text("Choice 1: 监控本地到 amazon.com 的延时数据"),
        onPressed: (){
          Navigator.push(
              context,
              CupertinoPageRoute(builder: (context) => C1Page())
          );
        }
    );
  }

  Widget _buildChoice2Button() {
    return CupertinoButton(
        child: Text("Choice 2: 创建 EC2 快照并展示"),
        onPressed: (){
          Navigator.push(
              context,
              CupertinoPageRoute(builder: (context) => C2Page())
          );
        }
    );
  }

  Widget _buildChoice3Button() {
    return CupertinoButton(
        child: Text("Choice 3: S3 文件上传"),
        onPressed: (){
          Navigator.push(
              context,
              CupertinoPageRoute(builder: (context) => C3Page())
          );
        }
    );
  }

  Widget _buildIntroText(String intro) {
    return Text(
      intro,
      softWrap: true,
    );
  }
}
