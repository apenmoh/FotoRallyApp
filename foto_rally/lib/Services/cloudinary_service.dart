import 'dart:io';
import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CloudinaryService {
  final CloudinaryPublic cloudinary = CloudinaryPublic(
    'dll3hadzh', 
    'file-preset',
    cache: true,
  );

  // Subir imagen a Cloudinary
  Future<String?> uploadImage(File imageFile) async {
    try {
      final response = await cloudinary.uploadFile(
        CloudinaryFile.fromFile(
          imageFile.path,
          resourceType: CloudinaryResourceType.Image,
        ),
      );
      return response.secureUrl; 
    } catch (e) {
      throw Exception('Error al subir la imagen: $e');
    }
  }

}