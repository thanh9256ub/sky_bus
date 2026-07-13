import '../utils/date_utils.dart';
import '../utils/fields.dart';
import '../utils/string_utils.dart';
import 'action_result.dart';
import 'taxi_model.dart';

class Vehicle {
  int vehicleID = 0;
  int customerID = 0;
  double x = 0;
  double y = 0;
  String plateNo = "";
  String vehicleCode = "";
  String deviceType = "";
  String showPlateNo = "";
  double currentSpeed = 0;
  int pulseSpeed = 0;
  int direction = 0;
  String contactNo = "";
  DateTime? createDate;
  DateTime? updateDate;
  DateTime? gpsDate;
  String engineState = "";
  String gpsState = "";
  int vibrator = 0;
  double fuelAmount = 0;
  double fuelAmount2 = 0;
  double totalFuelAmount = 0;
  double totalFuelAmount2 = 0;
  bool hasTemper = false;
  double temper1 = 0;
  double temper2 = 0;
  int staffID = 0;
  String staffName = "";
  String licenseNo = "";
  String versionNo = "";
  String vehicleNo = "";
  bool hasCamera = false;
  bool hasFuelSensor = false;
  bool hasPir = false;
  int cameraEnable = 0;
  bool shareCam = false;
  int status = 0;
  String iconID = "";
  int textColor = 0;
  DateTime? stopDate;
  int stopDuration = 0;
  int dailyDrivingDuration = 0;
  int drivingDuration = 0;
  int numOfOverSpeed = 0;
  int dailyEstFuelUsage = 0;
  double dailyDistance = 0;
  bool locked = false;
  bool sendToMT = false;
  int seatChartID = 0;
  int vehicleStatus = 0;
  int vehicleConfig = 0;
  int totalPassenger = 0;
  bool isExcavator = false;
  int excavatorID = 0;
  TaxiTrip? taxiTrip;
  bool granted = false;
  bool origGranted = false;

  String currentAddress = ""; // UI

  Vehicle();

  Map<String, dynamic> toJson() {
    Map<String, dynamic> map = {
      F_VEHICLE_ID: vehicleID,
      F_LOCKED: locked,
      F_SEND_TO_MT: sendToMT,
      F_GRANTED: granted,
      F_SHARE_CAM: shareCam,
    };

    return map;
  }

