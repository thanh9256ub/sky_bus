import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:crypto/crypto.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/services.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:flutter/material.dart';

import '../../models/login_model.dart';
import '../../service/admin_service.dart';
import '../../utils/fields.dart';
import '../../utils/global.dart';
import '../../utils/string_utils.dart';
import 'main_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  static final DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
  final Connectivity _connectivity = Connectivity();
  StreamSubscription<List<ConnectivityResult>>? _connSub;

  bool hasError = false;
  bool isRetry = false;

  @override
  void initState() {
    super.initState();
    initPlatformState();
    startApp();
  }

  @override
  void dispose() {
    _connSub?.cancel();
    super.dispose();
  }

  void initPlatformState() async {
    var deviceData = <String, dynamic>{};

    final appInfo = await PackageInfo.fromPlatform();

    try {
      if (Platform.isAndroid) {
        deviceData = readAndroidBuildData(await deviceInfoPlugin.androidInfo);
        signUpRequest.appOS = "Android";
        signUpRequest.deviceID = deviceData['id'];
        signUpRequest.language = "vi";

        loginRequest.appOS = "Android";
        loginRequest.deviceID = deviceData['id'];
        loginRequest.deviceName = deviceData['device'];
        loginRequest.language = "vi";
      } else if (Platform.isIOS) {
        deviceData = readIosDeviceInfo(await deviceInfoPlugin.iosInfo);
        signUpRequest.appOS = "iOS";
        signUpRequest.deviceID = deviceData['identifierForVendor'];
        signUpRequest.language = "vi";

        loginRequest.appOS = "iOS";
        loginRequest.osVersion = deviceData['systemVersion'];
        loginRequest.deviceID = deviceData['identifierForVendor'];
        loginRequest.deviceName = deviceData['utsname.nodename'];
        loginRequest.language = "vi";
      }
    } on PlatformException {
      signUpRequest.deviceID = '';
    }

    signUpRequest.appName = appInfo.appName;
    loginRequest.appVersion = appInfo.version;
  }

  Map<String, dynamic> readAndroidBuildData(AndroidDeviceInfo build) {
    return <String, dynamic>{
      'version.securityPatch': build.version.securityPatch,
      'version.sdkInt': build.version.sdkInt,
      'version.release': build.version.release,
      'version.previewSdkInt': build.version.previewSdkInt,
      'version.incremental': build.version.incremental,
      'version.codename': build.version.codename,
      'version.baseOS': build.version.baseOS,
      'board': build.board,
      'bootloader': build.bootloader,
      'brand': build.brand,
      'device': build.device,
      'display': build.display,
      'fingerprint': build.fingerprint,
      'hardware': build.hardware,
      'host': build.host,
      'id': build.id,
      'manufacturer': build.manufacturer,
      'model': build.model,
      'product': build.product,
      'supported32BitAbis': build.supported32BitAbis,
      'supported64BitAbis': build.supported64BitAbis,
      'supportedAbis': build.supportedAbis,
      'tags': build.tags,
      'type': build.type,
      'isPhysicalDevice': build.isPhysicalDevice,
      'systemFeatures': build.systemFeatures,
    };
  }

  Map<String, dynamic> readIosDeviceInfo(IosDeviceInfo data) {
    return <String, dynamic>{
      'name': data.name,
      'systemName': data.systemName,
      'systemVersion': data.systemVersion,
      'model': data.model,
      'localizedModel': data.localizedModel,
      'identifierForVendor': data.identifierForVendor,
      'isPhysicalDevice': data.isPhysicalDevice,
      'utsname.sysname': data.utsname.sysname,
      'utsname.nodename': data.utsname.nodename,
      'utsname.release': data.utsname.release,
      'utsname.version': data.utsname.version,
      'utsname.machine': data.utsname.machine,
    };
  }

  void pushToMainScreen() {
    Navigator.of(
      context,
    ).pushReplacement(MaterialPageRoute(builder: (context) => MainScreen()));
  }

  void _listenForReconnect() {
    _connSub?.cancel();
    _connSub = _connectivity.onConnectivityChanged.listen((result) {
      final hasConnection =
          !result.contains(ConnectivityResult.none) && result.isNotEmpty;
      if (hasConnection && hasError && !isRetry) {
        _connSub?.cancel();
        startApp();
      }
    });
  }

  Future<void> startApp() async {
    final result = await _connectivity.checkConnectivity();
    if (!mounted) return;
    setState(() {
      isRetry = true;
      hasError = false;
    });

    final hasNetwork =
        !result.contains(ConnectivityResult.none) && result.isNotEmpty;
    if (!hasNetwork) {
      _handleConnectionError();
      return;
    }

    final accountID = await readData(F_ACCOUNT_ID);
    if (nvl(accountID).isEmpty) {
      await Future.delayed(const Duration(seconds: 2));
      if (mounted) {
        isRetry = false;
        pushToMainScreen();
        return;
      }
    }

    try {
      loginRequest.accountID = accountID!;
      String time = DateTime.now().millisecondsSinceEpoch.toString();
      String? sercureKey = await readData(F_SECURE_KEY);
      String rawKey =
          "$accountID-$time-${loginRequest.deviceID}-$sercureKey-$PRIVATE_BUS_KEY";
      String authenKey = md5.convert(utf8.encode(rawKey)).toString();
      loginRequest.time = time;
      loginRequest.authenKey = authenKey;

      AdminService service = AdminService();
      final response = await service.login(loginRequest);
      isRetry = false;
      await processLoginResult(response);
    } on SocketException {
      _handleConnectionError();
    } on TimeoutException {
      _handleConnectionError();
    } catch (e) {
      isRetry = false;
      loginRequest.reconnect = false;
      if (mounted) pushToMainScreen;
    }
  }

  void _handleConnectionError() {
    isRetry = false;
    if (!mounted) return;
    setState(() {
      hasError = true;
    });
    _listenForReconnect();
  }

  Future<void> processLoginResult(LoginResponse value) async {
    if (value.errorMessage.isEmpty) {
      loginResponse = value;
      await saveData(F_FIREBASE_TOKEN, nvl(signUpRequest.authenByFirebase));
      if (mounted) pushToMainScreen;
    } else {
      loginRequest.reconnect = false;
      if (mounted) pushToMainScreen;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 50),
              child: Image.asset(
                "assets/images/skysoft_logo_ok_h80.png",
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(height: 30),
            hasError
                ? const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 40),
                    child: Text(
                      "Lỗi kết nối mạng",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 15, color: Colors.black87),
                    ),
                  )
                : const CircularProgressIndicator.adaptive(),
          ],
        ),
      ),
    );
  }
}
