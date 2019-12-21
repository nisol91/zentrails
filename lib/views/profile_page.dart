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

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
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
    getIfAuthenticated();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // createFavList();
  }

  void createFavList() {
    // new Future.delayed(new Duration(milliseconds: 2000), () {
    //   Firestore.instance
    //       .collection("users")
    //       .document(AppStateContainer.of(context).id)
    //       .collection('Service_favourite')
    //       .getDocuments()
    //       .then((doc) {
    //     // print('================');
    //     // print('SERVICE NAME${doc.documents[0]['service_name']}');
    //     // print('================');
    //     setState(() {
    //       _favServices = doc.documents.toList();
    //     });

    //     // print(_favServices[0]['service_name']);
    //     serviceLoaded = true;
    //   });
    // });
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
            .where('email', isEqualTo: email)
            .getDocuments()
            .then((doc) {
          print('MAIL FETCH ${doc.documents[0]['email']}');
          print('NAME FETCH ${doc.documents[0]['fname']}');

          if (!mounted) {
            return;
          }
          setState(() {
            name = doc.documents[0]['fname'];
            lastname = doc.documents[0]['surname'];
            email = doc.documents[0]['email'];
            points = doc.documents[0]['points'].toString();
            loaded = true;
          });
        });
      });

      return true;
    } else {
      return false;
    }
  }

//so che non è asincrona e quindi sarebbe poco ortodosso perchè non aspetta
//che finisca la chiamata asincrona qui sopra all user
//, pero tanto è solo per una sicurezza della pagina utente se per caso qualcuno
// riuscisse a navigarci direttamente, comunque non la vede se non è loggato con una mail
  void getIfAuthenticated() async {
    await getUser();
    if (email == '') {
      setState(() {
        authenticated = false;
      });
    } else {
      authenticated = true;
    }
  }

  Widget get _pageToDisplay {
    if (authenticated == false) {
      print('you are not logged in');
      // return Container();
      return AuthScreen();
    } else if (authenticated == true) {
      if (loaded == false) {
        print('..loading');
        print(loaded);
        return _loading;
      } else {
        print('dentro a profile view');
        return _profileView;
      }
    }
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

  Widget get _logOutButton {
    final container = AppStateContainer.of(context);

    return RaisedButton(
      onPressed: () => {
        print(container.firebaseUser),
        print(container.googleUser),
        container.signOut().whenComplete(() {
          Navigator.pop(context);
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (BuildContext context) {
                return MyHomePage();
              },
            ),
          );
          Flushbar(
            title: "Hey Ninja",
            message: "Logged Out!!",
            duration: Duration(seconds: 3),
            backgroundColor: Theme.of(context).accentColor,
          )..show(context);
        }),
      },
      color: Colors.white,
      shape: RoundedRectangleBorder(
          borderRadius: new BorderRadius.circular(10.0),
          side: BorderSide(color: Colors.grey)),
      child: new Container(
        width: 250.0,
        // width: MediaQuery.of(context).size.width * .5,
        height: 50.0,
        alignment: Alignment.center,
        child: new Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            new Text(
              'Sign Out',
              textAlign: TextAlign.center,
              style: new TextStyle(
                fontSize: 16.0,
                color: Colors.teal[900],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget get _profileView {
    var tema = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(top: 80),
      child: Container(
          width: MediaQuery.of(context).size.height * 1,
          child: (loaded == true)
              ? Column(
                  mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Expanded(
                      flex: 6,
                      child: Column(
                        children: <Widget>[
                          Image.network(
                            '${profilePic ?? profilePic}',
                            height: 70,
                            loadingBuilder: (BuildContext context, Widget child,
                                ImageChunkEvent loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Center(
                                child: LinearProgressIndicator(
                                  value: loadingProgress.expectedTotalBytes !=
                                          null
                                      ? loadingProgress.cumulativeBytesLoaded /
                                          loadingProgress.expectedTotalBytes
                                      : null,
                                ),
                              );
                            },
                          ),
                          Text(
                            name ?? name,
                            style: TextStyle(
                                fontWeight: FontWeight.w900,
                                fontSize: 22,
                                fontStyle: FontStyle.normal),
                          ),
                          Text(
                            lastname ?? lastname,
                            style: TextStyle(
                                fontWeight: FontWeight.w900,
                                fontSize: 22,
                                fontStyle: FontStyle.normal,
                                color: Colors.grey[500]),
                          ),
                          Text(
                            email ?? email,
                            style: TextStyle(
                                fontWeight: FontWeight.w900,
                                fontSize: 22,
                                fontStyle: FontStyle.normal,
                                color: Colors.grey[500]),
                          ),
                          Text(
                            'Total points: ${points ?? points}',
                            style: TextStyle(
                                fontWeight: FontWeight.w900,
                                fontSize: 22,
                                fontStyle: FontStyle.normal,
                                color: Colors.grey[500]),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: Container(
                          width: 500,
                          child: Material(
                            child: InkWell(
                              onTap: () => Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (BuildContext context) {
                                    return SettingsPage();
                                  },
                                ),
                              ),
                              child: Center(child: Text('Settings')),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.only(left: 5.0),
                            child: _logOutButton,
                          ),
                        ],
                      ),
                    ),
                  ],
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[CircularProgressIndicator()])),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: _pageToDisplay,
    );
  }
}
