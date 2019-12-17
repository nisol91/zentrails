import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import '../app_state_container.dart';
import '../models/service_model.dart';
import '../services/crud_model_service.dart';
import '../models/service_model.dart';
import '../services/crud_model_service.dart';
import 'package:provider/provider.dart';
import '../widgets/service_list.dart';
// import 'edit_service.dart';

class ServiceDetails extends StatefulWidget {
  // RegisterPage({Key key}) : super(key: key);
  ServiceDetails({@required this.service});
  final Service service;

  @override
  _ServiceDetailsState createState() => _ServiceDetailsState();
}

class _ServiceDetailsState extends State<ServiceDetails> {
  bool favourite = false;

  @override
  initState() {
    super.initState();

    print('SERVICE ID${widget.service.id}');
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    checkFav();
  }

  checkFav() {
    if (AppStateContainer.of(context).id != '') {
      Firestore.instance
          .collection("users")
          .document(AppStateContainer.of(context).id)
          .collection('Service_favourite')
          .document('Service_fav:${widget.service.id}')
          .get()
          .then((doc) {
        print('USER SERVICES -> ${doc.data}');
        if (doc.data != null) {
          setState(() {
            favourite = true;
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final serviceProvider = Provider.of<CrudModelService>(context);
    var container = AppStateContainer.of(context);

    var tema = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Service Details'),
        actions: (container.areYouAdmin == true)
            ? <Widget>[
                IconButton(
                  disabledColor: Colors.grey,
                  iconSize: 35,
                  icon: Icon(
                    Icons.delete_forever,
                  ),
                  color: tema.accentColor,
                  // onPressed: () {
                  //   return null;
                  // return showDialog<void>(
                  //     context: context,
                  //     barrierDismissible: false, // user must tap button!
                  //     builder: (BuildContext context) {
                  //       return AlertDialog(
                  //         title: new Text('You are going to delete this service'),
                  //         content: new Text(
                  //           'Are you sure my friend?',
                  //           style: new TextStyle(fontSize: 30.0),
                  //         ),
                  //         actions: <Widget>[
                  //           new FlatButton(
                  //               onPressed: () {
                  //                 print('no');
                  //                 Navigator.pop(context);
                  //               },
                  //               child: new Text('no')),
                  //           new FlatButton(
                  //               onPressed: () {
                  //                 print('yes');
                  //                 {
                  //                   serviceProvider.removeService(service.id);
                  //                   Navigator.pop(context);
                  //                   Navigator.pop(context);

                  //                   Flushbar(
                  //                     title: "Hey Ninja",
                  //                     message: "Successfully deleted",
                  //                     duration: Duration(seconds: 3),
                  //                     backgroundColor:
                  //                         Theme.of(context).accentColor,
                  //                   )..show(context);
                  //                 }
                  //               },
                  //               child: new Text('yes')),
                  //         ],
                  //       );
                  //     });
                  // }
                ),
                IconButton(
                  disabledColor: Colors.grey,
                  iconSize: 35,
                  icon: Icon(Icons.edit),
                  color: tema.accentColor,
                  // onPressed: () {
                  // Navigator.push(
                  //     context,
                  //     MaterialPageRoute(
                  //         builder: (_) => ModifyService(
                  //               service: service,
                  //             )));
                  // },
                )
              ]
            : null,
      ),
      body: Container(
        width: MediaQuery.of(context).size.width * 1,
        child: Column(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            IconButton(
              color: tema.accentColor,
              disabledColor: Colors.grey,
              iconSize: 35,
              icon: Icon(
                (favourite) ? Icons.wb_cloudy : Icons.cloud_queue,
              ),
              onPressed: () {
                setState(() {
                  favourite = !favourite;
                  // codice firestore che posta nel db dell utente un array con le info del servizio
                });
                print('CONTAINER EMAIL${container.email}');
                print('CONTAINER ID${container.id}');

                if (favourite == true) {
                  print('vero');
                  Firestore.instance
                      .collection("users")
                      .document(container.id)
                      //aggiungo una subcollection all utente
                      .collection('Service_favourite')
                      .document("Service_fav:${widget.service.id}")
                      .setData({
                    'service_name': widget.service.name,
                    'service_description': widget.service.description,
                    'service_company_name': widget.service.companyName,
                    'service_company_id': widget.service.companyId,
                    'service_id': widget.service.id,
                  });
                } else {
                  print('falso');
                  Firestore.instance
                      .collection("users")
                      .document(container.id)
                      .collection('Service_favourite')
                      .document("Service_fav:${widget.service.id}")
                      .delete();
                }
              },
            ),
            Image.network(
              '${widget.service.img}',
              height: 70,
              loadingBuilder: (BuildContext context, Widget child,
                  ImageChunkEvent loadingProgress) {
                if (loadingProgress == null) return child;
                return Center(
                  child: LinearProgressIndicator(
                    value: loadingProgress.expectedTotalBytes != null
                        ? loadingProgress.cumulativeBytesLoaded /
                            loadingProgress.expectedTotalBytes
                        : null,
                  ),
                );
              },
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Center(
                child: Text(
                  widget.service.name,
                  style: tema.textTheme.body2,
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            Text(
              widget.service.description,
              style: tema.textTheme.body1,
            ),
          ],
        ),
      ),
    );
  }
}
