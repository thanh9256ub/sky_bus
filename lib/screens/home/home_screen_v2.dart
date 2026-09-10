import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:latlong2/latlong.dart' as latlong;
import 'package:skysoft_bus/screens/home/busline_list_screen.dart';
import 'package:toastification/toastification.dart';

import '../../models/bus_line_model.dart';
import '../../models/vehicle_model.dart';
import '../../service/bus_service.dart';
import '../../utils/fields.dart';
import '../../utils/global.dart';
import '../../utils/image_utils.dart';
import '../../utils/map_helper.dart';
import '../../utils/sky_map_provider.dart';
import '../widgets/ticket_buy_dialog.dart';

class HomeScreenV2 extends StatefulWidget {
  const HomeScreenV2({super.key});

  @override
  State<HomeScreenV2> createState() => _HomeScreenV2State();
}

class _SkymapTileProvider implements TileProvider {
  static const int width = 256;
  static const int height = 256;

  @override
  Future<Tile> getTile(int x, int y, int? zoom) async {
    String url = "$skymapUrl/web_tile.jsp?c=$x&r=$y&z=$zoom";

    // String url = "https://tile.openstreetmap.org/$zoom/$x/$y.png";

    try {
      Uint8List byteData = (await NetworkAssetBundle(
        Uri.parse(url),
      ).load(url)).buffer.asUint8List();
      return Tile(width, height, byteData);
    } catch (e) {
      return Tile(width, height, null);
    }
  }
}

