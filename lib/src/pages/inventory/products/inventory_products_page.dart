import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:vernelly_app/src/models/inventory/category/categories_model_data.dart';
import 'package:vernelly_app/src/models/inventory/products/products_model_data.dart';
import 'dart:io';
import 'package:vernelly_app/src/pages/inventory/products/inventory_products_controller.dart';

class InventoryProductsPage extends StatefulWidget {
  @override
  _InventoryProductsPageState createState() => _InventoryProductsPageState();
}

class _InventoryProductsPageState extends State<InventoryProductsPage> {
  final InventoryProductsController con = Get.put(InventoryProductsController());
  final _formKey = GlobalKey<FormState>();
  final _editFormKey = GlobalKey<FormState>();
  File? _image;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Gestión de Productos',
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
        } else if (con.filteredProducts.isEmpty) {
          print('Filtered Products: ${con.filteredProducts}');  // Añade esta línea para imprimir los productos filtrados
          return Center(child: Text('No se encontraron productos.'));
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
                  onRefresh: con.fetchProducts,
                  child: ListView.builder(
                    itemCount: con.filteredProducts.length,
                    itemBuilder: (context, index) {
                      final product = con.filteredProducts[index];
                      final category = con.categories.firstWhere(
                            (category) => category.id == product.idCategoria,
                        orElse: () => Category(id: 0, name: 'Sin Categoría'),
                      );
                      return ListTile(
                        title: Text(product.nombre ?? 'Nombre no disponible'),
                        subtitle: Text('Precio: \$${product.precio?.toString() ?? 'N/A'}\nCategoría: ${category.name ?? 'Sin Categoría'}'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _buildActionButton(
                              icon: Icons.edit,
                              color: Colors.blue,
                              onPressed: () => _showEditProductDialog(context, product),
                            ),
                            SizedBox(width: 8),
                            _buildActionButton(
                              icon: product.estado == 'ACTIVO' ? Icons.remove_circle : Icons.add_circle,
                              color: product.estado == 'ACTIVO' ? Colors.red : Colors.green,
                              onPressed: () {
                                if (product.estado == 'ACTIVO') {
                                  _showConfirmationDialog(
                                    context,
                                    'Desactivar producto',
                                    '¿Desea desactivar este producto?',
                                        () => con.deactivateProduct(context, product),
                                  );
                                } else {
                                  _showConfirmationDialog(
                                    context,
                                    'Activar producto',
                                    '¿Desea activar este producto?',
                                        () => con.activateProduct(context, product),
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
              onTap: () => _showAddProductDialog(context, con),
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
                    Text('Agregar Producto', style: TextStyle(color: Colors.purpleAccent)),
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

  Future<void> _pickImage(BuildContext context, StateSetter setState) async {
    final pickedFile = await showDialog<File>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Seleccionar imagen'),
        content: Text('Elige una fuente'),
        actions: [
          TextButton(
            onPressed: () async {
              final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
              if (pickedFile != null) {
                setState(() {
                  _image = File(pickedFile.path);
                });
              }
              Navigator.of(context).pop();
            },
            child: Row(
              children: [
                Icon(Icons.photo_library),
                SizedBox(width: 8),
                Text('Galería'),
              ],
            ),
          ),
          TextButton(
            onPressed: () async {
              final pickedFile = await ImagePicker().pickImage(source: ImageSource.camera);
              if (pickedFile != null) {
                setState(() {
                  _image = File(pickedFile.path);
                });
              }
              Navigator.of(context).pop();
            },
            child: Row(
              children: [
                Icon(Icons.camera_alt),
                SizedBox(width: 8),
                Text('Cámara'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showEditProductDialog(BuildContext context, Product product) {
    final _nombreController = TextEditingController(text: product.nombre ?? '');
    final _precioController = TextEditingController(text: product.precio?.toString() ?? '');
    final _observacionController = TextEditingController(text: product.observacion ?? '');
    final _codigoxController = TextEditingController(text: product.codigox ?? '');
    String _categoria = product.idCategoria?.toString() ?? '';
    File? _image;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            Future<void> _pickImage() async {
              final pickedFile = await showDialog<File>(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text('Seleccionar imagen'),
                  content: Text('Elige una fuente'),
                  actions: [
                    TextButton(
                      onPressed: () async {
                        final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
                        if (pickedFile != null) {
                          setState(() {
                            _image = File(pickedFile.path);
                          });
                        }
                        Navigator.of(context).pop();
                      },
                      child: Row(
                        children: [
                          Icon(Icons.photo_library),
                          SizedBox(width: 8),
                          Text('Galería'),
                        ],
                      ),
                    ),
                    TextButton(
                      onPressed: () async {
                        final pickedFile = await ImagePicker().pickImage(source: ImageSource.camera);
                        if (pickedFile != null) {
                          setState(() {
                            _image = File(pickedFile.path);
                          });
                        }
                        Navigator.of(context).pop();
                      },
                      child: Row(
                        children: [
                          Icon(Icons.camera_alt),
                          SizedBox(width: 8),
                          Text('Cámara'),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }

            return AlertDialog(
              title: Text('Editar Producto', style: TextStyle(color: Colors.purpleAccent)),
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
                        controller: _precioController,
                        decoration: InputDecoration(labelText: 'Precio'),
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'El campo precio es obligatorio';
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
                      TextFormField(
                        controller: _codigoxController,
                        decoration: InputDecoration(labelText: 'Código personalizado'),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'El campo código personalizado es obligatorio';
                          }
                          return null;
                        },
                      ),
                      DropdownButtonFormField<String>(
                        value: _categoria.isNotEmpty ? _categoria : null,
                        onChanged: (String? newValue) {
                          setState(() {
                            _categoria = newValue!;
                          });
                        },
                        items: con.categories.map((category) {
                          return DropdownMenuItem<String>(
                            value: category.id.toString(),
                            child: Text(category.name ?? 'Sin Categoría'),
                          );
                        }).toList(),
                        decoration: InputDecoration(labelText: 'Categoría'),
                      ),
                      SizedBox(height: 16),
                      GestureDetector(
                        onTap: () => _pickImage(),
                        child: _image == null
                            ? Container(
                          width: 100,
                          height: 100,
                          color: Colors.grey[300],
                          child: Icon(Icons.add_a_photo, color: Colors.grey[800]),
                        )
                            : Image.file(
                          _image!,
                          width: 100,
                          height: 100,
                          fit: BoxFit.cover,
                        ),
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
                            final updatedProduct = product.copyWith(
                              nombre: _nombreController.text,
                              precio: double.tryParse(_precioController.text),
                              observacion: _observacionController.text,
                              codigox: _codigoxController.text,
                              idCategoria: int.tryParse(_categoria),
                            );
                            con.updateProduct(updatedProduct, _image);
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
      },
    );
  }




  void _showAddProductDialog(BuildContext context, InventoryProductsController con) {
    final _nombreController = TextEditingController();
    final _precioController = TextEditingController();
    final _observacionController = TextEditingController();
    final _codigoxController = TextEditingController();
    String _categoria = con.categories.isNotEmpty ? con.categories[0].id.toString() : '';

    File? _image;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            Future<void> _pickImage() async {
              final pickedFile = await showDialog<File>(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text('Seleccionar imagen'),
                  content: Text('Elige una fuente'),
                  actions: [
                    TextButton(
                      onPressed: () async {
                        final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
                        if (pickedFile != null) {
                          setState(() {
                            _image = File(pickedFile.path);
                          });
                        }
                        Navigator.of(context).pop();
                      },
                      child: Row(
                        children: [
                          Icon(Icons.photo_library),
                          SizedBox(width: 8),
                          Text('Galería'),
                        ],
                      ),
                    ),
                    TextButton(
                      onPressed: () async {
                        final pickedFile = await ImagePicker().pickImage(source: ImageSource.camera);
                        if (pickedFile != null) {
                          setState(() {
                            _image = File(pickedFile.path);
                          });
                        }
                        Navigator.of(context).pop();
                      },
                      child: Row(
                        children: [
                          Icon(Icons.camera_alt),
                          SizedBox(width: 8),
                          Text('Cámara'),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }

            return AlertDialog(
              title: Text('Nuevo Producto', style: TextStyle(color: Colors.purpleAccent)),
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
                        controller: _precioController,
                        decoration: InputDecoration(labelText: 'Precio'),
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'El campo precio es obligatorio';
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
                      TextFormField(
                        controller: _codigoxController,
                        decoration: InputDecoration(labelText: 'Código personalizado'),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'El campo código personalizado es obligatorio';
                          }
                          return null;
                        },
                      ),
                      DropdownButtonFormField<String>(
                        value: _categoria.isNotEmpty ? _categoria : null,
                        onChanged: (String? newValue) {
                          setState(() {
                            _categoria = newValue!;
                          });
                        },
                        items: con.categories.map((category) {
                          return DropdownMenuItem<String>(
                            value: category.id.toString(),
                            child: Text(category.name ?? 'Sin Categoría'),
                          );
                        }).toList(),
                        decoration: InputDecoration(labelText: 'Categoría'),
                      ),
                      SizedBox(height: 16),
                      GestureDetector(
                        onTap: _pickImage,
                        child: _image == null
                            ? Container(
                          width: 100,
                          height: 100,
                          color: Colors.grey[300],
                          child: Icon(Icons.add_a_photo, color: Colors.grey[800]),
                        )
                            : Image.file(
                          _image!,
                          width: 100,
                          height: 100,
                          fit: BoxFit.cover,
                        ),
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
                        child: Text('CANCELAR', style: TextStyle(color: Colors.white)),
                        style: TextButton.styleFrom(
                          backgroundColor: Colors.purpleAccent,
                        ),
                      ),
                    ),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            final newProduct = Product(
                              nombre: _nombreController.text,
                              precio: double.tryParse(_precioController.text),
                              observacion: _observacionController.text,
                              codigox: _codigoxController.text,
                              idCategoria: int.tryParse(_categoria), // Asigna la categoría seleccionada
                              estado: 'ACTIVO',
                            );
                            con.addProduct(newProduct, _image);
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
      },
    );
  }
}
