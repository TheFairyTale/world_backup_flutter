import 'package:flutter/material.dart';
import 'package:flutter_demo/entity/setting_item.dart';
import 'package:flutter_demo/entity/setting_item_for_header.dart';
import 'package:flutter_demo/entity/setting_item_for_item.dart';
import 'package:flutter_demo/utils/list_view_builder.dart';
import 'package:date_time_picker/date_time_picker.dart';

class SettingPage extends StatefulWidget {
  const SettingPage({super.key});

  @override
  State<SettingPage> createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  final String dateTime = "2023-08-29 00:00:00";

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      child: Expanded(
        child: Card(
          margin: const EdgeInsets.all(12.0),
          elevation: 0,
          color: Theme.of(context).colorScheme.surfaceVariant,
          child: Padding(
            padding: EdgeInsets.all(12.0),
            child:
                ListViewBuilder().getListViewWidget(buildPageItemList(context)),
          ),
        ),
      ),
    );
  }

  List<SettingItem> buildPageItemList(BuildContext context) {
    return [
      SettingItemForHeader("headerString1", () {}),
      SettingItemForHeader("headerString2", () {}),
      SettingItemForItem(
          "settingItemName1",
          "itemSubtitle",
          ElevatedButton(
            child: Text("btn1"),
            onPressed: () {},
          ),
          () {}),
      SettingItemForItem("定时备份时间", "选择一个时间，当处于该时间时则备份程序将自动执行相应的备份操作",
          Text('2023-10-12 00:00:00'),
          // , () {
          //   Navigator.of(context)
          //       .pushNamed("backup_datetime_picker", arguments: dateTime);
          // }
          () {
        DateTimePicker(
          type: DateTimePickerType.dateTimeSeparate,
          initialValue: DateTime.now().toString(),
          firstDate: DateTime(2000),
          lastDate: DateTime(2410),
          dateLabelText: 'Date',
          onChanged: (val) => print(val),
          validator: (val) {
            print(val);
            return null;
          },
          onSaved: (val) => print(val),
        );
      })
    ];
  }
}
