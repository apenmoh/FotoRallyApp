import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:foto_rally/Services/alert_service.dart';
import 'package:foto_rally/Services/cloudinary_service.dart';
import 'package:foto_rally/Services/firestore_service.dart';
import 'package:foto_rally/Services/image_picker_service.dart';
import 'package:foto_rally/Services/user_service.dart';
import 'package:foto_rally/Widgets/CustomButton.dart';
import 'package:foto_rally/Widgets/TabNavigation.dart';

class SubirFoto extends StatefulWidget {
  SubirFoto({super.key});

  @override
  State<SubirFoto> createState() => _SubirFotoState();
}

class _SubirFotoState extends State<SubirFoto> {

  final FirestoreService firestoreService = FirestoreService();
  final ImagePickerService imagePickerService = ImagePickerService();
  final CloudinaryService cloudinaryService = CloudinaryService();
  final AlertService alertService = AlertService(); 
  final UserService userService = UserService();

  // Controladores de texto
  final TextEditingController tituloFotoController = TextEditingController();
  final TextEditingController localidadController = TextEditingController();
  final TextEditingController categoriaController = TextEditingController();
  final TextEditingController descripcionController = TextEditingController();

  // Variables de estado
  bool isLoading = false;
  String? selectedCategory;
  File? selectedImageFile;
  List<String> categories = [];
  String? theme;
  String userId = '';

  @override
  void initState() {
    super.initState();
    _getData();
  }

  @override
  void dispose() {
    tituloFotoController.dispose();
    localidadController.dispose();
    categoriaController.dispose();
    descripcionController.dispose();
    super.dispose();
  }


