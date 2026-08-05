import 'package:skysoft_bus/models/action_result.dart';

import '../utils/fields.dart';
import '../utils/string_utils.dart';

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

class SignupResponse {
  String accountID = "";
  bool accountExisting = false;
  bool authenByFirebase = false;
  SignupResponse();
  factory SignupResponse.fromJson(Map<String, dynamic> json) {
    SignupResponse model = SignupResponse();

    model.accountID = nvl(json[F_ACCOUNT_ID]);

    model.accountExisting = json[F_ACCOUNT_EXISTING] ?? false;
    model.authenByFirebase = json[F_AUTHEN_BY_FIREBASE] ?? false;
    return model;
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
