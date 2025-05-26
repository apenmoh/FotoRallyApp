import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:foto_rally/Services/alert_service.dart';
import 'package:foto_rally/Services/cloudinary_service.dart';
import 'package:foto_rally/Services/firestore_service.dart';
import 'package:foto_rally/Services/image_picker_service.dart';
import 'package:foto_rally/Services/user_service.dart';
import 'package:foto_rally/Widgets/CustomButton.dart';
import 'package:foto_rally/Widgets/ParticipantTabNav.dart';

class SubirFoto extends StatefulWidget {
  SubirFoto({super.key});

  @override
  State<SubirFoto> createState() => _SubirFotoState();
}

class _SubirFotoState extends State<SubirFoto> {
  FirestoreService firestoreService = FirestoreService();
  ImagePickerService imagePickerService = ImagePickerService();
  CloudinaryService cloudinaryService = CloudinaryService();
  AlertService alertService = AlertService();
  UserService userService = UserService();

  final TextEditingController tituloFotoController = TextEditingController();
  final TextEditingController localidadController = TextEditingController();
  final TextEditingController categoriaController = TextEditingController();
  final TextEditingController descripcionController = TextEditingController();

  bool isLoading = false;
  String? selectedCategory;
  File? selectedImageFile;
  List<String> categories = [];
  String? theme;
  String userId = '';

  @override
  void initState() {
    super.initState();
    getData();
  }

  void getData() async {
    setState(() {
      isLoading = true;
    });
    try {
      final cta = await firestoreService.getRallyCategories();
      final rules = await firestoreService.getRallyRules();
      if (rules.exists) {
        setState(() {
          theme = rules['theme'];
        });
      } else {
        throw Exception('No se encontraron reglas en la base de datos.');
      }
      final uid = await userService.getUserId();
      setState(() {
        userId = uid;
        categories = cta;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error al cargar categorías: $e')));
    }
  }

  Future<void> TomarFoto() async {
    setState(() {
      isLoading = true;
    });
    try {
      await imagePickerService.openCamera().then((file) async {
        if (file != null) {
          setState(() {
            selectedImageFile = file;
            isLoading = false;
          });
        } else {
          setState(() {
            isLoading = false;
          });
        }
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> SelecionarFoto() async {
    setState(() {
      isLoading = true;
    });
    try {
      await imagePickerService.openGallery().then((file) async {
        if (file != null) {
          setState(() {
            selectedImageFile = file;
            isLoading = false;
          });
        } else {
          setState(() {
            isLoading = false;
          });
        }
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }
  
  Future<void> SavePhoto() async {
    setState(() {
      isLoading = true;
    });
    try {
      if (selectedImageFile != null &&
          theme != null &&
          userId.isNotEmpty &&
          selectedCategory != null &&
          tituloFotoController.text.isNotEmpty &&
          localidadController.text.isNotEmpty &&
          categoriaController.text.isNotEmpty &&
          descripcionController.text.isNotEmpty) {
        String? imageUrl = await cloudinaryService.uploadImage(selectedImageFile!);
        if (imageUrl != null) {
          final now = DateTime.now();
          final photoData = {
            'photoId': '',
            'userId': userId,
            'url': imageUrl,
            'status': 'pendiente',
            'uploadDate': Timestamp.fromDate(now),
            'title': tituloFotoController.text,
            'category': categoriaController.text,
            'description': descripcionController.text, 
            'theme': theme, 
            'votes': 0,
            'location': localidadController.text,
          };

          await firestoreService.addPhoto(photoData);
          clearAll();
          alertService.success(context, 'Solicitud de subida de foto enviada correctamente.');
        } else {
          alertService.error(context, 'Error al subir la foto');
        }
      } else {
        alertService.error(context, 'Falta datos requeridos');
      }
    } catch (e) {
      alertService.error(context, 'Error al subir la foto: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }
  void clearAll() {
    tituloFotoController.clear();
    localidadController.clear();
    categoriaController.clear();
    descripcionController.clear();
    setState(() {
      selectedImageFile = null;
      selectedCategory = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (categories.isEmpty) {
      return Scaffold(
        body: Center(child: Text('No se encontraron categorías disponibles.')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Subir Fotos',style: TextStyle(color: Colors.white),),
        centerTitle: true,
        backgroundColor: Color(0xFF1A56DB),
      ),
      bottomNavigationBar: ParticipantTabNav(),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 20),
              Container(
                width: double.infinity,
                height: 600,
                padding: EdgeInsets.all(16.0),
                margin: EdgeInsets.only(bottom: 20),
                color: Color(0xFF1A56DB),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    TextForm(
                      nombre: tituloFotoController,
                      value: "Título de la Foto",
                    ),
                    SizedBox(height: 10),
                    TextForm(nombre: localidadController, value: "Localidad"),
                    SizedBox(height: 20),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Categoría',
                          style: TextStyle(fontSize: 20, color: Colors.black),
                        ),
                        SizedBox(height: 7),
                        CategorySelect(),
                      ],
                    ),
                    SizedBox(height: 10),
                    TextForm(
                      nombre: descripcionController,
                      value: "Descripción",
                    ),
                    SizedBox(height: 40),
                    CustomButton(
                      onPressed: TomarFoto,
                      text: "Capturar Foto",
                      backgroundColor: Color(0xFF1E3A8A),
                      textColor: Colors.white,
                      borderRadius: 20.0,
                      width: 200,
                    ),
                    SizedBox(height: 20),
                    CustomButton(
                      onPressed: SelecionarFoto,
                      text: "Seleccionar Foto",
                      backgroundColor: Color(0xFF1E3A8A),
                      textColor: Colors.white,
                      borderRadius: 20.0,
                      width: 200,
                    ),
                  ],
                ),
              ),
              if (selectedImageFile != null)
                Image.file(
                  selectedImageFile!,
                  width: 200,
                  height: 200,
                ),  
              SizedBox(height: 20),
              Text(
                'El tamaño de las fotos no debe sobrepasar los 3 mb',
                style: TextStyle(color: Color(0xFF047857)),
              ),
              SizedBox(height: 10),
              CustomButton(
                onPressed: SavePhoto,
                text: "Solicitar Subida de foto",
                backgroundColor: Color(0xFF047857),
                textColor: Colors.white,
                borderRadius: 20,
                width: 300,
              ),
            ],
          ),
        ),
      ),
    );
  }


  DropdownButtonFormField<String> CategorySelect() {
    return DropdownButtonFormField<String>(
      value: selectedCategory,
      decoration: InputDecoration(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        filled: true,
        fillColor: Colors.white,
        labelText: 'Categoría',
        labelStyle: TextStyle(color: Colors.black),
      ),
      items:
          categories.map((String category) {
            return DropdownMenuItem<String>(
              value: category,
              child: Text(category),
            );
          }).toList(),
      onChanged: (String? newValue) {
        setState(() {
          selectedCategory = newValue;
          categoriaController.text = newValue ?? '';
        });
      },
    );
  }
}

class TextForm extends StatelessWidget {
  const TextForm({
    super.key,
    required TextEditingController nombre,
    required String value,
  }) : _nombre = nombre,
       _value = value;

  final TextEditingController _nombre;
  final String _value;

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(_value, style: TextStyle(fontSize: 20, color: Colors.black)),
          SizedBox(height: 7),
          TextFormField(
            controller: _nombre,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              filled: true,
              fillColor: Colors.white,
              labelText: _value,
              labelStyle: TextStyle(color: Colors.black),
            ),
          ),
        ],
      ),
    );
  }
}