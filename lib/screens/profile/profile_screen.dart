import 'package:flutter/material.dart';
import 'package:skysoft_bus/screens/profile/card_screen.dart';
import 'package:skysoft_bus/screens/profile/infomation_user_screen.dart';
import 'package:skysoft_bus/screens/roots/login_screen.dart';
import 'package:skysoft_bus/utils/string_utils.dart';

import '../../utils/global.dart';
import 'app_info_screen.dart';
import 'setting_screen.dart';
import '../widgets/header_widget.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  void pushToScreen() {
    if (nvl(loginResponse.fullName).isNotEmpty) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => InformationUserScreen(
            name: loginResponse.fullName,
            phoneNumber: loginResponse.mobileNo,
          ),
        ),
      );
    } else {
      Navigator.of(
        context,
      ).push(MaterialPageRoute(builder: (context) => LoginScreen()));
    }
  }

  void pushToSettingScreen() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (context) => SettingsScreen()));
  }

  void pushToCardScreen() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (context) => CardScreen()));
  }

  void pushToAppInfoScreen() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (context) => AppInfoScreen()));
  }

  bool get isLoggedIn => loginResponse.fullName.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      body: Stack(
        clipBehavior: Clip.none,
        children: [
          HeaderWidget(),
          Padding(
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).size.height * 0.21,
            ),
            child: Column(
              children: [
                SizedBox(height: 28),
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(horizontal: 18),
                    child: Column(
                      children: [
                        profileFeature(
                          "Thông tin cá nhân",
                          icon: Icons.person_outline_rounded,
                          iconColor: Color(0xFF4C6EF5),
                          onTap: pushToScreen,
                        ),
                        SizedBox(height: 12),
                        profileFeature(
                          "Kiểm tra thẻ",
                          icon: Icons.card_membership,
                          iconColor: secondaryColor,
                          onTap: pushToCardScreen,
                        ),
                        SizedBox(height: 12),
                        profileFeature(
                          "Cài đặt",
                          icon: Icons.settings_outlined,
                          iconColor: Color(0xFF12B886),
                          onTap: pushToSettingScreen,
                        ),
                        SizedBox(height: 12),
                        profileFeature(
                          "Về ứng dụng",
                          icon: Icons.info_outline_rounded,
                          iconColor: Color(0xFF868E96),
                          onTap: pushToAppInfoScreen,
                        ),
                        SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget profileFeature(
    String title, {
    required Function() onTap,
    required IconData icon,
    Color iconColor = Colors.grey,
    Color titleColor = const Color(0xFF1C1C1E),
    bool showArrow = true,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade300,
              blurRadius: 10,
              blurStyle: BlurStyle.outer,
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(9),
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 18, color: iconColor),
              ),
              SizedBox(width: 14),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w500,
                    color: titleColor,
                  ),
                ),
              ),
              if (showArrow)
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: Colors.grey.shade400,
                  size: 12,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
