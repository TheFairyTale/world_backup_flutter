import 'package:flutter/material.dart';
import 'package:flutter_demo/generated/json/base/json_field.dart';
import 'package:flutter_demo/generated/json/file_entity.g.dart';
import 'dart:convert';
export 'package:flutter_demo/generated/json/file_entity.g.dart';

@JsonSerializable()
class FileEntity {
  late String name;
  late String suffix;
  @JSONField(name: "abstractPath?")
  late String abstractpath;
  late int size;
  late String createAt;
  String? modifiedAt;

  FileEntity({
    required this.name,
    required this.suffix,
    required this.abstractpath,
    required this.size,
    required this.createAt,
    required this.modifiedAt,
  });

  factory FileEntity.fromJson(Map<String, dynamic> json) =>
      $FileEntityFromJson(json);

  Map<String, dynamic> toJson() => $FileEntityToJson(this);

  @override
  String toString() {
    return jsonEncode(this);
  }
}
