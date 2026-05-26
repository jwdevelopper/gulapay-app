import 'dart:math';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:my_app_teste/modules/mesa/model/restaurant_models.dart';
import 'package:my_app_teste/modules/mesa/repository/local_floor_plan_repository.dart';

class TableDraft {
  TableDraft({
    this.id,
    required this.code,
    required this.areaId,
    required this.shape,
    required this.chairsCount,
    required this.width,
    required this.height,
    this.seatedPeople,
  });

  final String? id;
  final String code;
  final String areaId;
  final TableShape shape;
  final int chairsCount;
  final double width;
  final double height;
  final int? seatedPeople;
}

class TableOrderOpenResult {
  TableOrderOpenResult({
    required this.orderId,
    required this.reusedExistingOrder,
    required this.tableIds,
  });

  final String orderId;
  final bool reusedExistingOrder;
  final List<String> tableIds;
}

class FloorPlanController extends ChangeNotifier {
  FloorPlanController({
    LocalFloorPlanRepository? repository,
  }) : _repository = repository ?? LocalFloorPlanRepository();

  final LocalFloorPlanRepository _repository;

  List<RestaurantArea> _areas = const [];
  String? _selectedAreaId;
  bool _isLoading = true;
  bool _isSaving = false;
  String? _movingTableId;
  String? _suggestedJoinTargetId;
  String? _lastActionError;
  String? _lastOpenedScopeId;
  DateTime? _lastOrderOpenAt;

  List<RestaurantArea> get areas => _areas;
  bool get isLoading => _isLoading;
  bool get isSaving => _isSaving;
  String? get lastActionError => _lastActionError;

  RestaurantArea? get selectedArea {
    if (_selectedAreaId == null) {
      return _areas.isEmpty ? null : _areas.first;
    }

    for (final area in _areas) {
      if (area.id == _selectedAreaId) {
        return area;
      }
    }
    return _areas.isEmpty ? null : _areas.first;
  }

  String? get movingTableId => _movingTableId;
  String? get suggestedJoinTargetId => _suggestedJoinTargetId;

  Future<void> load() async {
    _isLoading = true;
    notifyListeners();

    final snapshot = await _repository.load() ?? _repository.buildSeedData();
    _areas = snapshot.areas;
    _selectedAreaId = snapshot.selectedAreaId;
    _isLoading = false;
    notifyListeners();
  }

  Future<void> resetSeed() async {
    final snapshot = _repository.buildSeedData();
    _areas = snapshot.areas;
    _selectedAreaId = snapshot.selectedAreaId;
    await _persist();
    notifyListeners();
  }

  void selectArea(String areaId) {
    if (_selectedAreaId == areaId) {
      return;
    }

    _selectedAreaId = areaId;
    unselectJoinSuggestion();
    notifyListeners();
    _persist();
  }

  TableStatus resolveStatus(RestaurantTable table) {
    if (table.activeOrderId != null) {
      return TableStatus.withOrder;
    }

    if ((table.seatedPeople ?? 0) > 0) {
      if (table.lastOrderAt != null) {
        final elapsed = DateTime.now().difference(table.lastOrderAt!);
        if (elapsed >= const Duration(hours: 1)) {
          return TableStatus.awaitingRelease1H;
        }
        if (elapsed >= const Duration(minutes: 30)) {
          return TableStatus.noOrder30Min;
        }
      }

      return TableStatus.occupied;
    }

    return table.status == TableStatus.attention ? TableStatus.attention : TableStatus.free;
  }

  List<RestaurantTable> tablesForScope(String tableId) {
    final table = findTableById(tableId);
    if (table == null) {
      return const [];
    }

    if (!table.isJoined || table.joinGroupId == null) {
      return [table];
    }

    final area = areaById(table.areaId);
    if (area == null) {
      return [table];
    }

    return area.tables
        .where((item) => item.joinGroupId == table.joinGroupId)
        .toList();
  }

  int groupChairsCount(String tableId) {
    return tablesForScope(tableId).fold<int>(
      0,
      (total, table) => total + table.chairsCount,
    );
  }

  int groupSeatedCount(String tableId) {
    return tablesForScope(tableId).fold<int>(
      0,
      (total, table) => total + (table.seatedPeople ?? 0),
    );
  }

  int groupItemsCount(String tableId) {
    return tablesForScope(tableId).fold<int>(
      0,
      (total, table) => max(total, table.orderItemsCount),
    );
  }

