import 'dart:convert';
import 'dart:developer';

import '../models/bus_line_model.dart';
import '../utils/fields.dart';
import '../utils/global.dart';
import '../utils/http_service.dart';

class BusService {
  Future<BusLineResponse> listECheckBusLines(
    int type,
    bool includeMatrix,
  ) async {
    Map<String, dynamic> map = {
      F_LINE_TYPE: type,
      F_INCLUDE_MATRIX: includeMatrix,
    };
    String url = "$baseUrl/rest/app/listECheckBusLines";
    try {
      final response = await httpService.post(url, body: map);
      return BusLineResponse.fromJson(response);
    } on Exception catch (e) {
      return BusLineResponse("FAIL", e.toString());
    }
  }

  Future<BusLineResponse> listBusLines() async {
    String url = "$baseUrl/rest/bus/listBusLines";
    try {
      final response = await httpService.post(url);
      log(jsonEncode(response));
      return BusLineResponse.fromJson(response);
    } on Exception catch (e) {
      return BusLineResponse("FAIL", e.toString());
    }
  }
}
