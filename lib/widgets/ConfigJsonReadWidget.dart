import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:path_provider/path_provider.dart';

class ConfigJsonReadWidget extends StatefulWidget {
  const ConfigJsonReadWidget({super.key});

  @override
  State<ConfigJsonReadWidget> createState() => _ConfigJsonReadWidgetState();
}

// class _MyHomePageState extends State<MyHomePage> {

class _ConfigJsonReadWidgetState extends State<ConfigJsonReadWidget> {
  Future<Directory?>? _appDocumentsDirectory;
  static String configDirPath = "";

  /// 初始化获取配置文件所在目录
  Widget initConfig() {
    return FutureBuilder<Directory?>(
      future: getApplicationDocumentsDirectory(),
      builder: _buildDirectory,
    );
  }

  /// 当程序获取了系统文档文件夹中应用程序的配置文件地址后，调用该方法解析目录地址并返回地址字符串到configDirPath 变量
  Widget _buildDirectory(
      BuildContext context, AsyncSnapshot<Directory?> snapshot) {
    String text = '';
    if (snapshot.connectionState == ConnectionState.done) {
      if (snapshot.hasError) {
        print('Error: ${snapshot.error}');
      } else if (snapshot.hasData) {
        print('path: ${snapshot.data!.path}');
        // C:\Users\Administrator\Documents\WorldBackupFlutter\config
        Directory directory =
            Directory(snapshot.data!.path + "\\WorldBackupFlutter\\config");
        directory.createSync(recursive: true);
        text = directory.path;
      } else {
        print('path unavailable');
      }
    }

    if (text.isEmpty) {
      print("未能获取或创建指定的配置文件目录，将使用默认配置。");
      return const Padding(padding: EdgeInsets.all(16.0), child: Text(""));
    }
    configDirPath = text;
    return Padding(padding: const EdgeInsets.all(16.0), child: Text(text));
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return initConfig();
  }
}
