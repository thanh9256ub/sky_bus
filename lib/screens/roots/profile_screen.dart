import 'package:flutter/material.dart';
import 'package:skysoft_bus/screens/roots/login_screen.dart';

import '../../utils/global.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
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
                      TextButton(
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
                      ),
                      SizedBox(height: 5),
                      profileFeature(
                        "Thông tin cá nhân",
                        icon: Icons.person,
                        onTap: () {},
                      ),
                      SizedBox(height: 10),
                      profileFeature(
                        "Cài đặt",
                        icon: Icons.settings,
                        onTap: () {},
                      ),
                      SizedBox(height: 10),
                      profileFeature(
                        "Thông tin công ty",
                        icon: Icons.insert_page_break,
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
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: const CircleAvatar(
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
          padding: const EdgeInsets.all(14.0),
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
