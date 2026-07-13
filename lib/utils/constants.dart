final int TEMPER_NOT_CONNECTED_VALUE = -999;
final int TEMPER_INVALID_VALUE = -888;

class Rights {
  static String INSERT = "I";
  static String DELETE = "D";
  static String UPDATE = "U";
  static String SELECT = "S";
  static String EXECUTE = "E";
}

class Modules {
  static final String SYSTEM_LOGIN = "mnuLogin";
  static final String SYSTEM_LOGOUT = "mnuLogout";
  static final String SYSTEM_CHANGE_PASSWORD = "mnuChangePassword";
  static final String SYSTEM_RESET_PASSWORD = "mnuResetPassword";
  static final String SYSTEM_SYSTEM_PARAM = "mnuSystemParam";
  static final String SYSTEM_MODULE = "mnuModule";
  static final String SYSTEM_SCHEDULE = "mnuSchedule";
  static final String SYSTEM_IP_ADDRESS = "mnuIPAddress";
  static final String SESSION_MANAGER = "mnuSessionManager";
  static final String SYSTEM_POLICY = "mnuSystemPolicy";
  static final String SYSTEM_REGISTER_SUPER_KEY = "mnuRegisterSuperKey";
  static final String SYSTEM_ACCESS_LOG_VIEWER = "mnuAccessLogViewer";
  static final String SYSTEM_ACTION_LOG_VIEWER = "mnuActionLogViewer";
  static final String SYSTEM_PARAMETER = "mnuParameter";
  static final String SYSTEM_USER_MANAGER = "mnuUserManager";
  static final String SYSTEM_RAISE_NOTIFICATION = "mnuRaiseNotification";
  static final String SYSTEM_SESSION_VIEWER = "mnuSessionViewer";
  static final String SYSTEM_GRANT_GROUP_TO_USER = "mnuGrantGroupToUser";
  static final String SYSTEM_GRANT_REPORT_TO_CUSTOMER =
      "mnuGrantReportToCustomer";
  static final String SYSTEM_GRANT_REPORT_TO_USER = "mnuGrantReportToUser";
  static final String SYSTEM_GRANT_MT_VEHICLE = "mnuGrantMTVehicle";
  static final String SYSTEM_UPDATE_CLASS_TO_VEHICLE =
      "mnuUpdateClassToVehicle";
  static final String SYSTEM_GRANT_VEHICLE_TO_CUSTOMER =
      "mnuGrantVehicleToCustomer";
  static final String SYSTEM_PUBLIC_VEHICLE = "mnuPublicVehicle";
  static final String SYSTEM_VEHICLE_CONFIG = "mnuVehicleConfig";
  static final String SYSTEM_VEHICLE_MANAGER = "mnuVehicleManager";
  static final String SYSTEM_SUPER_PERMISSION = "mnuSuperPermission";
  static final String SYSTEM_UPDATE_ADV = "mnuUpdateAdv";
  static final String SYSTEM_RECHARGE_SIM = "mnuRechargeSIM";
  static final String SYSTEM_AD_WORDS = "mnuAdWords";
  static final String SYSTEM_SIM_BATCH = "mnuSimBatch";
  static final String SYSTEM_MAIL_NOTIFICATION = "mnuMailNotification";
  static final String SYSTEM_CHANGE_LOGIN_CUSTOMER = "mnuChangeLoginCustomer";
  static final String SYSTEM_CHARGE_MANAGER = "mnuChargeManager";
  static final String SYSTEM_SESSION = "mnuSession";

  //ticket
  static final String HIDDEN_LOCK_CARD = "mnuLockCard";
  static final String HIDDEN_CHANGE_CARD_NO = "mnuChangeCardNo";
  static final String HIDDEN_SHOW_EDIT_AVATAR = "mnuShowEditAvatar";
  static final String TRANS_CARD_RECHARGE = "mnuCardRecharge";
  static final String TRANS_RECHARGE_QUOTA = "mnuRechargeQuota";
  static final String HIDDEN_SHOW_E_TICKET = "mnuShowETicket";

