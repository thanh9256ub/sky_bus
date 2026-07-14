import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_animations/flutter_map_animations.dart';
import 'package:flutter_map_marker_popup/flutter_map_marker_popup.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:skysoft_bus/screens/homes/look_up_route_screen.dart';
import 'package:toastification/toastification.dart';

import '../../service/map_service.dart';
import '../../utils/global.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  String address = "";
  LatLng currentLocation = LatLng(21.051873, 105.777787);
  List<Marker> markers = [];
  final mapController = MapController();
  final popupController = PopupController();
  late final AnimatedMapController animatedMapController;
  bool snapDrag = false;
  String routeSelected = "";

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
    if (lastKnown != null && mounted) _updateLocation(lastKnown);

    await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.high,
            timeLimit: Duration(seconds: 5),
          ),
        )
        .then((pos) {
          if (mounted) _updateLocation(pos);
        })
        .catchError((e) {
          showToast(e.toString(), ToastificationType.error);
        });
  }

  void _updateLocation(Position pos) {
    setState(() {
      currentLocation = LatLng(pos.latitude, pos.longitude);
      markers = [
        Marker(
          point: currentLocation,
          width: 50,
          height: 50,
          rotate: true,
          child: const Icon(Icons.location_on, color: Colors.blue, size: 20),
        ),
      ];
    });
    if (mapController.camera.nonRotatedSize.width > 0) {
      animatedMapController.animateTo(
        dest: currentLocation,
        zoom: 16,
        duration: const Duration(milliseconds: 1200),
        curve: Curves.easeInOutCubic,
      );
    } else {
      mapController.move(currentLocation, 16);
    }
    getAddress();
  }

  void pushToLookUp() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (context) => LookUpRouteScreen()));
  }

  void getAddress() async {
    MapService service = MapService();
    final response = await service.getAddress(
      currentLocation.longitude,
      currentLocation.latitude,
    );
    if (mounted) {
      setState(() {
        address = response;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    animatedMapController = AnimatedMapController(
      vsync: this,
      mapController: mapController,
    );
  }

  @override
  void dispose() {
    mapController.dispose();
    popupController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          FlutterMap(
            mapController: mapController,
            options: MapOptions(
              initialCenter: LatLng(21.0285, 105.8542),
              initialZoom: 12,
              minZoom: 8,
              maxZoom: 16,
              onMapReady: () {
                getCurrentLocation();
              },
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
              PopupMarkerLayer(
                options: PopupMarkerLayerOptions(
                  markers: markers,
                  popupController: popupController,
                  markerTapBehavior: MarkerTapBehavior.togglePopup(),
                ),
              ),
            ],
          ),
          Positioned(
            top: 50,
            left: 15,
            child: Image.asset(
              "assets/images/skysoft_logo_ok_h80.png",
              height: 35,
            ),
          ),
          Positioned.fill(
            child: IgnorePointer(
              child: Center(
                child: Icon(Icons.add, color: Colors.red, size: 24),
              ),
            ),
          ),
          Positioned(
            top: 90,
            left: 15,
            right: 15,
            child: Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [
                  BoxShadow(blurRadius: 10, color: Colors.black12),
                ],
              ),
              child: nearbyRoutes(),
            ),
          ),
          Positioned(
            right: 16,
            bottom: 160,
            child: FloatingActionButton.small(
              backgroundColor: Colors.white,
              onPressed: getCurrentLocation,
              child: Icon(Icons.my_location, color: Colors.blue),
            ),
          ),
          DraggableScrollableSheet(
            initialChildSize: 0.18,
            minChildSize: 0.18,
            maxChildSize: 0.90,
            snap: true,
            snapSizes: [0.18, 0.90],
            builder: (context, scrollController) {
              return Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                  boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 15)],
                ),
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(16),
                  children: [
                    Center(
                      child: Container(
                        width: 50,
                        height: 5,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade400,
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    ),
                    SizedBox(height: 16),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: const [
                          BoxShadow(blurRadius: 10, color: Colors.black12),
                        ],
                      ),
                      child: TextFormField(
                        decoration: InputDecoration(
                          hintText: "Tìm kiếm tuyến xe...",
                          prefixIcon: Icon(Icons.search),
                          contentPadding: EdgeInsets.symmetric(vertical: 12),
                          border: InputBorder.none,
                        ),
                        onTapOutside: (event) {
                          FocusManager.instance.primaryFocus?.unfocus();
                        },
                      ),
                    ),
                    SizedBox(height: 16),
                    Text(
                      "Vị trí hiện tại:",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 5),
                    Text(address, maxLines: 2, overflow: TextOverflow.ellipsis),
                    SizedBox(height: 20),
                    Text(
                      "Truy cập nhanh",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 20),
                    quickAccessFeature(),
                    SizedBox(height: 20),
                    Row(
                      children: [
                        const Expanded(
                          child: Text(
                            "Tính năng khác",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: () {},
                          child: const Text("Xem tất cả"),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    otherFeatures(),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget quickAccessFeature() {
    return Row(
      children: [
        buttonFeature(
          "Tra cứu",
          Icons.search_rounded,
          Color(0xFFE8F2FF),
          Colors.blue,
          onTap: pushToLookUp,
        ),
        SizedBox(width: 10),
        buttonFeature(
          "Trạm gần",
          Icons.location_on_rounded,
          Color(0xFFFFF4E5),
          Colors.orange,
          onTap: () {},
        ),
      ],
    );
  }

  Widget otherFeatures() {
    return Row(
      children: [
        buttonFeature(
          "Khảo sát\nhành khách",
          Icons.assignment,
          Colors.pink.shade50,
          Colors.pink,
          onTap: () {},
        ),
        SizedBox(width: 10),
        buttonFeature(
          "Đăng kí thẻ \n xe bus",
          Icons.local_activity,
          Colors.green.shade50,
          Colors.green,
          onTap: () {},
        ),
        SizedBox(width: 10),
        buttonFeature(
          'Tìm xe buýt',
          Icons.location_on,
          Colors.blue.shade50,
          Colors.blue,
          onTap: () {},
        ),
      ],
    );
  }

  Widget buttonFeature(
    String title,
    IconData icon,
    Color bgColor,
    Color iconColor, {
    required Function() onTap,
  }) {
    return Column(
      children: [
        CircleAvatar(
          backgroundColor: bgColor,
          radius: 24,
          child: IconButton(
            onPressed: onTap,
            icon: Icon(icon, color: iconColor, size: 25),
          ),
        ),
        SizedBox(height: 6),
        SizedBox(
          height: 32,
          child: Text(
            title,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 11,
              height: 1.2,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget nearbyRoutes() {
    final routes = [
      "Gia Lâm - Yên Nghĩa",
      "Bác Cổ - Yên Nghĩa",
      "Giáp Bát - Nhổn",
      "Mỹ Đình - Gia Lâm",
      "Mai Động - Mỹ Đình",
      "Ga Hà Nội - Nội Bài",
      "Long Biên - Tứ Hiệp",
      "Kim Mã - Bến xe Sơn Tây",
      "Cầu Giấy - Nội Bài",
      "Trần Khánh Dư - Nam Thăng Long",
    ];

    return Row(
      children: [
        Text(
          "Tuyến gần nhất:",
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
        ),
        SizedBox(width: 5),
        Expanded(
          child: SizedBox(
            height: 40,
            child: DropdownButtonFormField(
              isExpanded: true,
              isDense: true,
              style: TextStyle(fontSize: 12),
              menuMaxHeight: 200,
              decoration: InputDecoration(
                contentPadding: EdgeInsets.symmetric(
                  vertical: 0,
                  horizontal: 10,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10.0)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10.0)),
                  borderSide: BorderSide(color: Colors.grey.shade400),
                ),
              ),
              initialValue: routes.first,
              items: routes.map((e) {
                return DropdownMenuItem(
                  value: e,
                  child: Text(e, style: TextStyle(color: Colors.black)),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  routeSelected = value!;
                });
              },
            ),
          ),
        ),
      ],
    );
  }
}
