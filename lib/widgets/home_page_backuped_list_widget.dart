import 'dart:io';

import 'package:animate_do/animate_do.dart';
import 'package:flustars_flutter3/flustars_flutter3.dart';
import 'package:flutter/material.dart';
import 'package:flutter_demo/widgets/setting_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/file_entity.dart';
import '../service/timer_clock_isolate.dart';
import '../utils/file_operator_util.dart';
import '../utils/list_view_item_builder.dart';

class HomePageBackupedListWidget extends StatefulWidget {
  const HomePageBackupedListWidget({Key? key, required this.title}) : super(key: key);

  final String title;
  @override
  _HomePageBackupedListWidgetState createState() =>
      _HomePageBackupedListWidgetState();
}

class _HomePageBackupedListWidgetState
    extends State<HomePageBackupedListWidget> with TickerProviderStateMixin {
  // todo 改为从配置文件中读取常量
  String _API_ADDRESS = "https://openapi.alipan.com";
  String _SCHEME = "https";
  String _HOST = "openapi.alipan.com";
  String _CLIENT_ID = "";
  String _REDIRECT_URI = "http://127.0.0.1";
  String _SCOPE = "user:base";

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
    Future<void>? _launched;

    TimerClockIsolate.getTimerBackupIsolateMainThread("hello")
        .then((value) => print(value));

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () {
              // TimerClockIsolate.getTimerBackupIsolateMainThread("stop")
              //     .then((value) => print(value));

              print("backup waiting.. ");
              TimerClockIsolate.getTimerBackupIsolateMainThread("backup")
                  .then((value) => print(value));
              print("backup waiting.. ");

              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SettingPage()),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.open_in_new),
            onPressed: () {
              setState(() {
                var uri = Uri(
                    scheme: _SCHEME,
                    host: _HOST,
                    path: "/oauth/authorize" +
                        "?client_id=" +
                        _CLIENT_ID +
                        "&redirect_uri=" +
                        _REDIRECT_URI +
                        "&scope=" +
                        _SCOPE +
                        "&response_type=code");
                _launched = _launchInBrowserView(uri);
              });
              print("外部浏览器启动结果：" + _launched.toString());
            },
          )
        ],
      ),
      body: FadeInDown(child: listWidget),
    );
  }

  /// 在浏览器中打开指定链接
  Future<void> _launchInBrowserView(Uri url) async {
    if (!await launchUrl(url, mode: LaunchMode.inAppBrowserView)) {
      throw Exception('Could not launch $url');
    }
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
