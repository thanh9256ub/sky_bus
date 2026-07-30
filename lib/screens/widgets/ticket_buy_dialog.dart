import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:skysoft_bus/models/bus_line_model.dart';

import '../../utils/global.dart';
import '../roots/payment_screen.dart';

class TicketBuyDialog extends StatefulWidget {
  final BusLine selectedLine;
  final List<int> palaceIds;
  final Matrix matrix;
  const TicketBuyDialog({
    super.key,
    required this.palaceIds,
    required this.selectedLine,
    required this.matrix,
  });

  @override
  State<TicketBuyDialog> createState() => _TicketBuyDialogState();
}

class _TicketBuyDialogState extends State<TicketBuyDialog> {
  int quantity = 1;
  final qtyController = TextEditingController();
  String getPlaceName(int placeId) {
    return widget.selectedLine.placeMarks
        .firstWhere((e) => e.placeID == placeId)
        .description;
  }

  @override
  void initState() {
    super.initState();
    qtyController.text = quantity.toString();
  }

  @override
  void dispose() {
    super.dispose();
    qtyController.dispose();
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
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: Colors.grey.shade200)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Center(
                  child: Text(
                    "Thông tin đặt vé",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                SizedBox(height: 10),
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
                          Icon(Icons.circle, color: Colors.blue, size: 20),
                          SizedBox(width: 8),
                          Text(
                            getPlaceName(widget.palaceIds[0]),
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
                          Icon(Icons.circle, color: Colors.green, size: 20),
                          SizedBox(width: 8),
                          Text(
                            getPlaceName(widget.palaceIds[1]),
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  "Đơn giá: ${moneyFormat.format(widget.matrix.price)},000đ/vé",
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                SizedBox(height: 5),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Số lượng vé muốn đặt"),
                    SizedBox(width: 5),
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
                        "${moneyFormat.format(widget.matrix.price * quantity == 0 ? widget.matrix.price : widget.matrix.price * quantity)},000đ",
                        style: TextStyle(
                          color: Colors.red,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(
                              builder: (context) => PaymentScreen(
                                matrix: widget.matrix,
                                placeIds: widget.palaceIds,
                                quantity: quantity,
                                selectedLine: widget.selectedLine,
                              ),
                            ),
                          );
                        },
                        label: Text(
                          "Xác nhận",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
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
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
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
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget updateQty() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          InkWell(
            onTap: quantity > 1
                ? () {
                    setState(() {
                      quantity--;
                      qtyController.text = quantity.toString();
                    });
                  }
                : null,
            child: Padding(
              padding: EdgeInsets.all(6),
              child: Icon(Icons.remove, size: 16),
            ),
          ),
          Container(
            width: 70,
            height: 40,
            alignment: Alignment.center,
            child: TextField(
              controller: qtyController,
              textAlign: TextAlign.center,
              readOnly: true,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: InputDecoration(
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 15),
              ),
              onChanged: (value) {
                setState(() {
                  quantity = int.tryParse(value) ?? 0;
                  qtyController.text = quantity.toString();
                });
              },
            ),
          ),
          InkWell(
            onTap: () {
              setState(() {
                quantity++;
                qtyController.text = quantity.toString();
              });
            },
            child: Padding(
              padding: EdgeInsets.all(6),
              child: Icon(Icons.add, size: 16),
            ),
          ),
        ],
      ),
    );
  }
}