class _HomeScreenV2State extends State<HomeScreenV2>
    with AutomaticKeepAliveClientMixin, RouteAware {
  @override
  bool get wantKeepAlive => true;
  var _maptype = MapType.none;
  LatLng currentLocation = const LatLng(21.051873, 105.777787);
  double currentZoom = 16;
  static const double _kPlaceLabelMinZoom = 12;
  GoogleMapController? mapController;
  final searchController = TextEditingController();
  final sheetController = DraggableScrollableController();
  final _focusNode = FocusNode();
  late final SkyMapTileProvider skyMapTileProvider;
  TileOverlay? _tileOverlay;
  BusLine? selectedBusLine;
  List<BusLine> busLines = [];
  List<Vehicle> nearVehicles = [];
  List<int> selectedPlaceIds = [];

  Timer? vehicleTimer;
  Timer? moveDebounce;
  bool skipNextPopClear = false;

  Set<Marker> placeMarkers = {};
  Set<Marker> vehicleMarkers = {};
  Marker? currentLocationMarker;

  Set<Marker> get _allMarkers => {
    ...placeMarkers,
    ...vehicleMarkers,
    ?currentLocationMarker,
  };

  void getCurrentLocation() async {
    final location = await MapHelper.getCurrentLocation();
    if (location == null) {
      showToast("Không thể lấy vị trí hiện tại", ToastificationType.error);
      return;
    }
    setState(() {
      currentLocation = LatLng(location.latitude, location.longitude);
      currentLocationMarker = Marker(
        markerId: const MarkerId('current_location'),
        position: currentLocation,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
        anchor: const Offset(0.5, 0.5),
      );
    });
    mapController?.animateCamera(
      CameraUpdate.newLatLngZoom(currentLocation, 16),
    );
  }

  void openBusLineListScreen() async {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => BusLineListScreen(
          busLines: busLines,
          selectedBusLine: selectedBusLine,
          onChanged: (value) {
            skipNextPopClear = true;
            selectLine(value);
          },
        ),
      ),
    );
  }

  void clearSelectedBusLine() async {
    setState(() {
      selectedBusLine = null;
      selectedPlaceIds = [];
    });
    rebuildPlaceMarkers();
  }

  void togglePlace(int placeId) {
    setState(() {
      if (selectedPlaceIds.contains(placeId)) {
        selectedPlaceIds.remove(placeId);
      } else if (selectedPlaceIds.length < 2) {
        selectedPlaceIds.add(placeId);
      } else {
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
        if (newIndex != null && firstIndex != null && secondIndex != null) {
          final distanceToFirst = (newIndex - firstIndex).abs();
          final distanceToSecond = (newIndex - secondIndex).abs();
          if (distanceToFirst <= distanceToSecond) {
            selectedPlaceIds[0] = placeId;
          } else {
            selectedPlaceIds[1] = placeId;
          }
        }
      }
    });
    rebuildPlaceMarkers();
  }

  void showDialogTicket(Matrix? matrix) async {
    if (matrix == null) {
      showToast("Không tìm thấy giá vé", ToastificationType.error);
      return;
    }
    if (selectedPlaceIds.length == 2) {
      await showDialog(
        context: context,
        builder: (context) {
          return TicketBuyDialog(
            selectedLine: selectedBusLine!,
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
    }
  }

  void selectLine(BusLine busLine, {LatLng? focusPoint}) async {
    setState(() {
      selectedBusLine = busLine;
      selectedPlaceIds = focusPoint == null
          ? []
          : (busLine.placeMarks
                .where((p) => LatLng(p.y, p.x) == focusPoint)
                .map((p) => p.placeID)
                .toList());
    });
    rebuildPlaceMarkers();
    LatLng target = currentLocation;
    if (focusPoint != null) {
      target = focusPoint;
    } else if (busLine.startPoint != null) {
      target = LatLng(
        busLine.startPoint!.latitude,
        busLine.startPoint!.longitude,
      );
    } else if (busLine.placeMarks.isNotEmpty) {
      final first = busLine.placeMarks.first;
      target = LatLng(first.y, first.x);
    }

    mapController?.animateCamera(CameraUpdate.newLatLngZoom(target, 16));
  }

  void switchMap(MapType value) {
    if (mounted) {
      setState(() {
        _maptype = value;
        saveData(F_MAP_TYPE, value.name);
        if (value == MapType.none) {
          _addTileOverlay();
        } else {
          _removeTileOverlay();
        }
      });
    }
  }

  void _addTileOverlay() {
    final TileOverlay tileOverlay = TileOverlay(
      tileOverlayId: const TileOverlayId('skymap'),
      tileProvider: _SkymapTileProvider(),
      tileSize: 2048,
    );
    if (mounted) {
      setState(() {
        _tileOverlay = tileOverlay;
      });
    }
  }

  void _removeTileOverlay() {
    if (mounted) {
      setState(() {
        _tileOverlay = null;
      });
    }
  }

  void showPopupMenu(BuildContext context, TapDownDetails details) {
    showMenu<String>(
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      context: context,
      position: RelativeRect.fromLTRB(
        details.globalPosition.dx,
        details.globalPosition.dy - 210,
        details.globalPosition.dx,
        details.globalPosition.dy,
      ),
      items: [
        PopupMenuItem<String>(
          onTap: () => switchMap(MapType.none),
          child: Row(
            children: <Widget>[
              SizedBox(
                height: 32,
                child: Image.asset(
                  'assets/images/logo_32x32.png',
                  fit: BoxFit.fitHeight,
                ),
              ),
              SizedBox(width: 15.0),
              Text('Bản đồ Skymap'),
            ],
          ),
        ),
        PopupMenuItem<String>(
          onTap: () => switchMap(MapType.normal),
          child: Row(
            children: <Widget>[
              SizedBox(
                height: 32,
                child: Image.asset(
                  'assets/images/default_mapicon.png',
                  fit: BoxFit.fitHeight,
                ),
              ),
              SizedBox(width: 15.0),
              Text('Bản đồ google'),
            ],
          ),
        ),
        PopupMenuItem<String>(
          onTap: () => switchMap(MapType.hybrid),
          child: Row(
            children: <Widget>[
              SizedBox(
                height: 32,
                child: Image.asset(
                  'assets/images/hybrid_mapicon.png',
                  fit: BoxFit.fitHeight,
                ),
              ),
              SizedBox(width: 15.0),
              Text('Bản đồ vệ tinh'),
            ],
          ),
        ),
      ],
      elevation: 8.0,
    );
  }

  void searchNearBus() async {
    final BusService busService = BusService();
    final GoogleMapController? controller = mapController;
    if (controller == null) return;
    final LatLngBounds bounds = await controller.getVisibleRegion();
    final LatLng center = LatLng(
      (bounds.northeast.latitude + bounds.southwest.latitude) / 2,
      (bounds.northeast.longitude + bounds.southwest.longitude) / 2,
    );
    final response = await busService.searchNearVehicles(
      center.latitude,
      center.longitude,
    );
    if (!mounted) return;
    if (response.errorMessage.isEmpty) {
      nearVehicles = response.vehicles;
      await rebuildVehicleMarkers();
    } else {
      showToast(response.errorMessage, ToastificationType.error);
    }
  }

  void getListBusLine() async {
    final BusService busService = BusService();
    final response = await busService.listBusLines();
    if (response.errorMessage.isEmpty && mounted) {
      setState(() {
        busLines = response.busLines;
      });
      rebuildPlaceMarkers();
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
    return result.isEmpty ? null : result.first;
  }

  Future<void> rebuildVehicleMarkers() async {
    final List<Vehicle> vehicles = nearVehicles;
    final Set<Marker> markers = {};

    for (final Vehicle v in vehicles) {
      final LatLng position = LatLng(v.y, v.x);

      final BitmapDescriptor arrowIcon = await VehicleArrowCache.instance
          .getIcon(getVehicleColor(v));
      markers.add(
        Marker(
          markerId: MarkerId('vehicle_arrow_${v.plateNo}'),
          position: position,
          icon: arrowIcon,
          anchor: kVehicleArrowAnchor,
          rotation: v.direction.toDouble(),
          flat: true,
        ),
      );

      final CachedVehiclePlate plate = await VehiclePlateCache.instance.getIcon(
        v.plateNo,
      );
      markers.add(
        Marker(
          markerId: MarkerId('vehicle_label_${v.plateNo}'),
          position: position,
          icon: plate.descriptor,
          anchor: plate.anchor,
          rotation: 0,
          flat: true,
        ),
      );
    }

    VehiclePlateCache.instance.evictExcept(vehicles.map((v) => v.plateNo));

    if (!mounted) return;
    setState(() {
      vehicleMarkers = markers;
    });
  }

  Future<void> rebuildPlaceMarkers() async {
    final List<BusLine> linesToShow = selectedBusLine != null
        ? [selectedBusLine!]
        : busLines;

    final List<({BusLine line, Place place})> candidates = [
      for (final line in linesToShow)
        for (final place in line.placeMarks) (line: line, place: place),
    ];

    if (candidates.isEmpty) {
      if (!mounted) return;
      setState(() => placeMarkers = {});
      return;
    }

    // Điểm đang chọn ưu tiên giữ chữ trước.
    candidates.sort((a, b) {
      final aSelected = selectedPlaceIds.contains(a.place.placeID);
      final bSelected = selectedPlaceIds.contains(b.place.placeID);
      if (aSelected == bSelected) return 0;
      return aSelected ? -1 : 1;
    });

    final bool zoomAllowsLabel = currentZoom >= _kPlaceLabelMinZoom;
    final GoogleMapController? controller = mapController;
    final List<Rect> acceptedLabelRects = [];
    final Set<Marker> markers = {};

    for (final candidate in candidates) {
      final BusLine line = candidate.line;
      final place = candidate.place;
      final bool selected = selectedPlaceIds.contains(place.placeID);
      final Color lineColor = Color(line.color.toUnsigned(32));

      bool showLabel = false;
      if (zoomAllowsLabel && controller != null) {
        try {
          final ScreenCoordinate sc = await controller.getScreenCoordinate(
            LatLng(place.y, place.x),
          );
          final double approxWidth = (place.description.length * 7.0 + 20)
              .clamp(40, 150);
          final Rect labelRect = Rect.fromCenter(
            center: Offset(sc.x.toDouble(), sc.y.toDouble() - 24),
            width: approxWidth,
            height: 34,
          );
          if (!acceptedLabelRects.any((r) => r.overlaps(labelRect))) {
            showLabel = true;
            acceptedLabelRects.add(labelRect);
          }
        } catch (_) {
          // Điểm nằm ngoài vùng nhìn thấy hoặc controller chưa sẵn sàng.
          showLabel = false;
        }
      }

      final CachedPlaceIcon placeIcon = await PlaceIconCache.instance.getIcon(
        lineColor: lineColor,
        selected: selected,
        description: place.description,
        showLabel: showLabel,
      );

      markers.add(
        Marker(
          markerId: MarkerId('place_${line.hashCode}_${place.placeID}'),
          position: LatLng(place.y, place.x),
          icon: placeIcon.descriptor,
          anchor: placeIcon.anchor,
          onTap: () {
            if (selectedBusLine != line) {
              selectLine(line, focusPoint: LatLng(place.y, place.x));
              return;
            }
            togglePlace(place.placeID);
            mapController?.animateCamera(
              CameraUpdate.newLatLng(LatLng(place.y, place.x)),
            );
          },
        ),
      );
    }

    if (!mounted) return;
    setState(() {
      placeMarkers = markers;
    });
  }

  Set<Polyline> get _polylines {
    if (selectedBusLine == null || selectedBusLine!.wayPoints.length < 2) {
      return {};
    }
    return {
      Polyline(
        polylineId: PolylineId('line_${selectedBusLine!.hashCode}'),
        points: selectedBusLine!.wayPoints
            .map((e) => LatLng(e.latitude, e.longitude))
            .toList(),
        width: 4,
        color: Color(selectedBusLine!.color.toUnsigned(32)),
      ),
    };
  }

  @override
  void initState() {
    super.initState();
    skyMapTileProvider = SkyMapTileProvider(baseUrl: skymapUrl);
    vehicleTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      searchNearBus();
    });
    getCurrentLocation();
    getListBusLine();
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    vehicleTimer?.cancel();
    moveDebounce?.cancel();
    searchController.dispose();
    _focusNode.dispose();
    mapController?.dispose();
    VehicleArrowCache.instance.clear();
    VehiclePlateCache.instance.clear();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context) as PageRoute);
  }

  @override
  void didPopNext() {
    if (skipNextPopClear) {
      skipNextPopClear = false;
      return;
    }
    clearSelectedBusLine();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final Set<TileOverlay> overlays = <TileOverlay>{?_tileOverlay};
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          mapWidget(overlays),
          centerPointMap(),
          searchBusLine(),
          if (selectedBusLine != null) mainContent(),
        ],
      ),
    );
  }

  Widget centerPointMap() {
    return const Positioned.fill(
      child: IgnorePointer(
        child: Center(child: Icon(Icons.add, color: Colors.red, size: 18)),
      ),
    );
  }

  Widget mapWidget(Set<TileOverlay> overlays) {
    return Positioned.fill(
      child: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: currentLocation,
          zoom: 16,
        ),
        mapType: _maptype,
        tileOverlays: overlays,
        minMaxZoomPreference: const MinMaxZoomPreference(8, 18),
        myLocationButtonEnabled: false,
        myLocationEnabled: false,
        zoomControlsEnabled: false,
        rotateGesturesEnabled: false,
        markers: _allMarkers,
        polylines: _polylines,
        onMapCreated: (controller) {
          mapController = controller;
          rebuildPlaceMarkers();
        },
        onCameraMove: (position) {
          currentZoom = position.zoom;
        },
        onCameraIdle: () {
          rebuildPlaceMarkers();
          moveDebounce?.cancel();
          moveDebounce = Timer(
            const Duration(milliseconds: 1500),
            searchNearBus,
          );
        },
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
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(25),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              InkWell(
                onTap: openBusLineListScreen,
                child: Container(
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(25),
                    border: Border.all(color: Colors.grey.shade400),
                  ),
                  child: Row(
                    children: [
                      SizedBox(width: 16),
                      Container(
                        padding: EdgeInsets.all(6),
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
                            color: Colors.black,
                            fontWeight: FontWeight.normal,
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
              SizedBox(height: 10),
              GestureDetector(
                onTap: getCurrentLocation,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.grey.shade400),
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: const Icon(Icons.my_location, color: Colors.blue),
                ),
              ),
              SizedBox(height: 10),
              GestureDetector(
                onTapDown: (details) => showPopupMenu(context, details),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.grey.shade400),
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: const Icon(Icons.layers, color: Colors.green),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget mainContent() {
    final screenHeight = MediaQuery.of(context).size.height;
    final bottomInset = MediaQuery.of(context).padding.bottom;
    final maxSize = ((screenHeight - bottomInset) / screenHeight).clamp(
      0.5,
      0.95,
    );
    return DraggableScrollableSheet(
      controller: sheetController,
      initialChildSize: 0.32,
      minChildSize: 0.32,
      maxChildSize: maxSize,
      snap: true,
      snapSizes: const [0.32, 0.82],
      builder: (context, scrollController) {
        final matrixPrice = getSelectedMatrixPrice();
        return Container(
          padding: EdgeInsets.only(bottom: bottomInset),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 12)],
          ),
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
              buildListItem(scrollController),
              Visibility(
                visible: selectedPlaceIds.length == 2,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 6, 12, 10),
                  child: SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () => showDialogTicket(matrixPrice),
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
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.confirmation_number_outlined),
                          const SizedBox(width: 10),
                          const Text(
                            "Đặt vé",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (matrixPrice != null) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white12,
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Text(
                                "${moneyFormat.format(matrixPrice.price)},000đ",
                                style: const TextStyle(
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
        padding: const EdgeInsets.only(top: 0, bottom: 12, left: 16, right: 16),
        controller: scrollController,
        itemCount: selectedBusLine!.placeMarks.length,
        // Giữ nguyên identity của item widget theo placeID để Flutter có thể
        // tái sử dụng Element thay vì build lại toàn bộ hàng khi list scroll.
        itemBuilder: (context, index) {
          final place = selectedBusLine!.placeMarks[index];
          final isSelected = selectedPlaceIds.contains(place.placeID);
          final isFirst = index == 0;
          final isLast = index == selectedBusLine!.placeMarks.length - 1;
          final String distance = MapHelper.calculateDistance(
            latlong.LatLng(currentLocation.latitude, currentLocation.longitude),
            latlong.LatLng(place.y, place.x),
          ).toStringAsFixed(1);
          return IntrinsicHeight(
            key: ValueKey(place.placeID),
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
                    padding: const EdgeInsets.symmetric(vertical: 12),
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
                              mapController?.animateCamera(
                                CameraUpdate.newLatLng(
                                  LatLng(place.y, place.x),
                                ),
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
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                        ),
                        Transform.scale(
                          scale: 1.1,
                          child: Checkbox(
                            value: isSelected,
                            activeColor: secondaryColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4),
                            ),
                            onChanged: (value) => togglePlace(place.placeID),
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
