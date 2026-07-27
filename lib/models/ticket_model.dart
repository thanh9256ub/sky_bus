import 'dart:convert';
import 'dart:typed_data';

import 'package:skysoft_bus/models/action_result.dart';
import 'package:skysoft_bus/models/bus_line_model.dart';

import '../utils/date_utils.dart';
import '../utils/fields.dart';
import '../utils/string_utils.dart';

class TicketLine {
  static int LINE_BUS = 0;
  static int LINE_CAR = 1;
  static int LINE_LIMO = 2;

  String? id;
  int lineID = 0;
  String? description;
  int fromPlaceID = 0;
  int toPlaceID = 0;
  String fromPlaceName = "";
  String toPlaceName = "";
  DateTime? createDate;
  DateTime? expireDate;
  String creator = "";
  int tariff = 0;
  List<int> vehicles = [];

  TicketLine();

  factory TicketLine.fromJson(Map<String, dynamic> json) {
    TicketLine response = TicketLine();

    response.id = json[F_ID];
    response.lineID = json[F_LINE_ID];
    response.description = json[F_DESCRIPTION];
    response.fromPlaceID = json[F_FROM_PLACE_ID];
    response.toPlaceID = json[F_TO_PLACE_ID];
    response.fromPlaceName = json[F_FROM_PLACE_NAME];
    response.toPlaceName = json[F_TO_PLACE_NAME];
    response.createDate = nvl(json[F_CREATE_DATE]).parseTz;
    response.expireDate = nvl(json[F_EXPIRE_DATE]).parseTz;
    response.creator = json[F_CREATOR];

    var vehicles = json[F_VEHICLES];
    if (vehicles != null) {
      response.vehicles = (vehicles as List).map((e) => (e as int)).toList();
    }

    return response;
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> map = {
      F_ID: nvl(id),
      F_LINE_ID: lineID,
      F_FROM_PLACE_ID: fromPlaceID,
      F_TO_PLACE_ID: toPlaceID,
      F_EXPIRE_DATE: expireDate != null ? expireDate!.formatDateTimeTz() : "",
    };

    return map;
  }
}

class TicketCharge {
  int chargeID;
  int price = 0;
  int quantity = 0;
  String? description;

  TicketCharge(this.chargeID);

  factory TicketCharge.fromJson(Map<String, dynamic> json) {
    TicketCharge response = TicketCharge(json[F_CHARGE_ID]);

    response.quantity = json[F_QUANTITY];
    response.price = json[F_PRICE];
    response.description = json[F_DESCRIPTION];

    return response;
  }
}

class RechargeItem {
  int rechargeID = 0;
  String id = "";
  DateTime? createDate;
  DateTime? fromDate;
  DateTime? toDate;
  String creator = "";
  String note = "";
  String token = "";
  String type = "";
  String cardNo = "";
  String phoneNo = "";
  String fullName = "";
  double amount = 0;
  int balanceAmount = 0;
  int totalAmount = 0;
  int discountPercent = 0;
  int paidAmount = 0;
  bool prepaid = false;
  bool locked = false;
  List<Matrix> matrixes = [];

  RechargeItem();

  factory RechargeItem.fromJson(Map<String, dynamic> json) {
    RechargeItem response = RechargeItem();

    response.rechargeID = json[F_RECHARGE_ID] ?? 0;
    response.createDate = nvl(json[F_CREATE_DATE]).parseTz;
    response.fromDate = nvl(json[F_FROM_DATE]).parseTz;
    response.toDate = nvl(json[F_TO_DATE]).parseTz;

    response.creator = nvl(json[F_CREATOR]);
    response.note = nvl(json[F_NOTE]);
    response.type = nvl(json[F_TYPE]);

    response.cardNo = nvl(json[F_CARD_NO]);
    response.phoneNo = nvl(json[F_PHONE_NO]);
    response.fullName = nvl(json[F_FULL_NAME]);

    response.locked = json[F_LOCKED] ?? false;
    response.prepaid = json[F_PREPAID] ?? false;
    response.totalAmount = json[F_TOTAL_AMOUNT] ?? 0;
    var amount = json[F_AMOUNT] ?? 0;
    if (amount is double) {
      response.amount = amount;
    } else {
      response.amount = amount.toDouble();
    }
    response.discountPercent = json[F_DISCOUNT_PERCENT] ?? 0;
    response.paidAmount = json[F_PAID_AMOUNT] ?? 0;

    var tickPrices = json[F_MATRIX_PRICES];

    if (tickPrices != null) {
      response.matrixes = (tickPrices as List)
          .map((e) => Matrix.fromMTicketJson(e))
          .toList();
    }

    return response;
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> map = {
      F_ID: id,
      F_CARD_NO: cardNo,
      F_FROM_DATE: fromDate?.formatDateTimeTz(),
      F_TO_DATE: toDate?.formatDateTimeTz(),
      F_TOTAL_AMOUNT: totalAmount,
      F_DISCOUNT_PERCENT: discountPercent,
      F_PAID_AMOUNT: paidAmount,
      F_TOKEN: token,
      F_MATRIX_PRICES: matrixes.map((e) => e.toMTicketJson()).toList(),
    };

    return map;
  }
}

