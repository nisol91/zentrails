import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../app_state_container.dart';

class MapListPage extends StatefulWidget {
  @override
  _MapListPageState createState() => new _MapListPageState();
}

class _MapListPageState extends State<MapListPage> {
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
    return Container(
      margin: EdgeInsets.only(top: 80),
      color: Colors.transparent,
      child: MapList(),
    );
  }
}

class MapList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final container = AppStateContainer.of(context);

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: new AppBar(
        backgroundColor: Colors.grey.withOpacity(.95),
        title: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text('Map List'),
        ),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.close),
            onPressed: () {
              container.closeMapList();
            },
            // color: tema.accentColor,
          ),
        ],
      ),
      body: Container(
        height: 500,
        color: Colors.grey.withOpacity(.92),
        child: StreamBuilder<QuerySnapshot>(
          stream: Firestore.instance.collection('maps').snapshots(),
          builder:
              (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
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
                      selected: (document['tag'] == container.mapTagState)
                          ? true
                          : false,
                      onTap: () {
                        container.selectMap(document['tag']);
                      },
                      title: new Text(document['name']),
                      subtitle: new Text(document['description']),
                    );
                  }).toList(),
                );
            }
          },
        ),
      ),
    );
  }
}