  double groupPartialTotal(String tableId) {
    return tablesForScope(tableId).fold<double>(
      0,
      (total, table) => max(total, table.partialTotal).toDouble(),
    );
  }

  String? groupCustomerName(String tableId) {
    for (final table in tablesForScope(tableId)) {
      if ((table.customerName ?? '').trim().isNotEmpty) {
        return table.customerName;
      }
    }
    return null;
  }

  DateTime? lastOrderAtForScope(String tableId) {
    DateTime? latest;
    for (final table in tablesForScope(tableId)) {
      if (table.lastOrderAt == null) {
        continue;
      }
      if (latest == null || table.lastOrderAt!.isAfter(latest)) {
        latest = table.lastOrderAt;
      }
    }
    return latest;
  }

  String? activeOrderIdForScope(String tableId) {
    for (final table in tablesForScope(tableId)) {
      if (table.activeOrderId != null) {
        return table.activeOrderId;
      }
    }
    return null;
  }

  List<RestaurantTable> joinableTablesFor(String tableId) {
    final table = findTableById(tableId);
    if (table == null) {
      return const [];
    }

    final area = areaById(table.areaId);
    if (area == null) {
      return const [];
    }

    return area.tables.where((candidate) {
      if (candidate.id == tableId) {
        return false;
      }
      if (candidate.isJoined || table.isJoined) {
        return false;
      }
      return true;
    }).toList();
  }

  RestaurantArea? areaById(String areaId) {
    for (final area in _areas) {
      if (area.id == areaId) {
        return area;
      }
    }
    return null;
  }

  RestaurantTable? findTableById(String tableId) {
    for (final area in _areas) {
      for (final table in area.tables) {
        if (table.id == tableId) {
          return table;
        }
      }
    }
    return null;
  }

  Future<void> saveTable(TableDraft draft) async {
    final targetArea = areaById(draft.areaId);
    if (targetArea == null) {
      _setError('Selecione uma area valida para a mesa.');
      return;
    }

    final trimmedCode = draft.code.trim();
    if (trimmedCode.isEmpty) {
      _setError('A mesa precisa ter um nome ou codigo.');
      return;
    }
    if (draft.chairsCount < 1 || draft.chairsCount > 12) {
      _setError('A quantidade de cadeiras deve ficar entre 1 e 12.');
      return;
    }
    if (draft.width < 72 || draft.height < 56) {
      _setError('A mesa precisa ter dimensoes minimas para leitura.');
      return;
    }

    if (draft.id == null) {
      final tables = [...targetArea.tables];
      tables.add(
        RestaurantTable(
          id: 'm${DateTime.now().microsecondsSinceEpoch}',
          code: trimmedCode,
          areaId: draft.areaId,
          x: 48,
          y: 48 + (tables.length * 18),
          width: draft.width,
          height: draft.height,
          shape: draft.shape,
          chairsCount: draft.chairsCount,
          status: draft.seatedPeople != null && draft.seatedPeople! > 0
              ? TableStatus.occupied
              : TableStatus.free,
          isJoined: false,
          seatedPeople: draft.seatedPeople,
          lastOrderAt: draft.seatedPeople != null && draft.seatedPeople! > 0
              ? DateTime.now()
              : null,
        ),
      );
      _replaceArea(targetArea.copyWith(tables: tables));
      await _persist();
      notifyListeners();
      return;
    }

    RestaurantArea? sourceArea;
    RestaurantTable? current;
    for (final area in _areas) {
      for (final table in area.tables) {
        if (table.id == draft.id) {
          sourceArea = area;
          current = table;
          break;
        }
      }
      if (current != null) {
        break;
      }
    }

    if (sourceArea == null || current == null) {
      _setError('Nao foi possivel localizar a mesa para edicao.');
      return;
    }

    final sourceAreaValue = sourceArea;
    final currentTable = current;

    if (currentTable.isJoined && draft.areaId != currentTable.areaId) {
      _setError('Separe a mesa antes de mover o grupo para outra area.');
      return;
    }

    final updatedTable = currentTable.copyWith(
      code: trimmedCode,
      areaId: draft.areaId,
      width: draft.width,
      height: draft.height,
      shape: draft.shape,
      chairsCount: draft.chairsCount,
      seatedPeople: draft.seatedPeople,
      status: (draft.seatedPeople ?? 0) > 0
          ? (currentTable.activeOrderId != null ? TableStatus.withOrder : TableStatus.occupied)
          : (currentTable.activeOrderId != null ? TableStatus.withOrder : TableStatus.free),
      lastOrderAt: (draft.seatedPeople ?? 0) > 0
          ? (currentTable.lastOrderAt ?? DateTime.now())
          : currentTable.lastOrderAt,
      clearSeatedPeople: draft.seatedPeople == null,
    );

    final sourceTables = sourceAreaValue.tables
        .where((table) => table.id != currentTable.id)
        .toList();
    _replaceArea(sourceAreaValue.copyWith(tables: sourceTables));

    final targetTables = [
      ...targetArea.tables.where((table) => table.id != currentTable.id),
      updatedTable,
    ];
    _replaceArea(targetArea.copyWith(tables: targetTables));
    await _persist();
    notifyListeners();
  }

