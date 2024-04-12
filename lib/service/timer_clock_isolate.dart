import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:isolate';
import 'dart:typed_data';

import 'package:async_zip/async_zip.dart';
import 'package:flustars_flutter3/flustars_flutter3.dart';
import 'package:flutter/services.dart';
import 'package:flutter_demo/utils/datetime_util.dart';
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
  // 确保这是全局唯一的一个备份线程
  static Isolate? _isolate;

  // 主线程用 ReceivePort
  static late ReceivePort _receivePort;

  static bool _threadCreated = false;

  static int _isolateCreateCount = 0;

  static String _mainThreadStaticUuid = Uuid().v1();

  // 表示主线程的receivePort 是否已经被监听
  static bool _isListened = false;

  // 标记备份操作是否正在进行
  static bool _isZippedOperationStarted = false;

  // 标记是否要立刻执行备份操作
  static bool _runBackupNow = false;

  // todo 监听主线程返回的备份时间，并在该时间在本线程执行备份操作，并告知主线程开始备份，结束备份及状态

  TimerClockIsolate() {
    // 如果子线程已经关闭则创建线程
    if (_isolate == null) {
      _isolateCreateCount++;
      // 1.创建主线程用的ReceivePort
      _receivePort = ReceivePort();
      // static late String _dateTime;

      _threadCreated = true;
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

  /// 子线程函数
  static void _periodicSubTask(SendPort sendPort) {
    String uuid = Uuid().v1();
    // 1.子线程也使用 ReceivePort 接收主线程消息
    ReceivePort receivePort = ReceivePort();
    // 2.发送子线程的SendPort给主线程
    sendPort.send(receivePort.sendPort);
    bool _backupCompleted = false;

    ReceivePort backupThreadPort = ReceivePort();
    Isolate.spawn(_backupSubTask, backupThreadPort.sendPort).then((value) {
      print("[" + uuid + "]" + "已成功获取到子线程对象");
      return value;
    }).then((value) {
      while (true) {
        if (_backupCompleted) {
          break;
        }
      }
    }).whenComplete(() {
      print("已创建子线程对象。");
    });

    // 3. 监听主线程发来的消息
    receivePort.listen((message) {
      print("[" + uuid + "]" + "收到消息：" + message);
      if (message == "backup") {
        _runBackupNow = true;
      }
    });

    int count = 0;
    while (true) {
      if ((count % 2) == 0) {
        print("[" + uuid + "]" + "count: " + count.toString() + ", sending...");
        sendPort.send(count);
      }

      print("[" + uuid + "]" + "当前时间: " + DateTime.now().toString());
      sleep(Duration(seconds: 5));
      count++;
    }
    // Timer.periodic(Duration(seconds: 5), (Timer timer) {
    //   DateTime now = DateTime.now();
    //   print('Background Task Executed at: $now');
    //
    //   // 发送消息给主线程
    //   sendPort.send(now);
    // });
  }

  /// zip文件创建并加入数据
  static void _backupSubTask(SendPort sendPort) {
    String uuid = Uuid().v1();
    // 1.子线程也使用 ReceivePort 接收主线程消息
    ReceivePort receivePort = ReceivePort();
    // 2.发送子线程的SendPort给主线程
    sendPort.send(receivePort.sendPort);
    if (_runBackupNow) {
      _createZipFile();
      _runBackupNow = false;
    }
    receivePort.listen((message) {});
  }

  static void _terminateTimerIsolate() {
    if (_isolate == null) {
      return;
    } else {
      // 终止Isolate
      _isolate!.kill(priority: Isolate.immediate);
    }
  }

  /// 主线程
  static Future<String> getTimerBackupIsolateMainThread(String inputMsg) async {
    String returnMsg = "";
    if (!_threadCreated) {
      var err = "未调用TimerClockIsolate() 进行初始化，无法访问线程。";
      print(err);
      return err;
    }
    // 如果子线程关闭则直接返回空字符串
    if (_isolate == null) {
      var err = "子线程未生成或已死亡，需要重新调用TimerClockIsolate() 进行初始化.";
      print(err);
      return err;
    }
    if (_receivePort == null) {
      var err = "无法访问子线程通讯端口，请调用TimerClockIsolate() 进行初始化.";
      print(err);
      return err;
    }
    if (inputMsg == "stop") {
      _terminateTimerIsolate();
      return "stoped";
    }
    // TimerClockIsolate();

    // 2.生成子线程
    // _isolate = await Isolate.spawn(_periodicSubTask, _receivePort.sendPort);
    // 3. 向子线程通讯
    _receivePort.sendPort.send(inputMsg);

    // 4.监听子线程消息
    // todo Bad state: Stream has already been listened to.
    // todo 判断是否已经监听
    // var isBroadcast = _receivePort.;
    try {
      if (!_isListened) {
        _receivePort.listen((message) {
          returnMsg = "[" +
              _mainThreadStaticUuid +
              "]" +
              'Received message from background task: $message';
          print(returnMsg);
        });
        _isListened = true;
      }
    } catch (e) {
      print(e);
    }
    return returnMsg;
  }

  static void _createZipFile() async {
    if (_isZippedOperationStarted) {
      print("已经有备份操作正在执行。");
      return;
    }

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
    String worldpath = "D:\\Users\\Administrator\\Downloads\\world";
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
// static void updateTimerClock(String str) {
//   DateTime dateTime = DateTimeUtil.parseDateString(inputDateTime: str);
//   Duration duration = dateTime.difference(DateTime.now());
//   duration.inSeconds
// }
}
