import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../app_state_container.dart';
import '../models/service_model.dart';
import '../services/crud_model_service.dart';
import 'package:provider/provider.dart';
import '../widgets/service_card.dart';

class ServiceList extends StatelessWidget {
//   @override
//   _ServiceListState createState() => _ServiceListState();
// }

// class _ServiceListState extends State<ServiceList> {
  List<Service> services;
  List<Service> selectedServices = [];

  String companyId;

  ServiceList({@required this.companyId});

  // @override
  // initState() {
  //   super.initState();
  // }

  @override
  Widget build(BuildContext context) {
    var container = AppStateContainer.of(context);

    final serviceProvider = Provider.of<CrudModelService>(context);

    return Container(
      height: MediaQuery.of(context).size.height * 0.5,
      padding: EdgeInsets.all(1),
      child: StreamBuilder(
          stream: serviceProvider.fetchServicesAsStream(),
          builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.hasData) {
              print('fatto');

              services = snapshot.data.documents
                  .map((doc) => Service.fromMap(doc.data, doc.documentID))
                  .toList();

              //sono riuscito a migliorare il filtro usando where!!!!ora funziona
              //filtro i servizi per company, ogni servizio ha un company id,
              // se combacia allora lo faccio apparire nella lista
              //di quella company.

              selectedServices = services
                  .where((doc) => (doc.companyId == companyId))
                  .toList();

              return ListView.builder(
                  scrollDirection: Axis.vertical,
                  itemCount: selectedServices.length,
                  itemBuilder: (buildContext, index) {
                    return ServiceCard(serviceDetails: selectedServices[index]);
                  });
            } else {
              print('loading');

              return Container(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[CircularProgressIndicator()],
                ),
              );
            }
          }),
    );
  }
}
