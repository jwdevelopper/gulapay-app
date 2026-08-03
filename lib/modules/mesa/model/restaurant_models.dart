enum TableShape { round, square, rectangular, oval }

enum TableStatus {
  free,
  occupied,
  noOrder30Min,
  awaitingRelease1H,
  withOrder,
  attention,
}

class RestaurantTable {
  RestaurantTable({
    required this.id,
    required this.code,
    required this.areaId,
    required this.x,
    required this.y,
    required this.width,
    required this.height,
    required this.shape,
    required this.chairsCount,
    required this.status,
    required this.isJoined,
    this.joinGroupId,
    this.activeOrderId,
    this.lastOrderAt,
    this.seatedPeople,
    this.customerName,
    this.orderItemsCount = 0,
    this.partialTotal = 0,
  });

  final String id;
  final String code;
  final String areaId;
  final double x;
  final double y;
  final double width;
  final double height;
  final TableShape shape;
  final int chairsCount;
  final TableStatus status;
  final bool isJoined;
  final String? joinGroupId;
  final String? activeOrderId;
  final DateTime? lastOrderAt;
  final int? seatedPeople;
  final String? customerName;
  final int orderItemsCount;
  final double partialTotal;

  RestaurantTable copyWith({
    String? id,
    String? code,
    String? areaId,
    double? x,
    double? y,
    double? width,
    double? height,
    TableShape? shape,
    int? chairsCount,
    TableStatus? status,
    bool? isJoined,
    String? joinGroupId,
    String? activeOrderId,
    DateTime? lastOrderAt,
    int? seatedPeople,
    String? customerName,
    int? orderItemsCount,
    double? partialTotal,
    bool clearJoinGroup = false,
    bool clearActiveOrder = false,
    bool clearLastOrderAt = false,
    bool clearSeatedPeople = false,
    bool clearCustomerName = false,
  }) {
    return RestaurantTable(
      id: id ?? this.id,
      code: code ?? this.code,
      areaId: areaId ?? this.areaId,
      x: x ?? this.x,
      y: y ?? this.y,
      width: width ?? this.width,
      height: height ?? this.height,
      shape: shape ?? this.shape,
      chairsCount: chairsCount ?? this.chairsCount,
      status: status ?? this.status,
      isJoined: isJoined ?? this.isJoined,
      joinGroupId: clearJoinGroup ? null : (joinGroupId ?? this.joinGroupId),
      activeOrderId: clearActiveOrder ? null : (activeOrderId ?? this.activeOrderId),
      lastOrderAt: clearLastOrderAt ? null : (lastOrderAt ?? this.lastOrderAt),
      seatedPeople: clearSeatedPeople ? null : (seatedPeople ?? this.seatedPeople),
      customerName: clearCustomerName ? null : (customerName ?? this.customerName),
      orderItemsCount: orderItemsCount ?? this.orderItemsCount,
      partialTotal: partialTotal ?? this.partialTotal,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'code': code,
      'areaId': areaId,
      'x': x,
      'y': y,
      'width': width,
      'height': height,
      'shape': shape.name,
      'chairsCount': chairsCount,
      'status': status.name,
      'isJoined': isJoined,
      'joinGroupId': joinGroupId,
      'activeOrderId': activeOrderId,
      'lastOrderAt': lastOrderAt?.toIso8601String(),
      'seatedPeople': seatedPeople,
      'customerName': customerName,
      'orderItemsCount': orderItemsCount,
      'partialTotal': partialTotal,
    };
  }

  factory RestaurantTable.fromMap(Map<String, dynamic> map) {
    return RestaurantTable(
      id: map['id'] as String,
      code: map['code'] as String,
      areaId: map['areaId'] as String,
      x: (map['x'] as num).toDouble(),
      y: (map['y'] as num).toDouble(),
      width: (map['width'] as num).toDouble(),
      height: (map['height'] as num).toDouble(),
      shape: TableShape.values.byName(map['shape'] as String),
      chairsCount: map['chairsCount'] as int,
      status: TableStatus.values.byName(map['status'] as String),
      isJoined: map['isJoined'] as bool? ?? false,
      joinGroupId: map['joinGroupId'] as String?,
      activeOrderId: map['activeOrderId'] as String?,
      lastOrderAt: map['lastOrderAt'] == null
          ? null
          : DateTime.parse(map['lastOrderAt'] as String),
      seatedPeople: map['seatedPeople'] as int?,
      customerName: map['customerName'] as String?,
      orderItemsCount: map['orderItemsCount'] as int? ?? 0,
      partialTotal: (map['partialTotal'] as num?)?.toDouble() ?? 0,
    );
  }
}

