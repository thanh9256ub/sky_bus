import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_animations/flutter_map_animations.dart';
import 'package:flutter_map_marker_popup/flutter_map_marker_popup.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:skysoft_bus/service/map_service.dart';

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

  void getCurrentLocation() async {
    var permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      permission = await Geolocator.requestPermission();

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return;
      }
    }
    final pos = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.best),
    );
    if (!mounted) return;
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
    animatedMapController.animateTo(
      dest: currentLocation,
      zoom: 16,
      duration: const Duration(milliseconds: 1200),
      curve: Curves.easeInOutCubic,
    );
    getAddress();
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
    getCurrentLocation();
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
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 10),
          child: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.2,
                    child: Image(
                      image: AssetImage('assets/images/anh_nen.png'),
                      width: double.infinity,
                      fit: BoxFit.fitWidth,
                    ),
                  ),
                  SizedBox(
                    height: 300,
                    child: Stack(
                      children: [
                        FlutterMap(
                          mapController: mapController,
                          options: MapOptions(
                            initialCenter: const LatLng(21.0285, 105.8542),
                            initialZoom: 13,
                          ),
                          children: [
                            TileLayer(
                              urlTemplate:
                                  '$skymapUrl/web_tile.jsp?c={x}&r={y}&z={z}',
                              userAgentPackageName: 'com.skysoft.sks_web',
                            ),
                            PopupMarkerLayer(
                              options: PopupMarkerLayerOptions(
                                markers: markers,
                                popupController: popupController,
                                markerTapBehavior:
                                    MarkerTapBehavior.togglePopup(),
                                popupDisplayOptions: PopupDisplayOptions(
                                  builder: (context, marker) {
                                    return Card(
                                      child: Padding(
                                        padding: const EdgeInsets.all(12),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            const Text(
                                              "Vị trí hiện tại",
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            Text(address),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                        Positioned(
                          right: 16,
                          bottom: 10,
                          child: CircleAvatar(
                            backgroundColor: Colors.white,
                            child: IconButton(
                              icon: Icon(Icons.my_location),
                              onPressed: getCurrentLocation,
                            ),
                          ),
                        ),
                        Positioned(
                          left: 16,
                          right: 16,
                          bottom: 10,
                          child: Row(
                            children: [
                              Icon(
                                Icons.location_on,
                                size: 20,
                                color: Colors.teal,
                              ),
                              SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  address,
                                  maxLines: 1,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 10),
                  nearbyRoutes(),
                  SizedBox(height: 10),
                  Row(
                    children: [
                      buttonWidget("Tra cứu", Icons.map, onTap: () {}),
                      buttonWidget(
                        "Tìm đường",
                        Icons.route_outlined,
                        onTap: () {},
                      ),
                      buttonWidget(
                        "Trạm xung\nquanh",
                        Icons.location_on_outlined,
                        onTap: () {},
                      ),
                      buttonWidget("Góp ý", Icons.thumb_up, onTap: () {}),
                    ],
                  ),
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
                      TextButton(
                        onPressed: () {},
                        child: Text(
                          "Xem tất cả",
                          style: TextStyle(color: Colors.blue.shade500),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 5),
                  otherFeatures(),
                ],
              ),
              Positioned(
                top: MediaQuery.of(context).size.height * 0.2 - 25,
                left: 15,
                right: 15,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 5),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 8,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Tìm kiếm tuyến, trạm xe buýt...',
                      prefixIcon: Icon(Icons.search),
                      contentPadding: EdgeInsets.symmetric(vertical: 12),
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 10,
                left: 10,
                child: SafeArea(
                  child: Image(
                    image: AssetImage("assets/images/skysoft_logo_ok_h80.png"),
                    height: 45,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget otherFeatures() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 10),
      child: Row(
        children: [
          buttonFeature(
            "Khảo sát\nhành khách",
            Colors.pink.shade50,
            icon: Icon(Icons.assignment, color: Colors.pink, size: 26),
            onPressed: () {},
          ),
          SizedBox(width: 10),
          buttonFeature(
            "Đăng kí thẻ \n xe bus",
            Colors.green.shade50,
            icon: Icon(Icons.local_activity, color: Colors.green, size: 26),
            onPressed: () {},
          ),
          SizedBox(width: 10),
          buttonFeature(
            'Tìm xe buýt',
            Colors.blue.shade50,
            icon: Icon(Icons.location_on, color: Colors.blue, size: 26),
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  Widget buttonWidget(
    String title,
    IconData icon, {
    required Function() onTap,
  }) {
    return Expanded(
      child: Column(
        children: [
          InkWell(
            onTap: onTap,
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.blue.shade200,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: Colors.white, size: 35),
            ),
          ),
          SizedBox(height: 10),
          SizedBox(
            height: 30,
            child: Text(
              title,
              textAlign: TextAlign.center,
              maxLines: 2,
              style: const TextStyle(fontSize: 11, height: 1.2),
            ),
          ),
        ],
      ),
    );
  }

  Widget buttonFeature(
    String title,
    Color backgroundColor, {
    required Icon icon,
    required Function() onPressed,
  }) {
    return Column(
      children: [
        CircleAvatar(
          backgroundColor: backgroundColor,
          radius: 24,
          child: IconButton(onPressed: onPressed, icon: icon),
        ),
        SizedBox(height: 6),
        SizedBox(
          height: 32,
          child: Text(
            title,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 11, height: 1.2),
          ),
        ),
      ],
    );
  }

  Widget nearbyRoutes() {
    final List<Map<String, dynamic>> nearbyRoutes = [
      {
        'route': 'Bus 32',
        'destination': 'Bến xe Mỹ Đình',
        'time': '3 phút',
        'distance': '150m',
      },
      {
        'route': 'Bus 09',
        'destination': 'Bờ Hồ - Cầu Giấy',
        'time': '7 phút',
        'distance': '240m',
      },
      {
        'route': 'Bus 22A',
        'destination': 'KĐT Trung Văn',
        'time': '12 phút',
        'distance': '350m',
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          child: Text(
            "Tuyến xe gần bạn nhất",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ),
        SizedBox(
          height: 120,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: nearbyRoutes.length,
            itemBuilder: (context, index) {
              final item = nearbyRoutes[index];
              return Container(
                margin: const EdgeInsets.only(right: 12),
                width: 200,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black,
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.teal.shade300,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            item['route'],
                            style: const TextStyle(
                              color: Colors.teal,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ),
                        Text(
                          item['time'],
                          style: const TextStyle(
                            color: Colors.redAccent,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Hướng: ${item['destination']}",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      "Cách đây: ${item['distance']}",
                      style: const TextStyle(fontSize: 11, color: Colors.grey),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
