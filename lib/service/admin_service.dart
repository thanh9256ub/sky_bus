import 'dart:convert';
import 'dart:developer';

import '../models/login_model.dart';
import '../utils/fields.dart';
import '../utils/global.dart';
import '../utils/http_service.dart';

class AdminService {
  Future<LoginResponse> login(LoginRequest requestModel) async {
    String url = "$baseUrl/rest/app/passenger/login";
    try {
      log("request: ${jsonEncode(requestModel)}");
      final response = await httpService.post(url, body: requestModel.toJson());
      log(jsonEncode(response));
      return await LoginResponse.fromJson(response);
    } on Exception catch (e) {
      return LoginResponse("FAIL", e.toString());
    }
  }

  Future<SignupResponse> signup(SignupRequest requestModel) async {
    String url = "$baseUrl/rest/app/passenger/signup";
    try {
      final response = await httpService.post(url, body: requestModel.toJson());
      return SignupResponse.fromJson(response);
    } on Exception catch (e) {
      return SignupResponse("FAIL", e.toString());
    }
  }

  Future<ActiveResponse> activatePassenger(ActiveRequest requestModel) async {
    String url = "$baseUrl/rest/app/passenger/activatePassenger";
    try {
      final response = await httpService.post(url, body: requestModel.toJson());
      log("Active Rp:${jsonEncode(response)}");
      return await ActiveResponse.fromJson(response);
    } on Exception catch (e) {
      return ActiveResponse("FAIL", e.toString());
    }
  }

  Future<SignupResponse> reactivePassenger(
    String mobileNo,
    String deviceSerial,
    String appOs,
    String language,
  ) async {
    String url = "$baseUrl/rest/app/passenger/reactivePassenger";
    try {
      Map<String, dynamic> map = {
        F_MOBILE_NO: mobileNo,
        F_DEVICE_ID: deviceSerial,
        F_APP_OS: appOs,
        F_LANGUAGE: language,
      };
      final response = await httpService.post(url, body: map);
      return SignupResponse.fromJson(response);
    } on Exception catch (e) {
      return SignupResponse("FAIL", e.toString());
    }
  }
}
