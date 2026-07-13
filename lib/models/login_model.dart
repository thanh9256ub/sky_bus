import 'package:skysoft_bus/models/action_result.dart';

import '../utils/fields.dart';
import '../utils/string_utils.dart';

class LoginRequest {
  String userName = "";
  String password = "";
  String appOs = "";
  String osVersion = "";
  String deviceID = "";
  String deviceName = "";
  String deviceModel = "";
  String deviceBrand = "";
  String appVersion = "";
  String fireBaseToken = "";
  bool reconnect = false;

  @override
  String toString() {
    return '{appOs: $appOs, deviceName: $deviceName, firebaseTo: $fireBaseToken}';
  }

  LoginRequest();

  Map<String, dynamic> toJson() {
    Map<String, dynamic> map = {
      F_USER_NAME: userName.trim(),
      F_PASSWORD: password.trim(),
      F_DEVICE_ID: deviceID,
      F_DEVICE_NAME: deviceName,
      F_DEVICE_MODEL: deviceModel,
      F_DEVICE_BRAND: deviceBrand,
      F_APP_OS: appOs,
      F_OS_VERSION: osVersion,
      F_APP_VERSION: appVersion,
      F_FIREBASE_TOKEN: fireBaseToken,
      F_RECONNECT: reconnect,
    };

    return map;
  }
}

class LoginResponse extends ActionResult {
  String loginState = "";
  String userName = "";
  String tokenID = "";
  int userID = 0;
  bool hasNewVersion = false;
  double x = 0;
  double y = 0;

  LoginResponse(super.errorCode, super.errorMessage);

  static Future<LoginResponse> fromJson(Map<String, dynamic> json) async {
    LoginResponse response = LoginResponse(
      nvl(json[F_ERROR_CODE]),
      nvl(json[F_ERROR_MESSAGE]),
    );

    response.loginState = nvl(json[F_LOGIN_STATE]);
    if (response.loginState != "OK") {
      return response;
    }

    response.userName = nvl(json[F_USER_NAME]);
    response.tokenID = nvl(json[F_TOKEN_ID]);
    response.userID = json[F_USER_ID] ?? 0;
    response.x = json[F_X] ?? 0;
    response.y = json[F_Y] ?? 0;

    return response;
  }
}
