import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:gal/gal.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:skysoft_bus/utils/string_utils.dart';
import 'package:toastification/toastification.dart';

import '../../models/bus_line_model.dart';
import '../../utils/global.dart';

class PaymentScreen extends StatefulWidget {
  final Place fromPlace;
  final Place toPlace;
  final Matrix matrix;
  final int quantity;
  const PaymentScreen({
    super.key,
    required this.fromPlace,
    required this.toPlace,
    required this.matrix,
    required this.quantity,
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final GlobalKey _globalKey = GlobalKey();
  String qrData = "https://flutter.dev";

  Future<void> downloadQrCode() async {
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
    }
  }

  @override
  Widget build(BuildContext context) {
    final totalPrice = widget.matrix.price * widget.quantity;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: Text("Thanh toán", style: TextStyle(color: Colors.white)),
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
                SizedBox(width: 10),
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
                            widget.fromPlace.description,
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
                            widget.toPlace.description,
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
                padding: EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Đơn giá",
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                        Text(
                          "${(widget.matrix.price).formatThousand()},000đ",
                          style: TextStyle(
                            color: Colors.black87,
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Số lượng",
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                        Text(
                          widget.quantity.toString(),
                          style: TextStyle(
                            color: Colors.black87,
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    Divider(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Tổng tiền",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          "${(totalPrice).formatThousand()},000đ",
                          style: TextStyle(
                            color: Colors.red,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 10),
            Row(
              children: [
                Icon(Icons.qr_code, size: 18, color: Colors.grey.shade700),
                SizedBox(width: 10),
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
                padding: EdgeInsets.all(5),
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
              onTap: downloadQrCode,
              child: Container(
                width: MediaQuery.of(context).size.width * 0.45,
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
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
                      "Lưu ảnh QR",
                      style: TextStyle(
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
}
