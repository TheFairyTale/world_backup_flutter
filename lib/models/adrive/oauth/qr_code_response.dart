import 'dart:convert';

/// status : "QRCodeExpired"
/// authCode : ""

QrCodeResponse qrCodeResponseFromJson(String str) => QrCodeResponse.fromJson(json.decode(str));
String qrCodeResponseToJson(QrCodeResponse data) => json.encode(data.toJson());
class QrCodeResponse {
  QrCodeResponse({
      String? status, 
      String? authCode,}){
    _status = status;
    _authCode = authCode;
}

  QrCodeResponse.fromJson(dynamic json) {
    _status = json['status'];
    _authCode = json['authCode'];
  }
  String? _status;
  String? _authCode;
QrCodeResponse copyWith({  String? status,
  String? authCode,
}) => QrCodeResponse(  status: status ?? _status,
  authCode: authCode ?? _authCode,
);
  String? get status => _status;
  String? get authCode => _authCode;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['status'] = _status;
    map['authCode'] = _authCode;
    return map;
  }

}