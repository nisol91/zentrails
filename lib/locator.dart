import 'package:get_it/get_it.dart';
import './services/api_crud_company.dart';
import './services/api_crud_service.dart';

import './services/crud_model_company.dart';
import './services/crud_model_service.dart';

//QUESTO FILE LOCALIZZA I MODEL DELLE CRUD
GetIt locator = GetIt.I;

void setupLocator() {
  locator.registerLazySingleton(() => ApiCompany('companies'));
  locator.registerLazySingleton(() => CrudModelCompany());
  locator.registerLazySingleton(() => ApiService('services'));
  locator.registerLazySingleton(() => CrudModelService());
}
