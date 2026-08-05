import 'package:flutter/material.dart';
import 'package:skysoft_bus/utils/global.dart';

class AddCardScreen extends StatefulWidget {
  const AddCardScreen({super.key});

  @override
  State<AddCardScreen> createState() => _AddCardScreenState();
}

class _AddCardScreenState extends State<AddCardScreen> {
  final TextEditingController cardController = TextEditingController();

  bool scanning = false;

  Future<void> scanNfcCard() async {
    setState(() {
      scanning = true;
    });

    try {
      await Future.delayed(const Duration(seconds: 2));

      cardController.text = "0528ec88000104e0";
    } finally {
      setState(() {
        scanning = false;
      });
    }
  }

  void addCard() {
    if (cardController.text.trim().isEmpty) return;

    Navigator.pop(context, cardController.text.trim());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffF4F7FC),
      appBar: AppBar(
        backgroundColor: secondaryColor,
        title: Text(
          "Thêm thẻ mới",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: Icon(Icons.arrow_back, color: Colors.white),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: SizedBox(
            height: 52,
            child: ElevatedButton(
              style: ButtonStyle(
                backgroundColor: WidgetStatePropertyAll(secondaryColor),
              ),
              onPressed: addCard,
              child: Text(
                "THÊM THẺ",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: secondaryColor,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 45,
                    backgroundColor: Colors.white,
                    child: scanning
                        ? CircularProgressIndicator()
                        : Icon(
                            Icons.contactless,
                            size: 50,
                            color: secondaryColor,
                          ),
                  ),
                  SizedBox(height: 20),

                  Text(
                    "Quét thẻ NFC",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 20),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: scanning ? null : scanNfcCard,
                      icon: Icon(Icons.nfc),
                      label: Text(
                        scanning ? "Đang quét..." : "Bắt đầu quét NFC",
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: secondaryColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 24),

            Row(
              children: [
                Expanded(child: Divider()),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  child: Text(
                    "HOẶC NHẬP THỦ CÔNG",
                    style: TextStyle(
                      color: Colors.grey,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Expanded(child: Divider()),
              ],
            ),

            SizedBox(height: 24),
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: TextField(
                controller: cardController,
                decoration: InputDecoration(
                  labelText: "Mã thẻ",
                  hintText: "Ví dụ: 0528ec88000104e0",
                  prefixIcon: const Icon(Icons.credit_card),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onTapOutside: (event) {
                  FocusManager.instance.primaryFocus?.unfocus();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
