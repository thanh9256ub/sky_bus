import 'dart:typed_data';

import 'package:latlong2/latlong.dart';
import 'package:skysoft_bus/models/action_result.dart';

import '../utils/fields.dart';
import '../utils/string_utils.dart';

class BusLine {
  int lineID;
  String description;
  String lineNo = "";
  int color = 0;
  List<int> places = [];
  List<int> vehicles = [];
  List<Place> placeMarks = [];
  List<LatLng> wayPoints = [];
  List<Matrix> matrixPrices = [];
  String schedules = "";
  bool starMark = false;
  LatLng? startPoint;
  LatLng? endPoint;

  BusLine(this.lineID, this.description);

  factory BusLine.fromJson(Map<String, dynamic> json) {
    BusLine response = BusLine(json[F_LINE_ID], nvl(json[F_DESCRIPTION]));

    response.color = json[F_LINE_COLOR];

    response.lineNo = nvl(json[F_LINE_NO]);
    response.schedules = nvl(json[F_SCHEDULES]);

    List<dynamic>? places = json[F_PLACES];

    if (places != null) {
      response.places = List<int>.from(places);
    }

    List<dynamic>? vehicles = json[F_VEHICLES];

    if (vehicles != null) {
      response.vehicles = List<int>.from(vehicles);
    }

    var matrixPrices = json[F_MATRIX_PRICES];

    if (matrixPrices != null) {
      response.matrixPrices = (matrixPrices as List)
          .map((e) => Matrix.fromMTicketJson(e))
          .toList();
    }
    var wayPoints = json[F_WAY_POINTS];

    if (wayPoints != null) {
      response.wayPoints = (wayPoints as List)
          .map((e) => LatLng(e[F_Y], e[F_X]))
          .toList();

      if (response.wayPoints.isNotEmpty) {
        response.startPoint = response.wayPoints[0];
        response.endPoint = response.wayPoints[response.wayPoints.length - 1];
      }
    }
    response.starMark = json[F_STAR_MARK] ?? false;
    var placeMarks = json[F_PLACE_MARKS];
    if (placeMarks != null) {
      response.placeMarks = (placeMarks as List)
          .map((e) => Place.fromJson(e))
          .toList();
    }

    return response;
  }
}

class BusLineResponse extends ActionResult {
  List<BusLine> busLines = [];

  BusLineResponse(super.errorCode, super.errorMessage);

  factory BusLineResponse.fromJson(Map<String, dynamic> json) {
    BusLineResponse response = BusLineResponse(
      nvl(json[F_ERROR_CODE]),
      nvl(json[F_ERROR_MESSAGE]),
    );

    if (response.errorMessage.isNotEmpty) {
      return response;
    }

    var busLines = json[F_TRAVEL_LINES];

    if (busLines != null) {
      response.busLines = (busLines as List)
          .map((e) => BusLine.fromJson(e))
          .toList();
    }

    return response;
  }
}

class Place {
  int placeID;
  String description;
  double x = 0;
  double y = 0;
  DateTime? createDate;
  DateTime? updateDate;
  int textColor = 0;
  int direction = 0;
  int iconID = 0;
  bool monitoringMark = false;
  int radius = 50;
  String? note;
  String? textToSpeech;
  bool granted = false;
  bool origGranted = false;

  Place(this.placeID, this.description);

  factory Place.fromJson(Map<String, dynamic> json) {
    Place response = Place(json[F_PLACE_ID] ?? 0, nvl(json[F_DESCRIPTION]));

    response.x = json[F_X];
    response.y = json[F_Y];
    response.textColor = json[F_TEXT_COLOR];
    response.iconID = json[F_ICON_ID];
    response.radius = json[F_RADIUS] ?? 50;

    response.granted = json[F_GRANTED] ?? false;
    response.origGranted = response.granted;
    return response;
  }
}

class Matrix {
  String key;
  int count = 0;
  int mTicketCount = 0;
  int countFree = 0;
  int countPromotion = 0;
  int countPrepaid = 0;
  int countPromotionPrepaid = 0;
  int price = 0;
  int promotionPrice = 0;
  int mTicketPrice = 0;
  int shippingFee = 0;
  int fromPlaceID = 0;
  int toPlaceID = 0;
  String fromPlaceName = "";
  String toPlaceName = "";
  bool checked = false;
  bool invalid = false;
  bool free = false;
  bool promotion = false;
  int checkerID = 0;
  int lineID = 0;
  String lineName = "";

  Matrix(this.key);

  factory Matrix.fromJson(Map<String, dynamic> json) {
    Matrix response = Matrix(json[F_KEY]);

    response.count = json[F_COUNT];
    response.mTicketCount = json[F_MTICKET_COUNT] ?? 0;
    response.countFree = json[F_COUNT_FREE] ?? 0;
    response.countPromotion = json[F_COUNT_PROMOTION] ?? 0;
    response.countPromotionPrepaid = json[F_COUNT_PROMOTION_PREPAID] ?? 0;
    response.countPrepaid = json[F_COUNT_PREPAID] ?? 0;
    response.price = json[F_PRICE];
    response.promotionPrice = json[F_PROMOTION_PRICE] ?? 0;
    response.mTicketPrice = json[F_M_TICKET_PRICE] ?? 0;
    response.price = json[F_PRICE] ?? 0;
    response.checked = json[F_CHECKED];
    response.invalid = json[F_INVALID];
    response.checkerID = json[F_CHECKER_ID];
    response.shippingFee = json[F_SHIPPING_FEE];
    response.lineID = json[F_LINE_ID] ?? 0;
    response.lineName = json[F_LINE_NAME] ?? "";
    response.fromPlaceName = json[F_FROM_PLACE_NAME] ?? "";
    response.toPlaceName = json[F_TO_PLACE_NAME] ?? "";

    return response;
  }