  factory Vehicle.fromJson(Map<String, dynamic> json) {
    Vehicle model = Vehicle();
    model.vehicleID = json[F_VEHICLE_ID] ?? 0;
    model.customerID = json[F_CUSTOMER_ID] ?? 0;
    model.x = json[F_X] ?? 0;
    model.y = json[F_Y] ?? 0;
    model.plateNo = nvl(json[F_PLATE_NO]);
    model.vehicleCode = nvl(json[F_VEHICLE_CODE]);
    model.deviceType = nvl(json[F_DEVICE_TYPE]);
    model.showPlateNo = nvl(json[F_SHOW_PLACE_NO]);
    model.currentSpeed = json[F_CURRENT_SPEED] ?? 0;
    model.pulseSpeed = json[F_PULSE_SPEED] ?? 0;
    model.direction = json[F_DIRECTION] ?? 0;
    model.contactNo = nvl(json[F_CONTACT_NO]);
    model.createDate = nvl(json[F_CREATE_DATE]).parseTz;
    model.updateDate = nvl(json[F_UPDATE_DATE]).parseTz;
    model.gpsDate = nvl(json[F_GPS_DATE]).parseTz;
    model.engineState = nvl(json[F_ENGINE_STATE]);
    model.gpsState = nvl(json[F_GPS_STATE]);
    model.vibrator = json[F_VIBRATOR] ?? 0;
    model.fuelAmount = json[F_FUEL_AMOUNT] ?? 0;
    model.fuelAmount2 = json[F_FUEL_AMOUNT_2] ?? 0;
    model.totalFuelAmount = json[F_TOTAL_FUEL_AMOUNT] ?? 0;
    model.totalFuelAmount2 = json[F_TOTAL_FUEL_AMOUNT_2] ?? 0;
    model.hasTemper = json[F_HAS_TEMPER];
    model.temper1 = json[F_TEMPER_1] ?? 0;
    model.temper2 = json[F_TEMPER_2] ?? 0;
    model.staffID = json[F_STAFF_ID] ?? 0;
    model.staffName = nvl(json[F_STAFF_NAME]);
    model.licenseNo = nvl(json[F_LICENSE_NO]);
    model.versionNo = nvl(json[F_VERSION_NO]);
    model.vehicleNo = nvl(json[F_VEHICLE_NO]);
    model.hasCamera = json[F_HAS_CAMERA] ?? false;
    model.hasFuelSensor = json[F_HAS_FUEL_SENSOR] ?? false;
    model.hasPir = json[F_HAS_PIR] ?? false;
    model.cameraEnable = json[F_CAMERA_ENABLE] ?? 0;
    model.shareCam = json[F_SHARE_CAM] ?? false;
    model.status = json[F_STATUS] ?? 0;
    model.iconID = nvl(json[F_ICON_ID]);
    model.textColor = json[F_TEXT_COLOR] ?? 0;
    model.stopDate = nvl(json[F_STOP_DATE]).parseTz;
    model.stopDuration = json[F_STOP_DURATION] ?? 0;
    model.dailyDrivingDuration = json[F_DAILY_DRIVING_DURATION] ?? 0;
    model.drivingDuration = json[F_DRIVING_DURATION] ?? 0;
    model.numOfOverSpeed = json[F_NUM_OF_OVER_SPEED] ?? 0;
    model.dailyEstFuelUsage = json[F_DAILY_EST_FUEL_USAGE] ?? 0;
    model.dailyDistance = json[F_DAILY_DISTANCE] ?? 0;
    model.locked = json[F_LOCKED] ?? false;
    model.sendToMT = json[F_SEND_TO_MT] ?? false;
    model.seatChartID = json[F_SEAT_CHART_ID] ?? 0;
    model.vehicleStatus = json[F_VEHICLE_STATUS] ?? 0;
    model.vehicleConfig = json[F_VEHICLE_CONFIG] ?? 0;
    model.totalPassenger = json[F_TOTAL_PASSENGER] ?? 0;
    model.excavatorID = json[F_EXCAVATOR_ID] ?? 0;
    model.isExcavator = json[F_IS_EXCAVATOR] ?? false;
    model.granted = json[F_GRANTED] ?? false;
    model.origGranted = model.granted;

    if (json[F_TAXI_TRIP] != null) {
      model.taxiTrip = TaxiTrip.fromJson(json[F_TAXI_TRIP]);
    }
    return model;
  }
}

class VehicleGroup {
  int groupID;
  String groupName;
  List<String> vehicles = [];
  bool granted = false;
  bool origGranted = false;

  VehicleGroup(this.groupID, this.groupName);

  factory VehicleGroup.fromJson(Map<String, dynamic> json) {
    VehicleGroup response = VehicleGroup(
      json[F_GROUP_ID] ?? 0,
      nvl(json[F_DESCRIPTION]),
    );

    List<dynamic>? vehicles = json[F_VEHICLES];

    if (vehicles != null) {
      for (var element in vehicles) {
        response.vehicles.add(element.toString());
      }
    }

    response.granted = json[F_GRANTED] ?? false;
    response.origGranted = response.granted;

    return response;
  }
}

class VehicleResponse extends ActionResult {
  List<Vehicle> vehicles = [];

  VehicleResponse(super.errorCode, super.errorMessage);

  factory VehicleResponse.fromJson(Map<String, dynamic> json) {
    VehicleResponse response = VehicleResponse(
      nvl(json[F_ERROR_CODE]),
      nvl(json[F_ERROR_MESSAGE]),
    );

    if (response.errorMessage.isNotEmpty) {
      return response;
    }

    var vehicles = json[F_VEHICLES];

    if (vehicles != null) {
      response.vehicles = (vehicles as List)
          .map((e) => Vehicle.fromJson(e))
          .toList();
    }

    return response;
  }
}

class VehicleGroupResponse extends ActionResult {
  VehicleGroup vehicleGroup = VehicleGroup(0, "");
  List<VehicleGroup> vehicleGroups = [];

  VehicleGroupResponse(super.errorCode, super.errorMessage);

  factory VehicleGroupResponse.fromJson(Map<String, dynamic> json) {
    VehicleGroupResponse response = VehicleGroupResponse(
      nvl(json[F_ERROR_CODE]),
      nvl(json[F_ERROR_MESSAGE]),
    );

    if (response.errorMessage.isNotEmpty) {
      return response;
    }

    var vehicleGroup = json[F_VEHICLE_GROUP];

    if (vehicleGroup != null) {
      response.vehicleGroup = VehicleGroup.fromJson(vehicleGroup);
    }

    var vehicleGroups = json[F_VEHICLE_GROUPS];

    if (vehicleGroups != null) {
      response.vehicleGroups = (vehicleGroups as List)
          .map((e) => VehicleGroup.fromJson(e))
          .toList();
    }

    return response;
  }
}

