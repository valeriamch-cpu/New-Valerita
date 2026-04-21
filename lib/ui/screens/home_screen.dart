import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'productos_screen.dart';
import 'cajas_screen.dart';
import 'racks_screen.dart';
import 'movimiento_screen.dart';
import 'importar_csv_screen.dart';
import 'usuarios_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final List<NavigationDestination> _destinations = const [
    NavigationDestination(icon: Icon(Icons.inventory), label: 'Productos'),
    NavigationDestination(icon: Icon(Icons.inbox), label: 'Cajas'),
    NavigationDestination(icon: Icon(Icons.storage), label: 'Racks'),
    NavigationDestination(icon: Icon(Icons.swap_horiz), label: 'Movimiento'),
  ];

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final screens = [
      const ProductosScreen(),
      const CajasScreen(),
      const RacksScreen(),
      const MovimientoScreen(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Bodega App'),
        actions: [
          if (auth.isAdmin) ...[
            IconButton(
              icon: const Icon(Icons.upload_file),
              tooltip: 'Importar CSV',
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ImportarCsvScreen()),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.people),
              tooltip: 'Usuarios',
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const UsuariosScreen()),
              ),
            ),
          ],
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Salir',
            onPressed: () => context.read<AuthProvider>().logout(),
          ),
        ],
      ),
      body: screens[_selectedIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        destinations: _destinations,
        onDestinationSelected: (i) => setState(() => _selectedIndex = i),
      ),
    );
  }
}
