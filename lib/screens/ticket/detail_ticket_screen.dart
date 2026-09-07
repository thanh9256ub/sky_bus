import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:screenshot/screenshot.dart';
import 'package:skysoft_bus/models/ticket_model.dart';
import 'package:skysoft_bus/service/bus_service.dart';
import 'package:skysoft_bus/utils/date_utils.dart';
import 'package:toastification/toastification.dart';

import '../../utils/global.dart';
import '../home/ticket_payment_screen.dart';
import '../widgets/ticket_divider.dart';

class DetailTicketScreen extends StatefulWidget {
  final Ticket ticket;
  final Function() onChange;
  const DetailTicketScreen({
    super.key,
    required this.ticket,
    required this.onChange,
  });

  @override
  State<DetailTicketScreen> createState() => _DetailTicketScreenState();
}

class _DetailTicketScreenState extends State<DetailTicketScreen> {
  List<SlotTicket> slots = [];
  int usedTicketCount = 0;
  ScreenshotController screenshotController = ScreenshotController();
  Ticket? ticket;
  Timer? ticketTimer;

  void getNewStateTicket() async {
    BusService service = BusService();
    final response = await service.listTickets();
    if (response.errorMessage.isEmpty && mounted) {
      final newTicket = response.tickets.firstWhere(
        (e) => e.id == widget.ticket.id,
      );
      setState(() {
        ticket = newTicket;
        slots = newTicket.slots;
        usedTicketCount = newTicket.slots
            .where((e) => e.usedDate != null)
            .length;
      });
    } else {
      showToast(response.errorMessage, ToastificationType.error);
    }
  }

  String stateLabel(int state) {
    if (state == Ticket.STATE_PAID) {
      return "Đã thanh toán";
    } else if (state == Ticket.STATE_USED) {
      return "Đã sử dụng";
    } else {
      return "Chưa thanh toán";
    }
  }

  Color stateColor(int state) {
    if (state == Ticket.STATE_PAID) {
      return Color(0xFF2E7D32);
    } else if (state == Ticket.STATE_USED) {
      return Colors.grey.shade500;
    } else {
      return secondaryColor;
    }
  }

  IconData get stateIcon {
    switch (ticket!.state) {
      case Ticket.STATE_PAID:
        return Icons.check_circle_rounded;
      case Ticket.STATE_USED:
        return Icons.task_alt_rounded;
      case Ticket.STATE_INPUT:
      default:
        return Icons.hourglass_bottom_rounded;
    }
  }

