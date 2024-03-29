import 'dart:async';
import 'dart:isolate';

import 'package:flutter_demo/utils/datetime_util.dart';

class TimerClockIsolate {

  // 全局唯一的一个备份线程
  static late Isolate _isolate;

  // static late String _dateTime;

  void _periodicTask(SendPort sendPort) {
    Timer.periodic(Duration(seconds: 5), (Timer timer) {
      DateTime now = DateTime.now();
      print('Background Task Executed at: $now');

      // 发送消息给主线程
      sendPort.send(now);
    });
  }

  void _terminateTimerIsolate() {
    if (_isolate == null) {
      return;
    }

    // 终止Isolate
    _isolate.kill(priority: Isolate.immediate);
  }

  void _createTimerBackupIsolate() async {
    ReceivePort receivePort = ReceivePort();

    _isolate = await Isolate.spawn(_periodicTask, receivePort.sendPort);
    SendPort sendPort = _isolate.controlPort;

    receivePort.listen((message) {
      print('Received message from background task: $message');
    });
  }

  static void updateTimerClock(String str) {
    DateTime dateTime = DateTimeUtil.parseDateString(inputDateTime: str);
    Duration duration = dateTime.difference(DateTime.now());
    duration.inSeconds
  }
}
