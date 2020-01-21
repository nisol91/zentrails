import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import '../app_state_container.dart';
import '../models/track_model.dart';
import '../models/service_model.dart';
import '../services/crud_model_service.dart';
import 'package:provider/provider.dart';
// import 'edit_track.dart';
// import '../services/crud_model_track.dart';
import '../widgets/service_list.dart';

class TrackDetails extends StatelessWidget {
  final Track track;

  TrackDetails({@required this.track});

  @override
  Widget build(BuildContext context) {
    // final trackProvider = Provider.of<CrudModelCompany>(context);
    var container = AppStateContainer.of(context);

    var tema = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Company Details'),
        actions: (container.areYouAdmin == true)
            ? <Widget>[
                IconButton(
                    iconSize: 35,
                    icon: Icon(Icons.delete_forever),
                    color: tema.accentColor,
                    onPressed: () {
                      return showDialog<void>(
                          context: context,
                          barrierDismissible: false, // user must tap button!
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: new Text(
                                  'You are going to delete this track'),
                              content: new Text(
                                'Are you sure my friend?',
                                style: new TextStyle(fontSize: 30.0),
                              ),
                              actions: <Widget>[
                                new FlatButton(
                                    onPressed: () {
                                      print('no');
                                      Navigator.pop(context);
                                    },
                                    child: new Text('no')),
                                new FlatButton(
                                    onPressed: () {
                                      print('yes');
                                      // {
                                      //   trackProvider.removeCompany(track.id);
                                      //   Navigator.pop(context);
                                      //   Navigator.pop(context);

                                      //   Flushbar(
                                      //     title: "Hey Ninja",
                                      //     message: "Successfully deleted",
                                      //     duration: Duration(seconds: 3),
                                      //     backgroundColor:
                                      //         Theme.of(context).accentColor,
                                      //   )..show(context);
                                      // }
                                    },
                                    child: new Text('yes')),
                              ],
                            );
                          });
                    }),
                IconButton(
                  iconSize: 35,
                  icon: Icon(Icons.edit),
                  color: tema.accentColor,
                  onPressed: () {
                    // Navigator.push(
                    //     context,
                    //     MaterialPageRoute(
                    //         builder: (_) => ModifyCompany(
                    //               track: track,
                    //             )));
                  },
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
            // Image.network(
            //   '${track.img}',
            //   height: 70,
            //   loadingBuilder: (BuildContext context, Widget child,
            //       ImageChunkEvent loadingProgress) {
            //     if (loadingProgress == null) return child;
            //     return Center(
            //       child: LinearProgressIndicator(
            //         value: loadingProgress.expectedTotalBytes != null
            //             ? loadingProgress.cumulativeBytesLoaded /
            //                 loadingProgress.expectedTotalBytes
            //             : null,
            //       ),
            //     );
            //   },
            // ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Center(
                child: Text(
                  track.name,
                  style: tema.textTheme.body2,
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            Text(
              track.description,
              style: tema.textTheme.body1,
            ),
            // Padding(
            //   padding: const EdgeInsets.only(top: 50),
            //   child: Container(
            //       color: tema.accentColor,
            //       child: ServiceList(
            //         trackId: track.id,
            //       )),
            // ),
          ],
        ),
      ),
    );
  }
}
