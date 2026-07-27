import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:gal/gal.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:toastification/toastification.dart';

import '../../models/bus_line_model.dart';
import '../../utils/global.dart';

class PaymentScreen extends StatefulWidget {
  final BusLine selectedLine;
  final List<int> placeIds;
  final Matrix matrix;
  final int quantity;
  const PaymentScreen({
    super.key,
    required this.selectedLine,
    required this.matrix,
    required this.placeIds,
    required this.quantity,
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final GlobalKey _globalKey = GlobalKey();
  String qrData = "https://flutter.dev";
  bool isSaving = false;

  String getPlaceName(int placeId) {
    return widget.selectedLine.placeMarks
        .firstWhere((e) => e.placeID == placeId)
        .description;
  }

  Future<void> _downloadQrCode() async {
    setState(() {
      isSaving = true;
    });
    try {
      RenderRepaintBoundary boundary =
          _globalKey.currentContext!.findRenderObject()
              as RenderRepaintBoundary;

      ui.Image image = await boundary.toImage(pixelRatio: 3.0);

      ByteData? byteData = await image.toByteData(
        format: ui.ImageByteFormat.png,
      );
      Uint8List pngBytes = byteData!.buffer.asUint8List();

      final hasAccess = await Gal.hasAccess();
      if (!hasAccess) {
        await Gal.requestAccess();
      }

      await Gal.putImageBytes(pngBytes, name: 'qr_code');

      if (mounted) {
        showToast('Đã lưu mã QR vào thư viện ảnh!', ToastificationType.success);
      }
    } catch (e) {
      if (mounted) {
        showToast('Lưu mã QR thất bại: $e', ToastificationType.error);
      }
    } finally {
      if (mounted) {
        setState(() {
          isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final totalPrice = widget.matrix.price * widget.quantity;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: const Text("Thanh toán", style: TextStyle(color: Colors.white)),
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: Icon(Icons.arrow_back, color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Icon(
                  Icons.confirmation_number_outlined,
                  size: 18,
                  color: Colors.grey.shade700,
                ),
                const SizedBox(width: 8),
                Text(
                  "Thông tin đặt vé",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade800,
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: Colors.grey.shade300),
              ),
              color: Colors.white,
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Icon(Icons.circle, size: 16, color: Colors.blue),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            getPlaceName(widget.placeIds[0]),
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: Icon(Icons.arrow_downward),
                    ),
                    Row(
                      children: [
                        Icon(Icons.circle, size: 16, color: Colors.green),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            getPlaceName(widget.placeIds[1]),
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 10),
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: Colors.grey.shade300),
              ),
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    buildRow(
                      "Đơn giá",
                      "${moneyFormat.format(widget.matrix.price)},000đ",
                    ),
                    const SizedBox(height: 12),
                    buildRow("Số lượng", widget.quantity.toString()),
                    const Divider(height: 24),
                    buildRow(
                      "Tổng tiền",
                      "${moneyFormat.format(totalPrice)},000đ",
                      isTotal: true,
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 10),
            Row(
              children: [
                Icon(Icons.qr_code, size: 18, color: Colors.grey.shade700),
                const SizedBox(width: 8),
                Text(
                  "Mã QR thanh toán",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade800,
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),
            RepaintBoundary(
              key: _globalKey,
              child: Container(
                width: 220,
                height: 220,
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: QrImageView(data: qrData, version: QrVersions.auto),
              ),
            ),
            SizedBox(height: 10),
            InkWell(
              onTap: isSaving ? null : _downloadQrCode,
              child: Container(
                width: MediaQuery.of(context).size.width * 0.45,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.blue),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.download_rounded, color: Colors.blue),
                    SizedBox(width: 10),
                    Text(
                      isSaving ? "Đang lưu..." : "Lưu ảnh QR",
                      style: const TextStyle(
                        color: Colors.blue,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildRow(String title, String value, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: isTotal ? 18 : 15,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: isTotal ? Colors.red : Colors.black87,
            fontSize: isTotal ? 20 : 15,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