  void beginMove(String tableId) {
    _movingTableId = tableId;
    notifyListeners();
  }

  void unselectJoinSuggestion() {
    _movingTableId = null;
    _suggestedJoinTargetId = null;
  }

  Future<void> moveTable(
    String tableId,
    Offset delta,
    Size canvasSize,
  ) async {
    final table = findTableById(tableId);
    final area = table == null ? null : areaById(table.areaId);
    if (table == null || area == null) {
      return;
    }

    final snap = 12.0;
    final maxX = max(0.0, canvasSize.width - table.width - 24);
    final maxY = max(0.0, canvasSize.height - table.height - 24);
    final nextX = _snapValue((table.x + delta.dx).clamp(0.0, maxX), snap);
    final nextY = _snapValue((table.y + delta.dy).clamp(0.0, maxY), snap);

    final updatedTable = table.copyWith(x: nextX, y: nextY);
    final updatedTables = area.tables
        .map((item) => item.id == tableId ? updatedTable : item)
        .toList();

    _replaceArea(area.copyWith(tables: updatedTables));
    _updateJoinSuggestion(updatedTable);
    notifyListeners();
  }

  Future<void> finishMove() async {
    _movingTableId = null;
    await _persist();
    notifyListeners();
  }

  Future<String?> joinTables({
    required String sourceTableId,
    required String targetTableId,
  }) async {
    final source = findTableById(sourceTableId);
    final target = findTableById(targetTableId);
    if (source == null || target == null) {
      return _setError('Nao foi possivel localizar as mesas para uniao.');
    }
    if (source.areaId != target.areaId) {
      return _setError('Mesas de areas diferentes nao podem ser unidas.');
    }
    if (source.isJoined || target.isJoined) {
      return _setError('Separe a mesa atual antes de criar um novo agrupamento.');
    }

    final activeOrderIds = <String>{
      ...tablesForScope(sourceTableId).map((table) => table.activeOrderId).whereType<String>(),
      ...tablesForScope(targetTableId).map((table) => table.activeOrderId).whereType<String>(),
    };
    if (activeOrderIds.length > 1) {
      return _setError('As mesas possuem pedidos diferentes e nao podem ser unidas agora.');
    }

    final area = areaById(source.areaId);
    if (area == null) {
      return _setError('Area da mesa nao encontrada.');
    }

    final joinGroupId = 'jg-${DateTime.now().millisecondsSinceEpoch}';
    final mergedOrderCarrier = source.activeOrderId != null ? source : target;

    final updatedTables = area.tables.map((table) {
      if (table.id != sourceTableId && table.id != targetTableId) {
        return table;
      }

      return table.copyWith(
        isJoined: true,
        joinGroupId: joinGroupId,
        activeOrderId: mergedOrderCarrier.activeOrderId,
        lastOrderAt: mergedOrderCarrier.lastOrderAt,
        customerName: mergedOrderCarrier.customerName,
        orderItemsCount: mergedOrderCarrier.orderItemsCount,
        partialTotal: mergedOrderCarrier.partialTotal,
        status: mergedOrderCarrier.activeOrderId != null
            ? TableStatus.withOrder
            : (table.seatedPeople ?? 0) > 0
                ? TableStatus.occupied
                : TableStatus.free,
      );
    }).toList();

    final updatedGroups = [
      ...area.joinGroups,
      TableJoinGroup(
        id: joinGroupId,
        areaId: area.id,
        tableIds: [sourceTableId, targetTableId],
      ),
    ];

    final snappedTables = _snapJoinedTables(
      updatedTables,
      sourceTableId,
      targetTableId,
    );

    _replaceArea(
      area.copyWith(
        tables: snappedTables,
        joinGroups: updatedGroups,
      ),
    );
    unselectJoinSuggestion();
    await _persist();
    notifyListeners();
    return null;
  }

