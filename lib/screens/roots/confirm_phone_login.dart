import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pinput/pinput.dart';
import 'package:skysoft_bus/screens/roots/main_screen.dart';
import 'package:skysoft_bus/screens/widgets/loading_screen.dart';
import 'package:skysoft_bus/utils/fields.dart';
import 'package:skysoft_bus/utils/global.dart';
import 'package:skysoft_bus/utils/string_utils.dart';
import 'package:toastification/toastification.dart';

import '../../models/login_model.dart';
import '../../service/admin_service.dart';

class ConfirmPhoneLogin extends StatefulWidget {
  final String verificationId;
  const ConfirmPhoneLogin({super.key, required this.verificationId});

  @override
  State<ConfirmPhoneLogin> createState() => _ConfirmPhoneLoginState();
}

class _ConfirmPhoneLoginState extends State<ConfirmPhoneLogin> {
  PinTheme defaultPinTheme = PinTheme();
  PinTheme focusedPinTheme = PinTheme();
  AdminService service = AdminService();
  ActiveRequest request = ActiveRequest();
  String validateMsg = "";
  bool isLoading = false;

  Future<void> verifyOTP(String smsCode) async {
    if (widget.verificationId.isEmpty) return;
    setState(() => isLoading = true);
    try {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: widget.verificationId,
        smsCode: smsCode,
      );
      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithCredential(credential);
      if (userCredential.user != null) {
        if (mounted) {
          String? tokenOTP = await userCredential.user!.getIdToken();
          String? uid = userCredential.user!.uid;
          request.tokenID = nvl(tokenOTP);
          request.uid = nvl(uid);

          await activatePassenger(smsCode);
        }
      } else {
        showToast("Lỗi thông tin user", ToastificationType.error);
      }
    } catch (e) {
      if (mounted) setState(() => isLoading = false);
      validateMsg = "Pin is incorrect";
    }
  }

  Future<void> activatePassenger(String smsCode) async {
    request.accountID = loginRequest.accountID;
    request.deviceID = loginRequest.deviceID;
    request.activeKey = smsCode;
    final response = await service.activatePassenger(request);
    if (response.errorMessage.isEmpty) {
      loginRequest.authenKey = smsCode;
      await saveData(F_SECURE_KEY, response.secureKey);
      login();
    } else {
      showToast(response.errorMessage, ToastificationType.error);
      setState(() => isLoading = false);
    }
  }

  Future<void> login() async {
    final response = await service.login(loginRequest);
    if (response.errorMessage.isEmpty) {
      setState(() {
        loginResponse = response;
      });
      await saveData(F_ACCOUNT_ID, loginRequest.accountID);
      if (mounted) {
        setState(() => isLoading = false);
        showToast("Đăng nhập thành công", ToastificationType.success);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MainScreen()),
        );
      }
    } else {
      showToast(response.errorMessage, ToastificationType.error);
      setState(() => isLoading = false);
    }
  }

  @override
  void initState() {
    super.initState();
    defaultPinTheme = PinTheme(
      width: 52,
      height: 58,
      textStyle: const TextStyle(
        fontSize: 20,
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
    return LoadingOverlay(
      visible: isLoading,
      child: Scaffold(
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
                          child: Icon(
                            Icons.arrow_back_ios_new_rounded,
                            size: 18,
                          ),
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
                    hapticFeedbackType: HapticFeedbackType.lightImpact,
                    errorTextStyle: TextStyle(color: Colors.red, fontSize: 13),
                    validator: (value) {
                      return validateMsg.isNotEmpty ? validateMsg : null;
                    },
                    onCompleted: verifyOTP,
                  ),
                  SizedBox(height: 28),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