  //category
  static final String LIST_VEHICLE_LOAD_PARAMS = "mnuVehicleLoadParams";
  static final String LIST_COUNTRY = "mnuCountry";
  static final String LIST_PROVINCE = "mnuProvince";
  static final String LIST_FIRM = "mnuFirm";
  static final String LIST_DEPARTMENT = "mnuDepartment";
  static final String LIST_MODEL = "mnuModel";
  static final String LIST_SHIPPING_MODEL = "mnuShippingModel";
  static final String LIST_SHIP_BRAND = "mnuShipBrand";
  static final String LIST_ZONE = "mnuZone";
  static final String LIST_PERFORMANCE = "mnuPerformance";
  static final String LIST_JOB = "mnuJob";
  static final String LIST_PARKING = "mnuParking";
  static final String LIST_SHIFT = "mnuShift";
  static final String LIST_CHECK_LIST = "mnuCheckList";
  static final String LIST_SEAT_CHART = "mnuSeatChart";
  static final String LIST_MATERIAL = "mnuMaterial";
  static final String LIST_PICKUP_POINT = "mnuPickupPoint";
  static final String LIST_RELEASE_POINT = "mnuReleasePoint";
  static final String LIST_VEHICLE_CLASS = "mnuVehicleClass";
  static final String LIST_HISTORY = "mnuHistory";
  static final String LIST_CARD = "mnuCard";
  static final String LIST_CONTACT = "mnuContact";
  static final String LIST_PARTNER = "mnuPartner";
  static final String LIST_TASK_CATEGORY = "mnuTaskCategory";
  static final String LIST_BUS_TRIP_SCHEDULE = "mnuBusTripSchedule";

  //transaction
  static final String TRANS_STAFF_MANAGER = "mnuStaff";
  static final String TRANS_STUDENT_MANAGER = "mnuStudent";
  static final String TRANS_STUDENT_GROUP_MANAGER = "mnuStudent";
  static final String TRANS_BUS_TICKET_MANAGER = "mnuBusTicketManager";
  static final String TRANS_DRIVING_DIARY = "mnuDrivingDiary";
  static final String TRANS_CUSTOMER = "mnuCustomer";
  static final String TRANS_VEHICLE_PARAM = "mnuVehicleParam";
  static final String TRANS_MAINTENANCE_DIARY = "mnuMaintenanceDiary";
  static final String TRANS_FUEL_SUPPLY_DIARY = "mnuFuelSupplyDiary";
  static final String TRANS_FUEL_SUPPLY_BY_CAMERA = "mnuFuelSupplyByCamera";
  static final String TRANS_TRIP_COUNTING_BY_CAMERA = "mnuTripCountingByCamera";
  static final String TRANS_TRIP_BOOKING = "mnuTripBooking";
  static final String TRANS_TICKET_BOOKING = "mnuTicketBooking";
  static final String TRANS_TRIP = "mnuTrip";
  static final String TRANS_PERMIT = "mnuPermit";
  static final String TRANS_DOCUMENT_EXPIRE = "mnuDocumentExpire";
  static final String TRANS_VEHILCE_TIME_LINE = "mnuVehicleTimeLine";
  static final String TRANS_TAXI_FARE = "mnuTaxiFare";
  static final String UTIL_INVOICE_MANAGER = "mnuInvoiceManager";

