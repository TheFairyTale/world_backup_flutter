import 'dart:convert';

/// client_id : "应用标识，创建应用时分配的 appId"
/// client_secret : "应用密钥，创建应用时分配的 secret。pkce模式下不需要传"
/// grant_type : "身份类型 authorization_code 或 refresh_token"
/// code : "授权码"
/// refresh_token : "刷新 token，单次请求有效。"
/// code_verifier : "PKCE 授权链接时生成的随机字符串值,也就是 code_challenge 原始值，不是其摘要值。"

AccessTokenRequest accessTokenRequestFromJson(String str) => AccessTokenRequest.fromJson(json.decode(str));
String accessTokenRequestToJson(AccessTokenRequest data) => json.encode(data.toJson());
class AccessTokenRequest {
  AccessTokenRequest({
      String? clientId, 
      String? clientSecret, 
      String? grantType, 
      String? code, 
      String? refreshToken, 
      String? codeVerifier,}){
    _clientId = clientId;
    _clientSecret = clientSecret;
    _grantType = grantType;
    _code = code;
    _refreshToken = refreshToken;
    _codeVerifier = codeVerifier;
}

  AccessTokenRequest.fromJson(dynamic json) {
    _clientId = json['client_id'];
    _clientSecret = json['client_secret'];
    _grantType = json['grant_type'];
    _code = json['code'];
    _refreshToken = json['refresh_token'];
    _codeVerifier = json['code_verifier'];
  }
  String? _clientId;
  String? _clientSecret;
  String? _grantType;
  String? _code;
  String? _refreshToken;
  String? _codeVerifier;
AccessTokenRequest copyWith({  String? clientId,
  String? clientSecret,
  String? grantType,
  String? code,
  String? refreshToken,
  String? codeVerifier,
}) => AccessTokenRequest(  clientId: clientId ?? _clientId,
  clientSecret: clientSecret ?? _clientSecret,
  grantType: grantType ?? _grantType,
  code: code ?? _code,
  refreshToken: refreshToken ?? _refreshToken,
  codeVerifier: codeVerifier ?? _codeVerifier,
);
  String? get clientId => _clientId;
  String? get clientSecret => _clientSecret;
  String? get grantType => _grantType;
  String? get code => _code;
  String? get refreshToken => _refreshToken;
  String? get codeVerifier => _codeVerifier;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['client_id'] = _clientId;
    map['client_secret'] = _clientSecret;
    map['grant_type'] = _grantType;
    map['code'] = _code;
    map['refresh_token'] = _refreshToken;
    map['code_verifier'] = _codeVerifier;
    return map;
  }

}