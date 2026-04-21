import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/inventario_provider.dart';
import 'producto_detail_screen.dart';

class ProductosScreen extends StatefulWidget {
  const ProductosScreen({super.key});

  @override
  State<ProductosScreen> createState() => _ProductosScreenState();
}

class _ProductosScreenState extends State<ProductosScreen> {
  final _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<InventarioProvider>().loadProductos();
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _search(String query) {
    context.read<InventarioProvider>().loadProductos(query: query);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: TextField(
            controller: _searchCtrl,
            decoration: const InputDecoration(
              hintText: 'Buscar por SKU, código de barras, nombre o marca...',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(),
              isDense: true,
            ),
            onSubmitted: _search,
            onChanged: (v) {
              if (v.isEmpty) _search('');
            },
          ),
        ),
        Expanded(
          child: Consumer<InventarioProvider>(
            builder: (context, inv, _) {
              final productos = inv.productos;
              if (productos.isEmpty) {
                return const Center(child: Text('No se encontraron productos'));
              }
              return ListView.builder(
                itemCount: productos.length,
                itemBuilder: (context, i) {
                  final p = productos[i];
                  return ListTile(
                    leading: const Icon(Icons.inventory_2),
                    title: Text(p.nombre),
                    subtitle: Text('SKU: ${p.sku}${p.marca != null ? ' | ${p.marca}' : ''}'),
                    trailing: p.barcode != null
                        ? Text(p.barcode!, style: const TextStyle(fontSize: 12, color: Colors.grey))
                        : null,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => ProductoDetailScreen(producto: p)),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
