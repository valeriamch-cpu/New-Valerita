import 'package:flutter/foundation.dart';
import '../../data/models/producto.dart';
import '../../data/models/caja.dart';
import '../../data/models/rack.dart';
import '../../data/repositories/producto_repository.dart';
import '../../data/repositories/caja_repository.dart';
import '../../data/repositories/rack_repository.dart';
import '../../data/repositories/movimiento_repository.dart';

class InventarioProvider extends ChangeNotifier {
  final ProductoRepository _productoRepo = ProductoRepository();
  final CajaRepository _cajaRepo = CajaRepository();
  final RackRepository _rackRepo = RackRepository();
  final MovimientoRepository _movimientoRepo = MovimientoRepository();

  List<Producto> _productos = [];
  List<Caja> _cajas = [];
  List<Rack> _racks = [];

  List<Producto> get productos => _productos;
  List<Caja> get cajas => _cajas;
  List<Rack> get racks => _racks;

  Future<void> loadProductos({String? query}) async {
    _productos = await _productoRepo.search(query: query);
    notifyListeners();
  }

  Future<void> loadCajas() async {
    _cajas = await _cajaRepo.getAll();
    notifyListeners();
  }

  Future<void> loadRacks() async {
    _racks = await _rackRepo.getAll();
    notifyListeners();
  }

  Future<Map<String, int>> getStockByCaja(int cajaId) async {
    return await _movimientoRepo.getStockByCaja(cajaId);
  }

  Future<Map<int, int>> getStockBySku(String sku) async {
    return await _movimientoRepo.getStockBySku(sku);
  }

  Future<int> getStock(int cajaId, String sku) async {
    return await _movimientoRepo.getStock(cajaId, sku);
  }

  MovimientoRepository get movimientoRepo => _movimientoRepo;
  ProductoRepository get productoRepo => _productoRepo;
  CajaRepository get cajaRepo => _cajaRepo;
  RackRepository get rackRepo => _rackRepo;
}
