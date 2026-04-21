import 'package:flutter/material.dart';
import '../../data/models/producto.dart';
import '../../data/repositories/movimiento_repository.dart';
import '../../data/repositories/caja_repository.dart';

class ProductoDetailScreen extends StatefulWidget {
  final Producto producto;
  const ProductoDetailScreen({super.key, required this.producto});

  @override
  State<ProductoDetailScreen> createState() => _ProductoDetailScreenState();
}

class _ProductoDetailScreenState extends State<ProductoDetailScreen> {
  final _movRepo = MovimientoRepository();
  final _cajaRepo = CajaRepository();
  Map<int, int> _stockByCaja = {};
  Map<int, String> _cajaNombres = {};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final stock = await _movRepo.getStockBySku(widget.producto.sku);
    final nombres = <int, String>{};
    for (final cajaId in stock.keys) {
      final caja = await _cajaRepo.getById(cajaId);
      if (caja != null) nombres[cajaId] = caja.nombre;
    }
    if (mounted) {
      setState(() {
        _stockByCaja = stock;
        _cajaNombres = nombres;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.producto;
    return Scaffold(
      appBar: AppBar(title: Text(p.nombre)),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _infoRow('SKU', p.sku),
                          if (p.barcode != null) _infoRow('Cód. Barras', p.barcode!),
                          if (p.marca != null) _infoRow('Marca', p.marca!),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text('Stock por Caja', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  if (_stockByCaja.isEmpty)
                    const Text('Sin stock en ninguna caja')
                  else
                    Expanded(
                      child: ListView(
                        children: _stockByCaja.entries.map((e) {
                          return ListTile(
                            leading: const Icon(Icons.inbox),
                            title: Text(_cajaNombres[e.key] ?? 'Caja ${e.key}'),
                            trailing: Chip(label: Text('${e.value} unid.')),
                          );
                        }).toList(),
                      ),
                    ),
                ],
              ),
            ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(label),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
