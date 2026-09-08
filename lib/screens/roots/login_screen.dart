import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:skysoft_bus/screens/roots/confirm_phone_login.dart';
import 'package:skysoft_bus/screens/widgets/loading_screen.dart';
import 'package:skysoft_bus/utils/fields.dart';
import 'package:skysoft_bus/utils/global.dart';
import 'package:toastification/toastification.dart';

import '../../models/login_model.dart';
import '../../service/admin_service.dart';
import '../../utils/string_utils.dart';
import 'main_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _key = GlobalKey<FormState>();
  String _verificationId = "";
  int _resendToken = 0;
  bool isLoading = false;

  Future<void> sendOTP(String phoneNumber) async {
    await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: convertToInternationalPhoneNumber(phoneNumber),
      timeout: Duration(seconds: 60),
      verificationCompleted: (phoneAuthCredential) {},
      verificationFailed: (error) {
        if (mounted) {
          setState(() => isLoading = false);
        }
        showToast(
          error.code == 'too-many-requests'
              ? 'Tạm thời bị chặn do gửi quá nhiều yêu cầu. Vui lòng thử lại sau.'
              : error.code == 'invalid-verification-code'
              ? 'Mã OTP không chính xác.'
              : error.code == 'session-expired'
              ? 'Mã OTP đã hết hạn. Vui lòng yêu cầu mã mới.'
              : nvl(error.message),
          ToastificationType.error,
        );
      },
      codeSent: (verificationId, forceResendingToken) {
        _verificationId = verificationId;
        _resendToken = forceResendingToken ?? 0;
        if (!mounted) return;
        setState(() => isLoading = false);
        pushToConfirm();
      },
      codeAutoRetrievalTimeout: (verificationId) {},
    );
  }

  void pushToConfirm() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => ConfirmPhoneLogin(
          verificationId: _verificationId,
          resendCode: _resendToken,
        ),
      ),
    );
  }

  void signUp() async {
    if (!_key.currentState!.validate()) return;
    setState(() => isLoading = true);
    AdminService service = AdminService();
    final response = await service.signup(signUpRequest);
    setState(() => isLoading = false);
    if (response.errorMessage.isEmpty) {
      saveData(F_ACCOUNT_ID, response.accountID);
      loginRequest.accountID = response.accountID;
      sendOTP(signUpRequest.mobileNo);
    } else {
      final response = await service.reactivePassenger(
        signUpRequest.mobileNo,
        signUpRequest.appOS,
        signUpRequest.deviceID,
        signUpRequest.language,
      );
      if (response.errorMessage.isEmpty) {
        loginRequest.accountID = response.accountID;
        sendOTP(signUpRequest.mobileNo);
      } else {
        showToast(response.errorMessage, ToastificationType.error);
      }
    }
  }

  Future<void> processLoginResult(LoginResponse value) async {
    if (value.errorMessage.isEmpty) {
      loginResponse = value;

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MainScreen()),
        );
      }
    } else {
      showToast(value.errorMessage, ToastificationType.error);
    }
  }

  String convertToInternationalPhoneNumber(
    String phoneNumber, {
    String defaultCountryCode = '+84',
  }) {
    phoneNumber = phoneNumber.replaceAll(RegExp(r'[\s\-\(\)]'), '');

    if (phoneNumber.startsWith('+')) {
      return phoneNumber;
    }

    if (phoneNumber.startsWith('0')) {
      return defaultCountryCode + phoneNumber.substring(1);
    }

    return defaultCountryCode + phoneNumber;
  }

  @override
  Widget build(BuildContext context) {
    return LoadingOverlay(
      visible: isLoading,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                secondaryColor.withValues(alpha: 0.08),
                Colors.white,
                Colors.white,
              ],
            ),
          ),
          child: SafeArea(
            child: Stack(
              children: [
                LayoutBuilder(
                  builder: (context, constraints) {
                    return SingleChildScrollView(
                      padding: EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 5,
                      ),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: constraints.maxHeight - 120,
                        ),
                        child: Center(
                          child: ConstrainedBox(
                            constraints: BoxConstraints(maxWidth: 420),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                _buildHeader(),
                                SizedBox(height: 25),
                                _buildCard(),
                                SizedBox(height: 20),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
                _buildBackButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBackButton() {
    return Positioned(
      top: 8,
      left: 16,
      child: Material(
        color: Colors.white38,
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
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Image.asset("assets/images/logo_skybus.png", height: 65),
        SizedBox(height: 20),
        Text(
          "Tạo tài khoản mới",
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1A1D29),
          ),
        ),
        SizedBox(height: 6),
        Text(
          "Điền thông tin bên dưới để bắt đầu",
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
        ),
      ],
    );
  }

  Widget _buildCard() {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 30,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [formLogin(), SizedBox(height: 24), _buildSubmitButton()],
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: signUp,
        style: ElevatedButton.styleFrom(
          backgroundColor: secondaryColor,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              colors: [secondaryColor, secondaryColor.withValues(alpha: 0.75)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: secondaryColor.withValues(alpha: 0.35),
                blurRadius: 16,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: Container(
            alignment: Alignment.center,
            child: Text(
              "XÁC NHẬN",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget formLogin() {
    return Form(
      key: _key,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 250),
        transitionBuilder: (child, animation) => FadeTransition(
          opacity: animation,
          child: SizeTransition(
            sizeFactor: animation,
            axis: Axis.vertical,
            child: child,
          ),
        ),
        child: Column(
          children: [
            TextFormField(
              decoration: _fieldDecoration(
                hint: "Nhập họ và tên",
                icon: Icons.person_outline_rounded,
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
            const SizedBox(height: 16),
            TextFormField(
              decoration: _fieldDecoration(
                hint: "Nhập số điện thoại",
                icon: Icons.call_outlined,
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
            const SizedBox(height: 16),
            TextFormField(
              decoration: _fieldDecoration(
                hint: "Nhập email",
                icon: Icons.email_outlined,
              ),
              onTapOutside: (_) {
                FocusManager.instance.primaryFocus?.unfocus();
              },
              onChanged: (value) {
                setState(() {
                  signUpRequest.email = value;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _fieldDecoration({
    required String hint,
    required IconData icon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      prefixIcon: Icon(
        icon,
        color: secondaryColor.withValues(alpha: 0.7),
        size: 20,
      ),
      suffixIcon: suffixIcon,
      hintText: hint,
      hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
      filled: true,
      fillColor: const Color(0xFFF5F7FA),
      contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 4),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: secondaryColor, width: 1.6),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Colors.redAccent, width: 1.2),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Colors.redAccent, width: 1.4),
      ),
    );
  }
}
