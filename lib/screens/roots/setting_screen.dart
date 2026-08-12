import 'package:flutter/material.dart';
import 'package:skysoft_bus/screens/roots/login_screen.dart';
import 'package:toastification/toastification.dart';
import '../../utils/global.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool notificationsEnabled = true;
  bool darkModeEnabled = false;

  void logout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          "Đăng xuất",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: const Text(
          "Bạn có chắc chắn muốn đăng xuất khỏi tài khoản này không?",
          style: TextStyle(fontSize: 14),
        ),
        actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text("Hủy", style: TextStyle(color: Colors.grey.shade600)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => const LoginScreen()),
                (route) => false,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              "Đăng xuất",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5F6FA),
      body: Stack(
        children: [
          Container(
            height: 150,
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [secondaryColor, secondaryColor.withValues(alpha: 0.5)],
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(32),
                bottomRight: Radius.circular(32),
              ),
            ),
            child: Stack(
              children: [
                Positioned(
                  top: -30,
                  right: -20,
                  child: Container(
                    width: 110,
                    height: 110,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white24,
                    ),
                  ),
                ),
                Positioned(
                  bottom: -30,
                  left: -20,
                  child: Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white24,
                    ),
                  ),
                ),
                Positioned(
                  bottom: 16,
                  right: 30,
                  child: Icon(
                    Icons.directions_bus_rounded,
                    size: 26,
                    color: Colors.white24,
                  ),
                ),
              ],
            ),
          ),

          SafeArea(
            child: Padding(
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
                    child: Icon(Icons.arrow_back_ios_new_rounded, size: 18),
                  ),
                ),
              ),
            ),
          ),

          Padding(
            padding: EdgeInsets.only(top: 130),
            child: ClipRRect(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(28),
                topRight: Radius.circular(28),
              ),
              child: Container(
                width: double.infinity,
                height: double.infinity,
                color: Color(0xFFF5F6FA),
                child: SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(18, 24, 18, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      sectionTitle("Tài khoản"),
                      SizedBox(height: 10),
                      settingsGroup([
                        settingsTile(
                          title: "Đổi mật khẩu",
                          icon: Icons.lock_outline_rounded,
                          iconColor: Color(0xFF4C6EF5),
                          onTap: () {
                            showToast(
                              "Tính năng đang phát triển",
                              ToastificationType.error,
                            );
                          },
                        ),
                        settingsTile(
                          title: "Thông tin cá nhân",
                          icon: Icons.person_outline_rounded,
                          iconColor: Color(0xFF12B886),
                          onTap: () {
                            showToast(
                              "Tính năng đang phát triển",
                              ToastificationType.error,
                            );
                          },
                        ),
                      ]),
                      SizedBox(height: 24),
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
          child: SizedBox(
            width: double.infinity,
            height: 50,
            child: OutlinedButton.icon(
              onPressed: logout,
              style: OutlinedButton.styleFrom(
                backgroundColor: Colors.redAccent.withValues(alpha: 0.1),
                side: BorderSide(
                  color: Colors.redAccent.withValues(alpha: 0.3),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              icon: Icon(
                Icons.logout_rounded,
                color: Colors.redAccent,
                size: 18,
              ),
              label: Text(
                "Đăng xuất",
                style: TextStyle(
                  color: Colors.redAccent,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
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