  Future<String?> separateGroup(String groupId) async {
    RestaurantArea? area;
    for (final candidate in _areas) {
      if (candidate.joinGroups.any((group) => group.id == groupId)) {
        area = candidate;
        break;
      }
    }

    if (area == null) {
      return _setError('Grupo de mesas nao encontrado.');
    }

    final groupTables = area.tables
        .where((table) => table.joinGroupId == groupId)
        .toList();
    final anchorWithOrder = groupTables.firstWhere(
      (table) => table.activeOrderId != null,
      orElse: () => groupTables.first,
    );

    final updatedTables = area.tables.map((table) {
      if (table.joinGroupId != groupId) {
        return table;
      }

      final keepOrder = table.id == anchorWithOrder.id;

      return table.copyWith(
        isJoined: false,
        clearJoinGroup: true,
        status: keepOrder && anchorWithOrder.activeOrderId != null
            ? TableStatus.withOrder
            : (table.seatedPeople ?? 0) > 0
                ? TableStatus.occupied
                : TableStatus.free,
        activeOrderId: keepOrder ? anchorWithOrder.activeOrderId : null,
        lastOrderAt: keepOrder ? anchorWithOrder.lastOrderAt : table.lastOrderAt,
        customerName: keepOrder ? anchorWithOrder.customerName : null,
        orderItemsCount: keepOrder ? anchorWithOrder.orderItemsCount : 0,
        partialTotal: keepOrder ? anchorWithOrder.partialTotal : 0,
        clearActiveOrder: !keepOrder,
        clearCustomerName: !keepOrder,
      );
    }).toList();

    final updatedGroups = area.joinGroups
        .where((group) => group.id != groupId)
        .toList();

    _replaceArea(area.copyWith(tables: updatedTables, joinGroups: updatedGroups));
    await _persist();
    notifyListeners();
    return null;
  }

  Future<TableOrderOpenResult?> openOrderForTable(String tableId) async {
    final scopeTables = tablesForScope(tableId);
    if (scopeTables.isEmpty) {
      _setError('Mesa nao encontrada para abrir pedido.');
      return null;
    }

    final scopeId = scopeTables.first.joinGroupId ?? scopeTables.first.id;
    final now = DateTime.now();
    if (_lastOpenedScopeId == scopeId &&
        _lastOrderOpenAt != null &&
        now.difference(_lastOrderOpenAt!) < const Duration(milliseconds: 900)) {
      return null;
    }

    _lastOpenedScopeId = scopeId;
    _lastOrderOpenAt = now;

    final existingOrderId = activeOrderIdForScope(tableId);
    if (existingOrderId != null) {
      return TableOrderOpenResult(
        orderId: existingOrderId,
        reusedExistingOrder: true,
        tableIds: scopeTables.map((table) => table.id).toList(),
      );
    }

    final area = areaById(scopeTables.first.areaId);
    if (area == null) {
      _setError('Area da mesa nao encontrada para abrir pedido.');
      return null;
    }

    final orderId = 'ORD-${DateTime.now().millisecondsSinceEpoch}';
    final updatedTables = area.tables.map((table) {
      if (!scopeTables.any((scopeTable) => scopeTable.id == table.id)) {
        return table;
      }

      return table.copyWith(
        activeOrderId: orderId,
        lastOrderAt: now,
        status: TableStatus.withOrder,
        orderItemsCount: max(table.orderItemsCount, 1),
        partialTotal: max(table.partialTotal, 0),
        seatedPeople: max(table.seatedPeople ?? 0, 1),
      );
    }).toList();

    _replaceArea(area.copyWith(tables: updatedTables));
    await _persist();
    notifyListeners();

    return TableOrderOpenResult(
      orderId: orderId,
      reusedExistingOrder: false,
      tableIds: scopeTables.map((table) => table.id).toList(),
    );
  }

