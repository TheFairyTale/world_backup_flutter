import 'dart:async';
import 'dart:io';
import 'dart:isolate';

import 'package:flutter_demo/utils/datetime_util.dart';

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
  static late Isolate _isolate;

  // static late String _dateTime;

  // todo 监听主线程返回的备份时间，并在该时间在本线程执行备份操作，并告知主线程开始备份，结束备份及状态

  TimerClockIsolate() {
    // 如果子线程已经关闭则直接返回空字符串
    if (_isolate == null) {
      // 1.创建ReceivePort
      ReceivePort receivePort = ReceivePort();
      // 2.生成子线程
      _isolate = await Isolate.spawn(_periodicSubTask, receivePort.sendPort);
      // 3. 向子线程通讯
      receivePort.sendPort.send(inputMsg);
    }
  }

  /// 子线程函数
  static void _periodicSubTask(SendPort sendPort) {
    // 1.子线程也使用 ReceivePort 接收主线程消息
    ReceivePort receivePort = ReceivePort();
    // 2.发送子线程的SendPort给主线程
    sendPort.send(receivePort.sendPort);

    // 3. 监听主线程发来的消息
    receivePort.listen((message) {
      print("收到消息：" + message);

    });

    while (true) {
      print("当前时间: " + DateTime.now().toString());
      sleep(Duration(seconds: 5));
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
    }

    // 终止Isolate
    _isolate.kill(priority: Isolate.immediate);
  }

  /// 主线程
  static Future<String> createTimerBackupIsolateMainThread(String inputMsg) async {
    String returnMsg = "";
    // 如果子线程已经关闭则直接返回空字符串
    if (_isolate == null) {
      return returnMsg;
    }
    if (inputMsg == "stop") {
      _terminateTimerIsolate();
    }  

    // 1.创建ReceivePort
    ReceivePort receivePort = ReceivePort();
    // 2.生成子线程
    _isolate = await Isolate.spawn(_periodicSubTask, receivePort.sendPort);
    // 3. 向子线程通讯
    receivePort.sendPort.send(inputMsg);

    // 4.监听子线程消息
    receivePort.listen((message) {
      returnMsg = 'Received message from background task: $message';
      print(returnMsg);
    });
    return returnMsg;
  }

  // static void updateTimerClock(String str) {
  //   DateTime dateTime = DateTimeUtil.parseDateString(inputDateTime: str);
  //   Duration duration = dateTime.difference(DateTime.now());
  //   duration.inSeconds
  // }
}
