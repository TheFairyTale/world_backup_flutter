import 'package:flutter_demo/generated/json/base/json_field.dart';
import 'package:flutter_demo/generated/json/file_entity.g.dart';
import 'dart:convert';
export 'package:flutter_demo/generated/json/file_entity.g.dart';

@JsonSerializable()
class FileEntity {
	String? name;
	String? suffix;
	@JSONField(name: "abstractPath?")
	String? abstractpath;
	int? size;
	String? createAt;
	String? modifiedAt;

	FileEntity();

	factory FileEntity.fromJson(Map<String, dynamic> json) => $FileEntityFromJson(json);

	Map<String, dynamic> toJson() => $FileEntityToJson(this);

	@override
	String toString() {
		return jsonEncode(this);
	}
}