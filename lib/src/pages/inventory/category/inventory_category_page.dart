import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vernelly_app/src/models/inventory/category/categories_model_data.dart';
import 'inventory_category_controller.dart';

class InventoryCategoryPage extends StatefulWidget {
  @override
  _InventoryCategoryPageState createState() => _InventoryCategoryPageState();
}

class _InventoryCategoryPageState extends State<InventoryCategoryPage> {
  final InventoryCategoryController con = Get.put(InventoryCategoryController());
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Gestión de Categorías',
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
        } else if (con.filteredCategories.isEmpty) {
          return Center(child: Text('No se encontraron categorías.'));
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
                  onRefresh: con.fetchCategories,
                  child: ListView.builder(
                    itemCount: con.filteredCategories.length,
                    itemBuilder: (context, index) {
                      final category = con.filteredCategories[index];
                      return ListTile(
                        title: Text(category.name ?? 'Nombre no disponible'),
                        subtitle: Text(category.observation ?? 'S/N'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _buildActionButton(
                              icon: Icons.edit,
                              color: Colors.blue,
                              onPressed: () => _showEditCategoryDialog(context, category),
                            ),
                            SizedBox(width: 8),
                            _buildActionButton(
                              icon: category.status == 'ACTIVO' ? Icons.remove_circle : Icons.add_circle,
                              color: category.status == 'ACTIVO' ? Colors.red : Colors.green,
                              onPressed: () {
                                if (category.status == 'ACTIVO') {
                                  _showConfirmationDialog(
                                    context,
                                    'Desactivar categoría',
                                    '¿Desea desactivar esta categoría?',
                                        () => con.deactivateCategory(context, category),
                                  );
                                } else {
                                  _showConfirmationDialog(
                                    context,
                                    'Activar categoría',
                                    '¿Desea activar esta categoría?',
                                        () => con.activateCategory(context, category),
                                  );
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
      bottomNavigationBar: BottomAppBar(
        color: Colors.purpleAccent,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _showAddCategoryDialog(context),
                  icon: Icon(Icons.add),
                  label: Text('Agregar Categoría'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.purpleAccent,
                  ),
                ),
              ),
              SizedBox(width: 8),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => con.downloadReport(),
                  icon: Icon(Icons.download),
                  label: Text('Descargar Reporte'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.purpleAccent,
                  ),
                ),
              ),
            ],
          ),
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

  void _showConfirmationDialog(BuildContext context, String title, String content, VoidCallback onConfirm) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            title,
            style: TextStyle(
              color: Colors.purpleAccent,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(content),
          actions: <Widget>[
            TextButton(
              child: Text(
                'CANCELAR',
                style: TextStyle(color: Colors.purpleAccent),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text(
                'ACEPTAR',
                style: TextStyle(color: Colors.purpleAccent),
              ),
              onPressed: () {
                Navigator.of(context).pop();
                onConfirm();
              },
            ),
          ],
        );
      },
    );
  }

  void _showEditCategoryDialog(BuildContext context, Category category) {
    final _nameController = TextEditingController(text: category.name);
    final _observationController = TextEditingController(text: category.observation);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Editar Categoría', style: TextStyle(color: Colors.purpleAccent)),
          content: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(labelText: 'Nombre'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'El campo nombre es obligatorio';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _observationController,
                    decoration: InputDecoration(labelText: 'Observación'),
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
                        final updatedCategory = category.copyWith(
                          name: _nameController.text,
                          observation: _observationController.text,
                        );
                        con.updateCategory(updatedCategory);
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

  void _showAddCategoryDialog(BuildContext context) {
    final _nameController = TextEditingController();
    final _observationController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Nueva Categoría', style: TextStyle(color: Colors.purpleAccent)),
          content: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(labelText: 'Nombre'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'El campo nombre es obligatorio';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _observationController,
                    decoration: InputDecoration(labelText: 'Observación'),
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
                        final newCategory = Category(
                          name: _nameController.text,
                          observation: _observationController.text,
                          status: 'ACTIVO',
                        );
                        con.addCategory(newCategory);
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
