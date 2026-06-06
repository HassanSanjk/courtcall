// repositories/map_repository.dart

abstract class MapRepository {
  Future<List<dynamic>> getNearbySessions({
    required double lat,
    required double lng,
  });
}