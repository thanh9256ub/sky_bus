import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart'
    show BitmapDescriptor;
import 'package:path_provider/path_provider.dart';

Future<Uint8List> resizeImage(Uint8List image, int width) async {
  ui.Codec codec = await ui.instantiateImageCodec(image, targetWidth: width);
  ui.FrameInfo fi = await codec.getNextFrame();
  return (await fi.image.toByteData(
    format: ui.ImageByteFormat.png,
  ))!.buffer.asUint8List();
}

/// Kích thước vùng vẽ icon (bằng với kích thước ảnh icon trong assets: 80x80).
const double kMarkerIconBox = 80.0;

/// Tỉ lệ vẽ, phải khớp với imagePixelRatio khi tạo BitmapDescriptor.bytes.
const double kMarkerScale = 3.0;

// ---------------------------------------------------------------------------
// Vehicle marker
// ---------------------------------------------------------------------------
//
// Mỗi xe được vẽ bằng HAI Marker chồng lên cùng 1 vị trí (position) thay vì
// một bitmap duy nhất:
//   1. "arrow" - mũi tên hướng di chuyển, xoay theo `Marker.rotation`.
//   2. "label" - biển số xe, KHÔNG xoay (rotation luôn = 0).
// Lý do: `Marker.rotation` xoay toàn bộ bitmap của marker đó, nên nếu vẽ icon
// + chữ chung 1 bitmap rồi set rotation thì chữ cũng bị xoay theo icon. Tách
// làm 2 marker độc lập giúp: mũi tên xoay bình thường, còn biển số luôn đứng
// thẳng và cố định ngay bên dưới icon dù xe quay hướng nào.
//
// Về hiệu năng: bitmap mũi tên chỉ phụ thuộc MÀU trạng thái xe (không phụ
// thuộc plate) nên được cache theo màu - chỉ có vài chục màu khác nhau dù có
// hàng trăm xe. Bitmap biển số cache theo plateNo, chỉ vẽ lại khi xe đổi biển
// số (gần như không đổi). Khi xe di chuyển/đổi hướng, ta chỉ cập nhật
// `position`/`rotation` của Marker, không tạo lại BitmapDescriptor nào.

/// Kích thước hộp vẽ mũi tên xe (đã tăng so với bản trước để icon to, rõ hơn
/// trên bản đồ). Dùng hằng số riêng, không dùng chung `kMarkerIconBox` để
/// không ảnh hưởng tới các icon khác (avatar, custom marker...) đang dùng
/// `kMarkerIconBox` = 80.
const double _kVehicleArrowBox = 110.0;

/// Điểm neo của icon mũi tên: luôn là tâm hộp vuông, xoay quanh chính nó.
const Offset kVehicleArrowAnchor = Offset(0.5, 0.5);

/// Khoảng cách (px, theo cùng đơn vị pixel thiết bị với `kMarkerScale`) từ vị
/// trí thực của xe tới điểm bắt đầu vẽ biển số bên dưới, để biển số không bị
/// mũi tên (khi xoay) đè lên.
const double _kVehicleLabelGapPx = 6.0 * kMarkerScale;
const double _kVehicleArrowHalfHeightPx = _kVehicleArrowBox * kMarkerScale / 2;

/// Bề rộng cố định của canvas biển số, không phụ thuộc độ dài chữ, để việc
/// tính anchor không phải làm lại theo từng biển số.
const double _kVehicleLabelWidth = 170.0;

TextPainter _markerTextPainter(
  String text,
  Color textColor, {
  double fontSize = 32,
  double maxWidth = _kVehicleLabelWidth - 8,
}) {
  TextSpan span = TextSpan(
    text: text,
    style: TextStyle(
      fontSize: fontSize,
      fontWeight: FontWeight.bold,
      color: textColor,
      shadows: const [
        Shadow(offset: Offset(-1.5, -1.5), color: Colors.white),
        Shadow(offset: Offset(1.5, -1.5), color: Colors.white),
        Shadow(offset: Offset(1.5, 1.5), color: Colors.white),
        Shadow(offset: Offset(-1.5, 1.5), color: Colors.white),
      ],
    ),
  );

  TextPainter tp = TextPainter(
    text: span,
    textAlign: TextAlign.center,
    textDirection: ui.TextDirection.ltr,
    maxLines: 1,
    ellipsis: '…',
  );
  tp.layout(maxWidth: maxWidth);

  return tp;
}

