import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:skysoft_bus/models/bus_line_model.dart';
import 'package:skysoft_bus/models/ticket_model.dart';
import 'package:skysoft_bus/screens/roots/login_screen.dart';
import 'package:skysoft_bus/service/bus_service.dart';
import 'package:toastification/toastification.dart';

import '../../utils/global.dart';
import '../../utils/string_utils.dart';
import '../home/ticket_payment_screen.dart';

class TicketBuyDialog extends StatefulWidget {
  final Place fromPlace;
  final Place toPlace;
  final Matrix matrix;
  final BusLine selectedLine;
  const TicketBuyDialog({
    super.key,
    required this.fromPlace,
    required this.toPlace,
    required this.matrix,
    required this.selectedLine,
  });

  @override
  State<TicketBuyDialog> createState() => _TicketBuyDialogState();
}

class _TicketBuyDialogState extends State<TicketBuyDialog> {
  int quantity = 1;
  final qtyController = TextEditingController();
  TicketAddRequest ticketLine = TicketAddRequest();

  void addNewTicket() async {
    if (loginResponse.fullName.isNotEmpty) {
      BusService service = BusService();
      ticketLine.lineID = widget.selectedLine.lineID;
      ticketLine.fromPlaceID = widget.fromPlace.placeID;
      ticketLine.toPlaceID = widget.toPlace.placeID;
      ticketLine.quantity = quantity;
      ticketLine.price = widget.matrix.price;
      final response = await service.addNewTicket(ticketLine);
      if (response.errorMessage.isEmpty) {
        if (mounted) {
          Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
            MaterialPageRoute(
              builder: (context) =>
                  TicketPaymentScreen(ticket: response.ticket),
            ),
            (route) => route.isFirst,
          );
        }
      } else {
        showToast(response.errorMessage, ToastificationType.error);
      }
    } else {
      showToast("Vui lòng đăng nhập để đặt vé", ToastificationType.error);
    }
  }

  void pushToLogin() {
    Navigator.of(
      context,
    ).pushReplacement(MaterialPageRoute(builder: (context) => LoginScreen()));
  }

  @override
  void initState() {
    super.initState();
    qtyController.text = quantity.toString();
  }

  @override
  void dispose() {
    qtyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      backgroundColor: Colors.transparent,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 660),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Container(
            decoration: BoxDecoration(color: Colors.white),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _header(),
                SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.all(15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.circle,
                                  color: Colors.blue,
                                  size: 20,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  widget.fromPlace.description,
                                  style: TextStyle(fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(vertical: 8),
                              child: Icon(Icons.arrow_downward),
                            ),
                            Row(
                              children: [
                                Icon(
                                  Icons.circle,
                                  color: Colors.green,
                                  size: 20,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  widget.toPlace.description,
                                  style: TextStyle(fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 10),
                      Row(
                        children: [
                          Icon(
                            Icons.sell_rounded,
                            size: 16,
                            color: Colors.red.shade400,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            "Đơn giá: ${moneyFormat.format(widget.matrix.price * 1000)}đ/vé",
                            style: TextStyle(
                              color: Colors.red.shade600,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 5),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Số lượng vé muốn đặt",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                          updateQty(),
                        ],
                      ),
                      SizedBox(height: 10),
                      Divider(thickness: 1, color: Colors.grey),
                      SizedBox(height: 10),
                      Container(
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
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
                              "${((widget.matrix.price * quantity * 1000)).formatThousand()}đ",
                              style: TextStyle(
                                color: Colors.red,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 10),
                      Visibility(
                        visible: loginResponse.fullName.isEmpty,
                        child: InkWell(
                          onTap: pushToLogin,
                          borderRadius: BorderRadius.circular(10),
                          child: Container(
                            width: double.infinity,
                            padding: EdgeInsets.symmetric(
                              vertical: 10,
                              horizontal: 12,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.orange.shade50,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: Colors.orange.shade200),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.info_outline,
                                  size: 18,
                                  color: Colors.orange.shade600,
                                ),
                                SizedBox(width: 8),
                                Expanded(
                                  child: RichText(
                                    text: TextSpan(
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: Colors.orange.shade600,
                                      ),
                                      children: [
                                        TextSpan(
                                          text: "Bạn chưa đăng ký tài khoản. ",
                                        ),
                                        TextSpan(
                                          text: "Vui lòng đăng ký để đặt vé",
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            decoration:
                                                TextDecoration.underline,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                Icon(
                                  Icons.chevron_right,
                                  size: 18,
                                  color: Colors.orange.shade600,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 20),
                      confirmBtn(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _header() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
      decoration: BoxDecoration(color: secondaryColor),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              Icons.confirmation_number_rounded,
              color: Colors.white,
              size: 22,
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              "Thông tin đặt vé",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget confirmBtn() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: addNewTicket,
            label: Text(
              "Xác nhận",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
        ),
        SizedBox(width: 10),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () {
              Navigator.of(context).pop();
            },
            label: Text(
              "Hủy",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey,
              foregroundColor: Colors.white,
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget updateQty() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF7F9FC),
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _qtyButton(
            icon: Icons.remove_rounded,
            enabled: quantity > 1,
            onTap: () {
              setState(() {
                quantity--;
                qtyController.text = quantity.toString();
              });
            },
          ),
          Container(
            width: 44,
            height: 40,
            alignment: Alignment.center,
            child: TextField(
              controller: qtyController,
              textAlign: TextAlign.center,
              readOnly: true,
              keyboardType: TextInputType.number,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: const InputDecoration(
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 15),
              ),
            ),
          ),
          _qtyButton(
            icon: Icons.add_rounded,
            enabled: true,
            onTap: () {
              setState(() {
                quantity++;
                qtyController.text = quantity.toString();
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _qtyButton({
    required IconData icon,
    required bool enabled,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: enabled ? onTap : null,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: enabled
              ? secondaryColor.withValues(alpha: 0.1)
              : Colors.transparent,
          shape: BoxShape.circle,
        ),
        margin: const EdgeInsets.all(3),
        child: Icon(
          icon,
          size: 16,
          color: enabled ? secondaryColor : Colors.grey.shade400,
        ),
      ),
    );
  }
}
