import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../app_state_container.dart';
import '../models/company_model.dart';
import '../widgets/company_card.dart';

class CompanyList extends StatefulWidget {
  final bool filter;
  final bool adminList;

  const CompanyList({Key key, this.filter, this.adminList}) : super(key: key);

  @override
  _CompanyListState createState() => _CompanyListState();
}

class _CompanyListState extends State<CompanyList> {
  List<Company> companies;
  List<Company> companiesFromFetch;
  TextEditingController editingController = TextEditingController();
  GlobalKey<ScaffoldState> _key;
  bool expandedSearch = false;

  bool loadedCompanies = false;
  List<String> filters = [
    'alphabethical',
    'featured',
    'nearby',
    'filtro3',
    'filtro4',
    'filtro5'
  ];

  @override
  initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    getCompanies();

    //richiama una funz periodicamente
    // Timer.periodic(Duration(seconds: 60), (Timer t) => getCompanies());
  }

  void selectFilter(tag) {
    switch (tag) {
      case 'alphabethical':
        print('alphabethical');
        orderAlfa();
        break;
      case 'featured':
        print('featured');
        filterFeatured();
        break;
      case 'nearby':
        print('nearby');
        break;
      case 'filtro3':
        print('filtro3');
        break;
      case 'filtro4':
        print('filtro4');
        break;
      default:
    }
  }

  void getCompanies() async {
    //MODO ALTERNATIVO SFRUTTANDO I METODI DELLA CRUD (CHE POI SONO IDENTICI)
    //A QUELLI CHE USO IO. SOLO CHE E' SCOMODO PERCHE RENDE COMPLESSI I FILTRI.
    // Provider.of<CrudModelCompany>(context)
    //     .fetchCompanies()
    //     .then((companiesFromFetch) => setState(() {
    //           companies = companiesFromFetch;
    //         }));
    // print('COMPANIES->${companies}');
    // loadedCompanies = true;
    print('GETTING=======================');
    Firestore.instance.collection("companies").snapshots().listen((doc) {
      companiesFromFetch = doc.documents
          .map((doc) => Company.fromMap(doc.data, doc.documentID))
          .toList();
      //se avessi messo collection().getDocuments().then() mi faceva la query una volta
      // non sarebbe rimasta in ascolto come fa ora. Cosi si aggiorna senza dover
      //richiamare la funzione periodicamente e si aggiorna solo quando vengono tolti
      //o aggiunti dei dati
      if (mounted) {
        setState(() {
          companies = companiesFromFetch;
        });
      }
      print('COMPANIES->${companies}');
      loadedCompanies = true;
    });
  }

  void orderAlfa() async {
    if (mounted) {
      setState(() {
        loadedCompanies = false;
      });
    }
    print('sorting alfab...');
    await Firestore.instance
        .collection("companies")
        .orderBy('name', descending: false)
        .getDocuments()
        .then((doc) {
      companiesFromFetch = doc.documents
          .map((doc) => Company.fromMap(doc.data, doc.documentID))
          .toList();
      if (mounted) {
        setState(() {
          companies = companiesFromFetch;
        });
      }
      print(companies);
      loadedCompanies = true;
    });
  }

  void filterSearchResults(value) async {
    if (value != null) {
      if (mounted) {
        setState(() {
          loadedCompanies = false;
        });
      }
      await Firestore.instance
          .collection("companies")
          .getDocuments()
          .then((doc) {
        companiesFromFetch = doc.documents
            .map((doc) => Company.fromMap(doc.data, doc.documentID))
            .where((doc) => doc.name.contains(value))
            .toList();
        if (mounted) {
          setState(() {
            companies = companiesFromFetch;
          });
        }
        print(companies);
        loadedCompanies = true;
      });
    }
  }

  void filterFeatured() async {
    if (mounted) {
      setState(() {
        loadedCompanies = false;
      });
    }
    print('sorting alfab...');
    await Firestore.instance
        .collection("companies")
        .where('featured', isEqualTo: true)
        .getDocuments()
        .then((doc) {
      companiesFromFetch = doc.documents
          .map((doc) => Company.fromMap(doc.data, doc.documentID))
          .toList();
      if (mounted) {
        setState(() {
          companies = companiesFromFetch;
        });
      }
      print(companies);
      loadedCompanies = true;
    });
  }

  Widget get _searchBar {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Container(
        height: 40,
        child: Row(
          children: <Widget>[
            Expanded(
              child: TextField(
                onTap: () {
                  expandedSearch = true;
                  print(expandedSearch);
                },
                controller: editingController,
                onChanged: (value) {
                  filterSearchResults(value);
                },
                decoration: InputDecoration(
                    labelText: "Search",
                    hintText: "Search",
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(25.0)))),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget get _filters {
    return Container(
      child: Expanded(
        flex: 1,
        child: Row(
          children: <Widget>[
            Expanded(
              child: SizedBox(
                height: 70,
                child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: filters.length,
                    itemBuilder: (BuildContext ctxt, int index) {
                      return Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Material(
                          child: InkWell(
                            onTap: () => selectFilter(filters[index]),
                            child: Container(
                              height: 30,
                              width: MediaQuery.of(context).size.width * 0.25,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Text(filters[index]),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var container = AppStateContainer.of(context);
    return Column(
      children: <Widget>[
        (widget.filter)
            ? Expanded(
                flex: (expandedSearch) ? 6 : 3,
                child: GestureDetector(
                  onTap: () {
                    FocusScopeNode currentFocus = FocusScope.of(context);
                    if (!currentFocus.hasPrimaryFocus) {
                      currentFocus.unfocus();
                      expandedSearch = false;
                    }
                  },
                  child: Column(
                    children: <Widget>[
                      // Text('FILTER'),
                      _searchBar,
                      _filters,
                    ],
                  ),
                ),
              )
            : Container(),
        Expanded(
          flex: 10,
          child: Container(
              padding: EdgeInsets.all(1),
              child:
                  (container.areYouAdmin == false && widget.adminList == true)
                      ? Container(
                          child: Column(
                            children: <Widget>[
                              Text(
                                  'devi essere admin per poter accedere a questa pagina'),
                            ],
                          ),
                        )
                      : (loadedCompanies)
                          ? ListView.builder(
                              scrollDirection: Axis.vertical,
                              itemCount: companies.length,
                              itemBuilder: (buildContext, index) =>
                                  CompanyCard(companyDetails: companies[index]),
                            )
                          : Container(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: <Widget>[CircularProgressIndicator()],
                              ),
                            )),
        ),
      ],
    );
  }
}