/// Vẽ 1 icon của font (Icons.xxx) căn giữa tại [center], tương đương widget Icon.
void _paintIcon(
  Canvas c,
  IconData icon,
  double size,
  Color color,
  Offset center,
) {
  TextPainter tp = TextPainter(
    text: TextSpan(
      text: String.fromCharCode(icon.codePoint),
      style: TextStyle(
        fontSize: size,
        fontFamily: icon.fontFamily,
        package: icon.fontPackage,
        color: color,
      ),
    ),
    textDirection: ui.TextDirection.ltr,
  );
  tp.layout();
  tp.paint(c, center - Offset(tp.width / 2, tp.height / 2));
}

Future<Uint8List> _finishRecording(
  ui.PictureRecorder recorder,
  int width,
  int height,
) async {
  final ui.Picture picture = recorder.endRecording();
  final ui.Image image = await picture.toImage(width, height);
  final ByteData? pngBytes = await image.toByteData(
    format: ui.ImageByteFormat.png,
  );
  return pngBytes!.buffer.asUint8List(
    pngBytes.offsetInBytes,
    pngBytes.lengthInBytes,
  );
}

/// Bitmap mũi tên xe, luôn vẽ hướng lên trên (0 độ) - hướng di chuyển thực tế
/// áp dụng sau, qua `Marker.rotation`, KHÔNG bake vào bitmap này.
/// Kích thước đã tăng lên so với bản cũ theo yêu cầu "to hơn chút".
Future<Uint8List> _createVehicleArrowBitmap(Color vehicleColor) async {
  final double box = _kVehicleArrowBox * kMarkerScale;
  final ui.PictureRecorder recorder = ui.PictureRecorder();
  final Canvas canvas = Canvas(recorder);
  final Offset center = Offset(box / 2, box / 2);

  _paintIcon(canvas, Icons.navigation, 34 * kMarkerScale, Colors.black, center);
  _paintIcon(canvas, Icons.navigation, 28 * kMarkerScale, vehicleColor, center);

  return _finishRecording(recorder, box.toInt(), box.toInt());
}

/// Bitmap biển số xe: có khoảng đệm trong suốt phía trên để khi ghép anchor,
/// chữ luôn nằm cố định NGAY BÊN DƯỚI mũi tên (không đè lên mũi tên dù mũi
/// tên đang xoay hướng nào), và bản thân marker này không bao giờ xoay.
Future<_PlateBitmap> _createVehiclePlateBitmap(
  String plateNo, {
  Color textColor = Colors.black,
}) async {
  final double canvasWidth = _kVehicleLabelWidth * kMarkerScale;
  final TextPainter tp = _markerTextPainter(
    plateNo,
    textColor,
    maxWidth: canvasWidth - 8 * kMarkerScale,
  );

  // paddingTop = nửa chiều cao mũi tên + khoảng hở mong muốn, để điểm neo
  // (vị trí thực của xe) rơi đúng vào đây, và chữ bắt đầu vẽ ngay bên dưới.
  final double paddingTop = _kVehicleArrowHalfHeightPx + _kVehicleLabelGapPx;
  final double canvasHeight = paddingTop + tp.height + 4 * kMarkerScale;

  final ui.PictureRecorder recorder = ui.PictureRecorder();
  final Canvas canvas = Canvas(recorder);
  tp.paint(canvas, Offset((canvasWidth - tp.width) / 2, paddingTop));

  final Uint8List bytes = await _finishRecording(
    recorder,
    canvasWidth.toInt(),
    canvasHeight.toInt(),
  );

  // Anchor: điểm x luôn ở giữa; điểm y = paddingTop/canvasHeight, tức là vị
  // trí thực của xe nằm ngay tại mép trên vùng chữ (phần padding trong suốt
  // phía trên không hiển thị gì).
  final Offset anchor = Offset(0.5, 0.5);
  return _PlateBitmap(bytes, anchor);
}

