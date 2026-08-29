import 'package:flutter/material.dart';
import 'package:skysoft_bus/models/ticket_model.dart';
import 'package:skysoft_bus/screens/ticket/detail_ticket_screen.dart';
import 'package:skysoft_bus/utils/date_utils.dart';
import 'package:toastification/toastification.dart';

import '../../service/bus_service.dart';
import '../../utils/global.dart';

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
      if (mounted) {
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
      }
    } else {
      setState(() => isLoading = false);
      showToast(response.errorMessage, ToastificationType.error);
    }
  }

  void pushToDetailTicket(Ticket ticket) async {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) =>
            DetailTicketScreen(ticket: ticket, onChange: getListTicket),
      ),
    );
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
      return Colors.red.shade400;
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
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [summaryBar(), SizedBox(height: 10), listTickets()],
        ),
      ),
    );
  }

  Widget summaryBar() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: secondaryColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(25),
            ),
            child: Icon(
              Icons.confirmation_number_rounded,
              size: 18,
              color: secondaryColor,
            ),
          ),
          const SizedBox(width: 5),
          Text(
            "Tổng vé",
            style: TextStyle(
              fontSize: 16,
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Spacer(),
          Text(
            "$totalCount vé",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: secondaryColor,
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
    final usedTicketCount = ticket.slots
        .where((e) => e.usedDate != null)
        .length;
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () {
        pushToDetailTicket(ticket);
      },
      child: Container(
        decoration: BoxDecoration(
          color: usedTicketCount == ticket.slots.length
              ? Colors.grey.shade200
              : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade300),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade300,
              blurRadius: 10,
              blurStyle: BlurStyle.outer,
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
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          ticket.fromPlaceName,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8),
                          child: Icon(
                            Icons.arrow_forward_rounded,
                            size: 18,
                            color: Colors.grey,
                          ),
                        ),
                        Text(
                          ticket.toPlaceName,
                          textAlign: TextAlign.end,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12),
              Divider(height: 1, thickness: 1, color: Colors.grey.shade300),
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
                        ? ticket.createDate!.formatDate
                        : "--",
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                  Spacer(),
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
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      SizedBox(width: 20),
                      Text(
                        "Đã dùng $usedTicketCount/${ticket.quantity}",
                        style: TextStyle(
                          fontSize: 12,
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
}
