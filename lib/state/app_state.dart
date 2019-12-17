import 'package:firebase_auth/firebase_auth.dart';

//QUESTO FILE è LEGATO ALL INHERITED WIDGET, PER LO STATO DELL APP
class AppState {
  // Your app will use this to know when to display loading spinners.
  bool isLoading;
  FirebaseUser user;

  // Constructor
  AppState({
    this.isLoading = false,
    this.user,
  });

  // A constructor for when the app is loading.
  factory AppState.loading() => new AppState(isLoading: true);

  @override
  String toString() {
    return 'AppState{isLoading: $isLoading}';
  }
}