enum PlateNoFilterType {
  all(-1),
  fuelSensor(1);

  final int value;

  const PlateNoFilterType(this.value);

  static PlateNoFilterType? fromValue(int value) {
    for (var e in PlateNoFilterType.values) {
      if (e.value == value) {
        return e;
      }
    }
    return null;
  }
}

class VehiclePosition {
  int id;
  int vehicleID = 0;
  double x = 0;
  double y = 0;
  int color = 0;
  int direction = 0;
  double distance = 0;
  double currentSpeed = 0;
  DateTime? createDate;
  DateTime? gpsDate;
  double fuelAmount = 0;
  double fuelAmount2 = 0;
  String engineState = "";
  int interpolateIndex = -1;

  VehiclePosition(this.id);

  factory VehiclePosition.fromJson(Map<String, dynamic> json) {
    VehiclePosition response = VehiclePosition(json[F_ID]);
    response.vehicleID = json[F_VEHICLE_ID] ?? 0;
    response.x = json[F_X] ?? 0;
    response.y = json[F_Y] ?? 0;
    response.color = json[F_COLOR] ?? 0;
    response.currentSpeed = json[F_CURRENT_SPEED] ?? 0;
    response.direction = json[F_DIRECTION] ?? 0;
    response.createDate = nvl(json[F_CREATE_DATE]).parseTz;
    response.gpsDate = nvl(json[F_GPS_DATE]).parseTz;
    response.fuelAmount = json[F_FUEL_AMOUNT] ?? 0;
    response.fuelAmount2 = json[F_FUEL_AMOUNT_2] ?? 0;
    response.distance = json[F_DISTANCE] ?? 0;
    response.engineState = nvl(json[F_ENGINE_STATE]);
    return response;
  }

  factory VehiclePosition.fromWaypoint(Map<String, dynamic> json) {
    VehiclePosition response = VehiclePosition(0);

    response.x = json[F_X];
    response.y = json[F_Y];
    response.color = json[F_COLOR] ?? 0;
    return response;
  }
}

class FuelRequest {
  String plateNo;
  DateTime date;

  FuelRequest(this.plateNo, this.date);

  Map<String, dynamic> toJson() {
    Map<String, dynamic> map = {F_DATE: date.formatDate, F_PLATE_NO: plateNo};
    return map;
  }
}

class FuelResponse extends ActionResult {
  int totalFuelAmount = 0;
  int totalFuelAmount2 = 0;

  List<VehiclePosition> positions = [];

  FuelResponse(super.errorCode, super.errorMessage);

  factory FuelResponse.fromJson(Map<String, dynamic> json) {
    FuelResponse response = FuelResponse(
      nvl(json[F_ERROR_CODE]),
      nvl(json[F_ERROR_MESSAGE]),
    );

    if (response.errorMessage.isNotEmpty) {
      return response;
    }

    var positions = json[F_POSITIONS];

    if (positions != null) {
      response.positions = (positions as List)
          .map((e) => VehiclePosition.fromJson(e))
          .toList();
    }

    response.totalFuelAmount = json[F_TOTAL_FUEL_AMOUNT];
    response.totalFuelAmount2 = json[F_TOTAL_FUEL_AMOUNT_2];

    return response;
  }
}

class CheckPoint {
  int pointID;
  double x = 0;
  double y = 0;
  int color = 0;
  CheckPointType? type;
  String? plateNo;
  DateTime? date;
  double currentSpeed = 0;
  int limitSpeed = 0;
  int direction = 0;
  int stopDuration = 0;
  String engineState = "OFF";
  double distance = 0;
  int km = 0;

  CheckPoint(this.pointID);

  factory CheckPoint.fromJson(Map<String, dynamic> json) {
    CheckPoint response = CheckPoint(json[F_ID]);

    response.x = json[F_X];
    response.y = json[F_Y];
    response.color = json[F_COLOR];
    if (json[F_TYPE] != null) {
      response.type = CheckPointType.fromValue(json[F_TYPE]);
    }
    response.plateNo = json[F_PLATE_NO];
    response.date = nvl(json[F_DATE]).parseTz;
    response.direction = json[F_DIRECTION];
    response.currentSpeed = json[F_CURRENT_SPEED];
    response.limitSpeed = json[F_LIMIT_SPEED];
    response.distance = json[F_DISTANCE];
    response.stopDuration = json[F_STOP_DURATION];
    response.km = json[F_KM];

    return response;
  }
}

