
import 'package:cloud_firestore/cloud_firestore.dart';

FirebaseFirestore db = FirebaseFirestore.instance;

Future<List<Map<String, dynamic>>> getVotes() async {
  List<Map<String, dynamic>> bandas = [];
  CollectionReference collectionReferencebandas = db.collection("bandas");
  QuerySnapshot queryBandas = await collectionReferencebandas.get(); 
  
  queryBandas.docs.forEach((documento) {
    final Map<String, dynamic>? data = documento.data() as Map<String, dynamic>?; 
    if (data != null) {
      data['id'] = documento.id; 
      bandas.add(data);
      print(data);
    }
  });
  return bandas;
}