  //util
  static final String UTIL_TRIP_X_FACTOR = "mnuTripXFactor";
  static final String UTIL_EXCAVATOR_TRIP_X_FACTOR = "mnuExcavatorTripXFactor";
  static final String UTIL_VEHICLE_FUEL_USAGE_PARAM =
      "mnuVehicleFuelUsageParam";
  static final String UTIL_EXCAVATOR_MATRIXES = "mnuExcavatorMatrixes";
  static final String UTIL_UPDATE_SHIFT_TO_VEHICLE = "mnuUpdateShiftToVehicle";
  static final String UTIL_DRIVER_TAG_WRITING = "mnuDriverTagWriting";
  static final String UTIL_PLACE_MARK = "mnuPlaceMark";
  static final String UTIL_CREATE_PUBLIC_PLACE = "mnuCreatePublicPlace";
  static final String UTIL_CREATE_NOTIFICATION = "mnuCreateNotification";
  static final String UTIL_SPEED_NODE = "mnuSpeedNode";
  static final String UTIL_TRAVEL_HISTORY = "mnuTravelHistory";
  static final String UTIL_UPLOAD_EXCEL_FILE = "mnuUploadExcelFile"; //For XMTD
  static final String UTIL_CAMERA_VIEWER = "mnuCameraViewer";
  static final String UTIL_VIDEO_LIVE_VIEWER = "mnuVideoViewer";
  static final String UTIL_VIDEO_PLAYBACK_VIEWER = "mnuVideoPlaybackViewer";
  static final String UTIL_ECHECK_VIEWER = "mnuECheckViewer";
  static final String UTIL_CHANGE_REGISTER_COLOR = "mnuChangeRegisterColor";
  static final String UTIL_TAKE_PHOTO = "mnuTakePhoto";
  static final String UTIL_SPEED_ALARM_SETTING = "mnuSpeedAlarmSetting";
  static final String UTIL_GRANT_VEHICLE_GROUP = "mnuGrantVehicleGroup";
  static final String UTIL_GRANT_REPORT_TO_USER = "mnuGrantReportToUser";
  static final String UTIL_VEHICLE_GROUP_MANAGER = "mnuVehicleGroupManager";
  static final String UTIL_PLACE_GROUP_MANAGER = "mnuPlaceGroupManager";
  static final String UTIL_RAISE_ALARM_CONFIG = "mnuRaiseAlarmConfig";
  static final String UTIL_LONG_STOP_ALARM_SETTING = "mnuLongStopAlarmSetting";
  static final String UTIL_LONG_ENGINE_ON_ALARM_SETTING =
      "mnuLongEngineOnAlarmSetting";
  static final String UTIL_INVALID_WORKING_ALARM_SETTING =
      "mnuInvalidWorkingAlarmSetting";
  static final String UTIL_INVALID_STOP_ALARM_SETTING =
      "mnuInvalidStopAlarmSetting";
  static final String UTIL_INVALID_ZONE_ALARM_SETTING =
      "mnuInvalidZoneAlarmSetting";
  static final String UTIL_PRIOR_ALARM_SETTING = "mnuPriorAlarmSetting";
  static final String UTIL_VOICE_ALARM_SETTING = "mnuVoiceAlarmSetting";
  static final String UTIL_FUEL_DOWN_ALARM_SETTING = "mnuFuelDownAlarmSetting";
  static final String UTIL_PHOTO_CAPTURE_SETTING = "mnuPhotoCaptureSetting";
  static final String UTIL_SNIFFER_REGISTER = "mnuSnifferRegister";
  static final String UTIL_UPDATE_CONTACT = "mnuUpdateContact";
  static final String UTIL_CHANGE_REGISTER_NO = "mnuChangeRegisterNo";
  static final String UTIL_UPDATE_VEHICLE_INFO = "mnuUpdateVehicleInfo";
  static final String UTIL_UPDATE_PASSENGER = "mnuUpdatePassenger";
  static final String UTIL_SEND_SMS = "mnuSendSMS";
  static final String UTIL_SEND_COMMAND = "mnuSendCommand";
  static final String UTIL_SEND_COMMAND_EX = "mnuSendCommandEx";
  static final String UTIL_KILL_SESSION = "mnuKillSession";
  static final String UTIL_UPDATE_STATUS = "mnuUpdateStatus";
  static final String UTIL_UPDATE_DESTINATION = "mnuUpdateDestination";
  static final String UTIL_MAP_EXPORTER = "mnuMapExporter";
  static final String UTIL_TRAVEL_HISTORY_EXPORTER = "mnuTravelHistoryExporter";
  static final String UTIL_VEHICLE_EXPORTER = "mnuVehicleExporter";
  static final String UTIL_MAP_CONVERTER = "mnuMapConverter";
  static final String UTIL_MAP_UPDATE_REQUEST = "mnuMapUpdateRequest";
  static final String UTIL_MAP_GENERATOR_REQUEST = "mnuMapGeneratorRequest";
  static final String UTIL_SPEED_CHANGE = "mnuSpeedChange";
  static final String UTIL_RECEIVED_MESSAGE = "mnuReceivedMessage";
  static final String UTIL_ALARM_VIEWER = "mnuAlarmViewer";
  static final String UTIL_DELETE_HISTORY = "mnuDeleteHistory";
  static final String UTIL_PLACE_PLACE_CHECK_IN = "mnuPlaceCheckIn";
  static final String UTIL_NOTIFY_VEHICLE = "mnuNotifyVehicle";
  static final String UTIL_TRAVEL_LINE_SETTING = "mnuTravelLineSetting";
  static final String UTIL_TICKET_BUS_LINE_SETTING = "mnuTicketBusLineSetting";
  static final String UTIL_VEHICLE_NOTE_VIEWER = "mnuVehicleNoteViewer";

