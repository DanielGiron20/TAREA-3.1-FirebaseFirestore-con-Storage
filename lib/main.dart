import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'firebase.dart';
import 'ingreso.dart'; // Importa el archivo de la pantalla de ingreso

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bandas en votacion',
      initialRoute: '/',
      routes: {
        '/': (context) => Home(),
        '/ingreso': (context) => AddBandScreen(), // Ruta para la pantalla de ingreso
      },
    );
  }
}

class Home extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bandas en votacion'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              Navigator.pushNamed(context, '/ingreso'); // Abre la pantalla de ingreso al presionar el botón
            },
          ),
        ],
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('bandas').snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No hay datos disponibles'));
          } else {
            return ListView.builder(
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (context, index) {
                var bandData = snapshot.data!.docs[index].data() as Map<String, dynamic>?; // Convertir a Map<String, dynamic>
                return GestureDetector(
                  onTap: () {
                    incrementVote(snapshot.data!.docs[index].id);
                  },
                  child: ListTile(
                    title: Text(bandData?['name'] ?? ''),
                    subtitle: Text('${bandData?['album'] ?? ''} (${bandData?['year'] ?? ''})'),
                    trailing: Text('Votos: ${bandData?['votes'] ?? ''}'),
                    leading: Image.network(
                      bandData?['imageUrl'] ?? '', // Obtener la URL de la imagen desde Firestore
                      width: 50, // Ajustar el ancho de la imagen según sea necesario
                      height: 50, // Ajustar la altura de la imagen según sea necesario
                      fit: BoxFit.cover, // Ajustar la forma en que se ajusta la imagen dentro del widget
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}

void incrementVote(String bandId) async {
  try {
    DocumentReference bandRef = FirebaseFirestore.instance.collection('bandas').doc(bandId);
    await bandRef.update({'votes': FieldValue.increment(1)});
    print('Voto registrado correctamente para la banda con ID: $bandId');
  } catch (e) {
    print('Error al registrar el voto para la banda con ID: $bandId, Error: $e');
  }
}



