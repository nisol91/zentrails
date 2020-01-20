import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:battery_optimization/battery_optimization.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'models/maps_model.dart';
import 'state/app_state.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';

//EFFETTIVA IMPLEMENTAZIONE DELLO STATO DELL APP (INHERITED WIDGET)
class AppStateContainer extends StatefulWidget {
  // Your apps state is managed by the container
  final AppState state;
  // This widget is simply the root of the tree,
  // so it has to have a child!
  final Widget child;

  AppStateContainer({
    @required this.child,
    this.state,
  });

  // This creates a method on the AppState that's just like 'of'
  // On MediaQueries, Theme, etc
  // This is the secret to accessing your AppState all over your app
  static _AppStateContainerState of(BuildContext context) {
    return (context
            .dependOnInheritedWidgetOfExactType<_InheritedStateContainer>())
        .data;
  }

  @override
  _AppStateContainerState createState() => new _AppStateContainerState();
}

class _AppStateContainerState extends State<AppStateContainer> {
  // Just padding the state through so we don't have to
  // manipulate it with widget.state.
  AppState state;

  //THEME
  bool chooseTheme = true;

  // This is used to sign into Google, not Firebase.

  GoogleSignInAccount googleUser;
  // This class handles signing into Google.
  // It comes from the Firebase plugin.

  final googleSignIn = new GoogleSignIn();

  //for firebase user
  FirebaseUser firebaseUser;

  String email = '';
  String id = '';

  bool areYouAdmin = false;
  bool isMailVerified;
  String userId;

  String mapTagState = "mapbox_out";
  List<Maps> maps;
  List<Maps> mapsFromFetch;
  bool loadedMaps = false;
  bool showMapListPage = false;
  String errorFetchMaps;

  bool batteryOptModal = false;

  final FirebaseAuth _auth = FirebaseAuth.instance;

  //==gps data
  double currentLat;
  double currentLng;
  double currentAlt;
  double currentSpeed;
  double currentHeading;
  double totalDistSum = 0;
  double totalElevationGain;
  double elevSum;
  double avgSpeed;
  double grade;
  double verticalSpeed;
  List trackPoints = <List>[];

  Stopwatch stopwatch = new Stopwatch();

  String trackName;
  String trackDescription;

  @override
  void initState() {
    // You'll almost certainly want to do some logic
    // in InitState of your AppStateContainer. In this example, we'll eventually
    // write the methods to check the local state
    // for existing users and all that.
    super.initState();
    if (widget.state != null) {
      state = widget.state;
    } else {
      state = new AppState.loading();
      print(state);
      // fake some config loading
      print('INIT APP');
      sharedPrefs();
      handleBatteryOpt();
      initUser().whenComplete(() => getUser().whenComplete(
          () => startCountdown().whenComplete(() => streamUser())));
      getMap();
    }
  }
  //===========================================

  void sharedPrefs() async {}
  //===========================================

  void handleBatteryOpt() async {
    if (Platform.isAndroid) {
      //l' app deve per forza essere esclusa dall'ottimizzazione della batteria per poter funzionare anche
      //in background, cosi salvo sul telefono se ho già visto l avviso almeno una volta, per non farlo riapparire.
      SharedPreferences prefsModalBattery =
          await SharedPreferences.getInstance();
      print(
          'VERO O FALSO????${prefsModalBattery.containsKey('checkBatteryOpt')}');
      if (prefsModalBattery.containsKey('checkBatteryOpt') == false) {
        prefsModalBattery.setBool('checkBatteryOpt', false);
      }
      BatteryOptimization.isIgnoringBatteryOptimizations()
          .then((onValue) async {
        SharedPreferences prefsModalBattery =
            await SharedPreferences.getInstance();
        if (onValue) {
          // Ignoring Battery Optimization
          print('ok, l app ignora battery opt');
        } else {
          // App is under battery optimization
          if (prefsModalBattery.getBool('checkBatteryOpt') == false) {
            setState(() {
              batteryOptModal = true;
            });

            prefsModalBattery.setBool('checkBatteryOpt', true);
            print('waAAAAAA${prefsModalBattery.getBool('checkBatteryOpt')}');
          }
        }
      });
    }
  }

  //===========================================
  void resetStopwatch() {
    stopwatch.reset();
  }