class _PlateBitmap {
  final Uint8List bytes;
  final Offset anchor;
  _PlateBitmap(this.bytes, this.anchor);
}

/// Cache bitmap mũi tên theo MÀU trạng thái xe (không phụ thuộc biển số).
/// Vì số màu trạng thái hữu hạn (chạy/nổ máy/tắt máy...), cache này chỉ có
/// vài entry dù có hàng trăm xe -> gần như không bao giờ phải vẽ lại canvas.
class VehicleArrowCache {
  VehicleArrowCache._();
  static final VehicleArrowCache instance = VehicleArrowCache._();

  final Map<int, BitmapDescriptor> _cache = {};

  Future<BitmapDescriptor> getIcon(Color vehicleColor) async {
    final int key = vehicleColor.toARGB32();
    final BitmapDescriptor? cached = _cache[key];
    if (cached != null) return cached;

    final Uint8List bytes = await _createVehicleArrowBitmap(vehicleColor);
    final BitmapDescriptor descriptor = BitmapDescriptor.bytes(
      bytes,
      imagePixelRatio: kMarkerScale,
    );
    _cache[key] = descriptor;
    return descriptor;
  }

  void clear() => _cache.clear();
}

/// Cache bitmap biển số theo plateNo - mỗi xe chỉ vẽ chữ MỘT LẦN, những lần
/// cập nhật vị trí sau chỉ cần đổi `position` của Marker (rotation luôn = 0).
class VehiclePlateCache {
  VehiclePlateCache._();
  static final VehiclePlateCache instance = VehiclePlateCache._();

  final Map<String, CachedVehiclePlate> _cache = {};

  Future<CachedVehiclePlate> getIcon(
    String plateNo, {
    Color textColor = Colors.black,
  }) async {
    final CachedVehiclePlate? cached = _cache[plateNo];
    if (cached != null) return cached;

    final _PlateBitmap plate = await _createVehiclePlateBitmap(
      plateNo,
      textColor: textColor,
    );
    final BitmapDescriptor descriptor = BitmapDescriptor.bytes(
      plate.bytes,
      imagePixelRatio: kMarkerScale,
    );
    final CachedVehiclePlate result = CachedVehiclePlate(
      descriptor,
      plate.anchor,
    );
    _cache[plateNo] = result;
    return result;
  }

  /// Gọi khi danh sách xe "gần" thay đổi hẳn để tránh cache phình to vô hạn
  /// với những biển số không còn xuất hiện nữa.
  void evictExcept(Iterable<String> plateNosStillVisible) {
    final Set<String> keep = plateNosStillVisible.toSet();
    _cache.removeWhere((key, _) => !keep.contains(key));
  }

  void clear() => _cache.clear();
}

class CachedVehiclePlate {
  final BitmapDescriptor descriptor;
  final Offset anchor;
  CachedVehiclePlate(this.descriptor, this.anchor);
}

// ---------------------------------------------------------------------------
// Bus-stop (place) marker
// ---------------------------------------------------------------------------
//
// Icon điểm dừng chỉ phụ thuộc vào (màu tuyến, có đang được chọn hay không),
// KHÔNG phụ thuộc vào tên điểm dừng -> số lượng bitmap khác nhau thực tế rất
// nhỏ (bằng số màu tuyến x 2) dù backend trả về hàng trăm điểm dừng thuộc
// hàng chục tuyến xe. Mô tả điểm dừng được hiển thị qua `InfoWindow` khi
// người dùng bấm vào marker, thay vì vẽ chữ trực tiếp lên bitmap, để tránh
// phải tạo một bitmap riêng cho từng điểm dừng.

class PlaceIconCache {
  PlaceIconCache._();
  static final PlaceIconCache instance = PlaceIconCache._();

  final Map<String, CachedPlaceIcon> _cache = {};