class RechargeListResult extends ActionResult {
  List<RechargeItem> recharges = [];

  RechargeListResult(super.errorCode, super.errorMessage);

  factory RechargeListResult.fromJson(Map<String, dynamic> json) {
    RechargeListResult response = RechargeListResult(
      nvl(json[F_ERROR_CODE]),
      nvl(json[F_ERROR_MESSAGE]),
    );

    if (response.errorMessage.isNotEmpty) {
      return response;
    }

    var recharges = json[F_RECHARGES];

    if (recharges != null) {
      response.recharges = (recharges as List)
          .map((e) => RechargeItem.fromJson(e))
          .toList();
    }

    return response;
  }
}

class BusCard {
  String? id;
  String cardNo;
  String? fullName;
  String? idCardNo;
  String? phoneNo;
  String? email;
  DateTime? expireDate;
  bool valid = false;
  bool locked = false;
  bool prepaid = false;
  bool requirePhoto = false;
  double balanceAmount = 0;
  int discountPercent = 0;
  int priorityID = 0;
  String priorityDescription = "Thẻ thường";
  DateTime? endDiscountDate;
  String token = "";
  Uint8List? avatar;
  DateTime? avatarDate;
  String avatarMd5 = "";
  String note = "";
  List<RechargeItem> rechargeItems = [];
  List<RechargeItem> prepaidRechargeItems = [];

  BusCard(this.cardNo);

  factory BusCard.fromJson(Map<String, dynamic> json) {
    BusCard response = BusCard(json[F_CARD_NO]);

    response.id = json[F_ID];
    response.fullName = json[F_FULL_NAME];
    response.phoneNo = json[F_PHONE_NO];
    response.idCardNo = json[F_ID_CARD_NO];
    response.valid = json[F_VALID];
    response.locked = json[F_LOCKED];
    response.token = json[F_TOKEN] ?? "";
    response.email = json[F_EMAIL];
    response.expireDate = nvl(json[F_EXPIRE_DATE]).parseTz;
    response.avatarDate = nvl(json[F_AVATAR_DATE]).parseTz;
    response.avatarMd5 = nvl(json[F_AVATAR_MD5]);
    var balanceAmount = json[F_BALANCE_AMOUNT] ?? 0;
    if (balanceAmount is double) {
      response.balanceAmount = balanceAmount;
    } else {
      response.balanceAmount = balanceAmount.toDouble();
    }
    response.prepaid = json[F_PREPAID] ?? false;
    response.requirePhoto = json[F_REQUIRE_PHOTO] ?? false;
    response.discountPercent = json[F_DISCOUNT_PERCENT] ?? 0;
    response.endDiscountDate = nvl(json[F_END_DISCOUNT_DATE]).parseTz;
    response.priorityID = json[F_PRIORITY_ID] ?? 0;
    response.priorityDescription = nvl(json[F_PRIORITY_DESCRIPTION]);
    response.note = nvl(json[F_NOTE]);

    var rechargeItems = json[F_RECHARGES];

    if (rechargeItems != null) {
      response.rechargeItems = (rechargeItems as List)
          .map((e) => RechargeItem.fromJson(e))
          .toList();
    }

    rechargeItems = json[F_PREPAID_RECHARGES];

    if (rechargeItems != null) {
      response.prepaidRechargeItems = (rechargeItems as List)
          .map((e) => RechargeItem.fromJson(e))
          .toList();
    }

    return response;
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> map = {
      F_ID: nvl(id),
      F_CARD_NO: cardNo,
      F_FULL_NAME: nvl(fullName),
      F_ID_CARD_NO: nvl(idCardNo),
      F_PHONE_NO: nvl(phoneNo),
      F_EMAIL: nvl(email),
      F_NOTE: nvl(note),
      F_PREPAID: prepaid,
      F_PRIORITY_ID: priorityID,
      F_DISCOUNT_PERCENT: discountPercent,
      F_END_DISCOUNT_DATE: endDiscountDate != null
          ? endDiscountDate!.formatDate
          : "",
      F_AVATAR: avatar != null ? base64.encoder.convert(avatar!) : "",
      F_TOKEN: token.isNotEmpty ? token : null,
    };

    return map;
  }
}
