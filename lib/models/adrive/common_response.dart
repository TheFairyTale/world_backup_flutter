import 'dart:convert';

/// code : "AppNotExists"
/// message : "app not exists"
/// requestId : "xxx"

CommonResponse commonResponseFromJson(String str) => CommonResponse.fromJson(json.decode(str));
String commonResponseToJson(CommonResponse data) => json.encode(data.toJson());
class CommonResponse {
  CommonResponse({
      String? code, 
      String? message, 
      String? requestId,}){
    _code = code;
    _message = message;
    _requestId = requestId;
}

  CommonResponse.fromJson(dynamic json) {
    _code = json['code'];
    _message = json['message'];
    _requestId = json['requestId'];
  }
  String? _code;
  String? _message;
  String? _requestId;
CommonResponse copyWith({  String? code,
  String? message,
  String? requestId,
}) => CommonResponse(  code: code ?? _code,
  message: message ?? _message,
  requestId: requestId ?? _requestId,
);
  String? get code => _code;
  String? get message => _message;
  String? get requestId => _requestId;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['code'] = _code;
    map['message'] = _message;
    map['requestId'] = _requestId;
    return map;
  }

}