import '../utils/fields.dart';
import '../utils/string_utils.dart';
import 'action_result.dart';
import 'place_model.dart';
import 'vehicle_model.dart';

enum MapLayerType { road, satellite, terrain }

class MapMarkerData {
  final bool isVehicle;
  final double latitude;
  final double longitude;
  final Vehicle? vehicle;
  final PlaceMark? place;
  final CheckPoint? checkPoint;
  final VehiclePosition? position;

  MapMarkerData.vehicle(Vehicle this.vehicle)
    : isVehicle = true,
      place = null,
      checkPoint = null,
      position = null,
      latitude = vehicle.y,
      longitude = vehicle.x;

  MapMarkerData.place(PlaceMark this.place)
    : isVehicle = false,
      vehicle = null,
      checkPoint = null,
      position = null,
      latitude = place.y,
      longitude = place.x;
  MapMarkerData.checkPoint(CheckPoint this.checkPoint)
    : isVehicle = false,
      vehicle = null,
      place = null,
      position = null,
      latitude = checkPoint.y,
      longitude = checkPoint.x;
  MapMarkerData.position(VehiclePosition this.position)
    : isVehicle = false,
      vehicle = null,
      place = null,
      checkPoint = null,
      latitude = position.y,
      longitude = position.x;
}

class MapObjectsResponse extends ActionResult {
  List<PlaceMark> places = [];
  List<Vehicle> vehicles = [];

  MapObjectsResponse(super.errorCode, super.errorMessage);

  factory MapObjectsResponse.fromJson(Map<String, dynamic> json) {
    MapObjectsResponse response = MapObjectsResponse(
      nvl(json[F_ERROR_CODE]),
      nvl(json[F_ERROR_MESSAGE]),
    );

    if (response.errorMessage.isNotEmpty) {
      return response;
    }

    var placeMarks = json[F_PLACE_MARKS];
    if (placeMarks != null) {
      response.places = (placeMarks as List)
          .map((e) => PlaceMark.fromJson(e))
          .toList();
    }

    var vehicles = json[F_VEHICLES];
    if (vehicles != null) {
      response.vehicles = (vehicles as List)
          .map((e) => Vehicle.fromJson(e))
          .toList();
    }

    return response;
  }

  factory MapObjectsResponse.copy(MapObjectsResponse model) {
    MapObjectsResponse response = MapObjectsResponse(
      model.errorCode,
      model.errorMessage,
    );
    response.places = model.places;
    response.vehicles = model.vehicles;

    return response;
  }
}
