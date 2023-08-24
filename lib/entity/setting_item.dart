import 'package:flutter/material.dart';

/// 该抽象类用于统一返回规整后的设置界面中的组件
abstract class SettingItem {
  /// 构建项目标题
  Widget buildTile(BuildContext buildContext);

  /// 构建子标题
  Widget buildSubTitle(BuildContext buildContext);

  /// 构建具体的选项
  Widget buildFormSelectWidget(BuildContext buildContext);
}
