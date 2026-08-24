import 'package:flutter/material.dart';
import 'package:skysoft_bus/service/bus_service.dart';
import 'package:skysoft_bus/utils/global.dart';
import 'package:toastification/toastification.dart';

import '../../models/bus_line_model.dart';
import '../../utils/string_utils.dart';

class BusLineListScreen extends StatefulWidget {
  final List<BusLine> busLines;
  final BusLine? selectedBusLine;
  final Function(BusLine value) onChanged;

  const BusLineListScreen({
    super.key,
    required this.busLines,
    required this.onChanged,
    this.selectedBusLine,
  });

  @override
  State<BusLineListScreen> createState() => _BusLineListScreenState();
}

class _BusLineListScreenState extends State<BusLineListScreen> {
  TextEditingController searchController = TextEditingController();
  List<BusLine> filteredBusLines = [];

  void updateStarMark(BusLine line, bool starMark) async {
    BusService service = BusService();
    final response = await service.updateStarMark(line.lineID, starMark);
    if (response.errorMessage.isEmpty) {
      setState(() {
        line.starMark = starMark;
        filteredBusLines.sort((a, b) {
          if (a.starMark != b.starMark) {
            return a.starMark ? -1 : 1;
          }
          return a.description.compareTo(b.description);
        });
      });
    } else {
      showToast(response.errorMessage, ToastificationType.error);
    }
  }

  @override
  void initState() {
    super.initState();
    filteredBusLines = List.from(widget.busLines);
    filteredBusLines.sort((a, b) {
      if (a.starMark != b.starMark) {
        return a.starMark ? -1 : 1;
      }
      return a.description.compareTo(b.description);
    });
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
        backgroundColor: const Color(0xFFF5F6FA),
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Color(0xFF1C1C1E)),
        title: const Text(
          'Chọn tuyến xe',
          style: TextStyle(
            color: Color(0xFF1C1C1E),
            fontWeight: FontWeight.w600,
            fontSize: 17,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: Container(
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(color: Colors.grey.shade300),
                  boxShadow: [BoxShadow(blurRadius: 10, color: Colors.black12)],
                ),
                child: TextFormField(
                  controller: searchController,
                  decoration: InputDecoration(
                    hintText: "Tìm kiếm tuyến xe...",
                    prefixIcon: Icon(Icons.search),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 12),
                  ),
                  onChanged: (value) {
                    setState(() {
                      filteredBusLines = widget.busLines
                          .where(
                            (e) => e.description.searchText.contains(
                              value.searchText,
                            ),
                          )
                          .toList();
                    });
                  },
                ),
              ),
            ),
            Expanded(
              child: filteredBusLines.isEmpty
                  ? Center(
                      child: Text(
                        "Không tìm thấy tuyến xe nào",
                        style: TextStyle(color: Colors.grey.shade500),
                      ),
                    )
                  : listBusLine(),
            ),
          ],
        ),
      ),
    );
  }

  Widget listBusLine() {
    return ListView.separated(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      itemCount: filteredBusLines.length,
      separatorBuilder: (context, index) => SizedBox(height: 12),
      itemBuilder: (context, index) {
        final busLine = filteredBusLines[index];
        final lineColor = Color(busLine.color.toUnsigned(32));
        final starMark = busLine.starMark;
        return InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            widget.onChanged(busLine);
            Navigator.of(context).pop();
          },
          child: Container(
            decoration: BoxDecoration(
              color: starMark
                  ? secondaryColor.withValues(alpha: 0.05)
                  : Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.shade100,
                  blurRadius: 10,
                  blurStyle: BlurStyle.outer,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(9),
                    decoration: BoxDecoration(
                      color: lineColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.directions_bus_rounded,
                      size: 20,
                      color: lineColor,
                    ),
                  ),
                  SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      busLine.description,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1C1C1E),
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  SizedBox(width: 5),
                  Visibility(
                    visible: loginResponse.fullName.isNotEmpty,
                    child: InkWell(
                      hoverColor: Colors.transparent,
                      onTap: () {
                        updateStarMark(busLine, !starMark);
                      },
                      child: Icon(
                        starMark ? Icons.star : Icons.star_border,
                        color: primaryColor,
                        size: 34,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
