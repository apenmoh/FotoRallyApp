import 'package:flutter/material.dart';
import 'package:foto_rally/Services/firestore_service.dart';
import 'package:foto_rally/Widgets/CustomButton.dart';
import 'package:foto_rally/Widgets/ParticipantTabNav.dart';

class SubirFoto extends StatefulWidget {
  SubirFoto({super.key});

  @override
  State<SubirFoto> createState() => _SubirFotoState();
}

class _SubirFotoState extends State<SubirFoto> {
  FirestoreService firestoreService = FirestoreService();
  final TextEditingController tituloFotoController = TextEditingController();
  final TextEditingController localidadController = TextEditingController();
  final TextEditingController categoriaController = TextEditingController();
  final TextEditingController descripcionController = TextEditingController();

  bool isLoading = false;
  String? selectedCategory;
  List<String> categories = [];

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
      setState(() {
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
        title: Text('Subir Fotos'),
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
                height: 550,
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
                          style: TextStyle(fontSize: 20, color: Colors.white),
                        ),
                        SizedBox(height: 7),
                        DropdownButtonFormField<String>(
                          value: selectedCategory,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
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
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    TextForm(
                      nombre: descripcionController,
                      value: "Descripción",
                    ),
                    SizedBox(height: 40),
                    CustomButton(
                      onPressed: () {},
                      text: "Subir Foto",
                      backgroundColor: Color(0xFF1E3A8A),
                      textColor: Colors.white,
                      borderRadius: 20.0,
                      width: 200,
                    ),
                    SizedBox(height: 20),
                    CustomButton(
                      onPressed: () {},
                      text: "Seleccionar Foto",
                      backgroundColor: Color(0xFF1E3A8A),
                      textColor: Colors.white,
                      borderRadius: 20.0,
                      width: 200,
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
              Text(
                'El tamaño de las fotos no debe sobrepasar los 3 mb',
                style: TextStyle(color: Color(0xFF047857)),
              ),
              SizedBox(height: 10),
              CustomButton(
                onPressed: () {},
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
