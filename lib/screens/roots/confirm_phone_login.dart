import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:pinput/pinput.dart';

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
      width: 60,
      height: 64,
      textStyle: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        color: Color(0xFF1E293B),
      ),
      decoration: BoxDecoration(
        color: Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Color(0xFFE2E8F0), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
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
            Text(widget.phone, style: TextStyle(fontSize: 14)),
            SizedBox(height: 50),
            Center(
              child: Pinput(
                defaultPinTheme: defaultPinTheme,
                onCompleted: (pin) => log(pin),
              ),
            ),
            SizedBox(height: 40),
            Text(
              "Không nhận được mã?",
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            SizedBox(height: 10),
            TextButton(
              style: ButtonStyle(
                overlayColor: WidgetStatePropertyAll(Colors.transparent),
              ),
              onPressed: () {},
              child: Text(
                "Gửi lại mã",
                style: TextStyle(decoration: TextDecoration.underline),
              ),
            ),
            SizedBox(height: 40),
          ],
        ),
      ),
      // bottomNavigationBar: SafeArea(
      //   child: Padding(
      //     padding: EdgeInsets.all(10.0),
      //     child: Container(
      //       height: 50,
      //       decoration: BoxDecoration(
      //         borderRadius: BorderRadius.circular(12),
      //         border: Border.all(color: Colors.grey.shade300),
      //         color: Colors.blue.shade100,
      //         boxShadow: [
      //           BoxShadow(
      //             color: Colors.black.withValues(alpha: 0.04),
      //             blurRadius: 8,
      //             blurStyle: BlurStyle.outer,
      //             offset: Offset(0, 2),
      //           ),
      //         ],
      //       ),
      //       alignment: Alignment.center,
      //       child: Text("Xác nhận", style: TextStyle(fontSize: 16)),
      //     ),
      //   ),
      // ),
    );
  }
}
