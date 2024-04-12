import 'dart:convert';

/// qrCodeUrl : "https://open.aliyundrive.com/oauth/qrcode/ed7ae7e4dd104667a185cc76d77f9c"
/// sid : "ed7ae7e4dd104667a185cc76d77f3"

QrCodeScanLoginResponse qrCodeScanLoginResponseFromJson(String str) => QrCodeScanLoginResponse.fromJson(json.decode(str));
String qrCodeScanLoginResponseToJson(QrCodeScanLoginResponse data) => json.encode(data.toJson());
class QrCodeScanLoginResponse {
  QrCodeScanLoginResponse({
      String? qrCodeUrl, 
      String? sid,}){
    _qrCodeUrl = qrCodeUrl;
    _sid = sid;
}

  QrCodeScanLoginResponse.fromJson(dynamic json) {
    _qrCodeUrl = json['qrCodeUrl'];
    _sid = json['sid'];
  }
  String? _qrCodeUrl;
  String? _sid;
QrCodeScanLoginResponse copyWith({  String? qrCodeUrl,
  String? sid,
}) => QrCodeScanLoginResponse(  qrCodeUrl: qrCodeUrl ?? _qrCodeUrl,
  sid: sid ?? _sid,
);
  String? get qrCodeUrl => _qrCodeUrl;
  String? get sid => _sid;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['qrCodeUrl'] = _qrCodeUrl;
    map['sid'] = _sid;
    return map;
  }

}