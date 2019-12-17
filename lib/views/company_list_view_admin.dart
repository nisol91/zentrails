import 'package:flutter/material.dart';
import '../models/company_model.dart';
import '../widgets/company_list.dart';

class CompanyListViewAdmin extends StatefulWidget {
  @override
  _CompanyListViewAdminState createState() => _CompanyListViewAdminState();
}

class _CompanyListViewAdminState extends State<CompanyListViewAdmin> {
  List<Company> companies;

  @override
  initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/addCompany');
        },
        child: Icon(Icons.add),
      ),
      appBar: AppBar(
        title: Center(child: Text('Admin Dashboard')),
      ),
      body: CompanyList(
        filter: false,
        adminList: true,
      ),
    );
    ;
  }
}
