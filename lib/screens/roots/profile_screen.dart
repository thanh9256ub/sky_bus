import 'package:flutter/material.dart';
import 'package:skysoft_bus/screens/roots/login_screen.dart';
import 'package:skysoft_bus/screens/roots/user_infomation_screen.dart';

import '../../utils/global.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        clipBehavior: Clip.none,
        children: [
          Column(
            children: [
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.22,
                width: double.infinity,
                child: Image.asset(
                  "assets/images/anh_nen.png",
                  fit: BoxFit.cover,
                ),
              ),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.only(top: 60, left: 10, right: 10),
                  color: Colors.white,
                  child: Column(
                    children: [
                      loginResponse.fullName.isEmpty
                          ? TextButton(
                              onPressed: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => LoginScreen(),
                                  ),
                                );
                              },
                              child: Text(
                                "Đăng nhập",
                                style: TextStyle(
                                  color: secondaryColor,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            )
                          : Text(
                              loginResponse.fullName,
                              style: TextStyle(
                                color: secondaryColor,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                      SizedBox(height: 20),
                      Visibility(
                        visible: loginResponse.fullName.isNotEmpty,
                        child: profileFeature(
                          "Thông tin cá nhân",
                          icon: Icons.person,
                          onTap: pushToUserInfoScreen,
                        ),
                      ),
                      SizedBox(height: 10),
                      profileFeature(
                        "Cài đặt",
                        icon: Icons.settings,
                        onTap: () {},
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          Positioned(
            top: MediaQuery.of(context).size.height * 0.22 - 50,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: CircleAvatar(
                  radius: 50,
                  backgroundImage: AssetImage('assets/images/images.jpg'),
                ),
              ),
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
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Padding(
          padding: EdgeInsets.all(14.0),
          child: Row(
            children: [
              Icon(icon, size: 18),
              SizedBox(width: 10),
              Expanded(child: Text(title, style: TextStyle(fontSize: 14))),
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
