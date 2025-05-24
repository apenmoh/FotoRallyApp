import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:foto_rally/Services/alert_service.dart';
import 'package:foto_rally/Services/firestore_service.dart';
import 'package:foto_rally/Widgets/Admin/Admin_TabNav.dart';
import 'package:foto_rally/Widgets/CustomButton.dart';
import 'package:intl/intl.dart';


class Configuration extends StatefulWidget {
  const Configuration({super.key});

  @override
  State<Configuration> createState() => _ConfigurationState();
}

class _ConfigurationState extends State<Configuration> {
  final _formKey = GlobalKey<FormState>();
  bool isLoading = false;
  bool allowPhotoUploads = false;
  bool allowVoting = false;
  bool isRallyActive = false;

  DateTime? startDate;
  DateTime? endDate;

  List<String> allowedCategories = [];

  FirestoreService firestoreService = FirestoreService();
  AlertService alertService = AlertService();
  

  final TextEditingController _categoryController = TextEditingController();
  final TextEditingController _themeController = TextEditingController();
  final TextEditingController _rulesController = TextEditingController();
  final TextEditingController _photoLimitController = TextEditingController();
  final TextEditingController _voteLimitController = TextEditingController();


  final DateFormat dateFormatter = DateFormat('dd/MM/yyyy');

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    setState(() {
      isLoading = true;
    });
    final snapshot =await firestoreService.getRallyRules();
    final data = snapshot.data();
    if (data != null) {
      final Map<String, dynamic> mapData = data as Map<String, dynamic>;
      setState(() {
        allowPhotoUploads = mapData['allowPhotoUploads'] ?? false;
        allowVoting = mapData['allowVoting'] ?? false;
        isRallyActive = mapData['isRallyActive'] ?? false;
        allowedCategories = List<String>.from(mapData['allowedCategories'] ?? []);
        startDate = (mapData['startDate'] as Timestamp).toDate();
        endDate = (mapData['endDate'] as Timestamp).toDate();
        _rulesController.text = mapData['rules'] ?? '';
        _themeController.text = mapData['theme'] ?? '';
        _photoLimitController.text = (mapData['photoLimit'] ?? 0).toString();
        _voteLimitController.text = (mapData['voteLimit'] ?? 0).toString();
      });
    }
    setState(() {
      isLoading = false;
    });
  }

  Future<void> saveData() async {
    setState(() {
      isLoading = true;
    });
    final rules = {
      'allowPhotoUploads': allowPhotoUploads,
      'allowVoting': allowVoting,
      'isRallyActive': isRallyActive,
      'allowedCategories': allowedCategories,
      'startDate': Timestamp.fromDate(startDate ?? DateTime.now()),
      'endDate': Timestamp.fromDate(endDate ?? DateTime.now()),
      'rules': _rulesController.text,
      'theme': _themeController.text,
      'photoLimit': int.tryParse(_photoLimitController.text) ?? 0,
      'voteLimit': int.tryParse(_voteLimitController.text) ?? 0,
    };
    await firestoreService.updateRallyRules(rules);

    alertService.success(context, "Configuración guardada correctamente.");
    setState(() {
      isLoading = false;
    });
  }

  Future<void> pickDate(bool isStart) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2024),
      lastDate: DateTime(2035),
    );

    if (picked != null) {
      setState(() {
        if (isStart) {
          startDate = picked;
        } else {
          endDate = picked;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Configuración del Rally'),
          backgroundColor: Colors.blue.shade700,
          foregroundColor: Colors.white,
          centerTitle: true,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configuración del Rally'),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      bottomNavigationBar: AdminTabNav(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            elevation: 4,
            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  SwitchListTile(
                    title: const Text('Rally activo'),
                    value: isRallyActive,
                    activeColor: Colors.indigo,
                    inactiveThumbColor: Colors.blueGrey,
                    onChanged: (val) => setState(() => isRallyActive = val),
                  ),
                   SizedBox(height: 10),
                  TextForm(
                    nombre: _themeController,
                    value: 'Tema del Rally',
                  ),
                  SizedBox(height: 10),
                  TextForm(
                    nombre: _photoLimitController,
                    value: "Límite de fotos por usuario",
                  ),
                  SizedBox(height: 10),
                  TextForm(
                    nombre: _voteLimitController,
                    value: "Límite de votos por usuario",
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                     Text("Fecha de inicio: ${startDate != null ? dateFormatter.format(startDate!) : ''}"),
                      IconButton(
                        icon: const Icon(Icons.calendar_today),
                        onPressed: () => pickDate(true),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Fecha fin: ${endDate != null ? dateFormatter.format(endDate!) : ''}"),
                      IconButton(
                        icon: const Icon(Icons.calendar_today),
                        onPressed: () => pickDate(false),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Text("Categorías permitidas", style: TextStyle(fontWeight: FontWeight.bold)),
                  Wrap(
                    spacing: 8,
                    children: allowedCategories.map((cat) {
                      return Chip(
                        label: Text(cat),
                        deleteIcon: const Icon(Icons.close),
                        onDeleted: () {
                          setState(() {
                            allowedCategories.remove(cat);
                          });
                        },
                      );
                    }).toList(),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _categoryController,
                          decoration: const InputDecoration(labelText: 'Añadir categoría'),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add_circle, color: Color(0xFF047857)),
                        onPressed: () {
                          final newCat = _categoryController.text.trim();
                          if (newCat.isNotEmpty && !allowedCategories.contains(newCat)) {
                            setState(() {
                              allowedCategories.add(newCat);
                              _categoryController.clear();
                            });
                          }
                        },
                      )
                    ],
                  ),
                  const SizedBox(height: 25),
                  CustomButton(
                    text: "Confirmar",
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        saveData();
                      }
                    },
                    backgroundColor: Color(0xFF047857),
                    textColor: Colors.white,
                    width: 150,
                    height: 50,
                    borderRadius: 15,
                  ),
                ],
              ),
            ),
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
          Text(
            _value,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 7),
          TextFormField(
            controller: _nombre,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              filled: true,
              fillColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
