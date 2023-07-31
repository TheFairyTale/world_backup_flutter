import 'dart:async';
import 'dart:convert';
import 'dart:ffi';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_demo/widgets/ConfigJsonReadWidget.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  var streamController;
  // 获取StreamSink用于发射事件
  StreamSink<String> get streamSink => streamController.sink;
  // 获取Stream用于监听
  Stream<String> get streamData => streamController.stream;
  List<Widget> widgetsOfFiles = [];

  @override
  void initState() {
    super.initState();
    streamController = StreamController<String>();
    initScanDirectory();
  }

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    // widgetsOfFiles.add(Text(
    //   '$_counter',
    //   style: Theme.of(context).textTheme.headlineMedium,
    // ));
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: ListView(
        // mainAxisAlignment: MainAxisAlignment.center,

        children: widgetsOfFiles,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }

  void updateWidgetListVarStatus(List<Widget> widgetList) {
    setState(() {
      widgetsOfFiles = widgetList;
      widgetsOfFiles.add(ConfigJsonReadWidget());
    });
  }

  /// 扫描指定目录下的文件及文件夹
  void initScanDirectory() {
    String dirPath =
        "C:\\Users\\Administrator\\Documents\\Flutter\\flutter_demo";
    Directory dirObj = Directory(dirPath);
    List<Widget> widgets = [];

    doesDirectoryExists(dirObj).then((value) {
      if (value) {
        // 存在
        dirObj.list(recursive: true, followLinks: false).forEach((element) {
          if (element is File) {
            widgets.add(Text(element.toString()));
          }
        });
      }
    }).whenComplete(() {
      updateWidgetListVarStatus(widgets);
    });
  }

  /// 判断目录是否是有效的
  Future<bool> doesDirectoryExists(Directory dirObj) async {
    return dirObj.exists();
  }

  /// 读取程序目录下的配置文件
  // Future<Map<String, dynamic>> getLocalJson(String jsonName) async {
  //   // Map<String, dynamic> map = jsonDecode(
  //   //     await rootBundle.loadString("assets/json/" + jsonName + ".json"));
  //   json
  //   return map;
  // }
}
