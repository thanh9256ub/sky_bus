import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:pinput/pinput.dart';
import 'package:skysoft_bus/models/action_result.dart';
import 'package:skysoft_bus/screens/roots/main_screen.dart';
import 'package:skysoft_bus/utils/fields.dart';
import 'package:skysoft_bus/utils/global.dart';
import 'package:toastification/toastification.dart';

import '../../models/login_model.dart';
import '../../service/admin_service.dart';

class ConfirmPhoneLogin extends StatefulWidget {
  const ConfirmPhoneLogin({super.key});

  @override
  State<ConfirmPhoneLogin> createState() => _ConfirmPhoneLoginState();
}

class _ConfirmPhoneLoginState extends State<ConfirmPhoneLogin> {
  PinTheme defaultPinTheme = PinTheme();
  PinTheme focusedPinTheme = PinTheme();
  AdminService service = AdminService();
  ActiveRequest request = ActiveRequest();

  bool isResending = false;

  void reactivePassenger() async {
    setState(() {
      isResending = true;
    });
    ActionResult response = await service.reactivePassenger(signUpRequest);
    log(response.errorMessage);
    if (mounted) {
      setState(() {
        isResending = false;
      });
    }
    if (response.errorMessage.isEmpty) {
      if (mounted) {
        showToast("Mã OTP đã được gửi lại", ToastificationType.success);
      }
    }
  }

  Future<void> activatePassenger(String activeKey) async {
    request.accountID = loginRequest.accountID;
    request.activeKey = activeKey;
    request.deviceID = loginRequest.deviceID;

    final response = await service.activatePassenger(request);

    if (response.errorMessage.isEmpty) {
      loginRequest.authenKey = activeKey;

      await login();
    } else {
      showToast(response.errorMessage, ToastificationType.error);
      return;
    }
  }

  Future<void> login() async {
    final response = await service.login(loginRequest);

    if (response.errorMessage.isEmpty) {
      setState(() {
        loginResponse = response;
      });
      await saveData(F_ACCOUNT_ID, loginRequest.accountID);

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => MainScreen()),
      );
    } else {
      showToast(response.errorMessage, ToastificationType.error);
      return;
    }
  }

  @override
  void initState() {
    super.initState();

    defaultPinTheme = PinTheme(
      width: 52,
      height: 58,
      textStyle: const TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.bold,
        color: Color(0xFF1F2937),
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F8FA),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB), width: 1.5),
      ),
    );

    focusedPinTheme = defaultPinTheme.copyWith(
      decoration: defaultPinTheme.decoration!.copyWith(
        color: Colors.white,
        border: Border.all(color: secondaryColor, width: 2),
        boxShadow: [
          BoxShadow(
            color: secondaryColor.withValues(alpha: 0.25),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF4F6F9),
      body: SafeArea(
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFFF4F6F9), Colors.white],
              stops: [0.0, 0.35],
            ),
          ),
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                SizedBox(height: 8),
                Align(
                  alignment: Alignment.topLeft,
                  child: Material(
                    color: Colors.white,
                    shape: CircleBorder(),
                    elevation: 3,
                    shadowColor: Colors.black.withValues(alpha: 0.15),
                    child: InkWell(
                      customBorder: CircleBorder(),
                      onTap: () {
                        Navigator.of(context).pop();
                      },
                      child: Padding(
                        padding: EdgeInsets.all(10),
                        child: Icon(Icons.arrow_back_ios_new_rounded, size: 18),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 24),
                Container(
                  width: 84,
                  height: 84,
                  decoration: BoxDecoration(
                    color: secondaryColor.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.sms_outlined,
                    size: 38,
                    color: secondaryColor,
                  ),
                ),
                SizedBox(height: 28),
                Text(
                  "Xác thực số điện thoại",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF111827),
                  ),
                ),
                SizedBox(height: 12),
                RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    style: TextStyle(
                      fontSize: 15,
                      color: Color(0xFF6B7280),
                      height: 1.4,
                    ),
                    children: [
                      TextSpan(
                        text: "Hãy nhập mã gồm 6 số đã được gửi đến số\n",
                      ),
                      TextSpan(
                        text: signUpRequest.mobileNo,
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF111827),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 36),
                Pinput(
                  length: 6,
                  defaultPinTheme: defaultPinTheme,
                  focusedPinTheme: focusedPinTheme,
                  pinAnimationType: PinAnimationType.scale,
                  errorTextStyle: TextStyle(color: Colors.red, fontSize: 13),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Vui lòng nhập mã OTP';
                    }
                    if (value.length < 6) {
                      return 'Mã OTP phải gồm 6 số';
                    }
                    return null;
                  },
                  onCompleted: activatePassenger,
                ),
                SizedBox(height: 28),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Không nhận được mã? ",
                      style: TextStyle(fontSize: 15, color: Color(0xFF6B7280)),
                    ),
                    TextButton(
                      onPressed: isResending ? null : reactivePassenger,
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: Size(0, 0),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: isResending
                          ? SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: secondaryColor,
                              ),
                            )
                          : Text(
                              "Gửi lại mã",
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: secondaryColor,
                                decoration: TextDecoration.underline,
                                decorationColor: secondaryColor,
                              ),
                            ),
                    ),
                  ],
                ),
                SizedBox(height: 28),
                SizedBox(
                  height: 56,
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: login,
                    style: ElevatedButton.styleFrom(
                      elevation: 0,
                      backgroundColor: secondaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Text(
                      "Xác nhận",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 5),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