  Future<CachedPlaceIcon> getIcon({
    required Color lineColor,
    required bool selected,
    required String description,
    required bool showLabel,
  }) async {
    final String key = showLabel
        ? '${lineColor.toARGB32()}_${selected}_label_$description'
        : '${lineColor.toARGB32()}_${selected}_nolabel';

    final CachedPlaceIcon? cached = _cache[key];
    if (cached != null) return cached;

    final CachedPlaceIcon result = showLabel
        ? await _createPlaceMarkerWithLabel(
            lineColor: lineColor,
            selected: selected,
            description: description,
          )
        : await _createPlaceMarkerIconOnly(
            lineColor: lineColor,
            selected: selected,
          );

    _cache[key] = result;
    return result;
  }

  void clear() => _cache.clear();
}

class CachedPlaceIcon {
  final BitmapDescriptor descriptor;
  final Offset anchor;
  CachedPlaceIcon(this.descriptor, this.anchor);
}

const double _kPlaceIconSize = 34.0;
const double _kPlaceLabelMaxWidth = 150.0;
const double _kPlaceLabelGapPx = 4.0 * kMarkerScale;

/// Vẽ vòng tròn màu tuyến + icon xe buýt, không có chữ. Dùng khi zoom xa
/// hoặc khi nhãn bị đè bởi điểm khác gần đó.
Future<CachedPlaceIcon> _createPlaceMarkerIconOnly({
  required Color lineColor,
  required bool selected,
}) async {
  final double size = _kPlaceIconSize * kMarkerScale;
  final double padding = 3.0 * kMarkerScale;
  final double radius = size / 2;

  final ui.PictureRecorder recorder = ui.PictureRecorder();
  final Canvas canvas = Canvas(recorder);
  final Offset center = Offset(radius, radius);

  final Paint fillPaint = Paint()
    ..color = selected ? lineColor : Colors.white
    ..style = PaintingStyle.fill;
  final Paint borderPaint = Paint()
    ..color = lineColor
    ..style = PaintingStyle.stroke
    ..strokeWidth = 2.0 * kMarkerScale;

  canvas.drawShadow(
    Path()..addOval(Rect.fromCircle(center: center, radius: radius - 1)),
    Colors.black,
    2.0,
    false,
  );
  canvas.drawCircle(center, radius - padding / 2, fillPaint);
  canvas.drawCircle(center, radius - padding / 2, borderPaint);
  _paintIcon(
    canvas,
    Icons.directions_bus,
    18 * kMarkerScale,
    selected ? Colors.white : lineColor,
    center,
  );

  final Uint8List bytes = await _finishRecording(
    recorder,
    size.toInt(),
    size.toInt(),
  );
  final BitmapDescriptor descriptor = BitmapDescriptor.bytes(
    bytes,
    imagePixelRatio: kMarkerScale,
  );
  return CachedPlaceIcon(descriptor, const Offset(0.5, 0.5));
}