  factory Matrix.fromMTicketJson(Map<String, dynamic> json) {
    Matrix response = Matrix("");

    response.lineID = json[F_LINE_ID] ?? 0;
    response.lineName = json[F_LINE_NAME] ?? "";
    response.fromPlaceID = json[F_FROM_PLACE_ID];
    response.fromPlaceName = json[F_FROM_PLACE_NAME] ?? "";
    response.toPlaceID = json[F_TO_PLACE_ID];
    response.toPlaceName = json[F_TO_PLACE_NAME] ?? "";
    response.mTicketPrice = json[F_M_TICKET_PRICE] ?? 0;
    response.price = json[F_PRICE] ?? 0;

    return response;
  }

  Matrix copy() {
    Matrix response = Matrix(key);
    response.count = count;
    response.countFree = countFree;
    response.countPromotion = countPromotion;
    response.countPrepaid = countPrepaid;
    response.price = price;
    response.promotionPrice = promotionPrice;
    response.shippingFee = shippingFee;
    response.fromPlaceID = fromPlaceID;
    response.toPlaceID = toPlaceID;
    response.fromPlaceName = fromPlaceName;
    response.toPlaceName = toPlaceName;
    response.checked = checked;
    response.invalid = invalid;
    response.checkerID = checkerID;
    response.free = free;
    return response;
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> map = {
      F_KEY: nvl(key),
      F_COUNT: count,
      F_FROM_PLACE_ID: fromPlaceID,
      F_TO_PLACE_ID: toPlaceID,
      F_CHECKED: checked,
      F_INVALID: invalid,
      F_CHECKER_ID: checkerID,
    };

    return map;
  }

  Map<String, dynamic> toMTicketJson() {
    Map<String, dynamic> map = {
      F_LINE_ID: lineID,
      F_FROM_PLACE_ID: fromPlaceID,
      F_TO_PLACE_ID: toPlaceID,
      F_M_TICKET_PRICE: mTicketPrice,
      F_PRICE: price,
    };

    return map;
  }
}

class BusCard {
  String id = "";
  String cardNo = "";
  String fullName = "";
  String idCardNo = "";
  String phoneNo = "";
  String email = "";
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
  Uint8List avatar = Uint8List(0);
  DateTime? avatarDate;
  String avatarMd5 = "";
  String note = "";
  List<RechargeItem> rechargeItems = [];
  List<RechargeItem> prepaidRechargeItems = [];

  BusCard();

  factory BusCard.fromJson(Map<String, dynamic> json) {
    BusCard response = BusCard();

    response.id = nvl(json[F_ID]);
    response.cardNo = nvl(nvl(json[F_CARD_NO]));
    response.fullName = nvl(json[F_FULL_NAME]);
    response.phoneNo = nvl(json[F_PHONE_NO]);
    response.idCardNo = nvl(json[F_ID_CARD_NO]);
    response.valid = json[F_VALID] ?? false;
    response.locked = json[F_LOCKED] ?? false;
    response.token = nvl(json[F_TOKEN]);
    response.email = nvl(json[F_EMAIL]);
    response.expireDate = nvl(json[F_EXPIRE_DATE]).parseTz;
    response.avatarDate = nvl(json[F_AVATAR_DATE]).parseTz;
    response.avatarMd5 = nvl(json[F_AVATAR_MD5]);

    num balanceAmount = json[F_BALANCE_AMOUNT] ?? 0;
    response.balanceAmount = balanceAmount.toDouble();

    response.prepaid = json[F_PREPAID] ?? false;
    response.requirePhoto = json[F_REQUIRE_PHOTO] ?? false;
    response.discountPercent = json[F_DISCOUNT_PERCENT] ?? 0;
    response.endDiscountDate = nvl(json[F_END_DISCOUNT_DATE]).parseTz;
    response.priorityID = json[F_PRIORITY_ID] ?? 0;
    response.priorityDescription = nvl(json[F_PRIORITY_DESCRIPTION]);
    response.note = nvl(json[F_NOTE]);

    if (json[F_RECHARGES] != null) {
      response.rechargeItems = (json[F_RECHARGES] as List)
          .map((e) => RechargeItem.fromJson(e))
          .toList();
    }

    if (json[F_PREPAID_RECHARGES] != null) {
      response.prepaidRechargeItems = (json[F_PREPAID_RECHARGES] as List)
          .map((e) => RechargeItem.fromJson(e))
          .toList();
    }

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
    num amount = json[F_AMOUNT] ?? 0;
    response.amount = amount.toDouble();
    response.discountPercent = json[F_DISCOUNT_PERCENT] ?? 0;
    response.paidAmount = json[F_PAID_AMOUNT] ?? 0;

    if (json[F_MATRIX_PRICES] != null) {
      response.matrixes = (json[F_MATRIX_PRICES] as List)
          .map((e) => Matrix.fromMTicketJson(e))
          .toList();
    }

    return response;
  }
}

class BusCardResponse extends ActionResult {
  BusCard busCard = BusCard();

  BusCardResponse(super.errorCode, super.errorMessage);

  factory BusCardResponse.fromJson(Map<String, dynamic> json) {
    BusCardResponse response = BusCardResponse(
      nvl(json[F_ERROR_CODE]),
      nvl(json[F_ERROR_MESSAGE]),
    );

    if (response.errorMessage.isNotEmpty) {
      return response;
    }

    var busCard = json[F_BUS_CARD];

    if (busCard != null) {
      response.busCard = BusCard.fromJson(busCard);
    }

    return response;
  }
}