  void _getData() async {
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
      // Uso de tu AlertService para mostrar SnackBar
      alertService.error(context, 'Error al cargar categorías: $e');
    }
  }

  Future<void> _pickImage(ImageSourceType sourceType) async {
    setState(() {
      isLoading = true;
    });
    try {
      final file = sourceType == ImageSourceType.camera
          ? await imagePickerService.openCamera()
          : await imagePickerService.openGallery();

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
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      alertService.error(context, 'Error al seleccionar imagen: $e');
    }
  }

  Future<void> _savePhoto() async {
    setState(() {
      isLoading = true;
    });
    final rallyRules = await firestoreService.getRallyRules();
    if(!rallyRules['isRallyActive'] || (rallyRules['endDate'] as Timestamp).toDate().isBefore(DateTime.now())) {
      alertService.error(context, 'El rally no está activo. No se pueden subir fotos.');
      return;
    }
    try {
      if (selectedImageFile == null ||
          theme == null ||
          userId.isEmpty ||
          selectedCategory == null ||
          tituloFotoController.text.isEmpty ||
          localidadController.text.isEmpty ||
          descripcionController.text.isEmpty) {
        alertService.error(context, 'Faltan datos requeridos');
        return;
      }

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
          'category': selectedCategory, // Usar selectedCategory directamente
          'description': descripcionController.text,
          'theme': theme,
          'votes': 0,
          'location': localidadController.text,
        };

        await firestoreService.addPhoto(photoData);
        _clearAll();
        // Uso de tu AlertService para mostrar SnackBar de éxito
        alertService.success(context, 'Solicitud de subida de foto enviada correctamente.');
      } else {
        alertService.error(context, 'Error al subir la foto');
      }
    } catch (e) {
      alertService.error(context, 'Error al subir la foto: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _clearAll() {
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
    // Colores originales
    const Color primaryBlue = Color(0xFF1A56DB);
    const Color darkBlue = Color(0xFF1E3A8A);
    const Color successGreen = Color(0xFF047857);
    const Color whiteText = Colors.white;
    const Color blackText = Colors.black; 

    if (isLoading && categories.isEmpty) {
      return Scaffold(
        backgroundColor: Colors.white, // Fondo blanco para la carga
        body: Center(child: CircularProgressIndicator(color: primaryBlue)),
      );
    }

    if (!isLoading && categories.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Subir Fotos', style: TextStyle(color: whiteText)),
          centerTitle: true,
          backgroundColor: primaryBlue,
          elevation: 0, // AppBar sin sombra para un look moderno
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.info_outline, size: 60, color: primaryBlue),
                const SizedBox(height: 20),
                Text(
                  'No se encontraron categorías disponibles. Por favor, intente de nuevo más tarde.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18, color: blackText),
                ),
                const SizedBox(height: 30),
                CustomButton(
                  onPressed: _getData, // Opción para reintentar
                  text: "Reintentar Carga",
                  backgroundColor: primaryBlue,
                  textColor: whiteText,
                  borderRadius: 12.0,
                  width: 200,
                  height: 50,
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey.shade50, // Un fondo ligeramente gris para el cuerpo
      appBar: AppBar(
        title: const Text('Subir Fotos', style: TextStyle(color: whiteText, fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: primaryBlue,
        elevation: 0, // AppBar sin sombra
        iconTheme: const IconThemeData(color: whiteText), // Color de los iconos del AppBar
      ),
      bottomNavigationBar:  Tabnavigation(),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 25.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Contenedor principal de formulario
                Container(
                  padding: const EdgeInsets.all(20.0),
                  decoration: BoxDecoration(
                    color: primaryBlue, // Fondo del contenedor con el azul original
                    borderRadius: BorderRadius.circular(20.0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.25), // Sombra más pronunciada para el contenedor principal
                        spreadRadius: 2,
                        blurRadius: 15,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      _buildStyledTextField(tituloFotoController, 'Título de la Foto',
                          labelColor: whiteText, inputFillColor: whiteText, inputTextColor: blackText),
                      const SizedBox(height: 18),
                      _buildStyledTextField(localidadController, 'Localidad',
                          labelColor: whiteText, inputFillColor: whiteText, inputTextColor: blackText),
                      const SizedBox(height: 18),
                      _buildCategoryDropdown(whiteText, primaryBlue, whiteText, blackText),
                      const SizedBox(height: 18),
                      _buildStyledTextField(descripcionController, 'Descripción', maxLines: 4,
                          labelColor: whiteText, inputFillColor: whiteText, inputTextColor: blackText),
                      const SizedBox(height: 30),
                      CustomButton(
                        onPressed: () => _pickImage(ImageSourceType.camera),
                        text: "Capturar Foto",
                        backgroundColor: darkBlue,
                        textColor: whiteText,
                        borderRadius: 28.0, 
                        width: 200, 
                        height: 35, 
                      ),
                      const SizedBox(height: 15),
                      CustomButton(
                        onPressed: () => _pickImage(ImageSourceType.gallery),
                        text: "Abrir Galería",
                        backgroundColor: darkBlue,
                        textColor: whiteText,
                        borderRadius: 28.0, // Más redondeado
                        width:200,
                        height: 45, // Un poco más alto
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),

                // Previsualización de la imagen seleccionada
                if (selectedImageFile != null) ...[
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: primaryBlue, width: 3), // Borde claro para la imagen
                      borderRadius: BorderRadius.circular(18), // Más redondeado
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black,
                          spreadRadius: 1,
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(15), // Menos que el borde para efecto
                      child: Image.file(
                        selectedImageFile!,
                        width: MediaQuery.of(context).size.width * 0.75, 
                        height: MediaQuery.of(context).size.width * 0.75,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),
                  TextButton.icon(
                    onPressed: () {
                      setState(() {
                        selectedImageFile = null;
                      });
                    },
                    icon: const Icon(Icons.clear, color: Colors.redAccent), 
                    label: const Text('Quitar imagen', style: TextStyle(color: Colors.redAccent, fontSize: 16)),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                  const SizedBox(height: 30),
                ],

                Text(
                  'El tamaño de las fotos no debe sobrepasar los 3 MB',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: successGreen, 
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    fontStyle: FontStyle.italic, 
                  ),
                ),
                const SizedBox(height: 25),

                // Botón final de envío
                CustomButton(
                  onPressed: _savePhoto,
                  text: "Solicitar Subida de Foto",
                  backgroundColor: successGreen,
                  textColor: whiteText,
                  borderRadius: 30,
                  width: 400, 
                  height: 58, 
                  elevation: 8, 
                ),
                const SizedBox(height: 40), // Espacio al final para el scroll
              ],
            ),
          ),
          if (isLoading)
            Container(
              color: Colors.black, 
              child: Center(
                child: CircularProgressIndicator(color: whiteText), // Indicador blanco para contraste
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStyledTextField(
    TextEditingController controller,
    String labelText, {
    int maxLines = 1,
    required Color labelColor,
    required Color inputFillColor,
    required Color inputTextColor,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Text(
            labelText,
            style: TextStyle(fontSize: 16, color: labelColor, fontWeight: FontWeight.w500),
          ),
        ),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          style: TextStyle(color: inputTextColor, fontSize: 16), 
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none, 
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.blueAccent, width: 2.0), 
            ),
            filled: true,
            fillColor: inputFillColor, 
            hintText: labelText,
            hintStyle: TextStyle(color: Colors.grey.shade500),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryDropdown(
    Color labelColor,
    Color borderColor, 
    Color fillColor,
    Color itemTextColor,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Text(
            'Categoría',
            style: TextStyle(fontSize: 16, color: labelColor, fontWeight: FontWeight.w500),
          ),
        ),
        DropdownButtonFormField<String>(
          value: selectedCategory,
          style: TextStyle(color: itemTextColor, fontSize: 16), 
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none, 
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.blueAccent, width: 2.0), 
            ),
            filled: true,
            fillColor: fillColor, // Fondo blanco
            hintText: 'Selecciona una categoría',
            hintStyle: TextStyle(color: Colors.grey[500]),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
          icon: Icon(Icons.arrow_drop_down, color: itemTextColor), 
          items: categories.map((String category) {
            return DropdownMenuItem<String>(
              value: category,
              child: Text(category, style: TextStyle(color: itemTextColor)), 
            );
          }).toList(),
          onChanged: (String? newValue) {
            setState(() {
              selectedCategory = newValue;
              categoriaController.text = newValue ?? '';
            });
          },
        ),
      ],
    );
  }
}


enum ImageSourceType { camera, gallery }
