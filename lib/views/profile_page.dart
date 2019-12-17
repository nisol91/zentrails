import 'package:cloud_firestore/cloud_firestore.dart';
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

  List _favServices;

  @override
  initState() {
    super.initState();
    getUser();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    createFavList();
  }

  void createFavList() {
    new Future.delayed(new Duration(milliseconds: 2000), () {
      Firestore.instance
          .collection("users")
          .document(AppStateContainer.of(context).id)
          .collection('Service_favourite')
          .getDocuments()
          .then((doc) {
        // print('================');
        // print('SERVICE NAME${doc.documents[0]['service_name']}');
        // print('================');
        setState(() {
          _favServices = doc.documents.toList();
        });

        // print(_favServices[0]['service_name']);
        serviceLoaded = true;
      });
    });
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
  Widget get _pageToDisplay {
    if (loaded == false) {
      print('loading');

      return _loading;
    } else {
      if (email != '') {
        print('dentro a profile view');
        print(email);
        return _profileView;
      } else {
        print('dentro a no access');

        return _noAccess;
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

  Widget get _favServList {
    return Expanded(
      flex: 3,
      child: (serviceLoaded)
          ? ListView.builder(
              scrollDirection: Axis.vertical,
              physics: BouncingScrollPhysics(),
              itemCount: _favServices.length,
              itemBuilder: (buildContext, index) {
                return Padding(
                  padding: const EdgeInsets.only(left: 15.0, right: 15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.all(5.0),
                        child: Card(
                          elevation: 3,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Container(
                                width: MediaQuery.of(context).size.width * 0.8,
                                child: Column(
                                  children: <Widget>[
                                    Text(_favServices[index]['service_name']),
                                    Text(_favServices[index]
                                        ['service_description']),
                                  ],
                                )),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
                // return ServiceCard(serviceDetails: _favServices[index]);
              })
          : Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: LinearProgressIndicator())
              ],
            ),
    );
  }

  Widget get _profileView {
    var tema = Theme.of(context);

    return Container(
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
                    flex: 3,
                    child: Row(
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.only(left: 15.0),
                          child: Text(
                            'FavList',
                            style: tema.textTheme.body2,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _favServList,
                  Expanded(
                    flex: 2,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.only(left: 15.0),
                          child: Text(
                            'Settings',
                            style: tema.textTheme.body2,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 8,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Container(
                          width: MediaQuery.of(context).size.width * 1,
                          height: MediaQuery.of(context).size.width * 0.7,
                          child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: (serviceLoaded)
                                  ? SettingsPage()
                                  : (tema.brightness != Brightness.dark)
                                      ? PKCardPageSkeleton(
                                          totalLines: 2,
                                        )
                                      : PKDarkCardPageSkeleton(
                                          totalLines: 2,
                                        ))),
                    ),
                  ),
                ],
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[CircularProgressIndicator()]));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('User & Settings'),
          actions: <Widget>[],
        ),
        body: _pageToDisplay);
  }
}
