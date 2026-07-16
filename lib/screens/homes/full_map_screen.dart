import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_animations/flutter_map_animations.dart';
import 'package:flutter_map_marker_popup/flutter_map_marker_popup.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:toastification/toastification.dart';

import '../../models/bus_line_model.dart';
import '../../service/map_service.dart';
import '../../utils/global.dart';

class FullMapScreen extends StatefulWidget {
  final BusLine? selectedBusLine;
  final List<Marker>? pointMarkers;
  const FullMapScreen({
    super.key,
    required this.selectedBusLine,
    required this.pointMarkers,
  });

  @override
  State<FullMapScreen> createState() => _FullMapScreenState();
}

class _FullMapScreenState extends State<FullMapScreen>
    with TickerProviderStateMixin {
  String address = "";
  LatLng currentLocation = LatLng(21.051873, 105.777787);
  List<Marker> markers = [];
  final mapController = MapController();
  final popupController = PopupController();
  late final AnimatedMapController animatedMapController;

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
    setState(() {
      currentLocation = LatLng(pos.latitude, pos.longitude);
      markers = [
        Marker(
          point: currentLocation,
          width: 50,
          height: 50,
          rotate: true,
          child: Icon(Icons.location_on, color: Colors.blue, size: 20),
        ),
      ];
    });
    if (mapController.camera.nonRotatedSize.width > 0) {
      animatedMapController.animateTo(
        dest: currentLocation,
        zoom: 16,
        duration: Duration(milliseconds: 1200),
        curve: Curves.easeInOutCubic,
      );
    } else {
      mapController.move(currentLocation, 16);
    }
    getAddress();
  }

  @override
  void initState() {
    super.initState();
    animatedMapController = AnimatedMapController(
      mapController: mapController,
      vsync: this,
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
      body: Stack(
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
              if (widget.selectedBusLine != null)
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: widget.selectedBusLine!.wayPoints
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
              if (widget.selectedBusLine != null)
                MarkerLayer(markers: widget.pointMarkers!),
            ],
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: FloatingActionButton.small(
                backgroundColor: Colors.white,
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Icon(Icons.close),
              ),
            ),
          ),
          Positioned(
            right: 20,
            top: 46,
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
}
