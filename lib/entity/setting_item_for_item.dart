import 'package:flutter/material.dart';
import 'package:flutter_demo/entity/setting_item.dart';

/// 设置页下统一的项目item
class SettingItemForItem implements SettingItem {
  final String settingItemName;
  final String itemSubtitle;
  final Widget actionFormWidget;

  SettingItemForItem(
      this.settingItemName, this.itemSubtitle, this.actionFormWidget);

  @override
  Widget buildTile(BuildContext buildContext) {
    return Text(
      settingItemName,
      style: Theme.of(buildContext).textTheme.labelSmall,
    );
  }

  /// 构建子标题
  @override
  Widget buildSubTitle(BuildContext buildContext) {
    return Text(
      itemSubtitle,
      style: Theme.of(buildContext).textTheme.displaySmall,
    );
  }

  /// 构建具体的选项
  @override
  Widget buildFormSelectWidget(BuildContext buildContext) {
    return actionFormWidget;
  }
}
