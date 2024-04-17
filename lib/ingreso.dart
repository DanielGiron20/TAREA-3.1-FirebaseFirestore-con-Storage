import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddBandScreen extends StatefulWidget {
  @override
  _AddBandScreenState createState() => _AddBandScreenState();
}

class _AddBandScreenState extends State<AddBandScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _albumController = TextEditingController();
  final TextEditingController _yearController = TextEditingController();
final TextEditingController _imageUrlController = TextEditingController(); 
  Future<void> _addBand() async {
    try {
      // Validaciones
      if (_nameController.text.isEmpty ||
          _albumController.text.isEmpty ||
          _yearController.text.isEmpty || 
          _imageUrlController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Todos los campos son obligatorios')),
        );
        return;
      }

      
      await FirebaseFirestore.instance.collection('bandas').add({
        'name': _nameController.text,
        'album': _albumController.text,
        'year': _yearController.text,
        'votes': 0,
        'imageUrl': _imageUrlController.text, // Inicializamos los votos en 0
      });

      
      _nameController.clear();
      _albumController.clear();
      _yearController.clear();
      _imageUrlController.clear();

  
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Banda agregada exitosamente')),
      );
    } catch (e) {
      
      print('Error al agregar banda: $e');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al agregar banda')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Agregar Banda'),
      ),
      body: Padding(
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
            TextField(
              controller: _imageUrlController, 
              decoration: InputDecoration(labelText: 'URL de la imagen'), 
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _addBand, 
              child: Text('Agregar Banda'),
            ),
          ],
        ),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: AddBandScreen(),
  ));
}
