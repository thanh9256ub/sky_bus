import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:pinput/pinput.dart';
import 'package:skysoft_bus/models/action_result.dart';
import 'package:skysoft_bus/utils/global.dart';

import '../../service/admin_service.dart';

class ConfirmPhoneLogin extends StatefulWidget {
  const ConfirmPhoneLogin({super.key});

  @override
  State<ConfirmPhoneLogin> createState() => _ConfirmPhoneLoginState();
}

class _ConfirmPhoneLoginState extends State<ConfirmPhoneLogin> {
  PinTheme defaultPinTheme = PinTheme();
  AdminService service = AdminService();
  void signUp() async {
    ActionResult response = await service.signup(signUpRequest);
    log(response.errorMessage);
  }

  @override
  void initState() {
    super.initState();
    defaultPinTheme = PinTheme(
      width: 56,
      height: 62,
      textStyle: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.grey.shade300, width: 1.5),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(backgroundColor: Colors.white),
      body: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: 20),
            Text(
              "Xác thực số điện thoại",
              style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 40),
            Text(
              "Hãy nhập mã đã được gửi đến số",
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            SizedBox(height: 20),
            Text(signUpRequest.mobileNo, style: TextStyle(fontSize: 16)),
            SizedBox(height: 30),
            Center(
              child: Pinput(
                length: 6,
                defaultPinTheme: defaultPinTheme,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng nhập mã OTP';
                  }
                  if (value.length < 6) {
                    return 'Mã OTP phải gồm 6 số';
                  }
                  return null;
                },
                onCompleted: (pin) => signUp,
              ),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Không nhận được mã?",
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
                SizedBox(width: 10),
                TextButton(
                  onPressed: () {},
                  child: Text(
                    "Gửi lại mã",
                    style: TextStyle(decoration: TextDecoration.underline),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            Padding(
              padding: EdgeInsets.all(10),
              child: SizedBox(
                height: 56,
                width: 300,
                child: ElevatedButton(
                  onPressed: signUp,
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
            ),
          ],
        ),
      ),
    );
  }
}
