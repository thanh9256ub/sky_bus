import '../utils/fields.dart';
import '../utils/string_utils.dart';

class TaxiTrip {
  String id = "";
  int tripID = 0;
  String fromPlaceName = "";
  String toPlaceName = "";
  int vehicleID = 0;
  int userID = 0;
  String userName = "";
  int creatorID = 0;
  String creator = "";
  String creatorPhoneNo = "";
  String plateNo = "";
  double km = 0;
  double emptyKm = 0;
  int charge = 0;
  TaxiState state = TaxiState.NEW;
  int realCharge = 0;
  int partnerReceivables = 0;
  int freeCharge = 0;
  int freeTickets = 0;
  int waitCharge = 0;
  int waitTime = 0;
  int typeID = 0;
  double x = 0;
  double y = 0;
  String note = "";
  String contactNo = "";
  String token = "";
  DateTime? createDate;
  DateTime? pickupDate;
  DateTime? startDate;
  DateTime? finishDate;
  DateTime? dropOffDate;
  DateTime? paidDate;
  double pickupX = 0;
  double pickupY = 0;
  double dropOffX = 0;
  double dropOffY = 0;

  TaxiTrip();

  factory TaxiTrip.fromJson(Map<String, dynamic> trip) {
    TaxiTrip response = TaxiTrip();
    response.id = nvl(trip[F_ID]);
    response.tripID = trip[F_TRIP_ID] ?? 0;
    response.vehicleID = trip[F_VEHICLE_ID] ?? 0;
    response.fromPlaceName = nvl(trip[F_FROM_PLACE_NAME]);
    response.toPlaceName = nvl(trip[F_TO_PLACE_NAME]);
    if (trip[F_STATE] != null) {
      response.state = TaxiState.fromValue(trip[F_STATE]) ?? TaxiState.NEW;
    }
    response.userID = trip[F_USER_ID] ?? 0;
    response.userName = nvl(trip[F_USER_NAME]);
    response.creator = nvl(trip[F_CREATOR]);
    response.creatorID = trip[F_CREATOR_ID] ?? 0;
    response.creatorPhoneNo = nvl(trip[F_CREATOR_PHONE_NO]);
    response.contactNo = nvl(trip[F_CONTACT_NO]);
    response.token = nvl(trip[F_TOKEN]);
    response.freeTickets = trip[F_FREE_TICKETS] ?? 0;
    response.plateNo = nvl(trip[F_PLATE_NO]);
    response.km = trip[F_KM] ?? 0;
    response.typeID = trip[F_TYPE_ID] ?? 0;
    response.charge = trip[F_CHARGE] ?? 0;
    response.realCharge = trip[F_REAL_CHARGE] ?? 0;
    response.partnerReceivables = trip[F_PARTNER_RECEIVABLES] ?? 0;
    response.emptyKm = trip[F_EMPTY_KM] ?? 0;
    response.freeCharge = trip[F_FREE_CHARGE] ?? 0;
    response.waitCharge = trip[F_WAIT_CHARGE] ?? 0;
    response.waitTime = trip[F_WAIT_TIME] ?? 0;
    response.note = nvl(trip[F_NOTE]);
    response.createDate = nvl(trip[F_CREATE_DATE]).parseTz;
    response.pickupDate = nvl(trip[F_PICKUP_DATE]).parseTz;
    response.startDate = nvl(trip[F_START_DATE]).parseTz;
    response.finishDate = nvl(trip[F_FINISH_DATE]).parseTz;
    response.dropOffDate = nvl(trip[F_DROP_OFF_DATE]).parseTz;
    response.paidDate = nvl(trip[F_PAID_DATE]).parseTz;
    response.pickupX = trip[F_PICKUP_X] ?? 0;
    response.pickupY = trip[F_PICKUP_Y] ?? 0;
    response.dropOffX = trip[F_DROP_OFF_X] ?? 0;
    response.dropOffY = trip[F_DROP_OFF_Y] ?? 0;

    return response;
  }
}

enum TaxiState {
  DRAFT(-1),
  NEW(0),
  FREE(1),
  CANCEL(8),
  FINISH(9),
  SERVING(2),
  WAITING(3);

  final int value;

  const TaxiState(this.value);

  static TaxiState? fromValue(int value) {
    for (var e in TaxiState.values) {
      if (e.value == value) {
        return e;
      }
    }
    return null;
  }
}
