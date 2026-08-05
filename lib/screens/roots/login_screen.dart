import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:skysoft_bus/screens/roots/confirm_phone_login.dart';
import 'package:skysoft_bus/utils/global.dart';
import 'package:toastification/toastification.dart';

import '../../models/login_model.dart';
import '../../utils/string_utils.dart';
import 'main_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool passwordVisible = false;
  bool isLogin = true;
  bool isLoginProcess = true;
  final confirmPasswordController = TextEditingController();
  final _key = GlobalKey<FormState>();

  void pushToConfirm() {
    if (!_key.currentState!.validate()) return;

    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (context) => ConfirmPhoneLogin()));
  }

  Future<void> processLoginResult(LoginResponse value) async {
    if (value.errorMessage.isEmpty) {
      loginResponse = value;

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MainScreen()),
      );
    } else {
      setState(() {
        isLoginProcess = false;
      });
      showToast(value.errorMessage, ToastificationType.error);
    }
  }

  @override
  void dispose() {
    isLoginProcess = false;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(backgroundColor: Colors.white),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Image.asset(
                  "assets/images/skysoft_logo_ok_h80.png",
                  height: 60,
                ),
              ),
              SizedBox(height: 30),
              selectType(),
              SizedBox(height: 30),
              formLogin(),
              SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 45,
                child: isLogin
                    ? ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: secondaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: Text(
                          "ĐĂNG NHẬP",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      )
                    : ElevatedButton(
                        onPressed: pushToConfirm,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: secondaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: Text(
                          "ĐĂNG KÝ",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget selectType() {
    return Container(
      padding: EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () {
                setState(() {
                  isLogin = true;
                });
              },
              child: Container(
                height: 42,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isLogin ? secondaryColor : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  "Đăng nhập",
                  style: TextStyle(
                    color: isLogin ? Colors.white : Colors.black87,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () {
                setState(() => isLogin = false);
              },
              child: Container(
                height: 42,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: !isLogin ? secondaryColor : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  "Đăng ký",
                  style: TextStyle(
                    color: !isLogin ? Colors.white : Colors.black87,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget formLogin() {
    return Form(
      key: _key,
      child: isLogin
          ? Column(
              children: [
                TextFormField(
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.call),
                    hintText: "Nhập số điện thoại",
                    filled: true,
                    fillColor: const Color(0xFFF5F7FA),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  keyboardType: TextInputType.phone,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  onTapOutside: (_) {
                    FocusManager.instance.primaryFocus?.unfocus();
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Vui lòng nhập số điện thoại';
                    } else if (!isValidPhoneNumber(value)) {
                      return "Sai định dạng số điện thoại";
                    } else {
                      return null;
                    }
                  },
                  onChanged: (value) {
                    setState(() {
                      signUpRequest.mobileNo = value;
                    });
                  },
                ),
                SizedBox(height: 20),
                TextFormField(
                  obscureText: !passwordVisible,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.lock_outline),
                    hintText: "Nhập mật khẩu",
                    filled: true,
                    fillColor: const Color(0xFFF5F7FA),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  onTapOutside: (event) {
                    FocusManager.instance.primaryFocus?.unfocus();
                  },
                ),
              ],
            )
          : Column(
              children: [
                TextFormField(
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.person),
                    hintText: "Nhập họ và tên",
                    filled: true,
                    fillColor: const Color(0xFFF5F7FA),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  onTapOutside: (_) {
                    FocusManager.instance.primaryFocus?.unfocus();
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Vui lòng nhập họ và tên';
                    }
                    return null;
                  },
                  onChanged: (value) {
                    setState(() {
                      signUpRequest.fullName = value;
                    });
                  },
                ),
                SizedBox(height: 20),
                TextFormField(
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.call),
                    hintText: "Nhập số điện thoại",
                    filled: true,
                    fillColor: const Color(0xFFF5F7FA),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  keyboardType: TextInputType.phone,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  onTapOutside: (_) {
                    FocusManager.instance.primaryFocus?.unfocus();
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Vui lòng nhập số điện thoại';
                    } else if (!isValidPhoneNumber(value)) {
                      return "Sai định dạng số điện thoại";
                    } else {
                      return null;
                    }
                  },
                  onChanged: (value) {
                    setState(() {
                      signUpRequest.mobileNo = value;
                    });
                  },
                ),
                SizedBox(height: 20),
                TextFormField(
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.email),
                    hintText: "Nhập email",
                    filled: true,
                    fillColor: const Color(0xFFF5F7FA),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  onTapOutside: (_) {
                    FocusManager.instance.primaryFocus?.unfocus();
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Vui lòng nhập email';
                    }
                    return null;
                  },
                  onChanged: (value) {
                    setState(() {
                      signUpRequest.email = value;
                    });
                  },
                ),
              ],
            ),
    );
  }
}