class TableJoinGroup {
  TableJoinGroup({
    required this.id,
    required this.areaId,
    required this.tableIds,
    this.originalPositions = const <TableOriginalPosition>[],
  });

  final String id;
  final String areaId;
  final List<String> tableIds;
  final List<TableOriginalPosition> originalPositions;

  TableJoinGroup copyWith({
    String? id,
    String? areaId,
    List<String>? tableIds,
    List<TableOriginalPosition>? originalPositions,
  }) {
    return TableJoinGroup(
      id: id ?? this.id,
      areaId: areaId ?? this.areaId,
      tableIds: tableIds ?? this.tableIds,
      originalPositions: originalPositions ?? this.originalPositions,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'areaId': areaId,
      'tableIds': tableIds,
      'originalPositions': originalPositions
          .map((position) => position.toMap())
          .toList(),
    };
  }

  factory TableJoinGroup.fromMap(Map<String, dynamic> map) {
    return TableJoinGroup(
      id: map['id'] as String,
      areaId: map['areaId'] as String,
      tableIds: List<String>.from(map['tableIds'] as List<dynamic>),
      originalPositions: (map['originalPositions'] as List<dynamic>? ?? const [])
          .map(
            (entry) => TableOriginalPosition.fromMap(
              Map<String, dynamic>.from(entry as Map),
            ),
          )
          .toList(),
    );
  }
}

class TableOriginalPosition {
  TableOriginalPosition({
    required this.tableId,
    required this.x,
    required this.y,
  });

  final String tableId;
  final double x;
  final double y;

  TableOriginalPosition copyWith({
    String? tableId,
    double? x,
    double? y,
  }) {
    return TableOriginalPosition(
      tableId: tableId ?? this.tableId,
      x: x ?? this.x,
      y: y ?? this.y,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'tableId': tableId,
      'x': x,
      'y': y,
    };
  }

  factory TableOriginalPosition.fromMap(Map<String, dynamic> map) {
    return TableOriginalPosition(
      tableId: map['tableId'] as String,
      x: (map['x'] as num).toDouble(),
      y: (map['y'] as num).toDouble(),
    );
  }
}

class RestaurantArea {
  RestaurantArea({
    required this.id,
    required this.name,
    required this.type,
    required this.tables,
    this.joinGroups = const <TableJoinGroup>[],
  });

  final String id;
  final String name;
  final String type;
  final List<RestaurantTable> tables;
  final List<TableJoinGroup> joinGroups;

  int get occupancyCount => tables
      .where((table) => table.activeOrderId != null || (table.seatedPeople ?? 0) > 0)
      .length;

  int get totalTables => tables.length;

  RestaurantArea copyWith({
    String? id,
    String? name,
    String? type,
    List<RestaurantTable>? tables,
    List<TableJoinGroup>? joinGroups,
  }) {
    return RestaurantArea(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      tables: tables ?? this.tables,
      joinGroups: joinGroups ?? this.joinGroups,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'tables': tables.map((table) => table.toMap()).toList(),
      'joinGroups': joinGroups.map((group) => group.toMap()).toList(),
    };
  }

  factory RestaurantArea.fromMap(Map<String, dynamic> map) {
    return RestaurantArea(
      id: map['id'] as String,
      name: map['name'] as String,
      type: map['type'] as String,
      tables: (map['tables'] as List<dynamic>)
          .map(
            (table) => RestaurantTable.fromMap(
              Map<String, dynamic>.from(table as Map),
            ),
          )
          .toList(),
      joinGroups: (map['joinGroups'] as List<dynamic>? ?? const [])
          .map(
            (group) => TableJoinGroup.fromMap(
              Map<String, dynamic>.from(group as Map),
            ),
          )
          .toList(),
    );
  }
}

class FloorPlanSnapshot {
  FloorPlanSnapshot({
    required this.selectedAreaId,
    required this.areas,
  });

  final String selectedAreaId;
  final List<RestaurantArea> areas;

  Map<String, dynamic> toMap() {
    return {
      'selectedAreaId': selectedAreaId,
      'areas': areas.map((area) => area.toMap()).toList(),
    };
  }

  factory FloorPlanSnapshot.fromMap(Map<String, dynamic> map) {
    return FloorPlanSnapshot(
      selectedAreaId: map['selectedAreaId'] as String,
      areas: (map['areas'] as List<dynamic>)
          .map(
            (area) => RestaurantArea.fromMap(
              Map<String, dynamic>.from(area as Map),
            ),
          )
          .toList(),
    );
  }
}
