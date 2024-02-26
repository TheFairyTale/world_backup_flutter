import 'package:flutter/material.dart';
import 'package:flutter_demo/models/setting_item.dart';

/// 设置页下统一的项目item
class SettingItemForItem implements SettingItem {
  final String settingItemName;
  final String itemSubtitle;
  final Widget actionFormWidget;

  /// 构建点击该项目时要执行的操作
  @override
  var executeOnPressed;

  SettingItemForItem(this.settingItemName, this.itemSubtitle,
      this.actionFormWidget, this.executeOnPressed);

  @override
  Widget buildTile(BuildContext buildContext) {
    return Text(
      settingItemName,
      style: Theme.of(buildContext).textTheme.titleMedium,
    );
  }

  /// 构建子标题
  @override
  Widget buildSubTitle(BuildContext buildContext) {
    return Text(
      itemSubtitle,
      style: Theme.of(buildContext).textTheme.labelSmall,
    );
  }

  /// 构建具体的选项
  @override
  Widget buildFormSelectWidget(BuildContext buildContext) {
    return actionFormWidget;
  }
}
