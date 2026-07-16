import 'package:flutter/material.dart';
import 'package:skysoft_bus/models/bus_line_model.dart';
import 'package:skysoft_bus/utils/global.dart';
import 'package:toastification/toastification.dart';

class DetailBusLineScreen extends StatefulWidget {
  final BusLine line;
  final Function() onClosed;
  const DetailBusLineScreen({
    super.key,
    required this.line,
    required this.onClosed,
  });

  @override
  State<DetailBusLineScreen> createState() => _DetailBusLineScreenState();
}

class _DetailBusLineScreenState extends State<DetailBusLineScreen> {
  final List<int> selectedPlaceIds = [];

  String getPlaceName(int placeId) {
    return widget.line.placeMarks
        .firstWhere((e) => e.placeID == placeId)
        .description;
  }

  void togglePlace(int placeId) {
    setState(() {
      if (selectedPlaceIds.contains(placeId)) {
        selectedPlaceIds.remove(placeId);
      } else if (selectedPlaceIds.length < 2) {
        selectedPlaceIds.add(placeId);
      } else {
        showToast(
          "Chỉ được chọn 2 điểm: điểm đi và điểm đến",
          ToastificationType.error,
        );
      }
    });
  }

  Matrix? getSelectedMatrixPrice() {
    if (selectedPlaceIds.length != 2) return null;
    final fromId = selectedPlaceIds[0];
    final toId = selectedPlaceIds[1];
    return widget.line.matrixPrices.firstWhere(
      (e) =>
          (e.fromPlaceID == fromId && e.toPlaceID == toId) ||
          (e.fromPlaceID == toId && e.toPlaceID == fromId),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.3,
      minChildSize: 0.1,
      maxChildSize: 0.9,
      snap: true,
      snapSizes: [0.1, 0.3, 0.9],
      builder: (context, scrollController) {
        final matrixPrice = getSelectedMatrixPrice();
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 15)],
          ),
          child: Column(
            children: [
              buildListLine(scrollController),
              if (selectedPlaceIds.length == 2)
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    border: Border(
                      top: BorderSide(color: Colors.grey.shade200),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "${getPlaceName(selectedPlaceIds[0])} → ${getPlaceName(selectedPlaceIds[1])}",
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(height: 4),
                            Text(
                              matrixPrice != null
                                  ? "${matrixPrice.mTicketPrice.toStringAsFixed(0)}.000đ"
                                  : "Chưa có giá cho chặng này",
                              style: TextStyle(
                                color: matrixPrice != null
                                    ? Colors.red
                                    : Colors.grey,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                      ElevatedButton(
                        onPressed: matrixPrice != null ? () {} : null,
                        child: Text("Đặt vé"),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget buildListLine(ScrollController scrollController) {
    return Expanded(
      child: CustomScrollView(
        controller: scrollController,
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 12),
              child: Column(
                children: [
                  SizedBox(height: 10),
                  Container(
                    width: 50,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  SizedBox(height: 10),
                  Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.line.description,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(height: 5),
                          Text(
                            "Lịch trình:  ${widget.line.schedules}",
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                      Spacer(),
                      Container(
                        width: 35,
                        height: 35,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(25),
                        ),
                        child: IconButton(
                          onPressed: widget.onClosed,
                          icon: Icon(Icons.close, size: 18),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 4),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Chọn điểm đi và điểm đến (tối đa 2 điểm)",
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: EdgeInsets.all(12),
            sliver: SliverList.separated(
              itemCount: widget.line.placeMarks.length,
              separatorBuilder: (context, index) {
                return SizedBox(height: 8);
              },
              itemBuilder: (context, index) {
                final place = widget.line.placeMarks[index];
                final isSelected = selectedPlaceIds.contains(place.placeID);
                final selectionOrder = selectedPlaceIds.indexOf(place.placeID);
                return Card(
                  elevation: isSelected ? 3 : 1,
                  color: isSelected ? Colors.blue.shade50 : Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                    side: BorderSide(
                      color: isSelected ? Colors.blue : Colors.transparent,
                      width: 1,
                    ),
                  ),
                  child: CheckboxListTile(
                    value: isSelected,
                    onChanged: (value) => togglePlace(place.placeID),
                    controlAffinity: ListTileControlAffinity.leading,
                    title: Text(
                      place.description,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                    subtitle: isSelected
                        ? Text(
                            selectionOrder == 0 ? "Điểm đi" : "Điểm đến",
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.blue,
                              fontWeight: FontWeight.w500,
                            ),
                          )
                        : null,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