class Summary {
  double totalDistance = 0;
  double totalFuelAmount = 0;
  double totalFuelAmount2 = 0;

  Summary();

  factory Summary.fromJson(Map<String, dynamic> json) {
    Summary response = Summary();

    response.totalDistance = json[F_TOTAL_DISTANCE];
    response.totalFuelAmount = json[F_TOTAL_FUEL_AMOUNT];
    response.totalFuelAmount2 = json[F_TOTAL_FUEL_AMOUNT_2];

    return response;
  }
}

enum CheckPointType {
  stop(1, "Điểm dừng"),
  overSpeed(2, "Điểm vượt tốc"),
  lowSpeed(3, "Điểm chạy chậm"),
  info(4, "Điểm thông tin"),
  photo(5, "Điểm chụp ảnh"),
  stopOver2Mins(6, "Điểm dừng quá 2p"),
  stopOver30Mins(7, "Điểm dừng quá 30p"),
  releaseGoods(8, "Điểm xuống hàng"),
  startTaxiTrip(9, "Điểm nhận khách"),
  endTaxiTrip(10, "Điểm trả khách"),
  sleepingAlarm(11, "Điểm ngủ gật"),
  pumping(12, "Điểm bơm"),
  doorOpen(13, "Điểm mở cửa");

  const CheckPointType(this.value, this.note);

  final int value;
  final String note;

  static CheckPointType? fromValue(int value) {
    try {
      return CheckPointType.values.firstWhere((e) => e.value == value);
    } catch (_) {
      return null;
    }
  }
}

class VehicleHistoryResponse extends ActionResult {
  Summary summary = Summary();
  List<CheckPoint> checkPoints = [];
  List<VehiclePosition> positions = [];

  VehicleHistoryResponse(super.errorCode, super.errorMessage);

  factory VehicleHistoryResponse.fromJson(Map<String, dynamic> json) {
    VehicleHistoryResponse response = VehicleHistoryResponse(
      nvl(json[F_ERROR_CODE]),
      nvl(json[F_ERROR_MESSAGE]),
    );

    if (response.errorMessage.isNotEmpty) {
      return response;
    }

    var positions = json[F_POSITIONS];

    if (positions != null) {
      response.positions = (positions as List)
          .map((e) => VehiclePosition.fromJson(e))
          .toList();
    }

    var checkPoints = json[F_CHECK_POINTS];

    if (checkPoints != null) {
      response.checkPoints = (checkPoints as List)
          .map((e) => CheckPoint.fromJson(e))
          .toList();
    }

    var summary = json[F_SUMMARY];

    if (summary != null) {
      response.summary = Summary.fromJson(json[F_SUMMARY]);
    }

    return response;
  }
}

class VehicleState {
  int stateID;
  String description;
  int color = 0;
  int count = 0;

  VehicleState(this.stateID, this.description);

  factory VehicleState.fromJson(Map<String, dynamic> json) {
    VehicleState response = VehicleState(
      json[F_STATE],
      nvl(json[F_DESCRIPTION]),
    );

    response.color = json[F_COLOR] ?? 0;
    return response;
  }

  factory VehicleState.copy(VehicleState state) {
    VehicleState response = VehicleState(state.stateID, state.description);
    response.color = state.color;

    return response;
  }
}

class TravelLine {
  String lineID = "";
  String description = "";
  TravelLine();
  factory TravelLine.fromJson(Map<String, dynamic> json) {
    TravelLine model = TravelLine();
    model.lineID = nvl(json[F_LINE_ID]);
    model.description = nvl(json[F_DESCRIPTION]);
    return model;
  }
}

class VehicleHistoryRequest {
  String filterCondition;
  String fromDate;
  String toDate;
  String plateNo;
  int vehicleID;

  VehicleHistoryRequest(
    this.filterCondition,
    this.fromDate,
    this.toDate,
    this.plateNo,
    this.vehicleID,
  );

  Map<String, dynamic> toJson() {
    final map = {
      F_CONDITION: filterCondition,
      F_FROM_DATE: fromDate,
      F_TO_DATE: toDate,
      F_VEHICLE_ID: vehicleID,
      F_PLATE_NO: plateNo,
    };
    return map;
  }
}
