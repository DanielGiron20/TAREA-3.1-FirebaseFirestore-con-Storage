import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class AddBandScreen extends StatefulWidget {
  @override
  _AddBandScreenState createState() => _AddBandScreenState();
}

class _AddBandScreenState extends State<AddBandScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _albumController = TextEditingController();
  final TextEditingController _yearController = TextEditingController();
  File? _imageFile; // Variable para almacenar la imagen seleccionada

  // Función para agregar una banda a Firestore
  Future<void> _addBand() async {
    // Verifica si se ha seleccionado una imagen
    if (_imageFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Debes seleccionar una imagen')),
      );
      return;
    }

    // Sube la imagen a Firebase Storage y obtén su URL de descarga
    String? imageUrl = await uploadImage(_imageFile!);

    try {
      // Validamos que los campos no estén vacíos
      if (_nameController.text.isEmpty ||
          _albumController.text.isEmpty ||
          _yearController.text.isEmpty ||
          imageUrl == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Todos los campos son obligatorios')),
        );
        return;
      }

      // Creamos un nuevo documento en la colección 'bandas' con la URL de la imagen
      await FirebaseFirestore.instance.collection('bandas').add({
        'name': _nameController.text,
        'album': _albumController.text,
        'year': _yearController.text,
        'votes': 0, // Inicializamos los votos en 0
        'imageUrl': imageUrl, // Agregamos la URL de la imagen
      });

      // Limpiamos los campos de texto después de agregar la banda exitosamente
      _nameController.clear();
      _albumController.clear();
      _yearController.clear();
      setState(() {
        _imageFile = null; // Limpiamos el archivo de imagen seleccionado
      });

      // Mostramos un mensaje de éxito
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Banda agregada exitosamente')),
      );
    } catch (e) {
      // Manejamos cualquier error que pueda ocurrir durante la operación
      print('Error al agregar banda: $e');
      // Mostramos un mensaje de error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al agregar banda')),
      );
    }
  }

  // Función para seleccionar una imagen desde la galería o tomar una foto
  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Agregar Banda'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'Nombre'),
              ),
              TextField(
                controller: _albumController,
                decoration: InputDecoration(labelText: 'Álbum'),
              ),
              TextField(
                controller: _yearController,
                decoration: InputDecoration(labelText: 'Año'),
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => _pickImage(ImageSource.gallery),
                child: Text('Seleccionar de la galería'),
              ),
              SizedBox(height: 8),
              ElevatedButton(
                onPressed: () => _pickImage(ImageSource.camera),
                child: Text('Tomar una foto'),
              ),
              SizedBox(height: 16),
              _imageFile != null
                  ? Image.file(_imageFile!, height: 200)
                  : SizedBox(),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: _addBand,
                child: Text('Agregar Banda'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Función para subir una imagen a Firebase Storage
Future<String?> uploadImage(File imageFile) async {
  try {
    // Obtén una referencia al bucket de Firebase Storage
    final Reference storageRef =
        FirebaseStorage.instance.ref().child('band_images/${DateTime.now().millisecondsSinceEpoch}.jpg');

    // Sube la imagen al bucket
    final UploadTask uploadTask = storageRef.putFile(imageFile);

    // Espera a que se complete la subida y obtén la URL de la imagen
    final TaskSnapshot snapshot = await uploadTask;
    final String downloadUrl = await snapshot.ref.getDownloadURL();

    // Devuelve la URL de descarga de la imagen
    return downloadUrl;
  } catch (e) {
    print('Error al subir imagen: $e');
    return null;
  }
}
