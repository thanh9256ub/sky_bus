import 'dart:convert';
import 'dart:developer';

import 'package:skysoft_bus/models/action_result.dart';
import 'package:skysoft_bus/utils/fields.dart';

import '../models/login_model.dart';
import '../utils/global.dart';
import '../utils/http_service.dart';

class AdminService {
  Future<LoginResponse> login(SignupRequest requestModel) async {
    String url = "$baseUrl/rest/admin/mobile/login";
    try {
      final response = await httpService.post(url, body: requestModel.toJson());
      log(jsonEncode(response));
      return LoginResponse.fromJson(response);
    } on Exception catch (e) {
      return LoginResponse("FAIL", e.toString());
    }
  }

  Future<ActionResult> signup(SignupRequest requestModel) async {
    String url = "$baseUrl/rest/app/passenger/signup";
    try {
      log("model: ${jsonEncode(requestModel)}");
      final response = await httpService.post(url, body: requestModel.toJson());
      log(jsonEncode(response));
      return ActionResult.fromJson(response);
    } on Exception catch (e) {
      return ActionResult("FAIL", e.toString());
    }
  }

  Future<ActionResult> reactivePassenger(
    String mobileNo,
    String deviceID,
    String appOS,
    String language,
  ) async {
    String url = "$baseUrl/rest/app/passenger/signup";
    try {
      Map<String, dynamic> map = {
        F_MOBILE_NO: mobileNo,
        F_DEVICE_ID: deviceID,
        F_APP_OS: appOS,
        F_LANGUAGE: language,
      };
      log("model: ${jsonEncode(map)}");
      final response = await httpService.post(url, body: map);
      log(jsonEncode(response));
      return ActionResult.fromJson(response);
    } on Exception catch (e) {
      return ActionResult("FAIL", e.toString());
    }
  }
}
