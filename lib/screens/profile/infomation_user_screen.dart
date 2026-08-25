import 'package:flutter/material.dart';

import '../../utils/global.dart';

class InformationUserScreen extends StatelessWidget {
  final String name;
  final String phoneNumber;

  const InformationUserScreen({
    super.key,
    required this.name,
    required this.phoneNumber,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: secondaryColor,
        centerTitle: true,
        title: Text(
          "Thông tin cá nhân",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        leading: Padding(
          padding: EdgeInsets.all(10),
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
                child: Icon(
                  Icons.arrow_back_ios_new_rounded,
                  size: 18,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
          child: Column(
            children: [
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.shade200,
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.grey.shade300,
                  child: const Icon(
                    Icons.person,
                    color: Colors.white,
                    size: 50,
                  ),
                ),
              ),
              const SizedBox(height: 28),
              infoTile(
                label: "Họ và tên",
                value: name,
                icon: Icons.person_outline_rounded,
                iconColor: const Color(0xFF4C6EF5),
              ),
              const SizedBox(height: 12),
              infoTile(
                label: "Số điện thoại",
                value: phoneNumber,
                icon: Icons.phone_outlined,
                iconColor: const Color(0xFF12B886),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget infoTile({
    required String label,
    required String value,
    required IconData icon,
    Color iconColor = Colors.grey,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade100,
            blurRadius: 10,
            blurStyle: BlurStyle.outer,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(9),
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 18, color: iconColor),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 12.5,
                      color: Colors.grey.shade500,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    value.isNotEmpty ? value : "—",
                    style: const TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1C1C1E),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