  void handleRecord() {
    if (stopwatch.isRunning) {
      stopwatch.stop();
      print(stopwatch.elapsed);
    } else {
      stopwatch.start();
    }
  }

  //===========================================
  //change theme dinamically
  void changeTheme() {
    if (!mounted) {
      return null;
    }
    setState(() {
      chooseTheme = !chooseTheme;
    });
  }

  //===========================================
  //METODO PER ORA NON UTILIZZATO

  void streamUser() {
    // StreamController streamController = StreamController();

    // streamController.stream.listen(
    //   (data) => print('il caricamento dovrebbe essere $data'),
    //   onError: (err) => print('Got an error! $err'),
    //   onDone: () => print('App caricata!'),
    //   cancelOnError: false,
    // );

    // streamController.sink.add('finito');
    // streamController.sink.addError('Houston, we have a problem!');
    // streamController.sink.close();
  }

  //===========================================

  void selectMap(String tag) {
    setState(() {
      mapTagState = tag;
    });
    print(tag);
    getMap();
  }

  void getMap() async {
    print('GETTING=======================');
    Firestore.instance
        .collection("maps")
        .where('tag', isEqualTo: mapTagState)
        .snapshots()
        .listen((doc) {
      mapsFromFetch = doc.documents
          .map((doc) => Maps.fromMap(doc.data, doc.documentID))
          .toList();

      if (mounted) {
        setState(() {
          maps = mapsFromFetch;
          loadedMaps = true;
        });
      }
      print('MAPS!!!!!->${maps[0].name}');
    }).onError((err) {
      setState(() {
        errorFetchMaps = err.toString();
      });
    });
  }

  void closeMapList() {
    setState(() {
      showMapListPage = false;
    });
  }
  //===========================================

  Future<AuthResult> signInWithEmail(String email, String password) async {
    try {
      AuthResult result = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      //ricorda che per trovare il firebaseUser dall authResult:
      // FirebaseUser user = result.user;
      if (result != null) {
        if (result.user.isEmailVerified) {
          print(result);
          return result;
        } else {
          signOut();
        }
      } else {
        print('ERROR -> user null');
        return null;
      }
    } catch (e) {
      print(e);
      return null;
    }
  }

  //===========================================

  Future<AuthResult> registerUser(String email, String password) async {
    AuthResult currentUser = await _auth.createUserWithEmailAndPassword(
        email: email, password: password);
    try {
      await currentUser.user.sendEmailVerification();
      return currentUser;
    } catch (e) {
      print("An error occured while trying to send email verification");
      print(e.message);
    }
  }

  //===========================================

  Future<FirebaseUser> getUser() async {
    FirebaseUser user = await FirebaseAuth.instance.currentUser();
    if (user != null) {
      email = user.email;
      if (user.isEmailVerified) {
        setState(() {
          isMailVerified = true;
        });
      }

      await Future.delayed(new Duration(milliseconds: 10), () {
        Firestore.instance
            .collection('users')
            .where('email', isEqualTo: email)
            .getDocuments()
            .then((doc) {
          if (doc.documents[0]['role'] == 'admin') {
            print('ADMIN===========');
            if (!mounted) {
              return null;
            }
            setState(() {
              areYouAdmin = true;
            });
          } else {
            print('false');
            setState(() {
              areYouAdmin = false;
            });
          }
          // print('==========!!!!!!!!');
          // print(doc.documents[0]['uid']);
          // print('==========!!!!!!!!');

          setState(() {
            email = doc.documents[0]['email'];
            id = doc.documents[0]['uid'];
          });
        });
      });
      return user;
    } else {
      print('false');
      setState(() {
        areYouAdmin = false;
      });
      return null;
    }
  }

  //===========================================

  Future<bool> loginWithGoogle() async {
    final GoogleSignInAccount googleSignInAccount = await googleSignIn.signIn();
    final GoogleSignInAuthentication googleSignInAuthentication =
        await googleSignInAccount.authentication;

    final AuthCredential credential = GoogleAuthProvider.getCredential(
      accessToken: googleSignInAuthentication.accessToken,
      idToken: googleSignInAuthentication.idToken,
    );

    final AuthResult authResult = await _auth.signInWithCredential(credential);
    final FirebaseUser user = authResult.user;

    assert(!user.isAnonymous);
    assert(await user.getIdToken() != null);

    final FirebaseUser currentUser = await _auth.currentUser();

    DocumentSnapshot utente =
        await Firestore.instance.collection("users").document(user.uid).get();
    if (!utente.exists) {
      print('ancora non esisteva');
      Firestore.instance.collection("users").document(user.uid).setData({
        "points": 0,
        "fname": user.displayName,
        "surname": '',
        "role": 'user',
        "creationDate": Timestamp.now(),
      });
    }

    Firestore.instance.collection("users").document(user.uid).updateData({
      "uid": user.uid,
      "email": user.email,
    });

    getUser();
    assert(user.uid == currentUser.uid);
    print('signInWithGoogle succeeded: $user');
    return true;
  }

