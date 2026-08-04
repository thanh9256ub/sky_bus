import 'package:skysoft_bus/models/action_result.dart';

import '../utils/fields.dart';
import '../utils/string_utils.dart';

class Vehicle {
  int vehicleID = 0;
  int customerID = 0;
  double x = 0;
  double y = 0;
  String plateNo = "";
  String phoneNo = "";
  String vehicleNo = "";
  double currentSpeed = 0;
  int direction = 0;
  DateTime? updateDate;
  DateTime? gpsDate;
  String engineState = "";
  String gpsState = "";

  Vehicle();

  factory Vehicle.fromJson(Map<String, dynamic> json) {
    Vehicle vehicle = Vehicle();

    vehicle.vehicleID = json[F_VEHICLE_ID] ?? 0;
    vehicle.customerID = json[F_CUSTOMER_ID] ?? 0;

    vehicle.x = json[F_X] ?? 0;
    vehicle.y = json[F_Y] ?? 0;

    vehicle.plateNo = json[F_PLATE_NO] ?? "";
    vehicle.phoneNo = json[F_PHONE_NO] ?? "";
    vehicle.vehicleNo = json[F_VEHICLE_NO] ?? "";

    vehicle.currentSpeed = json[F_CURRENT_SPEED] ?? 0;
    vehicle.direction = json[F_DIRECTION] ?? 0;

    vehicle.updateDate = nvl(json[F_UPDATE_DATE]).parseTz;
    vehicle.gpsDate = nvl(json[F_GPS_DATE]).parseTz;

    vehicle.engineState = json[F_ENGINE_STATE] ?? "";
    vehicle.gpsState = json[F_GPS_STATE] ?? "";

    return vehicle;
  }
  bool get isEngineOn {
    return engineState == "ON";
  }

  bool get isGpsOk {
    return gpsState == "OK";
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
