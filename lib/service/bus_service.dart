import 'dart:developer';

import 'package:skysoft_bus/models/ticket_model.dart';

import '../models/action_result.dart';
import '../models/bus_line_model.dart';
import '../models/vehicle_model.dart';
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
      return BusLineResponse.fromJson(response);
    } on Exception catch (e) {
      return BusLineResponse("FAIL", e.toString());
    }
  }

  Future<VehicleResponse> searchNearVehicles(
    double latitude,
    double longitude,
  ) async {
    String url = "$baseUrl/rest/bus/searchNearVehicles";
    try {
      Map<String, dynamic> map = {F_Y: latitude, F_X: longitude};
      final response = await httpService.post(url, body: map);
      return VehicleResponse.fromJson(response);
    } on Exception catch (e) {
      return VehicleResponse("FAIL", e.toString());
    }
  }

  Future<ActionResult> updateStarMark(int lineID, bool starMark) async {
    String url = "$baseUrl/rest/app/passenger/updateStarMark";
    try {
      Map<String, dynamic> map = {F_LINE_ID: lineID, F_STAR_MARK: starMark};
      final response = await httpService.post(url, body: map);
      return ActionResult.fromJson(response);
    } on Exception catch (e) {
      return ActionResult("FAIL", e.toString());
    }
  }

  Future<TicketResponse> addNewTicket(TicketAddRequest model) async {
    String url = "$baseUrl/rest/app/passenger/addNewTicket";
    try {
      final response = await httpService.post(url, body: model);
      return TicketResponse.fromJson(response);
    } on Exception catch (e) {
      return TicketResponse("FAIL", e.toString());
    }
  }

  Future<TicketListResponse> listTickets() async {
    String url = "$baseUrl/rest/app/passenger/listTickets";
    try {
      final response = await httpService.post(url);
      return TicketListResponse.fromJson(response);
    } on Exception catch (e) {
      return TicketListResponse("FAIL", e.toString());
    }
  }

  Future<BusCardResponse> getCard(String cardNo) async {
    String url = "$baseUrl/rest/bus/getCard";
    try {
      log("getCard request: $cardNo");
      final response = await httpService.post(url, body: {F_CARD_NO: cardNo});
      log("getCard response: $response");
      return BusCardResponse.fromJson(response);
    } on Exception catch (e) {
      return BusCardResponse("FAIL", e.toString());
    }
  }
}
