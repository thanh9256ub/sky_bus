import 'dart:io';

import 'package:flutter/material.dart';
import 'package:skysoft_bus/utils/global.dart';
import 'package:url_launcher/url_launcher.dart';

class AppInfoScreen extends StatelessWidget {
  const AppInfoScreen({super.key});
  static const String _supportEmail = "support@skysoft.vn";
  static const String _fanpageUrl = "https://www.facebook.com/skysoft.vn";
  Future<void> _openEmail(BuildContext context) async {
    final uri = Uri(
      scheme: 'mailto',
      path: _supportEmail,
      query: 'subject=Hỗ trợ ứng dụng SkyBus',
    );
    final ok = await launchUrl(uri);
    if (!ok && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Không thể mở ứng dụng Email")),
      );
    }
  }

  Future<void> _openFanpage(BuildContext context) async {
    final uri = Uri.parse(_fanpageUrl);
    final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!ok && context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Không thể mở Fanpage")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF4F6F9),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: secondaryColor,
        centerTitle: true,
        title: Text(
          "Thông tin ứng dụng",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: Icon(
            Platform.isIOS ? Icons.arrow_back_ios_new : Icons.arrow_back,
            color: Colors.white,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 20,
                    offset: Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Image(
                        image: AssetImage("assets/images/logo_skybus.png"),
                        height: 60,
                      ),
                      Image(
                        image: AssetImage(
                          "assets/images/skysoft_logo_ok_h80.png",
                        ),
                        height: 35,
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  Text(
                    "SkyBus (Official)",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                  SizedBox(height: 6),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: secondaryColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      "Phiên bản ${loginRequest.appVersion}",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: secondaryColor,
                      ),
                    ),
                  ),
                  SizedBox(height: 5),
                  Divider(thickness: 1, color: Colors.grey.shade200),
                  SizedBox(height: 5),

                  Text(
                    "SkyBus là Ứng dụng đặt vé xe buýt thông minh giúp hành khách "
                    "dễ dàng tra cứu tuyến xe, lựa chọn điểm đi và điểm đến, xem "
                    "giá vé và đặt vé trực tuyến ngay trên điện thoại. Bên cạnh "
                    "đó, ứng dụng còn tích hợp bản đồ thời gian thực cho phép "
                    "theo dõi vị trí các xe đang hoạt động trên tuyến, giúp người "
                    "dùng chủ động sắp xếp thời gian di chuyển, giảm thời gian chờ "
                    "đợi và nâng cao trải nghiệm sử dụng phương tiện giao thông "
                    "công cộng.",
                    style: TextStyle(
                      color: Colors.grey.shade700,
                      height: 1.5,
                      fontSize: 13.5,
                    ),
                  ),
                  SizedBox(height: 16),

                  Row(
                    children: [
                      Icon(
                        Icons.business,
                        size: 16,
                        color: Colors.grey.shade500,
                      ),
                      SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          "Phát triển bởi Công ty CP Công nghệ Trực tuyến Skysoft",
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 12.5,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            Text(
              "Liên hệ với chúng tôi",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
              ),
            ),
            SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _ContactTile(
                    icon: Icons.email_outlined,
                    label: "Email",
                    color: secondaryColor,
                    onTap: () => _openEmail(context),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: _ContactTile(
                    icon: Icons.facebook,
                    label: "Fanpage",
                    color: Color(0xFF1877F2),
                    onTap: () => _openFanpage(context),
                  ),
                ),
              ],
            ),
            SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _ContactTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ContactTile({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade300,
              blurRadius: 10,
              blurStyle: BlurStyle.outer,
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}
