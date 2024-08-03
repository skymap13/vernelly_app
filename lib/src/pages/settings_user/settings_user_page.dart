import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vernelly_app/src/models/settings_users/user_model_data.dart';
import 'package:vernelly_app/src/pages/settings_user/settings_user_controller.dart';
import 'package:flutter/services.dart';

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final SettingsController con = Get.put(SettingsController());
  final _formKey = GlobalKey<FormState>();
  final _editFormKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Configuración de usuarios',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.purpleAccent,
      ),
      body: Obx(() {
        if (con.isLoading.value) {
          return Center(child: CircularProgressIndicator());
        } else {
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  onChanged: con.updateSearchQuery,
                  decoration: InputDecoration(
                    hintText: 'Buscar...',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: con.fetchUsers,
                  child: ListView.builder(
                    itemCount: con.filteredUsers.length,
                    itemBuilder: (context, index) {
                      final user = con.filteredUsers[index];
                      return ListTile(
                        title: Text('${user.nombre ?? 'Nombre no disponible'} ${user.apellido ?? ''}'),
                        subtitle: Text(user.correo ?? 'Email no disponible'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _buildActionButton(
                              icon: Icons.edit,
                              color: Colors.blue,
                              onPressed: () => _showEditUserDialog(context, user),
                            ),
                            SizedBox(width: 8),
                            _buildActionButton(
                              icon: user.estado == 'ACTIVO' ? Icons.remove_circle : Icons.add_circle,
                              color: user.estado == 'ACTIVO' ? Colors.red : Colors.green,
                              onPressed: () {
                                if (user.estado == 'ACTIVO') {
                                  con.deactivateUser(context, user);
                                } else {
                                  con.activateUser(context, user);
                                }
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          );
        }
      }),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.purpleAccent,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
        ),
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            GestureDetector(
              onTap: () => _showAddUserDialog(context, con),
              child: AnimatedContainer(
                duration: Duration(milliseconds: 250),
                padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      spreadRadius: 1,
                      blurRadius: 2,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.add, color: Colors.purpleAccent),
                    SizedBox(width: 10),
                    Text('Agregar Usuario', style: TextStyle(color: Colors.purpleAccent)),
                  ],
                ),
              ),
            ),
            GestureDetector(
              onTap: () => con.downloadReport(),
              child: AnimatedContainer(
                duration: Duration(milliseconds: 250),
                padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      spreadRadius: 1,
                      blurRadius: 2,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.download, color: Colors.purpleAccent),
                    SizedBox(width: 10),
                    Text('Descargar Reporte', style: TextStyle(color: Colors.purpleAccent)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({required IconData icon, required Color color, required VoidCallback onPressed}) {
    return Container(
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 4,
            offset: Offset(2, 2),
          ),
        ],
      ),
      child: IconButton(
        icon: Icon(icon, color: Colors.white),
        onPressed: onPressed,
      ),
    );
  }

  void _showEditUserDialog(BuildContext context, User user) {
    final _nombreController = TextEditingController(text: user.nombre);
    final _apellidoController = TextEditingController(text: user.apellido);
    final _celularController = TextEditingController(text: user.celular);
    final _correoController = TextEditingController(text: user.correo);
    final _observacionController = TextEditingController(text: user.observacion);
    int _perfilCodigo = user.idPerfil ?? 16;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Editar Usuario', style: TextStyle(color: Colors.purpleAccent)),
          content: SingleChildScrollView(
            child: Form(
              key: _editFormKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _nombreController,
                    decoration: InputDecoration(labelText: 'Nombre'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'El campo nombre es obligatorio';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _apellidoController,
                    decoration: InputDecoration(labelText: 'Apellido'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'El campo apellido es obligatorio';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _celularController,
                    decoration: InputDecoration(labelText: 'Celular'),
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      LengthLimitingTextInputFormatter(10),
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'El campo celular es obligatorio';
                      }
                      if (value.length != 10) {
                        return 'El celular debe tener 10 dígitos';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _correoController,
                    decoration: InputDecoration(labelText: 'Correo'),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'El campo correo es obligatorio';
                      }
                      if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                        return 'Correo inválido';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _observacionController,
                    decoration: InputDecoration(labelText: 'Observación'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'El campo observación es obligatorio';
                      }
                      return null;
                    },
                  ),
                  DropdownButtonFormField<int>(
                    value: _perfilCodigo,
                    onChanged: (int? newValue) {
                      _perfilCodigo = newValue!;
                    },
                    items: [
                      DropdownMenuItem<int>(value: 16, child: Text('SUPER')),
                      DropdownMenuItem<int>(value: 22, child: Text('ADMINISTRADOR')),
                      DropdownMenuItem<int>(value: 31, child: Text('CLIENTE')),
                    ],
                    decoration: InputDecoration(labelText: 'Perfil'),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text('CANCELAR'),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.purpleAccent,
                    ),
                  ),
                ),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      if (_editFormKey.currentState!.validate()) {
                        final updatedUser = user.copyWith(
                          nombre: _nombreController.text,
                          apellido: _apellidoController.text,
                          celular: _celularController.text,
                          correo: _correoController.text,
                          observacion: _observacionController.text,
                          idPerfil: _perfilCodigo,
                        );
                        con.updateUser(updatedUser);
                        Navigator.of(context).pop();
                      }
                    },
                    child: Text('GUARDAR'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purpleAccent,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  void _showAddUserDialog(BuildContext context, SettingsController con) {
    final _nombreController = TextEditingController();
    final _apellidoController = TextEditingController();
    final _celularController = TextEditingController();
    final _correoController = TextEditingController();
    final _observacionController = TextEditingController();
    String _perfil = 'SUPER';
    int _perfilCodigo = 16;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Nuevo Usuario', style: TextStyle(color: Colors.purpleAccent)),
          content: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _nombreController,
                    decoration: InputDecoration(labelText: 'Nombre'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'El campo nombre es obligatorio';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _apellidoController,
                    decoration: InputDecoration(labelText: 'Apellido'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'El campo apellido es obligatorio';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _celularController,
                    decoration: InputDecoration(labelText: 'Celular'),
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      LengthLimitingTextInputFormatter(10),
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'El campo celular es obligatorio';
                      }
                      if (value.length != 10) {
                        return 'El celular debe tener 10 dígitos';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _correoController,
                    decoration: InputDecoration(labelText: 'Correo'),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'El campo correo es obligatorio';
                      }
                      if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                        return 'Correo inválido';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _observacionController,
                    decoration: InputDecoration(labelText: 'Observación'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'El campo observación es obligatorio';
                      }
                      return null;
                    },
                  ),
                  DropdownButtonFormField<String>(
                    value: _perfil,
                    onChanged: (String? newValue) {
                      setState(() {
                        _perfil = newValue!;
                        if (_perfil == 'SUPER') {
                          _perfilCodigo = 16;
                        } else if (_perfil == 'ADMINISTRADOR') {
                          _perfilCodigo = 22;
                        } else if (_perfil == 'CLIENTE') {
                          _perfilCodigo = 31;
                        }
                      });
                    },
                    items: <String>['SUPER', 'ADMINISTRADOR', 'CLIENTE'].map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    decoration: InputDecoration(labelText: 'Perfil'),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text('CANCELAR'),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.purpleAccent,
                    ),
                  ),
                ),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        final newUser = User(
                          nombre: _nombreController.text,
                          apellido: _apellidoController.text,
                          celular: _celularController.text,
                          correo: _correoController.text,
                          observacion: _observacionController.text,
                          estado: 'ACTIVO',
                          idPerfil: _perfilCodigo,
                        );
                        con.addUser(newUser);
                        Navigator.of(context).pop();
                      }
                    },
                    child: Text('GUARDAR'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purpleAccent,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}
