import 'dart:io';
import 'package:image_picker/image_picker.dart';

class ImagePickerService {
  final ImagePicker _picker = ImagePicker();

  /// Selecciona una imagen desde la galería o cámara.
  /// [source]: Origen de la imagen (galería o cámara).
  /// [maxSizeInBytes]: Tamaño máximo permitido en bytes (por defecto 3 MB).
  /// Retorna un [File] si la selección es exitosa, null si el usuario cancela.
  /// Lanza una excepción si la imagen excede el tamaño máximo o hay un error.
  Future<File?> pickImage({
    required ImageSource source,
    int maxSizeInBytes = 3 * 1024 * 1024, // 3 MB
    double maxWidth = 1024,
    double maxHeight = 1024,
  }) async {
    try {
      final pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: maxWidth,
        maxHeight: maxHeight,
      );

      if (pickedFile != null) {
        final file = File(pickedFile.path);
        final fileSize = await file.length();

        if (fileSize > maxSizeInBytes) {
          throw Exception('La imagen excede el límite de 3 MB');
        }

        return file;
      }
      return null;
    } catch (e) {
      throw Exception('Error al seleccionar la imagen: $e');
    }
  }

  /// Abre la cámara para tomar una foto.
  /// Retorna un [File] si la foto es tomada, null si el usuario cancela.
  Future<File?> openCamera() async {
    return await pickImage(source: ImageSource.camera);
  }

  /// Abre la galería para seleccionar una imagen.
  /// Retorna un [File] si la imagen es seleccionada, null si el usuario cancela.
  Future<File?> openGallery() async {
    return await pickImage(source: ImageSource.gallery);
  }

}