

abstract class MapRepository {
  Future<List<dynamic>> getNearbySessions({
    required double lat,
    required double lng,
  });
}