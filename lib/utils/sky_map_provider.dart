import 'dart:typed_data';

import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;

class SkyMapTileProvider implements TileProvider {
  final String baseUrl;

  SkyMapTileProvider({required this.baseUrl});

  @override
  Future<Tile> getTile(int x, int y, int? zoom) async {
    if (zoom == null) {
      return TileProvider.noTile;
    }

    try {
      final url = '$baseUrl/web_tile.jsp?c=$x&r=$y&z=$zoom';

      final response = await http.get(Uri.parse(url));

      if (response.statusCode != 200 || response.bodyBytes.isEmpty) {
        return TileProvider.noTile;
      }

      final Uint8List bytes = response.bodyBytes;

      return Tile(256, 256, bytes);
    } catch (_) {
      return TileProvider.noTile;
    }
  }
}
