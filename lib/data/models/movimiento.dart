class Movimiento {
  final int? id;
  final String uuid;
  final String deviceId;
  final int userId;
  final DateTime timestamp;
  final String sku;
  final int cajaId;
  final int delta;
  final bool synced;

  const Movimiento({
    this.id,
    required this.uuid,
    required this.deviceId,
    required this.userId,
    required this.timestamp,
    required this.sku,
    required this.cajaId,
    required this.delta,
    this.synced = false,
  });

  factory Movimiento.fromMap(Map<String, dynamic> map) {
    return Movimiento(
      id: map['id'] as int?,
      uuid: map['uuid'] as String,
      deviceId: map['device_id'] as String,
      userId: map['user_id'] as int,
      timestamp: DateTime.parse(map['timestamp'] as String),
      sku: map['sku'] as String,
      cajaId: map['caja_id'] as int,
      delta: map['delta'] as int,
      synced: (map['synced'] as int) == 1,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'uuid': uuid,
      'device_id': deviceId,
      'user_id': userId,
      'timestamp': timestamp.toIso8601String(),
      'sku': sku,
      'caja_id': cajaId,
      'delta': delta,
      'synced': synced ? 1 : 0,
    };
  }
}
