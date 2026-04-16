import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../providers/auth_provider.dart';
import '../providers/inventario_provider.dart';
import '../../data/models/movimiento.dart';
import '../../data/models/producto.dart';
import '../../data/models/caja.dart';

class MovimientoScreen extends StatefulWidget {
  const MovimientoScreen({super.key});

  @override
  State<MovimientoScreen> createState() => _MovimientoScreenState();
}

class _MovimientoScreenState extends State<MovimientoScreen> {
  final _scanCtrl = TextEditingController();
  final _cantidadCtrl = TextEditingController(text: '1');
  final _uuid = const Uuid();

  Producto? _producto;
  Caja? _caja;
  int _currentStock = 0;
  String? _error;
  String? _successMsg;
  bool _isEntrada = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<InventarioProvider>().loadCajas();
    });
  }

  @override
  void dispose() {
    _scanCtrl.dispose();
    _cantidadCtrl.dispose();
    super.dispose();
  }

  Future<void> _lookupProducto(String query) async {
    final inv = context.read<InventarioProvider>();
    Producto? found;
    if (query.isNotEmpty) {
      found = await inv.productoRepo.getByBarcode(query);
      found ??= await inv.productoRepo.getBySku(query);
    }
    setState(() {
      _producto = found;
      _error = found == null && query.isNotEmpty ? 'Producto no encontrado: $query' : null;
      _successMsg = null;
    });
    if (found != null && _caja != null) await _loadStock();
  }

  Future<void> _loadStock() async {
    if (_caja == null || _producto == null) return;
    final stock = await context.read<InventarioProvider>().getStock(_caja!.id!, _producto!.sku);
    setState(() => _currentStock = stock);
  }

  Future<void> _registrar() async {
    setState(() {
      _error = null;
      _successMsg = null;
    });
    if (_producto == null) {
      setState(() => _error = 'Seleccione un producto');
      return;
    }
    if (_caja == null) {
      setState(() => _error = 'Seleccione una caja');
      return;
    }
    final cantidad = int.tryParse(_cantidadCtrl.text.trim());
    if (cantidad == null || cantidad <= 0) {
      setState(() => _error = 'Cantidad inválida');
      return;
    }
    final delta = _isEntrada ? cantidad : -cantidad;
    final auth = context.read<AuthProvider>();
    final mov = Movimiento(
      uuid: _uuid.v4(),
      deviceId: 'device_local',
      userId: auth.currentUser!.id!,
      timestamp: DateTime.now(),
      sku: _producto!.sku,
      cajaId: _caja!.id!,
      delta: delta,
    );
    try {
      await context.read<InventarioProvider>().movimientoRepo.registrarMovimiento(mov);
      await _loadStock();
      setState(() {
        _successMsg =
            '${_isEntrada ? "Entrada" : "Salida"} registrada: $cantidad unid. de ${_producto!.nombre}';
        _cantidadCtrl.text = '1';
      });
    } catch (e) {
      setState(() => _error = e.toString().replaceFirst('Exception: ', ''));
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Registro de Movimiento', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 16),
          TextField(
            controller: _scanCtrl,
            decoration: InputDecoration(
              labelText: 'Escanear/ingresar barcode o SKU',
              prefixIcon: const Icon(Icons.qr_code_scanner),
              border: const OutlineInputBorder(),
              suffixIcon: _producto != null
                  ? const Icon(Icons.check_circle, color: Colors.green)
                  : null,
            ),
            onSubmitted: _lookupProducto,
          ),
          if (_producto != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                '✓ ${_producto!.nombre} (${_producto!.sku})',
                style: const TextStyle(color: Colors.green),
              ),
            ),
          const SizedBox(height: 12),
          Consumer<InventarioProvider>(
            builder: (context, inv, _) => DropdownButtonFormField<Caja>(
              // ignore: deprecated_member_use
              value: _caja,
              decoration: const InputDecoration(
                labelText: 'Caja destino/origen',
                prefixIcon: Icon(Icons.inbox),
                border: OutlineInputBorder(),
              ),
              items: inv.cajas
                  .map((c) => DropdownMenuItem(value: c, child: Text(c.nombre)))
                  .toList(),
              onChanged: (c) {
                setState(() => _caja = c);
                if (c != null) _loadStock();
              },
            ),
          ),
          if (_caja != null && _producto != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                'Stock actual en esta caja: $_currentStock unid.',
                style: const TextStyle(color: Colors.blue),
              ),
            ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: SegmentedButton<bool>(
                  segments: const [
                    ButtonSegment(value: true, label: Text('Entrada +'), icon: Icon(Icons.add)),
                    ButtonSegment(value: false, label: Text('Salida -'), icon: Icon(Icons.remove)),
                  ],
                  selected: {_isEntrada},
                  onSelectionChanged: (s) => setState(() => _isEntrada = s.first),
                ),
              ),
              const SizedBox(width: 12),
              SizedBox(
                width: 100,
                child: TextField(
                  controller: _cantidadCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Cantidad',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                  onSubmitted: (_) => _registrar(),
                ),
              ),
            ],
          ),
          if (_error != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(_error!, style: const TextStyle(color: Colors.red)),
            ),
          if (_successMsg != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(_successMsg!, style: const TextStyle(color: Colors.green)),
            ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: _registrar,
              icon: Icon(_isEntrada ? Icons.add : Icons.remove),
              label: Text(_isEntrada ? 'Registrar Entrada' : 'Registrar Salida'),
            ),
          ),
        ],
      ),
    );
  }
}