  Future<void> addSimulatedItem(String tableId) async {
    final scopeTables = tablesForScope(tableId);
    if (scopeTables.isEmpty) {
      return;
    }

    final area = areaById(scopeTables.first.areaId);
    final activeOrderId = activeOrderIdForScope(tableId);
    if (area == null || activeOrderId == null) {
      return;
    }

    final now = DateTime.now();
    final nextItems = groupItemsCount(tableId) + 1;
    final nextTotal = groupPartialTotal(tableId) + 24.90;

    final updatedTables = area.tables.map((table) {
      if (!scopeTables.any((scopeTable) => scopeTable.id == table.id)) {
        return table;
      }

      return table.copyWith(
        activeOrderId: activeOrderId,
        lastOrderAt: now,
        status: TableStatus.withOrder,
        orderItemsCount: nextItems,
        partialTotal: nextTotal,
      );
    }).toList();

    _replaceArea(area.copyWith(tables: updatedTables));
    await _persist();
    notifyListeners();
  }

  Future<void> markTableAsFree(String tableId) async {
    final scopeTables = tablesForScope(tableId);
    if (scopeTables.isEmpty) {
      return;
    }

    final area = areaById(scopeTables.first.areaId);
    if (area == null) {
      return;
    }

    final updatedTables = area.tables.map((table) {
      if (!scopeTables.any((scopeTable) => scopeTable.id == table.id)) {
        return table;
      }

      return table.copyWith(
        status: TableStatus.free,
        clearActiveOrder: true,
        clearLastOrderAt: true,
        clearSeatedPeople: true,
        clearCustomerName: true,
        orderItemsCount: 0,
        partialTotal: 0,
      );
    }).toList();

    _replaceArea(area.copyWith(tables: updatedTables));
    await _persist();
    notifyListeners();
  }

  double _snapValue(double value, double interval) {
    return (value / interval).round() * interval;
  }

  void _replaceArea(RestaurantArea nextArea) {
    _areas = _areas
        .map((area) => area.id == nextArea.id ? nextArea : area)
        .toList(growable: false);
  }

  void _updateJoinSuggestion(RestaurantTable movingTable) {
    final area = areaById(movingTable.areaId);
    if (area == null || movingTable.isJoined) {
      _suggestedJoinTargetId = null;
      return;
    }

    RestaurantTable? bestCandidate;
    double shortestDistance = double.infinity;

    for (final candidate in area.tables) {
      if (candidate.id == movingTable.id || candidate.isJoined) {
        continue;
      }

      final distance = _edgeDistance(movingTable, candidate);
      if (distance < 30 && distance < shortestDistance) {
        shortestDistance = distance;
        bestCandidate = candidate;
      }
    }

    _suggestedJoinTargetId = bestCandidate?.id;
  }

  double _edgeDistance(RestaurantTable a, RestaurantTable b) {
    final horizontal = (a.x - b.x).abs() - ((a.width + b.width) / 2);
    final vertical = (a.y - b.y).abs() - ((a.height + b.height) / 2);
    return max(horizontal.abs(), vertical.abs());
  }

  List<RestaurantTable> _snapJoinedTables(
    List<RestaurantTable> tables,
    String sourceTableId,
    String targetTableId,
  ) {
    final sourceIndex = tables.indexWhere((table) => table.id == sourceTableId);
    final targetIndex = tables.indexWhere((table) => table.id == targetTableId);
    if (sourceIndex < 0 || targetIndex < 0) {
      return tables;
    }

    final source = tables[sourceIndex];
    final target = tables[targetIndex];
    final sourceCenter = Offset(source.x + (source.width / 2), source.y + (source.height / 2));
    final targetCenter = Offset(target.x + (target.width / 2), target.y + (target.height / 2));

    final shouldStackHorizontally =
        (sourceCenter.dx - targetCenter.dx).abs() >= (sourceCenter.dy - targetCenter.dy).abs();

    final snappedTarget = shouldStackHorizontally
        ? target.copyWith(
            x: source.x + source.width + 18,
            y: source.y,
          )
        : target.copyWith(
            x: source.x,
            y: source.y + source.height + 18,
          );

    final result = [...tables];
    result[targetIndex] = snappedTarget;
    return result;
  }

  String _setError(String message) {
    _lastActionError = message;
    notifyListeners();
    return message;
  }

  Future<void> _persist() async {
    if (_selectedAreaId == null) {
      return;
    }

    _isSaving = true;
    notifyListeners();
    await _repository.save(
      FloorPlanSnapshot(
        selectedAreaId: _selectedAreaId!,
        areas: _areas,
      ),
    );
    _isSaving = false;
    _lastActionError = null;
    notifyListeners();
  }
}
