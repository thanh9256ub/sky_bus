import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:skysoft_bus/models/login_model.dart';
import 'package:skysoft_bus/screens/roots/main_screen.dart';
import 'package:skysoft_bus/utils/fields.dart';
import '../../utils/global.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool notificationsEnabled = true;
  bool darkModeEnabled = false;
  Future<void> logout() async {
    const storage = FlutterSecureStorage();
    storage.delete(key: F_ACCOUNT_ID);
    storage.delete(key: F_AUTHEN_KEY);
    loginResponse = LoginResponse("", "");
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MainScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          SafeArea(
            child: Padding(
              padding: EdgeInsets.all(10),
              child: Row(
                children: [
                  Material(
                    color: Colors.white38,
                    shape: CircleBorder(),
                    elevation: 3,
                    shadowColor: Colors.black26,
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
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      "Cài đặt",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(28),
                topRight: Radius.circular(28),
              ),
              child: Container(
                width: double.infinity,
                color: Color(0xFFF5F6FA),
                child: SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(18, 24, 18, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // sectionTitle("Tài khoản"),
                      // SizedBox(height: 10),
                      // settingsGroup([
                      //   settingsTile(
                      //     title: "Đổi mật khẩu",
                      //     icon: Icons.lock_outline_rounded,
                      //     iconColor: Color(0xFF4C6EF5),
                      //     onTap: () {
                      //       showToast(
                      //         "Tính năng đang phát triển",
                      //         ToastificationType.error,
                      //       );
                      //     },
                      //   ),
                      // ]),
                      // SizedBox(height: 24),
                      sectionTitle("Tuỳ chọn"),
                      SizedBox(height: 10),
                      settingsGroup([
                        settingsSwitchTile(
                          title: "Chế độ tối",
                          icon: Icons.dark_mode_outlined,
                          iconColor: Color(0xFF495057),
                          value: darkModeEnabled,
                          onChanged: (value) {
                            setState(() => darkModeEnabled = value);
                          },
                        ),
                        settingsTile(
                          title: "Ngôn ngữ",
                          icon: Icons.language_rounded,
                          iconColor: Color(0xFF15AABF),
                          trailingText: "Tiếng Việt",
                          onTap: () {},
                        ),
                      ]),
                      SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(10),
          child: ElevatedButton(
            onPressed: logout,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade50,
              elevation: 1,
              shape: RoundedRectangleBorder(
                side: BorderSide(color: Colors.red),
                borderRadius: BorderRadius.circular(15),
              ),
            ),
            child: Text(
              "Đăng xuất",
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),
    );
  }

  Widget sectionTitle(String title) {
    return Padding(
      padding: EdgeInsets.only(left: 4),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: Colors.grey.shade500,
          letterSpacing: 0.3,
        ),
      ),
    );
  }

  Widget settingsGroup(List<Widget> tiles) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          for (int i = 0; i < tiles.length; i++) ...[
            tiles[i],
            if (i != tiles.length - 1)
              Padding(
                padding: EdgeInsets.only(left: 58),
                child: Divider(height: 1, color: Colors.grey.shade100),
              ),
          ],
        ],
      ),
    );
  }

  Widget settingsTile({
    required String title,
    required IconData icon,
    required Color iconColor,
    required VoidCallback onTap,
    String? trailingText,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 17, color: iconColor),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF1C1C1E),
                ),
              ),
            ),
            if (trailingText != null)
              Padding(
                padding: const EdgeInsets.only(right: 6),
                child: Text(
                  trailingText,
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
                ),
              ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              color: Colors.grey.shade400,
              size: 12,
            ),
          ],
        ),
      ),
    );
  }

  Widget settingsSwitchTile({
    required String title,
    required IconData icon,
    required Color iconColor,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 17, color: iconColor),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 14.5,
                fontWeight: FontWeight.w500,
                color: Color(0xFF1C1C1E),
              ),
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: secondaryColor,
          ),
        ],
      ),
    );
  }
}
