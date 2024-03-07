import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_demo/models/file_entity.dart';
import 'package:flutter_demo/utils/list_view_builder.dart';

class ListViewItemBuilder extends ListViewBuilder {
  Widget getListViewItemWidget(List<FileEntity> items) {
    return ListView.builder(
      // Let the ListView know how many items it needs to build.
      itemCount: items.length,
      // Provide a builder function. This is where the magic happens.
      // Convert each item into a widget based on the type of item it is.
      itemBuilder: (context, index) {
        final item = items[index];

        return _buildItem(Icons.abc_outlined, item.name, item.suffix,
            item.size.toString(), item.createAt);
      },
    );
  }

  /// 自定义ListView 列表项目的外观
  /// @param icons 图标
  /// @param title 项目标题
  /// @param suffix 文件名称后缀
  /// @param size 文件大小（如：4096kb)
  /// @param modifiedAt 修改时间(如: 2024-01-01 00:00:00)
  ///
  Widget _buildItem(IconData icons, String title, String suffix, String size,
      String modifiedAt) {
    return Container(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          children: [
            Row(
              children: [Icon(icons), Text(title), Text(suffix), Text(size + ' bytes')],
            ),
            Row(
              children: [Text(modifiedAt)],
            )
          ],
        ));
  }
}
