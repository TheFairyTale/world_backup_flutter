import 'package:flutter_demo/generated/json/base/json_convert_content.dart';
import 'package:flutter_demo/models/file_entity.dart';

FileEntity $FileEntityFromJson(Map<String, dynamic> json) {
  final String? name = jsonConvert.convert<String>(json['name']);
  final String? suffix = jsonConvert.convert<String>(json['suffix']);
  final String? abstractpath =
      jsonConvert.convert<String>(json['abstractPath?']);
  final int? size = jsonConvert.convert<int>(json['size']);
  final String? createAt = jsonConvert.convert<String>(json['createAt']);
  final String? modifiedAt = jsonConvert.convert<String>(json['modifiedAt']);

  final FileEntity fileEntity = FileEntity(
      name: name!,
      suffix: suffix!,
      abstractpath: abstractpath!,
      size: size!,
      createAt: createAt!,
      modifiedAt: modifiedAt);

  if ((name != null) &&
      (suffix != null) &&
      (abstractpath != null) &&
      (size != null) &&
      (createAt != null) &&
      (modifiedAt != null)) {
    fileEntity.name = name;
    fileEntity.suffix = suffix;
    fileEntity.abstractpath = abstractpath;
    fileEntity.size = size;
    fileEntity.createAt = createAt;
    fileEntity.modifiedAt = modifiedAt;
  }
  return fileEntity;
}

Map<String, dynamic> $FileEntityToJson(FileEntity entity) {
  final Map<String, dynamic> data = <String, dynamic>{};
  data['name'] = entity.name;
  data['suffix'] = entity.suffix;
  data['abstractPath?'] = entity.abstractpath;
  data['size'] = entity.size;
  data['createAt'] = entity.createAt;
  data['modifiedAt'] = entity.modifiedAt;
  return data;
}

extension FileEntityExtension on FileEntity {
  FileEntity copyWith({
    String? name,
    String? suffix,
    String? abstractpath,
    int? size,
    String? createAt,
    String? modifiedAt,
  }) {
    return FileEntity(
        name: name!,
        suffix: suffix!,
        abstractpath: abstractpath!,
        size: size!,
        createAt: createAt!,
        modifiedAt: modifiedAt)
      ..name = name ?? this.name
      ..suffix = suffix ?? this.suffix
      ..abstractpath = abstractpath ?? this.abstractpath
      ..size = size ?? this.size
      ..createAt = createAt ?? this.createAt
      ..modifiedAt = modifiedAt ?? this.modifiedAt;
  }
}
