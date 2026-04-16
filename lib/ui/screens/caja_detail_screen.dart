import 'package:flutter/material.dart';
import '../../data/models/caja.dart';
import '../../data/repositories/movimiento_repository.dart';
import '../../data/repositories/producto_repository.dart';

class CajaDetailScreen extends StatefulWidget {
  final Caja caja;
  const CajaDetailScreen({super.key, required this.caja});

  @override
  State<CajaDetailScreen> createState() => _CajaDetailScreenState();
}

class _CajaDetailScreenState extends State<CajaDetailScreen> {
  final _movRepo = MovimientoRepository();
  final _prodRepo = ProductoRepository();
  Map<String, int> _stockBySku = {};
  Map<String, String> _productoNombres = {};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final stock = await _movRepo.getStockByCaja(widget.caja.id!);
    final nombres = <String, String>{};
    for (final sku in stock.keys) {
      final p = await _prodRepo.getBySku(sku);
      if (p != null) nombres[sku] = p.nombre;
    }
    if (mounted) {
      setState(() {
        _stockBySku = stock;
        _productoNombres = nombres;
        _loading = false;
      });
    }
  }

  int get _totalItems => _stockBySku.values.fold(0, (a, b) => a + b);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Caja ${widget.caja.nombre}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() => _loading = true);
              _load();
            },
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                if (widget.caja.rackNombre != null)
                  ListTile(
                    leading: const Icon(Icons.storage),
                    title: Text('Rack: ${widget.caja.rackNombre}'),
                  ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      Text(
                        '${_stockBySku.length} SKUs | $_totalItems unidades totales',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
                const Divider(),
                if (_stockBySku.isEmpty)
                  const Expanded(child: Center(child: Text('Caja vacía')))
                else
                  Expanded(
                    child: ListView(
                      children: _stockBySku.entries.map((e) {
                        return ListTile(
                          leading: const Icon(Icons.inventory_2),
                          title: Text(_productoNombres[e.key] ?? e.key),
                          subtitle: Text('SKU: ${e.key}'),
                          trailing: Chip(label: Text('${e.value} unid.')),
                        );
                      }).toList(),
                    ),
                  ),
              ],
            ),
    );
  }
}
