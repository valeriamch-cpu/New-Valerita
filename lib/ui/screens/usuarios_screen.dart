import 'package:flutter/material.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/models/usuario.dart';

class UsuariosScreen extends StatefulWidget {
  const UsuariosScreen({super.key});

  @override
  State<UsuariosScreen> createState() => _UsuariosScreenState();
}

class _UsuariosScreenState extends State<UsuariosScreen> {
  final _repo = AuthRepository();
  List<Usuario> _usuarios = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final users = await _repo.getAllUsuarios();
    if (mounted) {
      setState(() {
        _usuarios = users;
        _loading = false;
      });
    }
  }

  Future<void> _showCreateDialog() async {
    final userCtrl = TextEditingController();
    final passCtrl = TextEditingController();
    String selectedRole = 'operador';

    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setS) => AlertDialog(
          title: const Text('Nuevo Usuario'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: userCtrl,
                autofocus: true,
                decoration: const InputDecoration(labelText: 'Nombre de usuario'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: passCtrl,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Contraseña'),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                initialValue: selectedRole,
                decoration: const InputDecoration(labelText: 'Rol'),
                items: const [
                  DropdownMenuItem(value: 'operador', child: Text('Operador')),
                  DropdownMenuItem(value: 'admin', child: Text('Admin')),
                ],
                onChanged: (v) => setS(() => selectedRole = v ?? 'operador'),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
            FilledButton(
              onPressed: () async {
                final u = userCtrl.text.trim();
                final p = passCtrl.text;
                if (u.isNotEmpty && p.isNotEmpty) {
                  try {
                    await _repo.createUsuario(username: u, password: p, role: selectedRole);
                    await _load();
                    if (ctx.mounted) Navigator.pop(ctx);
                  } catch (e) {
                    if (ctx.mounted) {
                      ScaffoldMessenger.of(ctx).showSnackBar(
                        SnackBar(content: Text('Error: $e')),
                      );
                    }
                  }
                }
              },
              child: const Text('Crear'),
            ),
          ],
        ),
      ),
    );
    userCtrl.dispose();
    passCtrl.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Usuarios')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _usuarios.length,
              itemBuilder: (context, i) {
                final u = _usuarios[i];
                return ListTile(
                  leading: Icon(u.isAdmin ? Icons.admin_panel_settings : Icons.person),
                  title: Text(u.username),
                  subtitle: Text(u.role),
                  trailing: u.username == 'admin'
                      ? null
                      : IconButton(
                          icon: const Icon(Icons.delete_outline),
                          onPressed: () async {
                            final ok = await showDialog<bool>(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                title: const Text('Eliminar Usuario'),
                                content: Text('¿Eliminar usuario "${u.username}"?'),
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
                              await _repo.deleteUsuario(u.id!);
                              await _load();
                            }
                          },
                        ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showCreateDialog,
        child: const Icon(Icons.person_add),
      ),
    );
  }
}
