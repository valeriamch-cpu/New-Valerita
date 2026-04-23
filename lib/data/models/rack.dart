class Rack {
  final int? id;
  final String nombre;

  const Rack({this.id, required this.nombre});

  factory Rack.fromMap(Map<String, dynamic> map) {
    return Rack(
      id: map['id'] as int?,
      nombre: map['nombre'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'nombre': nombre,
    };
  }

  @override
  String toString() => 'Rack(id: $id, nombre: $nombre)';
}