  static final String HIDDEN_SHOW_TRAVEL_HISTORY = "mnuTravelHistory";
  static final String HIDDEN_SHOW_HISTORY_INFO = "mnuShowHistoryInfo";
  static final String HIDDEN_SHOW_HISTORY_STOP = "mnuShowHistoryStop";
  static final String HIDDEN_SHOW_HISTORY_SPEED = "mnuShowHistorySpeed";
  static final String HIDDEN_SHOW_CONTACT_NO = "mnuShowContactNo";
  static final String HIDDEN_QUICK_DELETE_PLACE = "mnuQuickDeletePlace";
  static final String HIDDEN_SHOW_PHONE_NO = "mnuShowPhoneNo";
  static final String HIDDEN_SHOW_ALARM = "mnuShowAlarm";
  static final String HIDDEN_TRIP_COUNTER = "mnuTripCounter";
  static final String HIDDEN_VEHICLE_NOTE = "mnuVehicleNote";
  static final String HIDDEN_SIGNAL_MAPPING = "mnuSignalMapping";
  static final String HIDDEN_SHOW_POSITION = "mnuShowPosition";
  static final String HIDDEN_SHOW_FUEL_INFO = "mnuShowFuelInfo";
  static final String HIDDEN_FUEL_PRICE = "mnuFuelPrice";
  static final String HIDDEN_SHOW_E_CHECK = "mnuShowECheck";
  static final String HIDDEN_SHOW_INSPECTOR = "mnuShowInspector";
  static final String HIDDEN_SHOW_B_CHECK = "mnuShowBCheck";
  static final String HIDDEN_SHOW_S_CHECK = "mnuShowSCheck";
  static final String HIDDEN_SHOW_TASK = "mnuShowTask";
  static final String HIDDEN_SHOW_ORDER = "mnuShowOrder";
  static final String HIDDEN_SHOW_SHIPPING = "mnuShowShipping";
  static final String HIDDEN_SHOW_FUEL_CHECK = "mnuShowFuelCheck"; //fuel check
  static final String HIDDEN_STATION_MARK = "mnuStationMark";
  static final String HIDDEN_MAP = "mnuMap";
  static final String HIDDEN_GRANT_MAP_DRAWING_AREA = "mnuGrantMapDrawingArea";
  static final String HIDDEN_CHECK_ROUTING_LOG = "mnuCheckRoutingLog";
  static final String HIDDEN_DELETE_PHOTO = "mnuDeletePhoto";
  static final String HIDDEN_CHANGE_DRIVER_SINGLE = "mnuChangeDriverSingle";
  static final String HIDDEN_CHANGE_DRIVER_MULTI = "mnuChangeDriverMulti";
  static final String HIDDEN_SETUP_SENDING_SMS = "mnuSetupSendingSms";
  static final String HIDDEN_CHANGE_SIM_NO = "mnuChangeSimNo";
  static final String HIDDEN_CHECK_MOBILE_NO = "mnuCheckMobileNo";
  static final String HIDDEN_LOCK_DATA = "mnuLockData";
  static final String HIDDEN_SHOW_MONITORING_PLACE = "mnuShowMonitoringPlace";
  static final String HIDDEN_CHANGE_VEHICLE_POSITION =
      "mnuChangeVehiclePosition";
  static final String HIDDEN_CHANGE_TRAVEL_MAP_LINE = "mnuChangeTravelMapLine";
  static final String HIDDEN_USING_SKYMAP_ROUTE = "mnuUsingSkymapRoute";
  static final String HIDDEN_USING_GOOGLE_ROUTE = "mnuUsingGoogleRoute";
  static final String HIDDEN_LOCK_TAXI_METER = "mnuLockTaxiMeter";
  static final String HIDDEN_UNLOCK_CONTAINER = "mnuUnlockContainer";
  static final String HIDDEN_CHECK_NETWORK_SIGNAL = "mnuCheckNetworkSignal";
  static final String HIDDEN_EXPORT_VEHICLE_QR = "mnuExportVehicleQR";
  static final String HIDDEN_BLUETOOTH_DOWNLOAD = "mnuBluetoothDownload";
  static final String HIDDEN_SHOW_GARAGE = "mnuShowGarage";
  static final String HIDDEN_SHOW_STATION_TICKET = "mnuShowStationTicket";
  static final String HIDDEN_DRIVING_TIME_MANAGER = "mnuDrivingTimeManager";
  static final String HIDDEN_WRITE_DRIVER_RFID_CARD = "mnuWriteDriverRFIDCard";

  static final String RPT_REPORT_EXPORTER = "mnuReportExporter";

  static final String VEHICLE_CHECK_LIST_CHECKER = "mnuVehicleCheckListChecker";

  static final String APPROVE_LOGIN_DEVICE = "mnuApproveLoginDevice";

  static final String HIDDEN_SHOW_PARKING_CARD = "mnuShowParkingCard";
}
