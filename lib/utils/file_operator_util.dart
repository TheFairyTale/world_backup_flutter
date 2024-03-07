import 'dart:io';

import 'package:flustars_flutter3/flustars_flutter3.dart';

class FileOperatorUtil {
  /// 遍历指定文件夹下的文件
  ///
  static Future<Stream<FileSystemEntity>> dirList(String path) async {
    LogUtil.d("入参: " + path);
    var dirObj = Directory(path);

    Stream<FileSystemEntity>? fileSystemEntities = null;
    await dirObj.exists().then((value) {
      if (value) {
        LogUtil.d("有值: " + dirObj.absolute.path);
        fileSystemEntities = Directory(path).list();
        // fileSystemEntities?.forEach((element) {
        //   LogUtil.d(element.absolute.path);
        // });
      } else {
        LogUtil.d("无值, 正在创建... " + dirObj.absolute.path);
        Future<Directory> directory = dirObj.create();
        directory.then((value) => LogUtil.d("创建结果：" + value.absolute.path));
      }
    });

    LogUtil.d("即将返回：" + fileSystemEntities.toString());
    // todo Null check operator used on a null value
    return fileSystemEntities!;
  }
}
