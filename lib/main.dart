import 'dart:async';
import 'dart:convert';
import 'dart:ffi';
import 'dart:io';
import 'dart:isolate';

import 'package:archive/archive.dart';
import 'package:archive/archive_io.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_demo/route/file_operation_route.dart';
import 'package:flutter_demo/route/http_test_route.dart';
import 'package:flutter_demo/widgets/ConfigJsonReadWidget.dart';
import 'package:flutter_demo/widgets/setting_page.dart';
import 'package:path/path.dart' as path;
import 'package:uuid/uuid.dart';

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
  void initState() {}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: homePageWidgets(),
    );
  }

  /// 判断目录是否是有效的
  Future<bool> doesDirectoryExists(Directory dirObj) async {
    // todo
    return dirObj.exists();
  }

  ListView homePageWidgets() {
    // itemBuilder为列表项的构建器（builder），我们需要在该回调中构建每一个列表项Widget
    return ListView();
  }
}
