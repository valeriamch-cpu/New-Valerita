import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/inventario_provider.dart';
import 'caja_detail_screen.dart';

class CajasScreen extends StatefulWidget {
  const CajasScreen({super.key});

  @override
  State<CajasScreen> createState() => _CajasScreenState();
}

class _CajasScreenState extends State<CajasScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final inv = context.read<InventarioProvider>();
      inv.loadCajas();
      inv.loadRacks();
    });
  }

  Future<void> _showCreateDialog() async {
    final nombreCtrl = TextEditingController();
    final inv = context.read<InventarioProvider>();
    int? selectedRackId;

    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Nueva Caja'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nombreCtrl,
              autofocus: true,
              decoration: const InputDecoration(labelText: 'Nombre de la caja (ej: C4)'),
            ),
            const SizedBox(height: 12),
            StatefulBuilder(
              builder: (context, setS) => DropdownButtonFormField<int?>(
                initialValue: selectedRackId,
                decoration: const InputDecoration(labelText: 'Rack (opcional)'),
                items: [
                  const DropdownMenuItem(value: null, child: Text('Sin rack')),
                  ...inv.racks.map((r) => DropdownMenuItem(value: r.id, child: Text(r.nombre))),
                ],
                onChanged: (v) => setS(() => selectedRackId = v),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          FilledButton(
            onPressed: () async {
              final nombre = nombreCtrl.text.trim();
              if (nombre.isNotEmpty) {
                await inv.cajaRepo.create(nombre, rackId: selectedRackId);
                await inv.loadCajas();
                if (ctx.mounted) Navigator.pop(ctx);
              }
            },
            child: const Text('Crear'),
          ),
        ],
      ),
    );
    nombreCtrl.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<InventarioProvider>(
        builder: (context, inv, _) {
          final cajas = inv.cajas;
          if (cajas.isEmpty) {
            return const Center(child: Text('No hay cajas. Crea una con el botón +'));
          }
          return ListView.builder(
            itemCount: cajas.length,
            itemBuilder: (context, i) {
              final c = cajas[i];
              return ListTile(
                leading: const Icon(Icons.inbox),
                title: Text(c.nombre),
                subtitle: c.rackNombre != null ? Text('Rack: ${c.rackNombre}') : null,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => CajaDetailScreen(caja: c)),
                ).then((_) => inv.loadCajas()),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showCreateDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}
