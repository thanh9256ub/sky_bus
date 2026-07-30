import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:pinput/pinput.dart';
import 'package:skysoft_bus/utils/global.dart';

class ConfirmPhoneLogin extends StatefulWidget {
  final String phone;
  const ConfirmPhoneLogin({super.key, required this.phone});

  @override
  State<ConfirmPhoneLogin> createState() => _ConfirmPhoneLoginState();
}

class _ConfirmPhoneLoginState extends State<ConfirmPhoneLogin> {
  PinTheme defaultPinTheme = PinTheme();

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
            Text(widget.phone, style: TextStyle(fontSize: 16)),
            SizedBox(height: 30),
            Center(
              child: Pinput(
                defaultPinTheme: defaultPinTheme,
                onCompleted: (pin) => log(pin),
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
                  onPressed: () {},
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
