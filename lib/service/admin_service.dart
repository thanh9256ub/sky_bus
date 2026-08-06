import '../models/login_model.dart';
import '../utils/global.dart';
import '../utils/http_service.dart';

class AdminService {
  Future<LoginResponse> login(LoginRequest requestModel) async {
    String url = "$baseUrl/rest/app/passenger/login";
    try {
      final response = await httpService.post(url, body: requestModel.toJson());
      return LoginResponse.fromJson(response);
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

  Future<SignupResponse> activatePassenger(ActiveRequest requestModel) async {
    String url = "$baseUrl/rest/app/passenger/activatePassenger";
    try {
      final response = await httpService.post(url, body: requestModel.toJson());
      return SignupResponse.fromJson(response);
    } on Exception catch (e) {
      return SignupResponse("FAIL", e.toString());
    }
  }

  Future<SignupResponse> reactivePassenger(SignupRequest requestModel) async {
    String url = "$baseUrl/rest/app/passenger/reactivePassenger";
    try {
      final response = await httpService.post(url, body: requestModel.toJson());
      return SignupResponse.fromJson(response);
    } on Exception catch (e) {
      return SignupResponse("FAIL", e.toString());
    }
  }
}
