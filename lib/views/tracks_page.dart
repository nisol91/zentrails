import '../main.dart';

import 'auth_screen.dart';
import 'map_view.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../app_state_container.dart';
import 'package:pk_skeleton/pk_skeleton.dart';
import '../widgets/service_card.dart';

import 'settings_page.dart';

class TracksPage extends StatefulWidget {
  @override
  _TracksPageState createState() => _TracksPageState();
}

class _TracksPageState extends State<TracksPage> {
  String name = '';
  String lastname = '';
  String email = '';
  String profilePic = '';

  String points;
  bool loaded = false;
  bool serviceLoaded = false;

  bool authenticated;

  List _favServices;

  @override
  initState() {
    super.initState();
    checkIfAuthenticated();
  }

//QUESTA FUNZIONE ANDREBBE TOLTA E SOSTITUITA COL GETUSER() DELL APP STATE
  Future<bool> getUser() async {
    FirebaseUser user = await FirebaseAuth.instance.currentUser();
    if (user != null) {
      email = user.email;
      name = user.displayName;
      profilePic = user.photoUrl;

      new Future.delayed(new Duration(milliseconds: 100), () {
        Firestore.instance
            .collection('users')
            .document(AppStateContainer.of(context).id)
            .collection('Tracks')
            .getDocuments()
            .then((doc) {
          if (!mounted) {
            return;
          }
          doc.documents.forEach((doc) {
            doc.data.values.forEach((f) {
              print('TRACK NAME---------$f');
            });
            print('TRACCE DELL UTENTE:------>${doc.data}');
          });
          setState(() {
            // name = doc.documents[0]['fname'];
            // lastname = doc.documents[0]['surname'];
            // email = doc.documents[0]['email'];
            loaded = true;
          });
        });
      });

      return true;
    } else {
      return false;
    }
  }

  void checkIfAuthenticated() async {
    await getUser();
    print('USER MAIL----------------------------------: $email');
    if (email == '') {
      setState(() {
        authenticated = false;
      });
    } else {
      authenticated = true;
    }
  }

  Widget get _pageToDisplay {
    // if (authenticated == false) {
    //   print('you are not logged in');
    //   return _loading;
    // } else if (authenticated == true) {
    //   if (loaded == false) {
    //     print('..loading');
    //     print(loaded);
    //     return _loading;
    //   } else {
    //     print('dentro a profile view');
    //     return _trackList;
    //   }
    // }
    // return _loading;
    return _trackList;
  }

  Widget get _loading {
    return Container(
      width: MediaQuery.of(context).size.width * 1,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[CircularProgressIndicator()],
      ),
    );
  }

  Widget get _noAccess {
    return new Text(
      'you need to login',
      style: TextStyle(
          fontWeight: FontWeight.w900,
          fontSize: 10,
          fontStyle: FontStyle.italic),
    );
  }

  Widget get _trackList {
    return Container(
      child: StreamBuilder<QuerySnapshot>(
        stream: Firestore.instance
            .collection('users')
            .document(AppStateContainer.of(context).id)
            .collection('Tracks')
            .snapshots(),
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
                      print(document.data['name']);
                    },
                    title: new Text(document.data['name'].toString()),
                  );
                }).toList(),
              );
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: _pageToDisplay,
    );
  }
}
