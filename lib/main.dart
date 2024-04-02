import 'dart:async';
import 'dart:convert';
import 'dart:ffi';
import 'dart:io';
import 'dart:isolate';

import 'package:animate_do/animate_do.dart';
import 'package:archive/archive.dart';
import 'package:archive/archive_io.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flustars_flutter3/flustars_flutter3.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_demo/models/file_entity.dart';
import 'package:flutter_demo/route/file_operation_route.dart';
import 'package:flutter_demo/route/http_test_route.dart';
import 'package:flutter_demo/service/timer_clock_isolate.dart';
import 'package:flutter_demo/utils/file_operator_util.dart';
import 'package:flutter_demo/utils/list_view_item_builder.dart';
import 'package:flutter_demo/widgets/ConfigJsonReadWidget.dart';
import 'package:flutter_demo/widgets/setting_page.dart';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

void main() {
  // 启用log，否则调用其他log 语句不会生效
  LogUtil.init(tag: "Main", isDebug: true, maxLen: 999999);
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
      routes: {
        // "backup_datetime_picker": (context) => BackupDateTimeSettingRoute()
      },
      // home: const HttpTestRoute(),
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

class _MyHomePageState extends State<MyHomePage> with TickerProviderStateMixin {
  // todo 某些内容不应放在init 生命周期内
  @override
  void initState() {
    homePageWidgets();
  }

  Widget listWidget = CircularProgressIndicator(
    backgroundColor: Colors.grey[200],
    valueColor: AlwaysStoppedAnimation(Colors.blue),
  );

  @override
  Widget build(BuildContext context) {
    TimerClockIsolate.createTimerBackupIsolateMainThread("hello")
        .then((value) => print(value))
        .whenComplete(() => print("创建完毕子线程"));



    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () {
              TimerClockIsolate.createTimerBackupIsolateMainThread("stop")
                  .then((value) => print(value))
                  .whenComplete(() => print("已关闭子线程"));
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SettingPage()),
              );
            },
          ),
        ],
      ),
      body: FadeInDown(child: listWidget),
    );
  }

  Future<String> getBackupFilePath() async {
    Future<SharedPreferences> sharedPreference = getPrefsInstance();
    String? path = "";

    await sharedPreference.then((value) {
      // todo Null check operator used on a null value
      path = value.getString('backupFilePath');
      var msg = 'D:\\Users\\Administrator\\Downloads';

// 等价于 path == null ? msg : path;
      path ??= msg;
      if (path!.isEmpty) {
        prefsWriteToString(value, 'backupFilePath', msg);
        path = msg;
      }

      return value;
    });

    return path!;
  }

  /// 将值写入SharedPrefs
  ///
  Future<dynamic> prefsWriteToString(
      SharedPreferences prefs, String key, String value) async {
    await prefs.setString(key, value);
  }

  void homePageWidgets() async {
    var backupFilePath = await getBackupFilePath();
    LogUtil.d(backupFilePath);

    // Stream<FileSystemEntity> files =
    await FileOperatorUtil.dirList(backupFilePath).then((files) {
      LogUtil.d("FileOperatorUtil.dirList(): " + files.toString());

      return files.toList();
    }).then((value) {
      List<FileSystemEntity> fileSystemEntitiesList = <FileSystemEntity>[];
      LogUtil.d(": " + value.length.toString());
      fileSystemEntitiesList = value;
      List<FileEntity> items = <FileEntity>[];
      for (var element in fileSystemEntitiesList) {
        String path = element.path;
        // 获取文件后缀
        int lastIndexOfSuffix = path.lastIndexOf('.');
        if (lastIndexOfSuffix == -1) {
          lastIndexOfSuffix = path.length;
        }
        // 获取文件名（去除后缀）
        int lastIndexOfFileName = path.lastIndexOf('\\');
        if (lastIndexOfFileName == -1) {
          lastIndexOfFileName = 0;
        }

        String fileName = path.substring(lastIndexOfFileName + 1, path.length);
        String suffixString = (lastIndexOfSuffix == path.length)
            ? ""
            : path.substring(lastIndexOfSuffix + 1, path.length);
        // 为文件时返回文件大小，否则返回0
        var fileLength = (element.statSync().type == FileSystemEntityType.file)
            ? File(path).lengthSync()
            : 0;
        DateTime modifiedTime = FileStat.statSync(path).modified;
        StringBuffer sb = StringBuffer();
        sb.write(modifiedTime.year);
        sb.write('-');
        sb.write(modifiedTime.month);
        sb.write('-');
        sb.write(modifiedTime.day);
        sb.write(' ');
        sb.write(modifiedTime.hour);
        sb.write(':');
        sb.write(modifiedTime.minute);
        sb.write(':');
        sb.write(modifiedTime.second);
        String fileModifiedTimeString = sb.toString();

        FileEntity fileEntity = FileEntity(
            name: fileName,
            suffix: suffixString,
            abstractpath: path,
            size: fileLength,
            createAt: fileModifiedTimeString,
            modifiedAt: fileModifiedTimeString);
        items.add(fileEntity);

        // itemBuilder为列表项的构建器（builder），我们需要在该回调中构建每一个列表项Widget
        setState(() {
          // Null check operator used on a null value
          listWidget = FadeInUp(
              child: ListViewItemBuilder().getListViewItemWidget(items));
        });
      }
    });
    // var filesLength = 0;
    // files.length.then((value) {
    //   LogUtil.d('File Entity count: ' + value)
    //   filesLength = value;
    // });

    // return ListView();
  }

  Future<SharedPreferences> getPrefsInstance() async {
    // Obtain shared preferences.
    return await SharedPreferences.getInstance();
  }
}
