import 'package:flutter/material.dart';

class CheckTicketScreen extends StatefulWidget {
  const CheckTicketScreen({super.key});

  @override
  State<CheckTicketScreen> createState() => _CheckTicketScreenState();
}

class TicketHistory {
  final String dateRange;
  final String route;
  final String station;
  final String timestamp;
  final String code;

  TicketHistory({
    required this.dateRange,
    required this.route,
    required this.station,
    required this.timestamp,
    required this.code,
  });
}

class _CheckTicketScreenState extends State<CheckTicketScreen> {
  final List<TicketHistory> history = [
    TicketHistory(
      dateRange: '16/03/2026 -> 31/05/2026',
      route: '06: Thái Nguyên - Định Hóa',
      station: 'Tòa án Tỉnh -> Định Hóa',
      timestamp: '16/03/2026 11:43:27',
      code: 'dmsks_echeck1',
    ),
    TicketHistory(
      dateRange: '02/02/2026 -> 28/02/2026',
      route: '06: Thái Nguyên - Định Hóa',
      station: 'Tòa án Tỉnh -> Định Hóa',
      timestamp: '02/02/2026 09:09:01',
      code: 'dmsks_echeck',
    ),
    TicketHistory(
      dateRange: '20/11/2025 -> 31/12/2025',
      route: '06: Thái Nguyên - Định Hóa',
      station: 'Tòa án Tỉnh -> Định Hóa',
      timestamp: '20/11/2025 08:44:30',
      code: 'dmsks_echeck',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2F80ED),
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Kiểm tra thẻ',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: Icon(Icons.add, color: Colors.white),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildCardInfoSection(),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              itemCount: history.length,
              separatorBuilder: (context, index) {
                return SizedBox(height: 10);
              },
              itemBuilder: (context, index) => _buildTicketCard(history[index]),
            ),
          ),
          _buildBottomActions(),
        ],
      ),
    );
  }

  Widget _buildCardInfoSection() {
    return Container(
      height: 210,
      padding: EdgeInsets.fromLTRB(16, 16, 16, 20),
      margin: EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.green.shade400,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Mã số thẻ',
                  style: TextStyle(color: Colors.white70, fontSize: 13),
                ),
                Row(
                  children: [
                    Text(
                      '0528ec88000104e0',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    SizedBox(width: 6),
                    Icon(Icons.edit, size: 14, color: Colors.white70),
                  ],
                ),
                SizedBox(height: 10),
                Text(
                  'Tên',
                  style: TextStyle(color: Colors.white70, fontSize: 13),
                ),
                Text(
                  'CHU HOÀNG TUẤN',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  'Điện thoại',
                  style: TextStyle(color: Colors.white70, fontSize: 13),
                ),
                Row(
                  children: [
                    Text(
                      '******5959',
                      style: TextStyle(color: Colors.white, fontSize: 14),
                    ),
                    SizedBox(width: 6),
                    Icon(Icons.phone, size: 14, color: Colors.white70),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  'Thẻ miễn phí chính sách',
                  style: TextStyle(
                    color: Colors.orangeAccent,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Stack(
              children: [
                Container(
                  width: double.infinity,
                  height: 150,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.wifi, size: 32, color: Colors.black87),
                      SizedBox(height: 4),
                      Text(
                        'NFC',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          letterSpacing: 1,
                        ),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  bottom: 5,
                  right: 5,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black26,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      onPressed: () {},
                      icon: Icon(
                        Icons.camera_alt,
                        size: 16,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTicketCard(TicketHistory item) {
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
                item.dateRange,
                style: TextStyle(fontSize: 13, color: Colors.black87),
              ),
              Spacer(),
              Icon(Icons.copy_outlined, size: 18, color: Colors.black45),
            ],
          ),
          SizedBox(height: 6),
          Row(
            children: [
              Expanded(
                child: Text(
                  item.route,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
              ),
              Icon(Icons.lock_open, size: 18, color: Colors.green),
            ],
          ),
          SizedBox(height: 2),
          Text(
            item.station,
            style: TextStyle(fontSize: 13, color: Colors.black54),
          ),
          SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                item.timestamp,
                style: TextStyle(fontSize: 12, color: Colors.black45),
              ),
              Text(
                item.code,
                style: TextStyle(fontSize: 12, color: Colors.black45),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ---- Bottom action buttons ----
  Widget _buildBottomActions() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      color: Colors.white,
      child: Row(
        children: [
          Expanded(child: _actionButton('Khóa thẻ', Icons.lock_outline)),
          SizedBox(width: 8),
          Expanded(child: _actionButton('Chỉnh sửa', Icons.edit_outlined)),
          SizedBox(width: 8),
          Expanded(child: _actionButton('Gia hạn thẻ', Icons.autorenew)),
        ],
      ),
    );
  }

  Widget _actionButton(String label, IconData icon) {
    return ElevatedButton.icon(
      onPressed: () {},
      icon: Icon(icon, size: 16, color: Colors.white),
      label: Text(
        label,
        style: TextStyle(fontSize: 12, color: Colors.white),
        overflow: TextOverflow.ellipsis,
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: Color(0xFF2F80ED),
        padding: EdgeInsets.symmetric(vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}
