import 'package:flutter/material.dart';
import 'package:skysoft_bus/models/ticket_model.dart';
import 'package:skysoft_bus/screens/roots/detail_ticket_screen.dart';
import 'package:skysoft_bus/utils/date_utils.dart';
import 'package:toastification/toastification.dart';

import '../../service/bus_service.dart';
import '../../utils/global.dart';
import '../../utils/string_utils.dart';

class TicketListScreen extends StatefulWidget {
  const TicketListScreen({super.key});

  @override
  State<TicketListScreen> createState() => _TicketListScreenState();
}

class _TicketListScreenState extends State<TicketListScreen> {
  final TextEditingController searchController = TextEditingController();
  List<Ticket> filteredTickets = [];
  bool isLoading = true;

  int totalCount = 0;
  int inputCount = 0;
  int paidCount = 0;
  int usedCount = 0;

  void getListTicket() async {
    setState(() => isLoading = true);
    BusService service = BusService();
    final response = await service.listTickets();
    if (response.errorMessage.isEmpty) {
      filteredTickets = response.tickets;
      setState(() {
        filteredTickets.sort(
          (a, b) => (b.createDate!).compareTo(a.createDate!),
        );
        totalCount = filteredTickets.length;
        inputCount = filteredTickets
            .where((t) => t.state == Ticket.STATE_INPUT)
            .length;
        paidCount = filteredTickets
            .where((t) => t.state == Ticket.STATE_PAID)
            .length;
        usedCount = filteredTickets
            .where((t) => t.state == Ticket.STATE_USED)
            .length;
        isLoading = false;
      });
    } else {
      setState(() => isLoading = false);
      showToast(response.errorMessage, ToastificationType.error);
    }
  }

  void pushToDetailTicket(Ticket ticket) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => DetailTicketScreen(ticket: ticket),
      ),
    );
  }

  void onSearchChanged(String value) {
    final key = value.searchText;
    setState(() {
      filteredTickets = filteredTickets.where((t) {
        return t.fromPlaceName.searchText.contains(key) ||
            t.toPlaceName.searchText.contains(key) ||
            t.id.searchText.contains(key);
      }).toList();
    });
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

  @override
  void initState() {
    super.initState();
    getListTicket();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: secondaryColor,
        centerTitle: true,
        title: Text(
          "Danh sách vé",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [searchWidget(), summaryBar(), listTickets()],
        ),
      ),
    );
  }

  Widget searchWidget() {
    return Padding(
      padding: EdgeInsets.all(12),
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(25),
          border: Border.all(color: Colors.grey.shade300),
          boxShadow: const [BoxShadow(blurRadius: 10, color: Colors.black12)],
        ),
        child: TextFormField(
          controller: searchController,
          decoration: const InputDecoration(
            hintText: "Tìm kiếm điểm đi, điểm đến...",
            prefixIcon: Icon(Icons.search),
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(vertical: 12),
          ),
          onChanged: onSearchChanged,
        ),
      ),
    );
  }

  Widget summaryBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Row(
        children: [
          Expanded(
            child: summaryItem(
              label: "Tổng vé",
              value: totalCount,
              color: secondaryColor,
              icon: Icons.confirmation_number_rounded,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: summaryItem(
              label: "Chưa TT",
              value: inputCount,
              color: const Color(0xFFE65100),
              icon: Icons.hourglass_bottom_rounded,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: summaryItem(
              label: "Đã TT",
              value: paidCount,
              color: const Color(0xFF2E7D32),
              icon: Icons.check_circle_rounded,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: summaryItem(
              label: "Đã dùng",
              value: usedCount,
              color: Colors.grey.shade600,
              icon: Icons.task_alt_rounded,
            ),
          ),
        ],
      ),
    );
  }

  Widget listTickets() {
    return Expanded(
      child: isLoading
          ? Center(child: CircularProgressIndicator())
          : filteredTickets.isEmpty
          ? Center(
              child: Text(
                "Không tìm thấy vé nào",
                style: TextStyle(color: Colors.grey.shade500),
              ),
            )
          : RefreshIndicator(
              color: secondaryColor,
              backgroundColor: Colors.white,
              onRefresh: () async => getListTicket(),
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 4,
                ),
                itemCount: filteredTickets.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final ticket = filteredTickets[index];
                  return ticketCard(ticket, index);
                },
              ),
            ),
    );
  }

  Widget ticketCard(Ticket ticket, int index) {
    final color = stateColor(ticket.state);
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () {
        pushToDetailTicket(ticket);
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade400,
              blurRadius: 10,
              blurStyle: BlurStyle.outer,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(9),
                    decoration: BoxDecoration(
                      color: secondaryColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.directions_bus,
                      size: 20,
                      color: secondaryColor,
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      "Vé #${index + 1}",
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1C1C1E),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      stateLabel(ticket.state),
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: color,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12),
              Divider(height: 1, thickness: 1, color: Colors.grey.shade300),
              SizedBox(height: 12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Text(
                      ticket.fromPlaceName,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    child: Icon(
                      Icons.arrow_forward_rounded,
                      size: 18,
                      color: Colors.grey,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      ticket.toPlaceName,
                      textAlign: TextAlign.end,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12),
              Row(
                children: [
                  Icon(
                    Icons.access_time_rounded,
                    size: 15,
                    color: Colors.grey.shade500,
                  ),
                  SizedBox(width: 6),
                  Text(
                    ticket.createDate != null
                        ? ticket.createDate!.formatDateTime
                        : "--",
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                  ),
                ],
              ),
              SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.people_alt_rounded,
                        size: 15,
                        color: Colors.grey.shade500,
                      ),
                      SizedBox(width: 6),
                      Text(
                        "${ticket.quantity} vé",
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    "${moneyFormat.format(ticket.price * ticket.quantity * 1000)} đ",
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1C1C1E),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget summaryItem({
    required String label,
    required int value,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade100,
            blurRadius: 8,
            blurStyle: BlurStyle.outer,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(height: 6),
          Text(
            "$value",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(fontSize: 12, color: Colors.black),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
