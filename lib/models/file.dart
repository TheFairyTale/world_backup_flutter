import 'package:json_annotation/json_annotation.dart';

@JsonSerializable()
class File {
  File() {
    name = "";
    suffix = "";
    abstractPath = "";
    size = 0;
    createAt = "";
    modifiedAt = "";
  }

  late String name;
  late String suffix;
  String? abstractPath;
  late num size;
  late String createAt;
  late String modifiedAt;

  // factory File.fromJson(Map<String, dynamic> json) {
  //   return _$FileFromJson(json);
  // }

  // Map<String, dynamic> toJson() {
  //   return _$FileFToJson(this);
  // }
}
