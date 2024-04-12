import 'dart:convert';

/// token_type : "Bearer"
/// access_token : "用来获取用户信息的 access_token。 刷新后，旧 access_token 不会立即失效。"
/// refresh_token : "单次有效，用来刷新 access_token，90 天有效期。刷新后，返回新的 refresh_token，请保存以便下一次刷新使用。"
/// expires_in : access_token的过期时间，单位秒。

AccessTokenResponse accessTokenResponseFromJson(String str) =>
    AccessTokenResponse.fromJson(json.decode(str));

String accessTokenResponseToJson(AccessTokenResponse data) =>
    json.encode(data.toJson());

class AccessTokenResponse {
  AccessTokenResponse({
    String? tokenType,
    String? accessToken,
    String? refreshToken,
    num? expiresIn,
  }) {
    _tokenType = tokenType;
    _accessToken = accessToken;
    _refreshToken = refreshToken;
    _expiresIn = expiresIn;
  }

  AccessTokenResponse.fromJson(dynamic json) {
    _tokenType = json['token_type'];
    _accessToken = json['access_token'];
    _refreshToken = json['refresh_token'];
    _expiresIn = json['expires_in'];
  }

  String? _tokenType;
  String? _accessToken;
  String? _refreshToken;
  num? _expiresIn;

  AccessTokenResponse copyWith({
    String? tokenType,
    String? accessToken,
    String? refreshToken,
    num? expiresIn,
  }) =>
      AccessTokenResponse(
        tokenType: tokenType ?? _tokenType,
        accessToken: accessToken ?? _accessToken,
        refreshToken: refreshToken ?? _refreshToken,
        expiresIn: expiresIn ?? _expiresIn,
      );

  String? get tokenType => _tokenType;

  String? get accessToken => _accessToken;

  String? get refreshToken => _refreshToken;

  num? get expiresIn => _expiresIn;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['token_type'] = _tokenType;
    map['access_token'] = _accessToken;
    map['refresh_token'] = _refreshToken;
    map['expires_in'] = _expiresIn;
    return map;
  }
}
