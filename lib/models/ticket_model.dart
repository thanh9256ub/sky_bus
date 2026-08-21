import 'package:skysoft_bus/models/action_result.dart';

import '../utils/fields.dart';
import '../utils/string_utils.dart';

class Ticket {
  static const int STATE_INPUT = 0;
  static const int STATE_PAID = 1;
  static const int STATE_USED = 2;

  String id = "";
  String accountID = "";
  DateTime? createDate;
  int lineID = 0;
  int fromPlaceID = 0;
  String fromPlaceName = "";
  int toPlaceID = 0;
  String toPlaceName = "";
  int price = 0;
  int quantity = 0;
  int customerID = 0;
  int bankID = 0;
  String bankAccountNo = "";
  String qrCode = "";
  int state = 0;
  Ticket();

  factory Ticket.fromJson(Map<String, dynamic> json) {
    Ticket model = Ticket();

    model.id = json[F_ID] ?? "";
    model.accountID = nvl(json[F_ACCOUNT_ID]);
    model.createDate = nvl(json[F_CREATE_DATE]).parseTz;
    model.lineID = json[F_LINE_ID] ?? 0;
    model.fromPlaceID = json[F_FROM_PLACE_ID] ?? 0;
    model.fromPlaceName = nvl(json[F_FROM_PLACE_NAME]);
    model.toPlaceID = json[F_TO_PLACE_ID] ?? 0;
    model.toPlaceName = nvl(json[F_TO_PLACE_NAME]);
    model.price = json[F_PRICE] ?? 0;
    model.quantity = json[F_QUANTITY] ?? 0;
    model.customerID = json[F_CUSTOMER_ID] ?? 0;
    model.bankID = json[F_BANK_ID] ?? 0;
    model.bankAccountNo = nvl(json[F_BANK_ACCOUNT_NO]);
    model.qrCode = nvl(json[F_QR_CODE]);
    model.state = json[F_STATE] ?? 0;
    return model;
  }
}

class TicketResponse extends ActionResult {
  Ticket ticket = Ticket();

  TicketResponse(super.errorCode, super.errorMessage);

  factory TicketResponse.fromJson(Map<String, dynamic> json) {
    TicketResponse model = TicketResponse(
      nvl(json[F_ERROR_CODE]),
      nvl(json[F_ERROR_MESSAGE]),
    );
    var ticket = json[F_TICKET];
    if (ticket != null) {
      model.ticket = Ticket.fromJson(ticket);
    }

    return model;
  }
}

class TicketListResponse extends ActionResult {
  List<Ticket> tickets = [];

  TicketListResponse(super.errorCode, super.errorMessage);

  factory TicketListResponse.fromJson(Map<String, dynamic> json) {
    TicketListResponse model = TicketListResponse(
      nvl(json[F_ERROR_CODE]),
      nvl(json[F_ERROR_MESSAGE]),
    );
    var tickets = json[F_TICKETS];
    if (tickets != null) {
      model.tickets = (tickets as List).map((e) => Ticket.fromJson(e)).toList();
    }

    return model;
  }
}

class TicketAddRequest {
  int lineID = 0;
  int fromPlaceID = 0;
  int toPlaceID = 0;
  int price = 0;
  int quantity = 0;

  TicketAddRequest();
  Map<String, dynamic> toJson() {
    Map<String, dynamic> map = {
      F_LINE_ID: lineID,
      F_FROM_PLACE_ID: fromPlaceID,
      F_TO_PLACE_ID: toPlaceID,
      F_PRICE: price,
      F_QUANTITY: quantity,
    };

    return map;
  }
}
