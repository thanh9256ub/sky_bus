import '../models/login_model.dart';
import '../utils/global.dart';
import '../utils/http_service.dart';

class AdminService {
  Future<LoginResponse> login(LoginRequest requestModel) async {
    String url = "$baseUrl/rest/win/v2/login";
    try {
      final response = await httpService.post(url, body: requestModel.toJson());
      return LoginResponse.fromJson(response);
    } on Exception catch (e) {
      return LoginResponse("FAIL", e.toString());
    }
  }
}
