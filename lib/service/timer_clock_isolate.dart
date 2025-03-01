import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:isolate';
import 'dart:typed_data';

import 'package:async_zip/async_zip.dart';
import 'package:flustars_flutter3/flustars_flutter3.dart';
import 'package:flutter/services.dart';
import 'package:flutter_demo/utils/datetime_util.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'package:path/path.dart' as path;

import '../models/file_entity.dart';
import '../utils/file_operator_util.dart';

/// 关于Isolate 如何对主子线程进行通讯的解释：
///  1. 创建一个ReceivePort来接收子线程的消息。然后创建一个子线程并将创建的ReceivePort及
///  后面创建的'专门用于执行子线程任务且方法参数的类型为SendPort '的方法传入，之后通过
///  receivePort.sendPort.send(Obj)与子线程通讯，而主线程则通过receivePort.listen(){} 回调函数
///  监听从子线程发出的消息
///  2. 创建一个'专门用于执行子线程任务且方法参数的类型为SendPort'的方法，在方法中创建一个
///  ReceivePort来接收主线程发出的消息。紧接着需要调用入参参数这个对象sendPort.send 方法
///  将receivePort.sendPort 发送给主线程，之后根据receivePort.listen() {}回调函数监听
///  从主线程发出的消息
///
/// 可以看到实际上主子线程间的通讯方式基本是一致的，可以理解为只是在你创建的子线程方法中需要使用
/// 入参的SendPort对象调用其send方法将子线程的通讯端口暴露给主线程以供主子双向建立连接
class TimerClockIsolate {
// 备份文件夹路径
  static late String? backupPathString;

  // 确保这是全局唯一的一个备份线程
  static Isolate? _isolate;

  // 标记备份操作是否正在进行
  static bool _isZippedOperationStarted = false;
  // 主线程用 ReceivePort
  static late ReceivePort _receivePort;

  static String _mainThreadStaticUuid = Uuid().v1();

  TimerClockIsolate() {
    // 如果子线程已经关闭则创建线程
    if (_isolate == null) {
      // 1.创建主线程用的ReceivePort
      _receivePort = ReceivePort();
      // static late String _dateTime;

      Isolate.spawn(_periodicSubTask, _receivePort.sendPort).then((value) {
        // 2.生成子线程
        _isolate = value;
        print("[" + _mainThreadStaticUuid + "]" + "已成功获取到子线程对象");
      }).whenComplete(() {
        if (_isolate != null) {
          print("[" +
              _mainThreadStaticUuid +
              "]" +
              "子线程创建过程执行完毕。当前已启动次，当前线程对象：" +
              _isolate.toString());
        } else {
          print("[" +
              _mainThreadStaticUuid +
              "]" +
              "子线程创建过程执行完毕。当前已启动次，当前线程对象为空。");
        }
      });
      // // 3. 向子线程通讯
      // _receivePort.sendPort.send(inputMsg);
    }
  }

  /// 向子线程发布备份指令
  static void sendBackupCommandToSubtask(String path) {
    if (_isolate == null) {
      return;
    }
    print('sending...');
    _receivePort.sendPort.send(path);
  }

  /// 子线程函数
  static void _periodicSubTask(SendPort sendPort) {
    print('main uuid: ' + _mainThreadStaticUuid);
    String uuid = Uuid().v1();
    print('sub task uuid: ' + uuid);
    // 1.子线程也使用 ReceivePort 接收主线程消息
    ReceivePort receivePort = ReceivePort();
    // 2.发送子线程的SendPort给主线程
    sendPort.send(receivePort.sendPort);
    print('running');
    bool _backupCompleted = false;

    SendPort? backupThreadSendPort = null;

    ReceivePort backupThreadPort = ReceivePort();
    // Isolate.spawn(_backupSubTask, backupThreadPort.sendPort).then((value) {
    //   print("[" + uuid + "]" + "已成功获取到子线程对象");
    //   backupThreadSendPort = value.controlPort;
    //   return value;
    // }).then((value) {
    //   while (true) {
    //     if (_backupCompleted) {
    //       break;
    //     }
    //   }
    // }).whenComplete(() {
    //   print("已创建子线程对象。");
    // });

    // 3. 监听主线程发来的消息
    receivePort.listen((message) {
      print(uuid + '_收到消息: ' + message);
      if (message is String) {
        _createZipFile(message);
      }
    });
  }

