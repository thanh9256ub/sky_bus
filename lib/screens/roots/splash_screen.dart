import 'dart:async';
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:package_info_plus/package_info_plus.dart';

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

  @override
  void initState() {
    super.initState();
    initPlatformState();
    startApp();
  }

  void initPlatformState() async {
    var deviceData = <String, dynamic>{};
    final appInfo = await PackageInfo.fromPlatform();

    try {
      if (Platform.isAndroid) {
        deviceData = readAndroidBuildData(await deviceInfoPlugin.androidInfo);
        loginRequest.appOs = "Android";
        loginRequest.deviceName = deviceData['device'];
        loginRequest.deviceID = deviceData['id'];
        loginRequest.deviceModel = deviceData['model'];
        loginRequest.deviceBrand = deviceData['brand'];
      } else if (Platform.isIOS) {
        deviceData = readIosDeviceInfo(await deviceInfoPlugin.iosInfo);
        loginRequest.appOs = "iOS";
        loginRequest.deviceName = deviceData['utsname.nodename'];
        loginRequest.osVersion = deviceData['systemVersion'];
        loginRequest.deviceID = deviceData['identifierForVendor'];
        loginRequest.deviceModel = deviceData['model'];
        loginRequest.deviceBrand = "Apple";
      }
    } on PlatformException {
      deviceData = <String, dynamic>{
        'Error': 'Failed to get platform version.',
      };
      loginRequest.deviceID = '';
    }

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

  Future<void> startApp() async {
    String? userName = await readData(F_USER_NAME);
    String? password = await readData(F_PASSWORD);
    String firebaseToken = nvl(await readData(F_FIREBASE_TOKEN));
    loginRequest.fireBaseToken = firebaseToken;

    if (nvl(userName).isNotEmpty) {
      loginRequest.userName = nvl(userName);
      loginRequest.password = nvl(password);
      loginRequest.reconnect = true;

      AdminService service = AdminService();
      LoginResponse response = await service.login(loginRequest);
      processLoginResult(response);
    } else {
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MainScreen()),
      );
    }
  }

  Future<void> processLoginResult(LoginResponse value) async {
    if (value.errorMessage.isEmpty) {
      loginResponse = value;
      await saveData(F_FIREBASE_TOKEN, nvl(loginRequest.fireBaseToken));
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MainScreen()),
        );
      }
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MainScreen()),
      );
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
            Container(
              margin: const EdgeInsets.all(30),
              child: const CircularProgressIndicator.adaptive(),
            ),
          ],
        ),
      ),
    );
  }
}
