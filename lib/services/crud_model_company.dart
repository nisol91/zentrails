import 'dart:async';
import 'package:flutter/material.dart';
import '../locator.dart';
import '../services/api_crud_company.dart';
import '../models/company_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

//CRUD PER LE CORPORATE
//The CRUD Model will use the Api class to Handle the different operations.
class CrudModelCompany extends ChangeNotifier {
  ApiCompany _api = locator<ApiCompany>();

  List<Company> companies;

  Future<List<Company>> fetchCompanies() async {
    var result = await _api.getDataCollection();
    companies = result.documents
        .map((doc) => Company.fromMap(doc.data, doc.documentID))
        .toList();
    return companies;
  }

  Stream<QuerySnapshot> fetchCompaniesAsStream() {
    return _api.streamDataCollection();
  }

  Future<Company> getCompanyById(String id) async {
    var doc = await _api.getDocumentById(id);
    return Company.fromMap(doc.data, doc.documentID);
  }

  Future removeCompany(String id) async {
    await _api.removeDocument(id);
    return;
  }

  Future updateCompany(Company data, String id) async {
    await _api.updateDocument(data.toJson(), id);
    return;
  }

  Future addCompany(Company data) async {
    var result = await _api.addDocument(data.toJson());

    return;
  }
}
