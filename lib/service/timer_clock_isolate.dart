import 'dart:async';
import 'dart:io';
import 'dart:isolate';

import 'package:flutter_demo/utils/datetime_util.dart';
import 'package:uuid/uuid.dart';

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
  // 全局唯一的一个备份线程
  // todo Error 该变量没有初始化。
  static Isolate? _isolate;
  static late ReceivePort receivePort;

  static bool threadCreated = false;

  static int isolateCreateCount = 0;

  // static late String _dateTime;
  static String staticUuid = Uuid().v1();

  // 表示主线程的receivePort 是否已经被监听
  static bool _isListened = false;

  // todo 监听主线程返回的备份时间，并在该时间在本线程执行备份操作，并告知主线程开始备份，结束备份及状态

  TimerClockIsolate() {
    // 如果子线程已经关闭则创建线程
    if (_isolate == null) {
      isolateCreateCount++;
      // 1.创建ReceivePort
      receivePort = ReceivePort();
      // 2.生成子线程
      Isolate.spawn(_periodicSubTask, receivePort.sendPort).then((value) {
        _isolate = value;
        print("[" + staticUuid + "]" + "已成功获取到子线程对象");
        threadCreated = true;
      }).whenComplete(() {
        if (_isolate != null) {
          print("[" +
              staticUuid +
              "]" +
              "子线程创建过程执行完毕。当前已启动次，当前线程对象：" +
              _isolate.toString());
        } else {
          print("[" + staticUuid + "]" + "子线程创建过程执行完毕。当前已启动次，当前线程对象为空。");
        }
      });
      // // 3. 向子线程通讯
      // receivePort.sendPort.send(inputMsg);
    }
  }

  /// 子线程函数
  static void _periodicSubTask(SendPort sendPort) {
    String uuid = Uuid().v1();
    // 1.子线程也使用 ReceivePort 接收主线程消息
    ReceivePort receivePort = ReceivePort();
    // 2.发送子线程的SendPort给主线程
    sendPort.send(receivePort.sendPort);

    // 3. 监听主线程发来的消息
    receivePort.listen((message) {
      print("[" + uuid + "]" + "收到消息：" + message);
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
    if (!threadCreated) {
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
    if (receivePort == null) {
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
    // _isolate = await Isolate.spawn(_periodicSubTask, receivePort.sendPort);
    // 3. 向子线程通讯
    receivePort.sendPort.send(inputMsg);

    // 4.监听子线程消息
    // todo Bad state: Stream has already been listened to.
    // todo 判断是否已经监听
    // var isBroadcast = receivePort.;
    try {
      if (!_isListened) {
        receivePort.listen((message) {
          returnMsg = "[" +
              staticUuid +
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

// static void updateTimerClock(String str) {
//   DateTime dateTime = DateTimeUtil.parseDateString(inputDateTime: str);
//   Duration duration = dateTime.difference(DateTime.now());
//   duration.inSeconds
// }
}
