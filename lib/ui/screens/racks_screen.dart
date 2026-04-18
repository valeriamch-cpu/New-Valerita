import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/inventario_provider.dart';

class RacksScreen extends StatefulWidget {
  const RacksScreen({super.key});

  @override
  State<RacksScreen> createState() => _RacksScreenState();
}

class _RacksScreenState extends State<RacksScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<InventarioProvider>().loadRacks();
    });
  }

  Future<void> _showCreateDialog() async {
    final ctrl = TextEditingController();
    final inv = context.read<InventarioProvider>();
    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Nuevo Rack'),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          decoration: const InputDecoration(labelText: 'Nombre del Rack'),
          onSubmitted: (_) async {
            if (ctrl.text.trim().isNotEmpty) {
              await inv.rackRepo.create(ctrl.text.trim());
              await inv.loadRacks();
              if (ctx.mounted) Navigator.pop(ctx);
            }
          },
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          FilledButton(
            onPressed: () async {
              if (ctrl.text.trim().isNotEmpty) {
                await inv.rackRepo.create(ctrl.text.trim());
                await inv.loadRacks();
                if (ctx.mounted) Navigator.pop(ctx);
              }
            },
            child: const Text('Crear'),
          ),
        ],
      ),
    );
    ctrl.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<InventarioProvider>(
        builder: (context, inv, _) {
          final racks = inv.racks;
          if (racks.isEmpty) {
            return const Center(child: Text('No hay racks. Crea uno con el botón +'));
          }
          return ListView.builder(
            itemCount: racks.length,
            itemBuilder: (context, i) {
              final r = racks[i];
              return ListTile(
                leading: const Icon(Icons.storage),
                title: Text(r.nombre),
                trailing: IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () async {
                    final ok = await showDialog<bool>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('Eliminar Rack'),
                        content: Text('¿Eliminar rack "${r.nombre}"?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx, false),
                            child: const Text('Cancelar'),
                          ),
                          FilledButton(
                            onPressed: () => Navigator.pop(ctx, true),
                            child: const Text('Eliminar'),
                          ),
                        ],
                      ),
                    );
                    if (ok == true) {
                      await inv.rackRepo.delete(r.id!);
                      await inv.loadRacks();
                    }
                  },
                ),
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
