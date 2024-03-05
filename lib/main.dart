import 'package:flutter/material.dart';
import 'package:mongo_database/map_screen.dart';
import 'package:mongo_database/models/milazzo_path_model.dart';
import 'mongo_database_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await MongoDatabaseService().connect();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MongoDB Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late Future<List<PathMilazzo>> paths;

  @override
  void initState() {
    super.initState();
    paths = MongoDatabaseService().getPaths();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text("MongoDB - Milazzo"),
        ),
        body: FutureBuilder<List<PathMilazzo>>(
          future: paths,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Text('Errore: ${snapshot.error}');
            } else {
              return ListView.builder(
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  PathMilazzo path = snapshot.data![index];
                  return ListTile(
                    title: Text(path.nome),
                    subtitle: Text('Tempo di percorrenza: ${path.tempoPercorrenza.toString()} minuti'),
                    onTap: () => _showPathDetails(context, path),
                  );
                },
              );
            }
          },
        ));
  }

  void _showPathDetails(BuildContext context, PathMilazzo path) {
    Navigator.of(context).push(MaterialPageRoute(builder: (context) => MapScreen(path: path)));
  }

/*
  void _showPathDetails(BuildContext context, PathMilazzo path) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(path.nome),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Tempo di percorrenza: ${path.tempoPercorrenza} minuti'),
                SizedBox(height: 10),
                Text('Features:'),
                ...path.datiGeoJSON.features.map((feature) => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      '${feature.properties.name}: ${feature.properties.description}',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text('Coordinate: ${feature.geometry.coordinates.join(", ")}'),
                    SizedBox(height: 5),
                  ],
                )),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Chiudi'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
*/

}
