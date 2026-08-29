import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_nfc_kit/flutter_nfc_kit.dart';
import 'package:skysoft_bus/service/bus_service.dart';
import 'package:skysoft_bus/utils/date_utils.dart';
import 'package:toastification/toastification.dart';

import '../../models/bus_line_model.dart';
import '../../utils/global.dart';
import '../widgets/loading_screen.dart';

class CardScreen extends StatefulWidget {
  const CardScreen({super.key});

  @override
  State<CardScreen> createState() => _CardScreenState();
}

class _CardScreenState extends State<CardScreen> {
  TextEditingController cardNoController = TextEditingController();
  bool isRequesting = false;
  BusCard? busCard;
  String cardNo = "";
  void initNFC() async {
    NFCAvailability availability = await FlutterNfcKit.nfcAvailability;
    if (availability == NFCAvailability.available) {
      FlutterNfcKit.tagStream.listen((tag) {
        if (tag.type == NFCTagType.iso15693) {
          getCard(tag.id);
        }
      });
    }
  }

  void getCard(String cardID) async {
    if (isRequesting) {
      return;
    }
    setState(() {
      isRequesting = true;
    });
    BusService service = BusService();
    final response = await service.getCard(cardID);
    setState(() {
      isRequesting = false;
    });
    if (response.errorMessage.isEmpty) {
      if (response.busCard.cardNo.isNotEmpty) {
        busCard = response.busCard;
      } else {
        showToast("Không tìm thấy thẻ này", ToastificationType.error);
        return;
      }
    } else {
      showToast(response.errorMessage, ToastificationType.error);
    }
  }

  @override
  void initState() {
    super.initState();
    initNFC();
  }

  @override
  Widget build(BuildContext context) {
    return LoadingOverlay(
      visible: isRequesting,
      child: Scaffold(
        backgroundColor: Color(0xFFF5F6FA),
        appBar: AppBar(
          elevation: 0,
          backgroundColor: secondaryColor,
          centerTitle: true,
          title: Text(
            "Thẻ của tôi",
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
        body: busCard == null
            ? Center(
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 24, horizontal: 24),
                  margin: EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: secondaryColor.withValues(alpha: 0.12),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.wifi,
                          color: secondaryColor,
                          size: 40,
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        "Vui lòng quẹt thẻ để kiểm tra \n hoặc \n Nhập mã thẻ ở dưới để xem",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.grey.shade400,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextField(
                        controller: cardNoController,
                        decoration: InputDecoration(
                          hintText: "Nhập mã thẻ",
                          filled: true,
                          fillColor: Colors.grey.shade50,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(
                              color: Colors.blue,
                              width: 1.5,
                            ),
                          ),
                          suffixIcon: IconButton(
                            onPressed: () {
                              getCard(cardNo);
                            },
                            icon: Icon(Icons.check, color: secondaryColor),
                          ),
                        ),
                        onChanged: (value) {
                          cardNo = value;
                        },
                      ),
                    ],
                  ),
                ),
              )
            : Column(
                children: [
                  buildCardInfoSection(),
                  Expanded(
                    child: ListView.separated(
                      padding: EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 10,
                      ),
                      itemCount: busCard!.rechargeItems.length,
                      separatorBuilder: (context, index) {
                        return SizedBox(height: 10);
                      },
                      itemBuilder: (context, index) =>
                          buildTicketCard(busCard!.rechargeItems[index]),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget buildCardInfoSection() {
    return Container(
      margin: EdgeInsets.all(14),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: secondaryColor,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 68,
                height: 68,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(Icons.person, size: 36, color: secondaryColor),
              ),
              SizedBox(width: 14),
              Expanded(
                child: Column(
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.credit_card,
                          size: 13,
                          color: Colors.white.withValues(alpha: 0.85),
                        ),
                        SizedBox(width: 5),
                        Expanded(
                          child: Text(
                            busCard!.cardNo,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(
                          Icons.call,
                          size: 13,
                          color: Colors.white.withValues(alpha: 0.85),
                        ),
                        SizedBox(width: 5),
                        Expanded(
                          child: Text(
                            busCard!.phoneNo,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.85),
                              fontSize: 13,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 15),
          Text(
            "TÊN NGƯỜI DÙNG",
            style: TextStyle(
              color: Colors.white70,
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),
          SizedBox(height: 4),
          Text(
            busCard!.fullName.toUpperCase(),
            style: TextStyle(
              color: Colors.white,
              fontSize: 17,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
            ),
          ),
          SizedBox(height: 15),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    Icon(Icons.verified, size: 14, color: Colors.white),
                    SizedBox(width: 6),
                    Text(
                      busCard!.priorityDescription,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.circle,
                      color: busCard!.locked
                          ? Colors.red.shade400
                          : Colors.greenAccent.shade400,
                      size: 12,
                    ),
                    SizedBox(width: 5),
                    Text(
                      busCard!.locked ? "Dừng" : "Hoạt động",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget buildTicketCard(RechargeItem item) {
    return Container(
      padding: EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.credit_card, size: 18, color: Colors.black54),
              SizedBox(width: 6),
              Text(
                " ${item.fromDate!.formatDate} - ${item.toDate!.formatDate}",
                style: TextStyle(fontSize: 13, color: Colors.black87),
              ),
              Spacer(),
              Icon(Icons.copy_outlined, size: 18, color: Colors.black45),
            ],
          ),
          SizedBox(height: 6),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: item.matrixes.length,
            itemBuilder: (context, index) {
              final matrix = item.matrixes[index];
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    matrix.lineName,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                  SizedBox(height: 10),
                  Text(
                    "${matrix.fromPlaceName} → ${matrix.toPlaceName}",
                    style: TextStyle(fontSize: 13, color: Colors.black54),
                  ),
                ],
              );
            },
            separatorBuilder: (context, index) =>
                Divider(thickness: 1, height: 1, color: Colors.grey),
          ),
          SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                item.createDate!.formatDateTime,
                style: TextStyle(fontSize: 12, color: Colors.black45),
              ),
              Text(
                item.creator,
                style: TextStyle(fontSize: 12, color: Colors.black45),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
