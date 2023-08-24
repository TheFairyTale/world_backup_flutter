import 'package:flutter/material.dart';
import 'package:flutter_demo/entity/setting_item.dart';

/// 设置页下的其中的某一个标题
class SettingItemForHeader implements SettingItem {
  final String headerString;

  SettingItemForHeader(this.headerString);

  @override
  Widget buildTile(BuildContext buildContext) {
    return Text(
      headerString,
      style: Theme.of(buildContext).textTheme.headlineSmall,
    );
  }

  /// 构建子标题
  @override
  Widget buildSubTitle(BuildContext buildContext) {
    return const SizedBox.shrink();
  }

  /// 构建具体的选项
  @override
  Widget buildFormSelectWidget(BuildContext buildContext) =>
      const SizedBox.shrink();
}
