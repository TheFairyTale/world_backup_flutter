import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

class FileOperationRoute extends StatefulWidget {
  const FileOperationRoute({super.key});

  @override
  State<FileOperationRoute> createState() => _FileOperationRouteState();
}

class _FileOperationRouteState extends State<FileOperationRoute> {
  int _counter = 0;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // 自文件读取点击次数
    _readCounter().then((int value) {
      setState(() {
        _counter = value;
      });
    });
  }

  /// 异步获取到本地文件
  Future<File> _getLocalFile() async {
    // 获取应用目录
    String dirPath = (await getApplicationDocumentsDirectory()).path;
    String pathString = '$dirPath/counter.txt';
    print('log for path: ' + pathString);
    return File(pathString);
  }

  /// 读取文件中的内容
  Future<int> _readCounter() async {
    try {
      File file = await _getLocalFile();
      // 读取点击次数（以字符串的形式）
      String contents = await file.readAsString();
      // 从字符串中粘贴数字
      return int.parse(contents);
    } on FileSystemException {
      return 0;
    }
  }

  /// 将当前数字+1并按字符串类型写入文件
  _incrementCounter() async {
    setState(() {
      _counter++;
    });
    // 将点击次数以字符串类型写到文件
    await (await _getLocalFile()).writeAsString('$_counter');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('文件操作示例'),
      ),
      body: Center(
          child: Expanded(
              child: Column(
        children: [
          Text('点击$_counter次'),
          const Placeholder(),
        ],
      ))),
      // 一旦点击则调单独的_counter + 1 方法去+1
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ),
    );
  }
}
