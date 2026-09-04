import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:gal/gal.dart';
import 'package:intl/intl.dart';
import 'package:screenshot/screenshot.dart';
import 'package:toastification/toastification.dart';

import '../models/login_model.dart';

// const String baseUrl = "https://dev.skysoft.vn";
const String baseUrl = "https://tracking.skysoft.vn";
const String skymapUrl = "https://maps.skysoft.vn";

LoginRequest loginRequest = LoginRequest();
SignupRequest signUpRequest = SignupRequest();
LoginResponse loginResponse = LoginResponse("", "");

Color primaryColor = Color(0xFFf97316);
Color secondaryColor = Color(0xFF0ea5e9);

final RouteObserver<ModalRoute<void>> routeObserver =
    RouteObserver<ModalRoute<void>>();

FlutterSecureStorage secureStorage = const FlutterSecureStorage();
final moneyFormat = NumberFormat("#,##0", "en_US");

const Color LIGHT_GREY = Color.fromARGB(255, 228, 227, 227);

void showToast(String msg, ToastificationType type) {
  toastification.show(
    title: Text(msg),
    type: type,
    style: ToastificationStyle.flatColored,
    alignment: Alignment.bottomCenter,
    autoCloseDuration: Duration(seconds: 3),
  );
}

Future<void> saveData(String key, String value) async {
  await secureStorage.write(key: key, value: value);
}

Future<String?> readData(String key) async {
  return secureStorage.read(key: key);
}

Future<void> downloadQrCode(ScreenshotController screenshotController) async {
  try {
    final image = await screenshotController.capture(
      pixelRatio: 3,
      delay: Duration(milliseconds: 100),
    );
    if (image == null) {
      throw Exception("Không thể chụp màn hình");
    }
    final hasAccess = await Gal.hasAccess();
    if (!hasAccess) {
      await Gal.requestAccess();
    }
    await Gal.putImageBytes(image, name: "payment_ticket");

    showToast("Đã lưu ảnh vé vào thư viện", ToastificationType.success);
  } catch (e) {
    showToast("Lỗi khi lưu ảnh: $e", ToastificationType.error);
  }
}
