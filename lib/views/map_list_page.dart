import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../app_state_container.dart';

// QUESTO FILE è SOLO UN ESPERIMENTO, NON è UFFICIALE
//NOTA: questa è una lista piu rudimentale e statica (senza stream) rispetto a company_list_view_admin

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => new _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  Firestore _firestore = Firestore.instance;
  @override
  void initState() {
    super.initState();
    Firestore.instance.collection('settings').snapshots().listen(
        (data) => data.documents.forEach((doc) => print(doc.data['name'])));
  }

  Future<QuerySnapshot> getAllDocuments() {
    return _firestore.collection('settings').getDocuments();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      body: new MapList(),
    );
  }
}

class MapList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final container = AppStateContainer.of(context);

    return Scaffold(
      appBar: new AppBar(
        title: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text('Map List'),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: Firestore.instance.collection('maps').snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) return new Text('Error: ${snapshot.error}');
          switch (snapshot.connectionState) {
            case ConnectionState.waiting:
              return Center(
                child: new Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[CircularProgressIndicator()]),
              );
            default:
              return new ListView(
                children:
                    snapshot.data.documents.map((DocumentSnapshot document) {
                  return new ListTile(
                    onTap: () {
                      container.selectMap(document['tag']);
                      Navigator.pop(context);
                    },
                    title: new Text(document['name']),
                    subtitle: new Text(document['description']),
                  );
                }).toList(),
              );
          }
        },
      ),
    );
  }
}
