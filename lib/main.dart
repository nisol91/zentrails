import 'package:ZenTrails/widgets/service_card.dart';
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
        primaryColor: Colors.blueGrey[400],
        secondaryHeaderColor: Colors.blueGrey[200],
        accentColor: Colors.blueGrey[900],
        dividerColor: Colors.blueGrey[600],

        scaffoldBackgroundColor: Colors.white,
        // Define the default font family.
        // fontFamily: 'Montserrat',
        fontFamily: 'Lato',

        // Define the default TextTheme. Use this to specify the default
        // text styling for headlines, titles, bodies of text, and more.
        textTheme: TextTheme(
            headline: TextStyle(
              fontSize: 72.0,
              color: Colors.blueGrey[900],
            ),
            title: TextStyle(
              fontSize: 36.0,
              color: Colors.blueGrey[900],
            ),
            body1: TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 16,
              fontStyle: FontStyle.normal,
              color: Colors.blueGrey[900],
            ),
            body2: TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 22,
              fontStyle: FontStyle.normal,
              color: Colors.blueGrey[900],
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
  //per il bottom bar nav
  int _currentIndex = 0;

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

  //====bottom navbar control
  final List<Widget> _bottomBarTabs = [
    MapView(),
    AuthScreen(),
    CompanyList(),
    ProfilePage(),
  ];
  Widget changeBottomBarTab(int index) {
    setState(() {
      _currentIndex = index;
    });
    print(_currentIndex);
    print(_bottomBarTabs[_currentIndex]);

    return _bottomBarTabs[_currentIndex];
  }
  //==========

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
            bottomNavigationBar: BottomNavigationBar(
              currentIndex:
                  _currentIndex, // this will be set when a new tab is tapped
              onTap: changeBottomBarTab,
              type: BottomNavigationBarType.fixed,
              items: [
                BottomNavigationBarItem(
                  icon: new Icon(Icons.home),
                  title: new Text('Maps'),
                  backgroundColor: Colors.black,
                ),
                BottomNavigationBarItem(
                  icon: new Icon(Icons.mail),
                  title: new Text('Stats'),
                  backgroundColor: Colors.black,
                ),
                BottomNavigationBarItem(
                  icon: new Icon(Icons.traffic),
                  title: new Text('Tracks'),
                  backgroundColor: Colors.black,
                ),
                BottomNavigationBarItem(
                  icon: new Icon(Icons.verified_user),
                  title: new Text('User'),
                  backgroundColor: Colors.black,
                ),
              ],
            ),
            //questo modo di fare l'appbar è diverso da quello convenzionale:
            // mi permette di fare un appbar trasparente.
            body: Stack(
              children: <Widget>[
                _bottomBarTabs[_currentIndex],
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: AppBar(
                    title: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text('ZenTrails'),
                    ),
                    backgroundColor: tema.primaryColor.withOpacity(.5),
                    actions: <Widget>[
                      IconButton(
                        icon: Icon(Icons.account_box),
                        onPressed: _logInPage,
                        color: tema.accentColor,
                      ),
                    ],
                  ),
                )
              ],
            ),
          )
        : _loadingView;
  }
}
