import 'package:flutter/material.dart';
import 'package:skysoft_bus/models/bus_line_model.dart';

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
  int quantity = 1;

  // void togglePlace(int placeId) {
  //   setState(() {
  //     if (selectedPlaceIds.contains(placeId)) {
  //       selectedPlaceIds.remove(placeId);
  //     } else if (selectedPlaceIds.length < 2) {
  //       selectedPlaceIds.add(placeId);
  //     } else {
  //       showToast(
  //         "Chỉ được chọn 2 điểm: điểm đi và điểm đến",
  //         ToastificationType.error,
  //       );
  //     }
  //   });
  // }

  void togglePlace(int placeId) {
    setState(() {
      if (selectedPlaceIds.contains(placeId)) {
        selectedPlaceIds.remove(placeId);
        return;
      }

      if (selectedPlaceIds.length < 2) {
        selectedPlaceIds.add(placeId);
        return;
      }

      final newIndex = widget.line.placeMarks.indexWhere(
        (e) => e.placeID == placeId,
      );

      final firstIndex = widget.line.placeMarks.indexWhere(
        (e) => e.placeID == selectedPlaceIds[0],
      );

      final secondIndex = widget.line.placeMarks.indexWhere(
        (e) => e.placeID == selectedPlaceIds[1],
      );

      final distanceToFirst = (newIndex - firstIndex).abs();
      final distanceToSecond = (newIndex - secondIndex).abs();

      if (distanceToFirst <= distanceToSecond) {
        selectedPlaceIds[0] = placeId;
      } else {
        selectedPlaceIds[1] = placeId;
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

  String getPlaceName(int placeId) {
    return widget.line.placeMarks
        .firstWhere((e) => e.placeID == placeId)
        .description;
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.25,
      minChildSize: 0.25,
      maxChildSize: 0.9,
      snap: true,
      snapSizes: [0.25, 0.9],
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
              buildBookingBar(matrixPrice),
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

  Widget buildBookingBar(Matrix? matrix) {
    return selectedPlaceIds.length == 2
        ? Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              border: Border(top: BorderSide(color: Colors.grey.shade200)),
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
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 4),
                      Row(
                        children: [
                          Text(
                            matrix != null
                                ? "${matrix.mTicketPrice.toStringAsFixed(0)}.000đ"
                                : "Chưa có giá cho chặng này",
                            style: TextStyle(
                              color: matrix != null ? Colors.red : Colors.grey,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          Spacer(),
                          Text("SL:"),
                          SizedBox(width: 5),
                          updateQty(),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 10),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.blue.shade400,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: IconButton(
                    onPressed: matrix != null ? () {} : null,
                    icon: Icon(Icons.add, color: Colors.white),
                  ),
                ),
              ],
            ),
          )
        : SizedBox();
  }

  Widget updateQty() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          InkWell(
            onTap: quantity > 1
                ? () {
                    setState(() {
                      quantity--;
                    });
                  }
                : null,
            child: Padding(
              padding: EdgeInsets.all(6),
              child: Icon(Icons.remove, size: 16),
            ),
          ),

          Container(
            constraints: BoxConstraints(minWidth: 30),
            alignment: Alignment.center,
            child: Text(
              quantity.toString(),
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
            ),
          ),

          InkWell(
            onTap: () {
              setState(() {
                quantity++;
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
