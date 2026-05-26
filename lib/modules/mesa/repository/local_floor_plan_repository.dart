import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:my_app_teste/modules/mesa/model/restaurant_models.dart';

class LocalFloorPlanRepository {
  static const _storageKey = 'gulapay_floor_plan_v1';

  Future<FloorPlanSnapshot?> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storageKey);
    if (raw == null || raw.isEmpty) {
      return null;
    }

    final map = jsonDecode(raw) as Map<String, dynamic>;
    return FloorPlanSnapshot.fromMap(map);
  }

  Future<bool> save(FloorPlanSnapshot snapshot) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.setString(_storageKey, jsonEncode(snapshot.toMap()));
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_storageKey);
  }

  FloorPlanSnapshot buildSeedData() {
    final now = DateTime.now();

    return FloorPlanSnapshot(
      selectedAreaId: 'salao',
      areas: [
        RestaurantArea(
          id: 'salao',
          name: 'Salao interno',
          type: 'interno',
          tables: [
            RestaurantTable(
              id: 'm1',
              code: 'Mesa 01',
              areaId: 'salao',
              x: 44,
              y: 48,
              width: 116,
              height: 86,
              shape: TableShape.rectangular,
              chairsCount: 6,
              status: TableStatus.withOrder,
              isJoined: false,
              activeOrderId: 'ORD-1001',
              lastOrderAt: now.subtract(const Duration(minutes: 12)),
              seatedPeople: 4,
              customerName: 'Marina',
              orderItemsCount: 8,
              partialTotal: 186.40,
            ),
            RestaurantTable(
              id: 'm2',
              code: 'Mesa 02',
              areaId: 'salao',
              x: 236,
              y: 58,
              width: 88,
              height: 88,
              shape: TableShape.round,
              chairsCount: 4,
              status: TableStatus.occupied,
              isJoined: false,
              lastOrderAt: now.subtract(const Duration(minutes: 38)),
              seatedPeople: 3,
            ),
            RestaurantTable(
              id: 'm3',
              code: 'Mesa 03',
              areaId: 'salao',
              x: 404,
              y: 182,
              width: 120,
              height: 74,
              shape: TableShape.oval,
              chairsCount: 6,
              status: TableStatus.free,
              isJoined: false,
            ),
          ],
        ),
        RestaurantArea(
          id: 'varanda',
          name: 'Varanda',
          type: 'externo',
          tables: [
            RestaurantTable(
              id: 'm4',
              code: 'Mesa 04',
              areaId: 'varanda',
              x: 70,
              y: 88,
              width: 86,
              height: 86,
              shape: TableShape.square,
              chairsCount: 4,
              status: TableStatus.free,
              isJoined: false,
            ),
            RestaurantTable(
              id: 'm5',
              code: 'Mesa 05',
              areaId: 'varanda',
              x: 242,
              y: 164,
              width: 120,
              height: 74,
              shape: TableShape.rectangular,
              chairsCount: 6,
              status: TableStatus.occupied,
              isJoined: false,
              lastOrderAt: now.subtract(const Duration(hours: 1, minutes: 10)),
              seatedPeople: 5,
            ),
          ],
        ),
        RestaurantArea(
          id: 'vip',
          name: 'Area VIP',
          type: 'premium',
          tables: [
            RestaurantTable(
              id: 'm6',
              code: 'Mesa 06',
              areaId: 'vip',
              x: 118,
              y: 96,
              width: 132,
              height: 80,
              shape: TableShape.oval,
              chairsCount: 6,
              status: TableStatus.free,
              isJoined: false,
            ),
            RestaurantTable(
              id: 'm7',
              code: 'Mesa 07',
              areaId: 'vip',
              x: 308,
              y: 98,
              width: 132,
              height: 80,
              shape: TableShape.oval,
              chairsCount: 6,
              status: TableStatus.free,
              isJoined: false,
            ),
          ],
        ),
      ],
    );
  }
}
