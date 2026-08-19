import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_animations/flutter_map_animations.dart';
import 'package:flutter_map_marker_popup/flutter_map_marker_popup.dart';
import 'package:latlong2/latlong.dart';
import 'package:skysoft_bus/screens/roots/busline_list_screen.dart';
import 'package:toastification/toastification.dart';

import '../../models/bus_line_model.dart';
import '../../models/vehicle_model.dart';
import '../../service/bus_service.dart';
import '../../utils/global.dart';
import '../../utils/map_helper.dart';
import '../widgets/ticket_buy_dialog.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with TickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;
  LatLng currentLocation = LatLng(21.051873, 105.777787);
  late final AnimatedMapController animatedMapController;
  final mapController = MapController();
  final popupController = PopupController();
  final searchController = TextEditingController();
  final sheetController = DraggableScrollableController();
  final _focusNode = FocusNode();

  BusLine? selectedBusLine;
  List<BusLine> busLines = [];
  List<Vehicle> nearVehicles = [];
  List<int> selectedPlaceIds = [];
  Timer? vehicleTimer;
  Timer? moveDebounce;

  void getCurrentLocation() async {
    final location = await MapHelper.getCurrentLocation();
    if (location == null) {
      showToast("Không thể lấy vị trí hiện tại", ToastificationType.error);
      return;
    }
    setState(() {
      currentLocation = location;
    });
    MapHelper.moveToLocation(
      mapController: mapController,
      animatedController: animatedMapController,
      location: currentLocation,
    );
  }

  void openBusLineListScreen() async {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => BusLineListScreen(
          busLines: busLines,
          selectedBusLine: selectedBusLine,
          onChanged: (value) {
            selectLine(value);
          },
        ),
      ),
    );
  }

  void clearSelectedBusLine() {
    setState(() {
      selectedBusLine = null;
      selectedPlaceIds = [];
    });
  }

  void togglePlace(int placeId) {
    setState(() {
      if (selectedPlaceIds.contains(placeId)) {
        selectedPlaceIds.remove(placeId);
        return;
      } else if (selectedPlaceIds.length < 2) {
        selectedPlaceIds.add(placeId);
        return;
      }

      int? newIndex;
      int? firstIndex;
      int? secondIndex;

      for (int i = 0; i < selectedBusLine!.placeMarks.length; i++) {
        final id = selectedBusLine!.placeMarks[i].placeID;
        if (id == placeId) {
          newIndex = i;
        } else if (id == selectedPlaceIds[0]) {
          firstIndex = i;
        } else if (id == selectedPlaceIds[1]) {
          secondIndex = i;
        }
      }
      if (newIndex == null || firstIndex == null || secondIndex == null) {
        return;
      }
      final distanceToFirst = (newIndex - firstIndex).abs();
      final distanceToSecond = (newIndex - secondIndex).abs();
      if (distanceToFirst <= distanceToSecond) {
        selectedPlaceIds[0] = placeId;
      } else {
        selectedPlaceIds[1] = placeId;
      }
    });
  }

  Future<void> showDialogTicket(Matrix? matrix) async {
    if (matrix == null) {
      showToast("Không tìm thấy giá vé", ToastificationType.error);
      return;
    }
    if (selectedPlaceIds.length == 2) {
      await showDialog(
        context: context,
        builder: (context) {
          return TicketBuyDialog(
            fromPlace: selectedBusLine!.placeMarks
                .where((e) => e.placeID == selectedPlaceIds.first)
                .first,
            toPlace: selectedBusLine!.placeMarks
                .where((e) => e.placeID == selectedPlaceIds.last)
                .first,
            matrix: matrix,
          );
        },
      );
    } else {
      showToast("Vui lòng chọn điểm đi và điểm đến", ToastificationType.error);
      return;
    }
  }

  void selectLine(BusLine busLine, {LatLng? focusPoint}) {
    setState(() {
      selectedBusLine = busLine;
      selectedPlaceIds = [];
    });

    LatLng? target = focusPoint ?? busLine.startPoint;

    if (target == null && busLine.placeMarks.isNotEmpty) {
      final first = busLine.placeMarks.first;
      target = LatLng(first.y, first.x);
    }

    if (target == null) return;

    animatedMapController.animateTo(
      dest: target,
      zoom: 16,
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeInOutCubic,
    );
  }

  Future<void> searchNearBus() async {
    if (!mounted) return;
    BusService busService = BusService();
    final center = mapController.camera.center;
    final response = await busService.searchNearVehicles(
      center.latitude,
      center.longitude,
    );
    if (response.errorMessage.isEmpty) {
      setState(() {
        nearVehicles = response.vehicles;
      });
    } else {
      showToast(response.errorMessage, ToastificationType.error);
    }
  }

  Marker createVehicleMarker(Vehicle e) {
    return Marker(
      point: LatLng(e.y, e.x),
      width: 70,
      height: 75,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            e.plateNo,
            style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
          ),
          Transform.rotate(
            angle: e.direction * math.pi / 180,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Icon(Icons.navigation, size: 32, color: Colors.black),
                Icon(Icons.navigation, size: 26, color: getVehicleColor(e)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void getListBusLine() async {
    BusService busService = BusService();
    final response = await busService.listBusLines();
    if (response.errorMessage.isEmpty && mounted) {
      setState(() {
        busLines = response.busLines;
      });
    } else {
      showToast(response.errorMessage, ToastificationType.error);
    }
  }

  Color getVehicleColor(Vehicle vehicle) {
    if (vehicle.currentSpeed > 0) {
      return Colors.greenAccent.shade400;
    } else if (vehicle.engineState == "ON") {
      return Colors.purpleAccent;
    } else {
      return Colors.red;
    }
  }

  Matrix? getSelectedMatrixPrice() {
    if (selectedPlaceIds.length != 2) return null;
    final fromId = selectedPlaceIds[0];
    final toId = selectedPlaceIds[1];
    final result = selectedBusLine!.matrixPrices.where(
      (e) =>
          (e.fromPlaceID == fromId && e.toPlaceID == toId) ||
          (e.fromPlaceID == toId && e.toPlaceID == fromId),
    );
    if (result.isEmpty) {
      return null;
    } else {
      return result.first;
    }
  }

  @override
  void initState() {
    super.initState();
    animatedMapController = AnimatedMapController(
      vsync: this,
      mapController: mapController,
    );
    vehicleTimer = Timer.periodic(Duration(seconds: 5), (timer) {
      searchNearBus();
    });
    getCurrentLocation();
    getListBusLine();
    WidgetsBinding.instance.addPostFrameCallback((e) {
      searchNearBus();
    });
  }

  @override
  void dispose() {
    vehicleTimer?.cancel();
    searchController.dispose();
    _focusNode.dispose();
    popupController.dispose();
    mapController.dispose();
    animatedMapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          mapWidget(),
          Positioned(
            bottom: MediaQuery.of(context).size.height * 0.03,
            right: 20,
            child: FloatingActionButton.small(
              heroTag: "gps_button",
              backgroundColor: Colors.white,
              onPressed: getCurrentLocation,
              child: Icon(Icons.my_location, color: Colors.blue),
            ),
          ),
          centerPointMap(),
          searchBusLine(),
          if (selectedBusLine != null) mainContent(),
        ],
      ),
    );
  }

  Widget mapWidget() {
    return Positioned.fill(
      child: FlutterMap(
        mapController: mapController,
        options: MapOptions(
          initialCenter: currentLocation,
          initialZoom: 16,
          minZoom: 8,
          maxZoom: 16,
          interactionOptions: InteractionOptions(
            flags:
                InteractiveFlag.drag |
                InteractiveFlag.pinchZoom |
                InteractiveFlag.flingAnimation,
          ),
          onPositionChanged: (position, hasGesture) {
            if (!hasGesture) return;
            moveDebounce?.cancel();
            moveDebounce = Timer(Duration(milliseconds: 1500), searchNearBus);
          },
        ),
        children: [
          TileLayer(
            urlTemplate: '$skymapUrl/web_tile.jsp?c={x}&r={y}&z={z}',
            userAgentPackageName: 'com.skysoft.sks_web',
          ),
          if (selectedBusLine != null && selectedBusLine!.wayPoints.length >= 2)
            PolylineLayer(
              polylines: [
                Polyline(
                  points: selectedBusLine!.wayPoints
                      .map((e) => LatLng(e.latitude, e.longitude))
                      .toList(),
                  strokeWidth: 4,
                  color: Color(selectedBusLine!.color.toUnsigned(32)),
                ),
              ],
            ),
          PopupMarkerLayer(
            options: PopupMarkerLayerOptions(
              markers: [
                ...nearVehicles.map((e) => createVehicleMarker(e)),
                Marker(
                  point: currentLocation,
                  width: 50,
                  height: 50,
                  child: Icon(Icons.location_on, color: Colors.blue, size: 24),
                ),
              ],
              popupController: popupController,
            ),
          ),
          MarkerLayer(
            markers: (selectedBusLine != null ? [selectedBusLine!] : busLines)
                .expand((line) {
                  return line.placeMarks.map((place) {
                    return Marker(
                      point: LatLng(place.y, place.x),
                      width: 110,
                      height: 65,
                      child: GestureDetector(
                        onTap: () {
                          if (selectedBusLine != line) {
                            selectLine(
                              line,
                              focusPoint: LatLng(place.y, place.x),
                            );
                            return;
                          }
                          MapHelper.moveToLocation(
                            mapController: mapController,
                            animatedController: animatedMapController,
                            location: LatLng(place.y, place.x),
                          );
                        },
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                border: Border.all(
                                  color: Color(line.color.toUnsigned(32)),
                                ),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Icon(
                                Icons.directions_bus,
                                color: Color(line.color.toUnsigned(32)),
                                size: 18,
                              ),
                            ),
                            Visibility(
                              visible:
                                  mapController.camera.zoom >= 12 ||
                                  selectedBusLine != null,
                              child: Container(
                                padding: EdgeInsets.symmetric(horizontal: 2),
                                child: Text(
                                  place.description,
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  });
                })
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget centerPointMap() {
    return Positioned.fill(
      child: IgnorePointer(
        child: Center(child: Icon(Icons.add, color: Colors.red, size: 18)),
      ),
    );
  }

  Widget searchBusLine() {
    return Positioned(
      top: MediaQuery.of(context).size.height * 0.02,
      left: 16,
      right: 16,
      child: SafeArea(
        child: Material(
          color: Colors.white,
          borderRadius: BorderRadius.circular(25),
          child: InkWell(
            borderRadius: BorderRadius.circular(25),
            onTap: openBusLineListScreen,
            child: Container(
              height: 45,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(25),
                border: Border.all(color: Colors.grey.shade400),
                boxShadow: [BoxShadow(blurRadius: 10, color: Colors.black12)],
              ),
              child: Row(
                children: [
                  SizedBox(width: 16),
                  Container(
                    padding: EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: secondaryColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: Icon(Icons.search, color: secondaryColor),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      selectedBusLine?.description ?? "Tìm kiếm tuyến xe",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 15,
                        color: selectedBusLine != null
                            ? Colors.black87
                            : Colors.grey.shade600,
                        fontWeight: selectedBusLine != null
                            ? FontWeight.w600
                            : FontWeight.normal,
                      ),
                    ),
                  ),
                  if (selectedBusLine != null)
                    IconButton(
                      onPressed: clearSelectedBusLine,
                      icon: const Icon(Icons.close),
                    )
                  else
                    const SizedBox(width: 16),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget mainContent() {
    return DraggableScrollableSheet(
      controller: sheetController,
      initialChildSize: 0.3,
      minChildSize: 0.3,
      maxChildSize: 0.8,
      snap: true,
      snapSizes: [0.3, 0.8],
      builder: (context, scrollController) {
        final matrixPrice = getSelectedMatrixPrice();
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 12)],
          ),
          child: Column(
            children: [
              if (selectedBusLine!.placeMarks.isNotEmpty)
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onVerticalDragUpdate: (details) {
                    final screenHeight = MediaQuery.of(context).size.height;
                    final newSize =
                        sheetController.size - details.delta.dy / screenHeight;
                    sheetController.jumpTo(newSize.clamp(0.3, 0.8));
                  },
                  onVerticalDragEnd: (details) {
                    final target = sheetController.size > 0.4 ? 0.8 : 0.3;
                    sheetController.animateTo(
                      target,
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.easeOut,
                    );
                  },
                  child: Column(
                    children: [
                      if (selectedBusLine!.placeMarks.isNotEmpty)
                        Container(
                          margin: const EdgeInsets.fromLTRB(16, 10, 16, 4),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: secondaryColor,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: secondaryColor.withValues(alpha: 0.35),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.alt_route_rounded,
                                color: Colors.white,
                                size: 20,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  "${selectedBusLine!.placeMarks.first.description} → "
                                  "${selectedBusLine!.placeMarks.last.description}",
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              buildListItem(scrollController),
              SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 6, 12, 10),
                  child: SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {
                        showDialogTicket(matrixPrice);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: secondaryColor,
                        foregroundColor: Colors.white,
                        elevation: 4,
                        shadowColor: secondaryColor.withValues(alpha: 0.5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.confirmation_number_outlined),
                          SizedBox(width: 10),
                          Text(
                            "Đặt vé",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (matrixPrice != null) ...[
                            SizedBox(width: 8),
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white12,
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Text(
                                "${moneyFormat.format(matrixPrice.price)},000đ",
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget buildListItem(ScrollController scrollController) {
    return Expanded(
      child: ListView.builder(
        controller: scrollController,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: selectedBusLine!.placeMarks.length,
        itemBuilder: (context, index) {
          final place = selectedBusLine!.placeMarks[index];
          final isSelected = selectedPlaceIds.contains(place.placeID);
          final isFirst = index == 0;
          final isLast = index == selectedBusLine!.placeMarks.length - 1;
          String distance = MapHelper.calculateDistance(
            currentLocation,
            LatLng(place.y, place.x),
          ).toStringAsFixed(2);
          return IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  width: 34,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Positioned.fill(
                        child: Align(
                          alignment: Alignment.center,
                          child: Container(
                            margin: EdgeInsets.only(
                              top: isFirst ? 20 : 0,
                              bottom: isLast ? 20 : 0,
                            ),
                            width: 3,
                            color: secondaryColor.withValues(alpha: 0.25),
                          ),
                        ),
                      ),
                      Container(
                        width: isSelected ? 16 : 12,
                        height: isSelected ? 16 : 12,
                        decoration: BoxDecoration(
                          color: isSelected ? secondaryColor : Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(color: secondaryColor, width: 3),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: secondaryColor.withValues(
                                      alpha: 0.4,
                                    ),
                                    blurRadius: 6,
                                  ),
                                ]
                              : null,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(color: Colors.grey.shade300),
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            borderRadius: BorderRadius.circular(10),
                            onTap: () {
                              MapHelper.moveToLocation(
                                mapController: mapController,
                                animatedController: animatedMapController,
                                location: LatLng(place.y, place.x),
                              );
                              sheetController.animateTo(
                                0.25,
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeOut,
                              );
                              scrollController.jumpTo(0);
                            },
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  place.description,
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: isSelected
                                        ? FontWeight.bold
                                        : FontWeight.w500,
                                    color: isSelected
                                        ? secondaryColor
                                        : Colors.black87,
                                  ),
                                ),
                                if (isSelected)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 2),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: secondaryColor,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        selectedPlaceIds.indexOf(
                                                  place.placeID,
                                                ) ==
                                                0
                                            ? "Điểm đi"
                                            : "Điểm đến",
                                        style: const TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                        Text(
                          "$distance km",
                          style: TextStyle(color: Colors.grey, fontSize: 12),
                        ),
                        Transform.scale(
                          scale: 1.1,
                          child: Checkbox(
                            value: isSelected,
                            activeColor: secondaryColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4),
                            ),
                            onChanged: (value) {
                              togglePlace(place.placeID);
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
