import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../app_state_container.dart';
import '../main.dart';

class SaveTrackModal extends StatefulWidget {
  SaveTrackModal({Key key}) : super(key: key);

  @override
  _SaveTrackModalState createState() => _SaveTrackModalState();
}

class _SaveTrackModalState extends State<SaveTrackModal> {
  final GlobalKey<FormState> _registerFormKey = GlobalKey<FormState>();
  TextEditingController trackNameInputController;
  TextEditingController trackDescriptionInputController;

  final FocusNode _nameFocus = FocusNode();
  final FocusNode _lastnameFocus = FocusNode();
  final FocusNode _emailFocus = FocusNode();

  @override
  initState() {
    trackNameInputController = new TextEditingController();
    trackDescriptionInputController = new TextEditingController();
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

    return AlertDialog(
      content: Container(
          padding: const EdgeInsets.all(20.0),
          child: SingleChildScrollView(
              child: Form(
            key: _registerFormKey,
            child: Column(
              children: <Widget>[
                TextFormField(
                  decoration: InputDecoration(
                      labelText: 'First Name*', hintText: "John"),
                  controller: trackNameInputController,
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
                  decoration:
                      InputDecoration(labelText: 'Last Name*', hintText: "Doe"),
                  controller: trackDescriptionInputController,
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
                RaisedButton(
                    child: Text("Save Track"),
                    color: Theme.of(context).primaryColor,
                    textColor: Colors.white,
                    onPressed: () {
                      print('OPRESSED');
                      FocusScope.of(context).requestFocus(new FocusNode());
                      Navigator.pop(context);

                      Flushbar(
                        title: "Hey Ninja",
                        message: "EMAIL ALREADY IN USE",
                        duration: Duration(seconds: 3),
                        backgroundColor: Theme.of(context).accentColor,
                      )..show(context);
                    }),
              ],
            ),
          ))),
    );
  }
}
