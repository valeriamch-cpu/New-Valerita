import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:csv/csv.dart';
import 'dart:io';
import 'package:provider/provider.dart';
import '../providers/inventario_provider.dart';

class ImportarCsvScreen extends StatefulWidget {
  const ImportarCsvScreen({super.key});

  @override
  State<ImportarCsvScreen> createState() => _ImportarCsvScreenState();
}

class _ImportarCsvScreenState extends State<ImportarCsvScreen> {
  String? _mensaje;
  bool _loading = false;

  Future<void> _pickAndImport() async {
    setState(() {
      _loading = true;
      _mensaje = null;
    });
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv'],
      );
      if (result == null || result.files.isEmpty) {
        setState(() => _loading = false);
        return;
      }
      final path = result.files.first.path!;
      final content = await File(path).readAsString();
      final rows = const CsvToListConverter(eol: '\n').convert(content);
      if (rows.isEmpty) {
        setState(() {
          _mensaje = 'El archivo CSV está vacío';
          _loading = false;
        });
        return;
      }
      final headers = rows.first.map((e) => e.toString().trim().toLowerCase()).toList();
      final data = rows.skip(1).map((row) {
        final map = <String, dynamic>{};
        for (int i = 0; i < headers.length && i < row.length; i++) {
          map[headers[i]] = row[i];
        }
        return map;
      }).toList();

      if (!mounted) return;
      final inv = context.read<InventarioProvider>();
      final count = await inv.productoRepo.importFromCsv(data);
      await inv.loadProductos();
      if (mounted) {
        setState(() {
          _mensaje = 'Se importaron $count productos correctamente';
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _mensaje = 'Error al importar: $e';
          _loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Importar CSV (Bsale)')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Importar productos desde CSV de Bsale',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 8),
            const Text(
              'El CSV debe tener las columnas:\nnombre, marca, codigo_barra, sku',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _loading ? null : _pickAndImport,
                icon: const Icon(Icons.upload_file),
                label: const Text('Seleccionar archivo CSV'),
              ),
            ),
            if (_loading) ...[
              const SizedBox(height: 16),
              const Center(child: CircularProgressIndicator()),
            ],
            if (_mensaje != null) ...[
              const SizedBox(height: 16),
              Card(
                color: _mensaje!.startsWith('Error')
                    ? Colors.red.shade50
                    : Colors.green.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    _mensaje!,
                    style: TextStyle(
                      color: _mensaje!.startsWith('Error') ? Colors.red : Colors.green,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