/// Vẽ chữ tên điểm dừng ở trên, icon tròn ở dưới.
Future<CachedPlaceIcon> _createPlaceMarkerWithLabel({
  required Color lineColor,
  required bool selected,
  required String description,
}) async {
  final double iconSize = _kPlaceIconSize * kMarkerScale;
  final double iconPadding = 3.0 * kMarkerScale;
  final double iconRadius = iconSize / 2;

  final TextSpan span = TextSpan(
    text: description,
    style: TextStyle(
      fontSize: 35,
      fontWeight: FontWeight.w600,
      color: selected ? lineColor : Colors.black87,
      shadows: const [
        Shadow(offset: Offset(-1, -1), color: Colors.white),
        Shadow(offset: Offset(1, -1), color: Colors.white),
        Shadow(offset: Offset(1, 1), color: Colors.white),
        Shadow(offset: Offset(-1, 1), color: Colors.white),
      ],
    ),
  );
  final TextPainter tp = TextPainter(
    text: span,
    textAlign: TextAlign.center,
    textDirection: ui.TextDirection.ltr,
    maxLines: 2,
    ellipsis: '…',
  );
  tp.layout(maxWidth: _kPlaceLabelMaxWidth * kMarkerScale);

  final double canvasWidth =
      (tp.width > iconSize ? tp.width : iconSize) + 8 * kMarkerScale;
  final double canvasHeight =
      tp.height + _kPlaceLabelGapPx + iconSize + 4 * kMarkerScale;

  final ui.PictureRecorder recorder = ui.PictureRecorder();
  final Canvas canvas = Canvas(recorder);

  tp.paint(canvas, Offset((canvasWidth - tp.width) / 2, 0));

  final double iconCenterY = tp.height + _kPlaceLabelGapPx + iconRadius;
  final Offset iconCenter = Offset(canvasWidth / 2, iconCenterY);

  final Paint fillPaint = Paint()
    ..color = selected ? lineColor : Colors.white
    ..style = PaintingStyle.fill;
  final Paint borderPaint = Paint()
    ..color = lineColor
    ..style = PaintingStyle.stroke
    ..strokeWidth = 2.0 * kMarkerScale;

  canvas.drawShadow(
    Path()
      ..addOval(Rect.fromCircle(center: iconCenter, radius: iconRadius - 1)),
    Colors.black,
    2.0,
    false,
  );
  canvas.drawCircle(iconCenter, iconRadius - iconPadding / 2, fillPaint);
  canvas.drawCircle(iconCenter, iconRadius - iconPadding / 2, borderPaint);
  _paintIcon(
    canvas,
    Icons.directions_bus,
    18 * kMarkerScale,
    selected ? Colors.white : lineColor,
    iconCenter,
  );

  final Uint8List bytes = await _finishRecording(
    recorder,
    canvasWidth.toInt(),
    canvasHeight.toInt(),
  );
  final BitmapDescriptor descriptor = BitmapDescriptor.bytes(
    bytes,
    imagePixelRatio: kMarkerScale,
  );

  return CachedPlaceIcon(descriptor, Offset(0.5, iconCenterY / canvasHeight));
}
// ---------------------------------------------------------------------------
// Các hàm khác giữ nguyên như bản gốc
// ---------------------------------------------------------------------------

Future<Uint8List> createCustomMarkerBitmap(
  Uint8List bytes,
  String text,
  Color textColor,
) async {
  ui.PictureRecorder recorder = ui.PictureRecorder();
  Canvas c = Canvas(recorder);

  final Paint paint = Paint()
    ..color = Colors.red
    ..strokeWidth = 2.0
    ..strokeCap = StrokeCap.butt
    ..style = PaintingStyle.stroke;

  final Completer<ui.Image> completer = Completer();
  ui.decodeImageFromList(bytes, (ui.Image img) {
    return completer.complete(img);
  });
  ui.Image image = await completer.future;

  c.drawImage(image, Offset.zero, paint);

  TextPainter tp = _markerTextPainter(text, textColor);
  tp.paint(c, const Offset(95.0, 20.0));

  return _finishRecording(
    recorder,
    tp.width.toInt() + 150,
    tp.height.toInt() + 60,
  );
}

Future<Uint8List> textToImage(String text, double fontSize) async {
  ui.PictureRecorder recorder = ui.PictureRecorder();
  Canvas c = Canvas(recorder);

  TextSpan span = TextSpan(
    text: text,
    style: TextStyle(
      color: Colors.black,
      fontSize: fontSize,
      fontWeight: ui.FontWeight.bold,
    ),
  );
  TextPainter tp = TextPainter(
    text: span,
    textAlign: TextAlign.left,
    textDirection: ui.TextDirection.ltr,
  );
  tp.layout();
  tp.paint(c, const Offset(0.0, 20.0));

  return _finishRecording(recorder, tp.width.toInt(), tp.height.toInt() + 20);
}

Future<void> saveParkingPhotoToCache(int parkingID, Uint8List? result) async {
  final Directory temp = await getTemporaryDirectory();
  final File imageFile = File('${temp.path}/images/parkings/$parkingID.png');

  if (await imageFile.exists()) {
    await imageFile.delete();
  }

  await imageFile.create(recursive: true);

  if (result != null) {
    await imageFile.writeAsBytes(result);
  }
}

Future<void> deleteParkingPhotoFromCache(int parkingID) async {
  final Directory temp = await getTemporaryDirectory();
  final File imageFile = File('${temp.path}/images/parkings/$parkingID.png');

  if (await imageFile.exists()) {
    await imageFile.delete();
  }
}
