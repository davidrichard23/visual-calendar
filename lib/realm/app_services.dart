import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:localstorage/localstorage.dart';
import 'package:realm/realm.dart';

class AppServices with ChangeNotifier {
  String id;
  Uri baseUrl;
  late App _app;
  bool didInit = false;
  User? currentUser;

  AppServices(this.id, this.baseUrl) {
    init();
  }

  init() {
    _app = App(AppConfiguration(id, baseUrl: baseUrl));
    currentUser = _app.currentUser;
    didInit = true;
    notifyListeners();
  }

  // Future<void> refreshCustomData() async {
  //   await _app.currentUser!.refreshCustomData();
  //   currentUser = _app.currentUser;
  //   notifyListeners();
  // }

  Future<User> logInUserEmailPw(String email, String password) async {
    try {
      User loggedInUser =
          await _app.logIn(Credentials.emailPassword(email, password));
      currentUser = loggedInUser;
      notifyListeners();
      return loggedInUser;
    } catch (err) {
      rethrow;
    }
  }

  Future<User> logInAnon() async {
    try {
      User loggedInUser = await _app.logIn(Credentials.anonymous());
      currentUser = loggedInUser;
      notifyListeners();
      return loggedInUser;
    } catch (err) {
      rethrow;
    }
  }

  Future<void> sendPasswordResetEmail(String email) async {
    try {
      EmailPasswordAuthProvider authProvider = EmailPasswordAuthProvider(_app);
      await authProvider.resetPassword(email);
    } catch (err) {
      rethrow;
    }
  }

  Future<void> resetPassword(
      String password, String token, String tokenId) async {
    try {
      EmailPasswordAuthProvider authProvider = EmailPasswordAuthProvider(_app);
      await authProvider.completeResetPassword(password, token, tokenId);
    } catch (err) {
      rethrow;
    }
  }

  Future<User> registerUserEmailPw(String email, String password) async {
    try {
      EmailPasswordAuthProvider authProvider = EmailPasswordAuthProvider(_app);
      await authProvider.registerUser(email, password);
      User loggedInUser =
          await _app.logIn(Credentials.emailPassword(email, password));
      currentUser = loggedInUser;
      notifyListeners();
      return loggedInUser;
    } catch (err) {
      rethrow;
    }
  }

  Future<void> logOutUser() async {
    final LocalStorage appStorage = LocalStorage('app');

    await _app.currentUser?.logOut();
    appStorage.deleteItem('active-team-id');
    currentUser = null;
    notifyListeners();
  }

  // Future<void> deleteUser(Realm realm) async {
  //   final LocalStorage appStorage = LocalStorage('app');

  //   appStorage.deleteItem('active-team-id');
  //   await logOutUser();

  //   // for some reason we need a small delay before deleting realm
  //   Timer(const Duration(milliseconds: 500), () {
  //     realm.close();
  //     Realm.deleteRealm(realm.config.path);
  //   });

  //   currentUser = null;
  //   notifyListeners();
  // }
}
