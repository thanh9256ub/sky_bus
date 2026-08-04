import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_animations/flutter_map_animations.dart';
import 'package:flutter_map_marker_popup/flutter_map_marker_popup.dart';
import 'package:latlong2/latlong.dart';
import 'package:toastification/toastification.dart';

import '../../models/bus_line_model.dart';
import '../../models/vehicle_model.dart';
import '../../service/bus_service.dart';
import '../../utils/global.dart';
import '../../utils/map_helper.dart';
import '../../utils/string_utils.dart';
import '../widgets/ticket_buy_dialog.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
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
  BusService busService = BusService();
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

      final newIndex = selectedBusLine!.placeMarks.indexWhere(
        (e) => e.placeID == placeId,
      );

      final firstIndex = selectedBusLine!.placeMarks.indexWhere(
        (e) => e.placeID == selectedPlaceIds[0],
      );

      final secondIndex = selectedBusLine!.placeMarks.indexWhere(
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

  Future<void> showDialogTicket(Matrix? matrix) async {
    if (selectedPlaceIds.length == 2) {
      await showDialog(
        context: context,
        builder: (context) {
          return TicketBuyDialog(
            matrix: matrix!,
            palaceIds: selectedPlaceIds,
            selectedLine: selectedBusLine!,
          );
        },
      );
    } else {
      showToast("Vui lòng chọn điểm đi và điểm đến", ToastificationType.error);
    }
  }

  void selectLine(BusLine busLine) {
    setState(() {
      selectedBusLine = busLine;
    });
    animatedMapController.animateTo(
      dest: busLine.startPoint!,
      zoom: 16,
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeInOutCubic,
    );
  }

  Future<void> searchNearBus() async {
    if (!mounted) return;
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
    final response = await busService.listBusLines();
    if (response.errorMessage.isEmpty && mounted) {
      setState(() {
        busLines = response.busLines;
      });
    } else {
      showToast(response.errorMessage, ToastificationType.error);
    }
  }

  String getPlaceName(int placeId) {
    return selectedBusLine!.placeMarks
        .firstWhere((e) => e.placeID == placeId)
        .description;
  }

  Color getVehicleColor(Vehicle vehicle) {
    if (vehicle.currentSpeed > 0) {
      return Colors.greenAccent.shade400;
    }
    if (vehicle.engineState == "ON") {
      return Colors.purpleAccent;
    }
    return Colors.red;
  }

  Matrix? getSelectedMatrixPrice() {
    if (selectedPlaceIds.length != 2) return null;
    final fromId = selectedPlaceIds[0];
    final toId = selectedPlaceIds[1];
    return selectedBusLine!.matrixPrices.firstWhere(
      (e) =>
          (e.fromPlaceID == fromId && e.toPlaceID == toId) ||
          (e.fromPlaceID == toId && e.toPlaceID == fromId),
    );
  }

  @override
  void initState() {
    super.initState();
    animatedMapController = AnimatedMapController(
      vsync: this,
      mapController: mapController,
    );
    WidgetsBinding.instance.addPostFrameCallback((e) {
      getCurrentLocation();
      searchNearBus();
      vehicleTimer = Timer.periodic(
        Duration(seconds: 5),
        (timer) => searchNearBus(),
      );
    });
    getListBusLine();
  }

  @override
  void dispose() {
    vehicleTimer?.cancel();
    sheetController.dispose();
    searchController.dispose();
    _focusNode.dispose();
    popupController.dispose();
    mapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          mapWidget(),
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
            moveDebounce = Timer(
              Duration(milliseconds: 1500),
              () => searchNearBus(),
            );
          },
        ),
        children: [
          TileLayer(
            urlTemplate: '$skymapUrl/web_tile.jsp?c={x}&r={y}&z={z}',
            userAgentPackageName: 'com.skysoft.sks_web',
          ),
          PolylineLayer(
            polylines: busLines.map((line) {
              final isSelected = selectedBusLine?.lineID == line.lineID;
              return Polyline(
                points: line.wayPoints
                    .map((e) => LatLng(e.latitude, e.longitude))
                    .toList(),
                strokeWidth: isSelected ? 6 : 3,
                color: isSelected ? Colors.green : Color(line.color),
              );
            }).toList(),
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
            markers: busLines.expand((line) {
              return line.placeMarks.map((place) {
                return Marker(
                  point: LatLng(place.y, place.x),
                  width: 70,
                  height: 50,
                  child: GestureDetector(
                    onTap: () {
                      selectLine(line);
                    },
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.directions_bus,
                          color: Color(line.color),
                          size: 22,
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 2),
                          child: Text(
                            place.description,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 8,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              });
            }).toList(),
          ),
          Positioned(
            bottom: MediaQuery.of(context).size.height * 0.01,
            right: 20,
            child: FloatingActionButton.small(
              heroTag: "gps_button",
              backgroundColor: Colors.white,
              onPressed: getCurrentLocation,
              child: Icon(Icons.my_location, color: Colors.blue),
            ),
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
        child: Autocomplete<BusLine>(
          textEditingController: searchController,
          focusNode: _focusNode,
          displayStringForOption: (busLine) => busLine.description,
          optionsBuilder: (textEditingValue) {
            final query = textEditingValue.text.searchText;
            if (query.isNotEmpty) {
              return busLines.where(
                (e) => e.description.searchText.contains(query),
              );
            } else {
              return busLines;
            }
          },
          fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
            return Container(
              height: 50,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(25),
                border: Border.all(color: Colors.grey.shade400),
                boxShadow: [BoxShadow(blurRadius: 10, color: Colors.black12)],
              ),
              child: TextFormField(
                controller: controller,
                focusNode: focusNode,
                decoration: InputDecoration(
                  hintText: "Tìm kiếm tuyến xe...",
                  prefixIcon: Icon(Icons.search),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 12),
                  fillColor: Colors.white,
                  suffixIcon: selectedBusLine != null
                      ? IconButton(
                          onPressed: () {
                            setState(() {
                              selectedBusLine = null;
                              searchController.text = "";
                              selectedPlaceIds = [];
                            });
                          },
                          icon: Icon(Icons.close),
                        )
                      : SizedBox(),
                ),
                onFieldSubmitted: (value) => onFieldSubmitted,
                onTapOutside: (event) {
                  FocusManager.instance.primaryFocus!.unfocus();
                },
              ),
            );
          },
          onSelected: (busLine) {
            _focusNode.unfocus();
            selectLine(busLine);
          },
        ),
      ),
    );
  }

  Widget mainContent() {
    return DraggableScrollableSheet(
      controller: sheetController,
      initialChildSize: 0.25,
      minChildSize: 0.25,
      maxChildSize: 0.8,
      snap: true,
      snapSizes: [0.25, 0.8],
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
              Container(
                height: 50,
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: secondaryColor,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  ),
                ),
                child: Text(
                  "${selectedBusLine!.placeMarks.first.description} - ${selectedBusLine!.placeMarks.last.description}",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              buildListItem(scrollController),
              Padding(
                padding: EdgeInsets.all(10),
                child: SizedBox(
                  width: double.infinity,
                  height: 45,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      showDialogTicket(matrixPrice);
                    },
                    label: Row(
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
                        matrixPrice != null
                            ? Text(
                                " - Giá vé: ${moneyFormat.format(matrixPrice.price)},000đ",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              )
                            : Text(""),
                      ],
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
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
          return IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  width: 40,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Positioned.fill(
                        child: Align(
                          alignment: Alignment.center,
                          child: Container(width: 3, color: Colors.blue),
                        ),
                      ),
                      Container(
                        width: 14,
                        height: 14,
                        decoration: BoxDecoration(
                          color: isSelected ? Colors.white : Colors.blue,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.blue, width: 3),
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
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              TextButton(
                                onPressed: () {
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
                                child: Text(
                                  place.description,
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: isSelected
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                    color: isSelected
                                        ? Colors.blue.shade400
                                        : Colors.black,
                                  ),
                                ),
                              ),
                              if (isSelected)
                                Padding(
                                  padding: const EdgeInsets.only(left: 10),
                                  child: Text(
                                    selectedPlaceIds.indexOf(place.placeID) == 0
                                        ? "Điểm đi"
                                        : "Điểm đến",
                                    style: TextStyle(
                                      color: isSelected
                                          ? Colors.blue.shade400
                                          : Colors.black,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        Text(
                          "${MapHelper.calculateDistance(currentLocation, LatLng(place.y, place.x)).toStringAsFixed(2)} km",
                          style: TextStyle(color: Colors.grey),
                        ),
                        Checkbox(
                          value: isSelected,
                          onChanged: (value) {
                            togglePlace(place.placeID);
                          },
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
