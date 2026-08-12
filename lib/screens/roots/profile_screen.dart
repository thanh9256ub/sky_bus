import 'package:flutter/material.dart';
import 'package:skysoft_bus/screens/roots/app_info_screen.dart';
import 'package:skysoft_bus/screens/roots/login_screen.dart';
import 'package:skysoft_bus/screens/roots/setting_screen.dart';
import 'package:skysoft_bus/screens/roots/user_infomation_screen.dart';

import '../../utils/global.dart';
import '../widgets/header_widget.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  void pushToUserInfoScreen() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (context) => UserInfomationScreen()));
  }

  void pushToLoginScreen() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (context) => LoginScreen()));
  }

  void pushToSettingScreen() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (context) => SettingsScreen()));
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
              top: MediaQuery.of(context).size.height * 0.20 - 50,
            ),
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.shade200,
                        blurRadius: 12,
                        offset: Offset(0, 6),
                      ),
                    ],
                  ),
                  child: CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.grey.shade300,
                    child: Icon(Icons.person, color: Colors.white, size: 50),
                  ),
                ),
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
                          onTap: pushToLoginScreen,
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
                        if (loginResponse.fullName.isNotEmpty) ...[
                          SizedBox(height: 24),
                          profileFeature(
                            "Đăng xuất",
                            icon: Icons.logout_rounded,
                            iconColor: Colors.redAccent,
                            titleColor: Colors.redAccent,
                            showArrow: false,
                            onTap: () {},
                          ),
                        ],
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
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.shade100,
                blurRadius: 10,
                blurStyle: BlurStyle.outer,
                offset: Offset(0, 4),
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
      ),
    );
  }
}
