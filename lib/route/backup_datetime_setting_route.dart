import 'package:flutter/material.dart';

class BackupDateTimeSettingRoute extends StatefulWidget {
  const BackupDateTimeSettingRoute({super.key});

  @override
  State<BackupDateTimeSettingRoute> createState() =>
      _BackupDateTimeSettingRouteState();
}

class _BackupDateTimeSettingRouteState
    extends State<BackupDateTimeSettingRoute> {
  @override
  Widget build(BuildContext context) {
    //获取路由参数
    var args = ModalRoute.of(context)?.settings.arguments;
    if (args == null) {
      return Text("data");
    }

    return Scaffold(
        appBar: AppBar(
          title: const Text("选择备份时间..."),
        ),
        body: Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          child: Expanded(
              child: Card(
                  margin: const EdgeInsets.all(12.0),
                  elevation: 0,
                  color: Theme.of(context).colorScheme.surfaceVariant,
                  child: Padding(
                    padding: EdgeInsets.all(12.0),
                    child: ElevatedButton(
                      child: Text("$args"),
                      onPressed: () {
                        DatePicker.showDatePicker(context,
                            showTitleActions: true,
                            // minTime: DateTime(2018, 3, 5),
                            // maxTime: DateTime(2019, 6, 7),
                            theme: DatePickerTheme(
                                headerColor: Colors.grey,
                                backgroundColor: Colors.green,
                                itemStyle: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18),
                                doneStyle: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16)), onChanged: (date) {
                          print('change $date in time zone ' +
                              date.timeZoneOffset.inHours.toString());
                        }, onConfirm: (date) {
                          print('confirm $date');
                        }, currentTime: DateTime.now(), locale: LocaleType.en);
                      },
                    ),
                  ))),
        ));
  }
}
