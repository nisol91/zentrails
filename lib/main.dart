import 'package:cloud_firestore/cloud_firestore.dart';
import './views/add_company.dart';
import './views/profile_page.dart';
import 'package:flushbar/flushbar.dart';
import './views/company_list_view_admin.dart';
import 'package:flutter/material.dart';
import './views/auth_screen.dart';
import './state/app_state.dart';
import 'app_state_container.dart';
import './services/crud_model_company.dart';
import 'locator.dart';
import 'package:provider/provider.dart';
import 'models/company_model.dart';
import 'services/crud_model_service.dart';
import 'views/map_view.dart';
import 'widgets/company_card.dart';
import 'widgets/company_list.dart';

void main() {
  setupLocator();
  runApp(new AppStateContainer(
    child: new MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  ThemeData get _themeData => new ThemeData(
        primaryColor: Colors.green[400],
        secondaryHeaderColor: Colors.green[200],
        accentColor: Colors.teal[900],
        dividerColor: Colors.green[600],

        scaffoldBackgroundColor: Colors.white,
        // Define the default font family.
        // fontFamily: 'Montserrat',
        fontFamily: 'Lato',

        // Define the default TextTheme. Use this to specify the default
        // text styling for headlines, titles, bodies of text, and more.
        textTheme: TextTheme(
            headline: TextStyle(
              fontSize: 72.0,
              color: Colors.teal[900],
            ),
            title: TextStyle(
              fontSize: 36.0,
              color: Colors.teal[900],
            ),
            body1: TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 16,
              fontStyle: FontStyle.normal,
              color: Colors.teal[900],
            ),
            body2: TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 22,
              fontStyle: FontStyle.normal,
              color: Colors.teal[900],
            )),
      );
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(builder: (_) => locator<CrudModelCompany>()),
        ChangeNotifierProvider(builder: (_) => locator<CrudModelService>()),
      ],
      child: MaterialApp(
        title: 'ZenTrails App',
        theme: (AppStateContainer.of(context).chooseTheme == true)
            ? _themeData
            : ThemeData(brightness: Brightness.dark),
        routes: {
          '/': (BuildContext context) => new MyHomePage(title: 'ZenTrails'),
          '/addCompany': (BuildContext context) => new AddCompany(),
          '/companyListAdmin': (BuildContext context) =>
              new CompanyListViewAdmin(),
        },
        // theme: ThemeData(brightness: Brightness.dark),
        // home: new MyHomePage(),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => new _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage>
    with SingleTickerProviderStateMixin {
  String email = '';
  bool areYouAdmin = false;
  List<Company> companies;
  TabController controller;

  @override
  initState() {
    super.initState();
    controller = new TabController(vsync: this, length: 3);
  }

  _logInPage() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (BuildContext context) {
          return AuthScreen();
        },
      ),
    );
  }

  _profilePage() async {
    final container = AppStateContainer.of(context);
    print(await container.ensureGoogleLoggedInOnStartUp());
    if (await container.ensureGoogleLoggedInOnStartUp() != null ||
        await container.ensureEmailLoggedInOnStartup() != null) {
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (BuildContext context) {
            return ProfilePage();
          },
        ),
      );
    } else {
      Flushbar(
        title: "Hey Ninja",
        message: "You need to login, to access this page",
        duration: Duration(seconds: 3),
        backgroundColor: Theme.of(context).accentColor,
      )..show(context);
    }
  }

  _companyPage_2() async {
    final container = AppStateContainer.of(context);
    print(await container.ensureGoogleLoggedInOnStartUp());
    if (await container.ensureGoogleLoggedInOnStartUp() != null ||
        await container.ensureEmailLoggedInOnStartup() != null) {
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (BuildContext context) {
            return CompanyListViewAdmin();
          },
        ),
      );
    } else {
      Flushbar(
        title: "Hey Ninja",
        message: "You need to login, to access this page",
        duration: Duration(seconds: 3),
        backgroundColor: Theme.of(context).accentColor,
      )..show(context);
    }
  }

  AppState appState;

  Widget get _loadingView {
    return new Scaffold(
      body: new Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: <Widget>[
                  Text('ECHO'),
                  Image(image: AssetImage('assets/echo_logo.png'))
                ],
              ),
            ),
            new CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }

  Widget get _companyListViewHome {
    return Container(
      child: CompanyList(
        filter: true,
        adminList: false,
      ),
    );
  }

  Widget get _mapView {
    return Container(
      child: MapView(),
    );
  }

  Widget get _homeView {
    final companyProvider = Provider.of<CrudModelCompany>(context);
    var tema = Theme.of(context);

    return StreamBuilder(
        stream: companyProvider.fetchCompaniesAsStream(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasData) {
            print('fatto');

            companies = snapshot.data.documents
                .map((doc) => Company.fromMap(doc.data, doc.documentID))
                .toList();
            return Column(
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                            border: Border(
                                bottom: BorderSide(
                                    color: tema.dividerColor, width: 3))),
                        child: SizedBox(
                          height: MediaQuery.of(context).size.height * 0.25,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: companies.length,
                            itemBuilder: (buildContext, index) =>
                                (companies[index].featured == true)
                                    ? CompanyCard(
                                        companyDetails: companies[index],
                                        featuredColor: tema.primaryColor,
                                      )
                                    : Container(),
                          ),
                        ),
                      ),
                    )
                  ],
                ),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: SizedBox(
                          height: MediaQuery.of(context).size.height * 0.5774,
                          child: Stack(
                            children: <Widget>[
                              Container(
                                decoration: BoxDecoration(
                                  // Box decoration takes a gradient
                                  gradient: LinearGradient(
                                    // Where the linear gradient begins and ends
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    // Add one stop for each color. Stops should increase from 0 to 1
                                    stops: [0.1, 0.99],
                                    colors: [
                                      // Colors are easy thanks to Flutter's Colors class.
                                      Colors.transparent,
                                      Theme.of(context).accentColor,
                                    ],
                                  ),
                                ),
                              ),
                              ListView.builder(
                                scrollDirection: Axis.vertical,
                                itemCount: companies.length,
                                itemBuilder: (buildContext, index) =>
                                    CompanyCard(
                                        companyDetails: companies[index]),
                              ),
                            ],
                          )),
                    )
                  ],
                ),
              ],
            );
          } else {
            print('loading');

            return Container(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  CircularProgressIndicator(),
                ],
              ),
            );
          }
        });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var tema = Theme.of(context);

    var container = AppStateContainer.of(context);

    appState = container.state;

    return (!appState.isLoading)
        ? new Scaffold(
            appBar: new AppBar(
              title: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Image(
                  image: AssetImage('assets/echo_logo.png'),
                  height: 30,
                ),
              ),

              backgroundColor: tema.primaryColor,
              bottom: new TabBar(controller: controller, tabs: <Tab>[
                new Tab(
                    icon: new Icon(
                  Icons.home,
                  color: tema.accentColor,
                )),
                new Tab(icon: new Icon(Icons.list, color: tema.accentColor)),
                new Tab(
                    icon: new Icon(Icons.location_on, color: tema.accentColor))
              ]),
              // This is how you add new buttons to the top right of a material appBar.
              // You can add as many as you'd like.
              actions: <Widget>[
                IconButton(
                  icon: Icon(Icons.account_box),
                  onPressed: _logInPage,
                  color: tema.accentColor,
                ),
                IconButton(
                  icon: Icon(Icons.settings),
                  onPressed: _profilePage,
                  color: tema.accentColor,
                ),
                (container.areYouAdmin == true)
                    ? IconButton(
                        icon: Icon(Icons.dashboard),
                        onPressed: _companyPage_2,
                        color: tema.accentColor,
                      )
                    : Container(),
              ],
            ),
            bottomNavigationBar: BottomNavigationBar(
              currentIndex: 0, // this will be set when a new tab is tapped
              items: [
                BottomNavigationBarItem(
                  icon: new Icon(Icons.home),
                  title: new Text('Home'),
                ),
                BottomNavigationBarItem(
                  icon: new Icon(Icons.mail),
                  title: new Text('Messages'),
                ),
              ],
            ),
            body: Container(
              height: MediaQuery.of(context).size.height * 1,
              child: TabBarView(
                controller: controller,
                children: [
                  _homeView,
                  _companyListViewHome,
                  _mapView,
                  // Text('tab cosa ci metto?una mappa? una lista di citta?'),
                  // new CompanyList(),
                  // new AuthScreen(),
                ],
              ),
            ),
          )
        : _loadingView;
  }
}
