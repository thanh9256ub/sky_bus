import 'package:http/http.dart' as http;

import '../utils/global.dart';

class MapService {
  Future<String> getAddress(double x, double y) async {
    String url = "$skymapUrl/get_address.jsp?x=$x&y=$y";
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        return response.body;
      }
      return "";
    } catch (e) {
      return "Lỗi lấy địa chỉ";
    }
  }
}
