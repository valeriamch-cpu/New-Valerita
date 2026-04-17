class Caja {
  final int? id;
  final String nombre;
  final int? rackId;
  String? rackNombre; // populated by join queries

  Caja({
    this.id,
    required this.nombre,
    this.rackId,
    this.rackNombre,
  });

  factory Caja.fromMap(Map<String, dynamic> map) {
    return Caja(
      id: map['id'] as int?,
      nombre: map['nombre'] as String,
      rackId: map['rack_id'] as int?,
      rackNombre: map['rack_nombre'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'nombre': nombre,
      'rack_id': rackId,
    };
  }

  @override
  String toString() => 'Caja(id: $id, nombre: $nombre, rackId: $rackId)';
}
