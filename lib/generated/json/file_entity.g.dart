import 'package:flutter_demo/generated/json/base/json_convert_content.dart';
import 'package:flutter_demo/models/file_entity.dart';

FileEntity $FileEntityFromJson(Map<String, dynamic> json) {
  final FileEntity fileEntity = FileEntity();
  final String? name = jsonConvert.convert<String>(json['name']);
  if (name != null) {
    fileEntity.name = name;
  }
  final String? suffix = jsonConvert.convert<String>(json['suffix']);
  if (suffix != null) {
    fileEntity.suffix = suffix;
  }
  final String? abstractpath = jsonConvert.convert<String>(
      json['abstractPath?']);
  if (abstractpath != null) {
    fileEntity.abstractpath = abstractpath;
  }
  final int? size = jsonConvert.convert<int>(json['size']);
  if (size != null) {
    fileEntity.size = size;
  }
  final String? createAt = jsonConvert.convert<String>(json['createAt']);
  if (createAt != null) {
    fileEntity.createAt = createAt;
  }
  final String? modifiedAt = jsonConvert.convert<String>(json['modifiedAt']);
  if (modifiedAt != null) {
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
    return FileEntity()
      ..name = name ?? this.name
      ..suffix = suffix ?? this.suffix
      ..abstractpath = abstractpath ?? this.abstractpath
      ..size = size ?? this.size
      ..createAt = createAt ?? this.createAt
      ..modifiedAt = modifiedAt ?? this.modifiedAt;
  }
}