import 'package:flutter/material.dart';
import 'package:skysoft_bus/utils/global.dart';
import '../../utils/date_utils.dart';

class ExtendCardDialog extends StatefulWidget {
  const ExtendCardDialog({super.key});

  @override
  State<ExtendCardDialog> createState() => _ExtendCardDialogState();
}

class _ExtendCardDialogState extends State<ExtendCardDialog> {
  DateTimeRange? selectedRange;

  TextEditingController fromDateController = TextEditingController();
  TextEditingController toDateController = TextEditingController();
  static const int pricePerDay = 5000;

  int get totalDays {
    if (selectedRange == null) return 0;
    return selectedRange!.end.difference(selectedRange!.start).inDays + 1;
  }

  int get totalPrice => totalDays * pricePerDay;

  void _showDateRangePicker() async {
    DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2010),
      lastDate: DateTime(2100),
      currentDate: DateTime.now(),
      saveText: "Xác nhận",
    );
    if (picked != null) {
      setState(() {
        selectedRange = picked;
        fromDateController.text = FormatDate(selectedRange!.start).formatDate;
        toDateController.text = FormatDate(selectedRange!.end).formatDate;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Gia hạn thẻ",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            SizedBox(
              height: 40,
              width: double.infinity,
              child: TextField(
                controller: fromDateController,
                readOnly: true,
                textAlign: TextAlign.center,
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.calendar_today),
                  labelText: "Từ ngày",
                  filled: true,
                  fillColor: Colors.grey.shade50,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(color: Colors.grey.shade200),
                  ),
                ),
                onTap: _showDateRangePicker,
              ),
            ),
            SizedBox(height: 20),
            SizedBox(
              height: 40,
              width: double.infinity,
              child: TextField(
                controller: toDateController,
                readOnly: true,
                textAlign: TextAlign.center,
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.calendar_month),
                  labelText: "Đến ngày",
                  filled: true,
                  fillColor: Colors.grey.shade50,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(color: Colors.grey.shade200),
                  ),
                ),
                onTap: _showDateRangePicker,
              ),
            ),
            if (selectedRange != null)
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(16),
                margin: EdgeInsets.only(top: 10),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.blue.shade100),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Số ngày gia hạn"),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.blue,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            "$totalDays ngày",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
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
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          "${moneyFormat.format(totalPrice)} đ",
                          style: TextStyle(
                            fontSize: 24,
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      minimumSize: Size(0, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: Text("Hủy"),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: ElevatedButton.icon(
                    onPressed: selectedRange == null ? null : () {},
                    icon: Icon(Icons.payment),
                    label: Text("Thanh toán"),
                    style: ElevatedButton.styleFrom(
                      minimumSize: Size(0, 50),
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
    );
  }
}
