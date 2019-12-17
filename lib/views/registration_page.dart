import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../app_state_container.dart';
import '../main.dart';

class RegisterPage extends StatefulWidget {
  RegisterPage({Key key}) : super(key: key);

  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final GlobalKey<FormState> _registerFormKey = GlobalKey<FormState>();
  TextEditingController firstNameInputController;
  TextEditingController lastNameInputController;
  TextEditingController emailInputController;
  TextEditingController pwdInputController;
  TextEditingController confirmPwdInputController;

  final FocusNode _nameFocus = FocusNode();
  final FocusNode _lastnameFocus = FocusNode();
  final FocusNode _emailFocus = FocusNode();
  final FocusNode _pwd1Focus = FocusNode();
  final FocusNode _pwd2Focus = FocusNode();

  @override
  initState() {
    firstNameInputController = new TextEditingController();
    lastNameInputController = new TextEditingController();
    emailInputController = new TextEditingController();
    pwdInputController = new TextEditingController();
    confirmPwdInputController = new TextEditingController();
    super.initState();
  }

  _fieldFocusChange(
      BuildContext context, FocusNode currentFocus, FocusNode nextFocus) {
    currentFocus.unfocus();
    FocusScope.of(context).requestFocus(nextFocus);
  }

  String emailValidator(String value) {
    Pattern pattern =
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
    RegExp regex = new RegExp(pattern);
    if (!regex.hasMatch(value)) {
      return 'Email format is invalid';
    } else {
      return null;
    }
  }

  String pwdValidator(String value) {
    if (value.length < 8) {
      return 'Password must be longer than 8 characters';
    } else {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    var container = AppStateContainer.of(context);
    var tema = Theme.of(context);

    return Scaffold(
        appBar: AppBar(
          title: Text("Register"),
        ),
        body: Container(
            padding: const EdgeInsets.all(20.0),
            child: SingleChildScrollView(
                child: Form(
              key: _registerFormKey,
              child: Column(
                children: <Widget>[
                  TextFormField(
                    decoration: InputDecoration(
                        labelText: 'First Name*', hintText: "John"),
                    controller: firstNameInputController,
                    cursorColor: tema.accentColor,
                    validator: (value) {
                      if (value.length < 3) {
                        return "Please enter a valid first name.";
                      }
                    },
                    textInputAction: TextInputAction.next,
                    focusNode: _nameFocus,
                    onFieldSubmitted: (term) {
                      _fieldFocusChange(context, _nameFocus, _lastnameFocus);
                    },
                  ),
                  TextFormField(
                    decoration: InputDecoration(
                        labelText: 'Last Name*', hintText: "Doe"),
                    controller: lastNameInputController,
                    cursorColor: tema.accentColor,
                    validator: (value) {
                      if (value.length < 3) {
                        return "Please enter a valid last name.";
                      }
                    },
                    textInputAction: TextInputAction.next,
                    focusNode: _lastnameFocus,
                    onFieldSubmitted: (term) {
                      _fieldFocusChange(context, _lastnameFocus, _emailFocus);
                    },
                  ),
                  TextFormField(
                    decoration: InputDecoration(
                        labelText: 'Email*', hintText: "john.doe@gmail.com"),
                    controller: emailInputController,
                    cursorColor: tema.accentColor,
                    keyboardType: TextInputType.emailAddress,
                    validator: emailValidator,
                    textInputAction: TextInputAction.next,
                    focusNode: _emailFocus,
                    onFieldSubmitted: (term) {
                      _fieldFocusChange(context, _emailFocus, _pwd1Focus);
                    },
                  ),
                  TextFormField(
                    decoration: InputDecoration(
                        labelText: 'Password*', hintText: "********"),
                    controller: pwdInputController,
                    cursorColor: tema.accentColor,
                    obscureText: true,
                    validator: pwdValidator,
                    textInputAction: TextInputAction.next,
                    focusNode: _pwd1Focus,
                    onFieldSubmitted: (term) {
                      _fieldFocusChange(context, _pwd1Focus, _pwd2Focus);
                    },
                  ),
                  TextFormField(
                    decoration: InputDecoration(
                        labelText: 'Confirm Password*', hintText: "********"),
                    controller: confirmPwdInputController,
                    cursorColor: tema.accentColor,
                    obscureText: true,
                    validator: pwdValidator,
                    focusNode: _pwd2Focus,
                  ),
                  RaisedButton(
                    child: Text("Register"),
                    color: Theme.of(context).primaryColor,
                    textColor: Colors.white,
                    onPressed: () {
                      if (_registerFormKey.currentState.validate()) {
                        if (pwdInputController.text ==
                            confirmPwdInputController.text) {
                          //controllo, in fase di registrazione, che la mail non esista già
                          Firestore.instance
                              .collection("users")
                              .where('email',
                                  isEqualTo: emailInputController.text)
                              .getDocuments()
                              .then((doc) {
                            print('DOCUMENTONI${doc.documents}');
                            if (doc.documents.isEmpty) {
                              container
                                  .registerUser(emailInputController.text,
                                      pwdInputController.text)
                                  .then((currentUser) => Firestore.instance
                                      .collection("users")
                                      .document(currentUser.user.uid)
                                      .setData({
                                        "uid": currentUser.user.uid,
                                        "fname": firstNameInputController.text,
                                        "surname": lastNameInputController.text,
                                        "email": emailInputController.text,
                                        "points": 0,
                                        "role": 'user',
                                        "creationDate": Timestamp.now(),
                                      })
                                      .then((_) => {
                                            container.signOut(),
                                            //per ora alla registration non voglio mettere il login automatico
                                            //cosi obbligo l'utente a verificare la mail prima di tutto.
                                            // container.signInWithEmail(
                                            //     emailInputController.text,
                                            //     pwdInputController.text),
                                            firstNameInputController.clear(),
                                            lastNameInputController.clear(),
                                            emailInputController.clear(),
                                            pwdInputController.clear(),
                                            confirmPwdInputController.clear()
                                          })
                                      .catchError((err) => print(err)))
                                  .catchError((err) => print(err));
                              FocusScope.of(context)
                                  .requestFocus(new FocusNode());
                              AppStateContainer.of(context).getUser();
                              Navigator.of(context).pushNamedAndRemoveUntil(
                                  '/', (Route<dynamic> route) => false);

                              Flushbar(
                                title: "Hey Ninja",
                                message:
                                    "Successfully Registered, now verify your email and sign in with your credentials",
                                duration: Duration(seconds: 3),
                                backgroundColor: Theme.of(context).accentColor,
                              )..show(context);
                            } else {
                              FocusScope.of(context)
                                  .requestFocus(new FocusNode());
                              AppStateContainer.of(context).getUser();
                              Navigator.of(context).pushNamedAndRemoveUntil(
                                  '/', (Route<dynamic> route) => false);

                              Flushbar(
                                title: "Hey Ninja",
                                message: "EMAIL ALREADY IN USE",
                                duration: Duration(seconds: 3),
                                backgroundColor: Theme.of(context).accentColor,
                              )..show(context);
                            }
                          });
                        } else {
                          showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: Text("Error"),
                                  content: Text("The passwords do not match"),
                                  actions: <Widget>[
                                    FlatButton(
                                      child: Text("Close"),
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                    )
                                  ],
                                );
                              });
                        }
                      }
                    },
                  ),
                  Text("Already have an account?"),
                  FlatButton(
                    child: Text("Login here!"),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
            ))));
  }
}