  static void _createZipFile(String backupPath) async {
    print('备份正在执行');
    if (_isZippedOperationStarted) {
      print("已经有备份操作正在执行。");
      return;
    }

    backupPathString = backupPath;
    if (backupPathString == null) {
      print('备份路径为空，无法启动备份程序');
      return;
    }
    print('backupping... ');

    _isZippedOperationStarted = true;
    int _backupFileCount = 0;
    // Save bundled files to temporary directory in order to write
    // them to the Zip file. This is just for illustration purposes.
    final tempDir = Directory.systemTemp;
    // todo 自定义输出目录
    print("文件输出地址：" + tempDir.path);
    // todo 自定义时间与后缀间的名称
    final archiveFile = File(path.join(
        tempDir.path, DateTimeUtil.writeDateTimeStr(0) + "_" + '.zip'));
    // todo 可配置的备份文件夹地址
    String worldpath = backupPathString ?? '';
    print("backup level folder: " + worldpath);

    // Create the Zip file synchronously同步
    final writer = ZipFileWriterSync();
    await FileOperatorUtil.dirList(worldpath).then((files) {
      LogUtil.d("FileOperatorUtil.dirList(): " + files.toString());

      return files.toList();
    }).then((value) {
      List<FileSystemEntity> fileSystemEntitiesList = <FileSystemEntity>[];
      LogUtil.d(": " + value.length.toString());
      fileSystemEntitiesList = value;
      List<FileEntity> items = <FileEntity>[];

      try {
        for (var element in fileSystemEntitiesList) {
          String path = element.path;

          final file = File(path
              // .join(tempDir.path, 'image.jpg')
              );

          writer.create(archiveFile);
          writer.writeFile(
              element.path.substring(
                  element.path.lastIndexOf("/"), element.path.length),
              file);
          // writer.writeFile('data/person.json', jsonFile);

          // final textData = await rootBundle.loadString('assets/fox.txt');
          // writer.writeData('fox.txt', Uint8List.fromList(utf8.encode(textData)));

          // butterflyFile.readAsBytes()
          // await butterflyFile.writeAsBytes(butterflyData.buffer.asUint8List());
          _backupFileCount++;
        }
      } on ZipException catch (ex) {
        print('An error occurred while creating the Zip file: ${ex.message}');
      } finally {
        writer.close();
        _isZippedOperationStarted = false;
      }
    });
    // final jsonData = await rootBundle.load('assets/person.json');
    // final jsonFile = File(path.join(tempDir.path, 'person.json'));
    // await jsonFile.writeAsBytes(jsonData.buffer.asUint8List());

    print("Completed " + _backupFileCount.toString() + " files.");
    final archiveSize = archiveFile.lengthSync();
    print(
        'Created Zip file at ${archiveFile.path} with a size of $archiveSize bytes');

    // Create the Zip file asynchronously异步
    // final asyncArchiveFile = File(path.join(tempDir.path, 'create-archive-async.zip'));
    // final asyncWriter = ZipFileWriter();
    // try {
    //   await asyncWriter.create(asyncArchiveFile);
    //   await asyncWriter.writeFile('butterfly.jpg', butterflyFile);
    //   await asyncWriter.writeFile('data/person.json', jsonFile);
    //
    //   final textData = await rootBundle.loadString('assets/fox.txt');
    //   await asyncWriter.writeData('fox.txt', Uint8List.fromList(utf8.encode(textData)));
    // } on ZipException catch (ex) {
    //   print('An error occurred while creating the Zip file: ${ex.message}');
    // } finally {
    //   await asyncWriter.close();
    // }
    //
    // final asyncArchiveSize = asyncArchiveFile.lengthSync();
    // print('Created Zip file at ${asyncArchiveFile.path} with a size of $asyncArchiveSize bytes');
  }
}
