import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_animations/flutter_map_animations.dart';
import 'package:flutter_map_marker_popup/flutter_map_marker_popup.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:skysoft_bus/models/bus_line_model.dart';
import 'package:skysoft_bus/screens/homes/look_up_route_screen.dart';
import 'package:skysoft_bus/service/bus_service.dart';
import 'package:toastification/toastification.dart';

import '../../service/map_service.dart';
import '../../utils/global.dart';
import '../../utils/string_utils.dart';
import '../../widgets/button_feature.dart';
import '../homes/detail_bus_line_screen.dart';
import '../homes/full_map_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  String address = "";
  LatLng currentLocation = LatLng(21.051873, 105.777787);
  List<Marker> markers = [];
  late final AnimatedMapController animatedMapController;
  final mapController = MapController();
  final popupController = PopupController();
  final searchController = TextEditingController();
  final _focusNode = FocusNode();
  bool snapDrag = false;
  String routeSelected = "";
  BusLine? selectedBusLine;
  List<BusLine> busLines = [];

  void getCurrentLocation() async {
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      return;
    }

    final lastKnown = await Geolocator.getLastKnownPosition();
    if (lastKnown != null && mounted) updateLocation(lastKnown);

    await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.medium,
          ),
        )
        .then((pos) {
          if (mounted) updateLocation(pos);
        })
        .catchError((e) {
          showToast(e.toString(), ToastificationType.error);
        });
  }

  void updateLocation(Position pos) {
    currentLocation = LatLng(pos.latitude, pos.longitude);
    markers = [_currentLocationMarker];
    setState(() {
      _moveToCurrentLocation();
    });
    getAddress();
  }

  Marker get _currentLocationMarker => Marker(
    point: currentLocation,
    width: 50,
    height: 50,
    child: const Icon(Icons.location_on, color: Colors.blue, size: 24),
  );

  void _moveToCurrentLocation() {
    if (mapController.camera.nonRotatedSize.width > 0) {
      animatedMapController.animateTo(
        dest: currentLocation,
        zoom: 16,
        duration: const Duration(milliseconds: 1000),
        curve: Curves.easeInOutCubic,
      );
    } else {
      mapController.move(currentLocation, 16);
    }
  }

  void _moveToBusLocation() {
    if (selectedBusLine != null) {
      setState(() {
        animatedMapController.animateTo(
          dest: selectedBusLine!.startPoint,
          zoom: 16,
          duration: const Duration(milliseconds: 1000),
          curve: Curves.easeInOutCubic,
        );
      });
    } else {
      showToast("Vui lòng chọn tuyến xe", ToastificationType.error);
    }
  }

  List<Marker> buildCheckpointMarkers(BusLine line) {
    return line.placeMarks.map((place) {
      return Marker(
        point: LatLng(place.y, place.x),
        width: 70,
        height: 50,
        child: GestureDetector(
          onTap: () {},
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.directions_bus,
                color: Colors.green.shade500,
                size: 26,
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 2),
                child: Text(
                  place.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      );
    }).toList();
  }

  void getListBusLine() async {
    BusService service = BusService();
    final response = await service.listBusLines();
    if (response.errorMessage.isEmpty && mounted) {
      setState(() {
        busLines = response.busLines;
      });
    } else {
      showToast(response.errorMessage, ToastificationType.error);
    }
  }

  void getAddress() async {
    MapService service = MapService();
    final response = await service.getAddress(
      currentLocation.longitude,
      currentLocation.latitude,
    );
    if (!mounted) return;
    setState(() {
      address = response;
    });
  }

  void pushToLookUp() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (context) => LookUpRouteScreen()));
  }

  @override
  void initState() {
    super.initState();
    animatedMapController = AnimatedMapController(
      vsync: this,
      mapController: mapController,
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      getCurrentLocation();
    });
    getListBusLine();
  }

  @override
  void dispose() {
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
      appBar: AppBar(
        backgroundColor: Colors.blue.shade300,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        title: Image.asset("assets/images/skysoft_logo_ok_h80.png", height: 35),
        actions: [IconButton(onPressed: () {}, icon: Icon(Icons.menu))],
      ),
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: EdgeInsets.all(5),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  searchBusLine(),
                  SizedBox(height: 16),
                  mapWidget(),
                  SizedBox(height: 16),
                  Text(
                    "Truy cập nhanh",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 16),
                  quickAccessFeature(),
                  SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          "Tính năng khác",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      TextButton(onPressed: () {}, child: Text("Xem tất cả")),
                    ],
                  ),
                  SizedBox(height: 10),
                  otherFeatures(),
                ],
              ),
            ),
            if (selectedBusLine != null)
              Positioned.fill(
                child: DetailBusLineScreen(
                  line: selectedBusLine!,
                  onClosed: () {
                    setState(() {
                      selectedBusLine = null;
                      searchController.text = "";
                    });
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget searchBusLine() {
    return Autocomplete<BusLine>(
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
          height: 40,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(blurRadius: 10, color: Colors.black12)],
          ),
          child: TextFormField(
            controller: controller,
            focusNode: focusNode,
            decoration: InputDecoration(
              hintText: "Tìm kiếm tuyến xe...",
              prefixIcon: Icon(Icons.search),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(vertical: 5),
              fillColor: Colors.white,
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(10.0)),
                borderSide: BorderSide(color: Colors.grey.shade400),
              ),
            ),
            onTapOutside: (event) {
              FocusManager.instance.primaryFocus?.unfocus();
            },
            onFieldSubmitted: (value) => onFieldSubmitted,
          ),
        );
      },
      onSelected: (busLine) {
        _focusNode.unfocus();
        setState(() {
          selectedBusLine = busLine;
          animatedMapController.animateTo(
            dest: busLine.startPoint,
            zoom: 16,
            duration: const Duration(milliseconds: 1000),
            curve: Curves.easeInOutCubic,
          );
        });
      },
    );
  }

  Widget mapWidget() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: SizedBox(
        height: 400,
        child: Stack(
          children: [
            FlutterMap(
              mapController: mapController,
              options: MapOptions(
                initialCenter: currentLocation,
                initialZoom: 16,
                minZoom: 10,
                maxZoom: 16,
                interactionOptions: InteractionOptions(
                  flags:
                      InteractiveFlag.drag |
                      InteractiveFlag.pinchZoom |
                      InteractiveFlag.flingAnimation,
                ),
              ),
              children: [
                TileLayer(
                  urlTemplate: '$skymapUrl/web_tile.jsp?c={x}&r={y}&z={z}',
                  userAgentPackageName: 'com.skysoft.sks_web',
                ),
                if (selectedBusLine != null)
                  PolylineLayer(
                    polylines: [
                      Polyline(
                        points: selectedBusLine!.wayPoints
                            .map((w) => LatLng(w.latitude, w.longitude))
                            .toList(),
                        strokeWidth: 4,
                        color: Color(Colors.greenAccent.intValue),
                      ),
                    ],
                  ),
                PopupMarkerLayer(
                  options: PopupMarkerLayerOptions(
                    markers: markers,
                    popupController: popupController,
                  ),
                ),
                if (selectedBusLine != null)
                  MarkerLayer(
                    markers: buildCheckpointMarkers(selectedBusLine!),
                  ),
              ],
            ),
            Positioned(
              right: 10,
              bottom: 10,
              child: FloatingActionButton.small(
                heroTag: "fullscreen_button",
                backgroundColor: Colors.white,
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => FullMapScreen(
                        selectedBusLine: selectedBusLine,
                        pointMarkers: selectedBusLine != null
                            ? buildCheckpointMarkers(selectedBusLine!)
                            : null,
                      ),
                    ),
                  );
                },
                child: Icon(Icons.open_in_full, color: Colors.blue),
              ),
            ),
            Positioned(
              right: 10,
              top: 10,
              child: FloatingActionButton.small(
                heroTag: "gps_button",
                backgroundColor: Colors.white,
                onPressed: getCurrentLocation,
                child: Icon(Icons.my_location, color: Colors.blue),
              ),
            ),
            Positioned(
              right: 60,
              top: 10,
              child: FloatingActionButton.small(
                heroTag: "bus_button",
                backgroundColor: Colors.white,
                onPressed: _moveToBusLocation,
                child: Icon(
                  Icons.directions_bus_filled_outlined,
                  color: Colors.blue,
                ),
              ),
            ),
            Positioned.fill(
              child: IgnorePointer(
                child: Center(
                  child: Icon(Icons.add, color: Colors.red, size: 18),
                ),
              ),
            ),
            Positioned(
              left: 10,
              bottom: 15,
              child: SizedBox(
                width: 300,
                child: Row(
                  children: [
                    Icon(Icons.location_on, color: Colors.blue),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        address.isEmpty ? "Đang xác định vị trí..." : address,
                        maxLines: 2,
                        style: TextStyle(fontSize: 12),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget quickAccessFeature() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 10),
      child: Row(
        children: [
          FeatureButton(
            title: "Tra cứu",
            icon: Icons.search_rounded,
            bgColor: Color(0xFFE8F2FF),
            iconColor: Colors.blue,
            onTap: pushToLookUp,
          ),
          SizedBox(width: 10),
          FeatureButton(
            title: "Trạm gần",
            icon: Icons.location_on_rounded,
            bgColor: Color(0xFFFFF4E5),
            iconColor: Colors.orange,
            onTap: () {},
          ),
        ],
      ),
    );
  }

  Widget otherFeatures() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 10),
      child: Row(
        children: [
          FeatureButton(
            title: "Khảo sát\nhành khách",
            icon: Icons.assignment,
            bgColor: Colors.pink.shade50,
            iconColor: Colors.pink,
            onTap: () {},
          ),
          SizedBox(width: 10),
          FeatureButton(
            title: "Đăng kí thẻ \n xe bus",
            icon: Icons.local_activity,
            bgColor: Colors.green.shade50,
            iconColor: Colors.green,
            onTap: () {},
          ),
          SizedBox(width: 10),
          FeatureButton(
            title: 'Tìm xe buýt',
            icon: Icons.location_on,
            bgColor: Colors.blue.shade50,
            iconColor: Colors.blue,
            onTap: () {},
          ),
        ],
      ),
    );
  }
}