  void pushToPayment(Ticket ticket) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => TicketPaymentScreen(ticket: ticket),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    ticket = widget.ticket;
    slots = widget.ticket.slots;
    usedTicketCount = widget.ticket.slots
        .where((e) => e.usedDate != null)
        .length;
    ticketTimer = Timer.periodic(Duration(seconds: 10), (timer) {
      getNewStateTicket();
    });
  }

  @override
  void dispose() {
    super.dispose();
    ticketTimer?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return Screenshot(
      controller: screenshotController,
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F6FA),
        appBar: AppBar(
          elevation: 0,
          backgroundColor: secondaryColor,
          centerTitle: true,
          title: Text(
            "Chi tiết vé",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
          ),
          leading: IconButton(
            onPressed: () {
              widget.onChange();
              Navigator.of(context).pop();
            },
            icon: Icon(
              Platform.isIOS ? Icons.arrow_back_ios_new : Icons.arrow_back,
              color: Colors.white,
            ),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ticketCard(ticket!),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.qr_code_rounded,
                        size: 18,
                        color: Colors.grey.shade700,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        "Danh sách vé (${slots.length})",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade800,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    "Đã dùng $usedTicketCount/${slots.length}",
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                  ),
                ],
              ),
              SizedBox(height: 12),
              qrListView(),
              paymentQR(),
            ],
          ),
        ),
      ),
    );
  }

  Widget ticketCard(Ticket ticket) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: secondaryColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        Icons.directions_bus_rounded,
                        size: 18,
                        color: secondaryColor,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      ticket.fromPlaceName,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        color: Color(0xFF1C1C1E),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 5),
                Icon(Icons.arrow_downward, color: secondaryColor),
                SizedBox(height: 5),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: secondaryColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        Icons.directions_bus_rounded,
                        size: 18,
                        color: secondaryColor,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      ticket.toPlaceName,
                      maxLines: 2,
                      textAlign: TextAlign.end,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        color: Color(0xFF1C1C1E),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          TicketDivider(),
          Padding(
            padding: EdgeInsetsGeometry.all(12),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.access_time_rounded,
                          color: Colors.grey,
                          size: 16,
                        ),
                        SizedBox(width: 5),
                        Text(
                          ticket.createDate != null
                              ? ticket.createDate!.formatDateTime
                              : "--",
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: stateColor(ticket.state).withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            stateIcon,
                            size: 13,
                            color: stateColor(ticket.state),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            stateLabel(ticket.state),
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: stateColor(ticket.state),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.people,
                          size: 18,
                          color: Colors.grey.shade500,
                        ),
                        SizedBox(width: 8),
                        Text(
                          "${ticket.quantity.toString()} vé",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      "${moneyFormat.format(ticket.price * ticket.quantity * 1000)}đ",
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1C1C1E),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget qrListView() {
    final isUnpaid = widget.ticket.state == Ticket.STATE_INPUT;

    return Stack(
      alignment: Alignment.center,
      children: [
        Opacity(
          opacity: isUnpaid ? 0.2 : 1,
          child: IgnorePointer(
            ignoring: isUnpaid,
            child: SizedBox(
              height: MediaQuery.of(context).size.height * 0.25,
              child: ListView.separated(
                shrinkWrap: true,
                scrollDirection: Axis.horizontal,
                itemCount: slots.length,
                separatorBuilder: (context, index) => const SizedBox(width: 10),
                itemBuilder: (context, index) {
                  return qrItemTile(slots[index], index);
                },
              ),
            ),
          ),
        ),

        if (isUnpaid)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.lock_outline),
                SizedBox(width: 8),
                Text(
                  "Thanh toán để sử dụng vé",
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
      ],
    );
    // return SizedBox(
    //   height: MediaQuery.of(context).size.height * 0.25,
    //   child: ListView.separated(
    //     shrinkWrap: true,
    //     scrollDirection: Axis.horizontal,
    //     itemCount: slots.length,
    //     separatorBuilder: (context, index) => const SizedBox(width: 10),
    //     itemBuilder: (context, index) {
    //       return qrItemTile(slots[index], index);
    //     },
    //   ),
    // );
  }

  Widget qrItemTile(SlotTicket item, int index) {
    final color = item.usedDate != null
        ? Colors.red.shade400
        : const Color(0xFF2E7D32);
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: item.usedDate != null ? Colors.red.shade300 : secondaryColor,
        ),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "QR vé: ${index + 1}",
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 5),
            Row(
              children: [
                Container(
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade200),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Stack(
                    children: [
                      Opacity(
                        opacity: item.usedDate == null ? 1 : 0.2,
                        child: QrImageView(
                          data: item.token,
                          version: QrVersions.auto,
                        ),
                      ),
                      Visibility(
                        visible: item.usedDate != null,
                        child: Container(
                          padding: EdgeInsets.all(10),
                          width: 150,
                          height: 150,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: Colors.grey.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            "Mã đã sử dụng",
                            textAlign: TextAlign.center,
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            item.usedDate != null
                                ? Icons.check_circle_rounded
                                : Icons.radio_button_unchecked_rounded,
                            size: 13,
                            color: color,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            item.usedDate != null ? "Đã dùng" : "Chưa dùng",
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: color,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 10),
                        Text(
                          "Thời gian dùng vé:",
                          style: TextStyle(color: Colors.grey, fontSize: 13),
                        ),
                        SizedBox(height: 5),
                        Text(
                          item.usedDate != null
                              ? item.usedDate!.formatDateTime
                              : "Chưa sử dụng",
                          style: TextStyle(color: Colors.grey, fontSize: 13),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget paymentQR() {
    final isUnpaid = ticket!.state == Ticket.STATE_INPUT;
    if (isUnpaid) {
      return Container(
        width: MediaQuery.of(context).size.width,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text("Vui lòng thanh toán mã để xem danh sách vé"),
            SizedBox(height: 5),
            Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade200),
                borderRadius: BorderRadius.circular(8),
              ),
              child: QrImageView(
                data: ticket!.qrCode,
                version: QrVersions.auto,
              ),
            ),
            SizedBox(height: 5),
            InkWell(
              onTap: () {
                downloadQrCode(screenshotController);
              },
              child: Container(
                width: MediaQuery.of(context).size.width * 0.4,
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
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
      );
    } else {
      return SizedBox();
    }
  }
}