  //===========================================

  Future<Null> signOut() async {
    try {
      // Sign out with firebase
      await _auth.signOut();
      setState(() {
        firebaseUser = null;
      });
      // Sign out with google
      await googleSignIn.signOut();
      setState(() {
        googleUser = null;
      });

      getUser();
      setState(() {
        email = '';
        id = '';
      });
      print('==================');
      print(id);
      print(email);

      print('==================');

      print('logged out!!!');
    } catch (e) {
      print('error logging out from google');
    }
  }

  //===========================================
// If all goes well, when you launch the app
  // you'll see a loading spinner for n seconds
  // Then the HomeScreen main view will appear
  //QUESTO METODO VIENE CHIAMATO UNA VOLTA CHE I METODI DI INIZIALIZZAZIONE
  // SONO STATI COMPLETATI

  Future<Null> startCountdown() async {
    const timeOut = const Duration(seconds: 3);
    new Timer(timeOut, () {
      setState(() => state.isLoading = false);
    });
  }

  //===========================================

  Future<GoogleSignInAccount> ensureGoogleLoggedInOnStartUp() async {
    // That class has a currentUser if there's already a user signed in on
    // this device.
    GoogleSignInAccount user = googleSignIn.currentUser;
    if (user == null) {
      // but if not, Google should try to sign one in whos previously signed in
      // on this phone.
      user = await googleSignIn.signInSilently();
    }
    // NB: This could still possibly be null.
    googleUser = user;
    return user;
  }

  Future<FirebaseUser> ensureEmailLoggedInOnStartup() async {
    FirebaseUser user = await FirebaseAuth.instance.currentUser();
    firebaseUser = user;
    print('FIREBASE USER ${firebaseUser}');
    // print('EMAIL VERIFIED ??? ${firebaseUser.isEmailVerified}');

    return user;
  }

  //===========================================

  Future<bool> initUser() async {
    // First, check if a user exists.
    googleUser = await ensureGoogleLoggedInOnStartUp();
    firebaseUser = await ensureEmailLoggedInOnStartup();
    // If the user is null, we aren't loading anyhting
    // because there isn't anything to load.
    // This will force the homepage to navigate to the auth page.
    if (googleUser == null && firebaseUser == null) {
      setState(() {
        print('NO USER LOGGED IN');
      });
      return false;
    } else if (googleUser != null) {
      setState(() {
        print('USER LOGGED IN -> ${googleUser.email}');
      });
      return true;
    } else if (firebaseUser != null) {
      setState(() {
        print('USER LOGGED IN -> ${firebaseUser.email}');
      });
      return true;
    }
    return false;
  }

  //===========================================

  // So the WidgetTree is actually
  // AppStateContainer --> InheritedStateContainer --> The rest of your app.
  @override
  Widget build(BuildContext context) {
    return new _InheritedStateContainer(
      data: this,
      child: widget.child,
    );
  }
}

// This is likely all your InheritedWidget will ever need.
class _InheritedStateContainer extends InheritedWidget {
  // The data is whatever this widget is passing down.
  final _AppStateContainerState data;

  // InheritedWidgets are always just wrappers.
  // So there has to be a child,
  // Although Flutter just knows to build the Widget thats passed to it
  // So you don't have have a build method or anything.
  _InheritedStateContainer({
    Key key,
    @required this.data,
    @required Widget child,
  }) : super(key: key, child: child);

  // This is a better way to do this, which you'll see later.
  // But basically, Flutter automatically calls this method when any data
  // in this widget is changed.
  // You can use this method to make sure that flutter actually should
  // repaint the tree, or do nothing.
  // It helps with performance.
  @override
  bool updateShouldNotify(_InheritedStateContainer old) => true;
}
