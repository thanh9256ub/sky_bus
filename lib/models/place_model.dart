import '../utils/fields.dart';
import '../utils/string_utils.dart';
import 'action_result.dart';

class PlaceMark {
  int placeID = 0;
  double x = 0;
  double y = 0;
  String description = "";
  bool monitoringMark = false;
  String englishName = "";
  String note = "";
  String textToSpeech = "";
  int iconID = 0;
  int radius = 0;
  DateTime? createDate;
  DateTime? updateDate;
  int textColor = 0;
  int direction = 0;
  int voiceSize = 0;
  bool granted = false;

  PlaceMark();

  Map<String, dynamic> toJson() {
    Map<String, dynamic> map = {
      F_PLACE_ID: placeID,
      F_DESCRIPTION: description,
      F_X: x,
      F_Y: y,
      F_ICON_ID: iconID,
      F_TEXT_COLOR: textColor,
      F_RADIUS: radius,
      F_MONITORING_MARK: monitoringMark,
      F_NOTE: nvl(note),
      F_GRANTED: granted,
      F_DIRECTION: direction,
    };

    return map;
  }

  factory PlaceMark.fromJson(Map<String, dynamic> json) {
    PlaceMark model = PlaceMark();
    model.placeID = json[F_PLACE_ID] ?? 0;
    model.x = json[F_X] ?? 0;
    model.y = json[F_Y] ?? 0;
    model.description = nvl(json[F_DESCRIPTION]);
    model.monitoringMark = json[F_MONITORING_MARK] ?? false;
    model.englishName = nvl(json[F_ENGLISH_NAME]);
    model.note = nvl(json[F_NOTE]);
    model.textToSpeech = nvl(json[F_TEXT_TO_SPEECH]);
    model.iconID = json[F_ICON_ID] ?? 0;
    model.radius = json[F_RADIUS] ?? 0;
    model.createDate = nvl(json[F_CREATE_DATE]).parseTz;
    model.updateDate = nvl(json[F_UPDATE_DATE]).parseTz;
    model.textColor = json[F_TEXT_COLOR] ?? 0;
    model.voiceSize = json[F_VOICE_SIZE] ?? 0;
    model.granted = json[F_GRANTED] ?? false;
    return model;
  }
}

class PlaceResponse extends ActionResult {
  PlaceMark place = PlaceMark();
  List<PlaceMark> places = [];

  PlaceResponse(super.errorCode, super.errorMessage);

  factory PlaceResponse.fromJson(Map<String, dynamic> json) {
    PlaceResponse response = PlaceResponse(
      nvl(json[F_ERROR_CODE]),
      nvl(json[F_ERROR_MESSAGE]),
    );

    if (response.errorMessage.isNotEmpty) {
      return response;
    }

    if (json[F_PLACE_MARK] != null) {
      response.place = PlaceMark.fromJson(json[F_PLACE_MARK]);
    }

    if (json[F_PLACE_MARKS] != null) {
      response.places = (json[F_PLACE_MARKS] as List)
          .map((e) => PlaceMark.fromJson(e))
          .toList();
    }

    return response;
  }
}

class PlaceGroup {
  int groupID;
  String groupName;
  List<int> places = [];

  PlaceGroup(this.groupID, this.groupName);

  factory PlaceGroup.fromJson(Map<String, dynamic> json) {
    PlaceGroup response = PlaceGroup(
      json[F_GROUP_ID],
      nvl(json[F_DESCRIPTION]),
    );

    List<dynamic>? places = json[F_PLACES];

    if (places != null) {
      response.places = List<int>.from(places);
    }

    return response;
  }
}

class PlaceGroupResponse extends ActionResult {
  PlaceGroup placeGroup = PlaceGroup(0, "");
  List<PlaceGroup> placeGroups = [];

  PlaceGroupResponse(super.errorCode, super.errorMessage);

  factory PlaceGroupResponse.fromJson(Map<String, dynamic> json) {
    PlaceGroupResponse response = PlaceGroupResponse(
      nvl(json[F_ERROR_CODE]),
      nvl(json[F_ERROR_MESSAGE]),
    );

    if (response.errorMessage.isNotEmpty) {
      return response;
    }

    var placeGroup = json[F_PLACE_GROUP];

    if (placeGroup != null) {
      response.placeGroup = PlaceGroup.fromJson(placeGroup);
    }

    var placeGroups = json[F_PLACE_GROUPS];

    if (placeGroups != null) {
      response.placeGroups = (placeGroups as List)
          .map((e) => PlaceGroup.fromJson(e))
          .toList();
    }

    return response;
  }
}
