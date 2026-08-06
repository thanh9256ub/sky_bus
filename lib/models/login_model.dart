import 'package:skysoft_bus/models/action_result.dart';

import '../utils/date_utils.dart';
import '../utils/fields.dart';
import '../utils/string_utils.dart';

class LoginRequest {
  String accountID = "";
  DateTime time = DateTime.now();
  String authenKey = "";
  String appOS = "";
  String osVersion = "";
  String deviceID = "";
  String deviceName = "";
  String appVersion = "";
  String fireBaseToken = "";
  bool reconnect = false;
  String language = "";

  LoginRequest();

  Map<String, dynamic> toJson() {
    return {
      F_ACCOUNT_ID: nvl(accountID),
      F_TIME: DateTime.now().formatDateTimeTz(),
      F_AUTHEN_KEY: nvl(authenKey),
      F_APP_OS: nvl(appOS),
      F_OS_VERSION: nvl(osVersion),
      F_DEVICE_ID: nvl(deviceID),
      F_DEVICE_NAME: nvl(deviceName),
      F_APP_VERSION: nvl(appVersion),
      F_FIREBASE_TOKEN: nvl(fireBaseToken),
      F_RECONNECT: reconnect,
      F_LANGUAGE: nvl(language),
    };
  }
}

class SignupRequest {
  String mobileNo = "";
  String email = "";
  String fullName = "";
  String appOS = "";
  String signupType = "";
  String deviceID = "";
  String authenByFirebase = "";
  String language = "";
  String appName = "";

  SignupRequest();

  Map<String, dynamic> toJson() {
    Map<String, dynamic> map = {
      F_MOBILE_NO: mobileNo,
      F_EMAIL: email,
      F_FULL_NAME: fullName,
      F_APP_OS: appOS,
      F_SIGNUP_TYPE: signupType,
      F_DEVICE_ID: deviceID,
      F_AUTHEN_BY_FIREBASE: authenByFirebase,
      F_LANGUAGE: language,
      F_APP_NAME: appName,
    };

    return map;
  }
}

class SignupResponse extends ActionResult {
  String accountID = "";
  bool accountExisting = false;
  bool authenByFirebase = false;
  SignupResponse(super.errorCode, super.errorMessage);
  factory SignupResponse.fromJson(Map<String, dynamic> json) {
    SignupResponse model = SignupResponse(
      nvl(json[F_ERROR_CODE]),
      nvl(json[F_ERROR_MESSAGE]),
    );

    model.accountID = nvl(json[F_ACCOUNT_ID]);

    model.accountExisting = json[F_ACCOUNT_EXISTING] ?? false;
    model.authenByFirebase = json[F_AUTHEN_BY_FIREBASE] ?? false;
    return model;
  }
}

class LoginResponse extends ActionResult {
  bool authenByFirebase = false;
  String tokenID = "";
  String sessionID = "";
  String fullName = "";
  String mobileNo = "";

  LoginResponse(super.errorCode, super.errorMessage);

  static Future<LoginResponse> fromJson(Map<String, dynamic> json) async {
    final response = LoginResponse(
      nvl(json[F_ERROR_CODE]),
      nvl(json[F_ERROR_MESSAGE]),
    );

    response.authenByFirebase = json[F_AUTHEN_BY_FIREBASE] ?? false;

    response.tokenID = nvl(json[F_TOKEN_ID]);
    response.sessionID = nvl(json[F_SESSION_ID]);
    response.fullName = nvl(json[F_FULL_NAME]);
    response.mobileNo = nvl(json[F_MOBILE_NO]);

    return response;
  }
}

class ActiveRequest {
  String accountID = "";
  String activeKey = "";
  String uid = "";
  String deviceID = "";
  String tokenID = "";

  ActiveRequest();

  Map<String, dynamic> toJson() {
    return {
      F_ACCOUNT_ID: accountID,
      F_ACTIVE_KEY: activeKey,
      F_UID: uid,
      F_DEVICE_ID: deviceID,
      F_TOKEN_ID: tokenID,
    };
  }
}
