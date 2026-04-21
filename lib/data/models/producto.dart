class Producto {
  final int? id;
  final String sku;
  final String? barcode;
  final String nombre;
  final String? marca;

  const Producto({
    this.id,
    required this.sku,
    this.barcode,
    required this.nombre,
    this.marca,
  });

  factory Producto.fromMap(Map<String, dynamic> map) {
    return Producto(
      id: map['id'] as int?,
      sku: map['sku'] as String,
      barcode: map['barcode'] as String?,
      nombre: map['nombre'] as String,
      marca: map['marca'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'sku': sku,
      'barcode': barcode,
      'nombre': nombre,
      'marca': marca,
    };
  }

  @override
  String toString() => 'Producto(sku: $sku, nombre: $nombre)';
}
