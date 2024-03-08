import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_demo/models/file_entity.dart';
import 'package:flutter_demo/utils/list_view_builder.dart';

class ListViewItemBuilder extends ListViewBuilder {
  /// 根据入参实体类构建一个个具体的列表项目组件
  Widget getListViewItemWidget(List<FileEntity> items) {
    return ListView.builder(
      // Let the ListView know how many items it needs to build.
      itemCount: items.length,
      // Provide a builder function. This is where the magic happens.
      // Convert each item into a widget based on the type of item it is.
      itemBuilder: (context, index) {
        final item = items[index];

        return _buildItem(Icons.abc_outlined, item.name, item.suffix,
            item.size.toString(), item.abstractpath, item.createAt);
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
      String absolutePath, String modifiedAt) {
    return Container(
        padding: const EdgeInsets.all(10.0),
        child: DecoratedBox(
            decoration: BoxDecoration(
                color: Colors.orange,
                border: Border(
                    top: BorderSide(width: 1.0),
                    bottom: BorderSide(width: 1.0),
                    left: BorderSide(width: 1.0),
                    right: BorderSide(width: 1.0))),
            child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                mainAxisSize: MainAxisSize.max,
                children: [
                  // 图标列
                  DecoratedBox(
                    decoration: BoxDecoration(
                        border: Border(
                            // top: BorderSide(width: 1.0),
                            // bottom: BorderSide(width: 1.0),
                            // left: BorderSide(width: 1.0),
                            // right: BorderSide(width: 1.0)
                            )),
                    child: Column(
                      children: [
                        CircleAvatar(
                          child: Icon(icons),
                        ),
                      ],
                    ),
                  ),
                  // 内容行（用于设置其中元素按照靠左右边缘排列）
                  // Expanded用于将其内部的元素给expanded, 而不是将邻居或父元素给expanded
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        // 左列（包含主标题、所在路径等）
                        DecoratedBox(
                            decoration: BoxDecoration(
                                color: Colors.lightGreen,
                                border: Border(
                                    top: BorderSide(width: 1.0),
                                    bottom: BorderSide(width: 1.0),
                                    left: BorderSide(width: 1.0),
                                    right: BorderSide(width: 1.0))),
                            child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [Text(title), Text(absolutePath)])),
                        // 空位置填空
                        // Expanded(child: SizedBox()),
                        // Expanded(child: Spacer()),
                        DecoratedBox(
                            decoration: BoxDecoration(
                                color: Colors.purple,
                                border: Border(
                                    top: BorderSide(width: 1.0),
                                    bottom: BorderSide(width: 1.0),
                                    left: BorderSide(width: 1.0),
                                    right: BorderSide(width: 1.0))),
                            child: Column(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      // Text(textAlign: TextAlign.end, suffix),
                                      Text(
                                          textAlign: TextAlign.end,
                                          size + ' bytes'),
                                    ],
                                  ),
                                  Row(
                                    children: [Text(modifiedAt)],
                                  )
                                ])),
                      ],
                    ),
                  )
                ])));

    // DecoratedBox(
    //     decoration: BoxDecoration(
    //         border: Border(
    //             top: BorderSide(width: 1.0),
    //             bottom: BorderSide(width: 1.0),
    //             left: BorderSide(width: 1.0),
    //             right: BorderSide(width: 1.0))),
    //     child: Column(
    //         mainAxisAlignment: MainAxisAlignment.end,
    //         mainAxisSize: MainAxisSize.max,
    //         children: [
    //         ])),
  }
}
