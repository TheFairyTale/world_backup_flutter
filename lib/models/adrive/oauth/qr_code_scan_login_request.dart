import 'dart:convert';

/// client_id : 应用注册时分配的
/// client_secret : 应用注册时分配的。pkce模式下，不需要传
/// scopes : 申请的授权范围 详见 用户授权与权限列表
/// width : 二维码宽度，默认 430
/// height : 二维码高度，默认 430
/// code_challenge 一个长度 43 - 128 的随机字符串。
/// code_challenge_method  如果 code_challenge_method 是 plain，可以不用计算，直接明
///                        文传递一个长度大于等于 43 的字符串。 推荐：如果
///                        code_challenge_method 是 S256，首先生成一个字符串 S，
///                        计算 SHA256(S) 得到一个二进制 Buffer，然后将其转为 base64 编码。伪代码：
///                        BASE64URL-ENCODE(SHA256(ASCII(S)))
///

QrCodeScanLoginRequest qrCodeScanLoginRequestFromJson(String str) =>
    QrCodeScanLoginRequest.fromJson(json.decode(str));

String qrCodeScanLoginRequestToJson(QrCodeScanLoginRequest data) =>
    json.encode(data.toJson());

class QrCodeScanLoginRequest {
  QrCodeScanLoginRequest({
    String? clientId,
    String? clientSecret,
    List<String>? scopes,
    num? width,
    num? height,
  }) {
    _clientId = clientId;
    _clientSecret = clientSecret;
    _scopes = scopes;
    _width = width;
    _height = height;
  }

  QrCodeScanLoginRequest.fromJson(dynamic json) {
    _clientId = json['client_id'];
    _clientSecret = json['client_secret'];
    _scopes = json['scopes'] != null ? json['scopes'].cast<String>() : [];
    _width = json['width'];
    _height = json['height'];
  }

  String? _clientId;
  String? _clientSecret;
  List<String>? _scopes;
  num? _width;
  num? _height;

  QrCodeScanLoginRequest copyWith({
    String? clientId,
    String? clientSecret,
    List<String>? scopes,
    num? width,
    num? height,
  }) =>
      QrCodeScanLoginRequest(
        clientId: clientId ?? _clientId,
        clientSecret: clientSecret ?? _clientSecret,
        scopes: scopes ?? _scopes,
        width: width ?? _width,
        height: height ?? _height,
      );

  String? get clientId => _clientId;

  String? get clientSecret => _clientSecret;

  List<String>? get scopes => _scopes;

  num? get width => _width;

  num? get height => _height;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['client_id'] = _clientId;
    map['client_secret'] = _clientSecret;
    map['scopes'] = _scopes;
    map['width'] = _width;
    map['height'] = _height;
    return map;
  }
}
