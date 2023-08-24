import 'package:flutter/material.dart';
import 'package:flutter_demo/entity/setting_item.dart';

class ListViewBuilder {
  /// 获取专为设置界面配置的ListView ，用于生成设置界面的基础列表外观样式
  Widget getListViewWidget(List<SettingItem> items) {
    return ListView.builder(
      // Let the ListView know how many items it needs to build.
      itemCount: items.length,
      // Provide a builder function. This is where the magic happens.
      // Convert each item into a widget based on the type of item it is.
      itemBuilder: (context, index) {
        final item = items[index];

        return ListTile(
          title: item.buildTile(context),
          subtitle: item.buildSubTitle(context),
          // trailing: item.buildFormSelectWidget(context),
          onTap: () {},
        );
      },
    );
  }

  /// 获取专为备份列表界面配置的ListView ，用于生成备份文件列表界面的卡片列表样式
  Widget getListViewWidgetByCard(List<SettingItem> items) {
    return ListView.builder(
      // Let the ListView know how many items it needs to build.
      itemCount: items.length,
      // Provide a builder function. This is where the magic happens.
      // Convert each item into a widget based on the type of item it is.
      itemBuilder: (context, index) {
        final item = items[index];

        return ListTile(
          title: item.buildTile(context),
          subtitle: item.buildSubTitle(context),
          trailing: item.buildFormSelectWidget(context),
          onTap: () {},
        );
      },
    );
  }
}
