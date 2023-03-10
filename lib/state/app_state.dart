import 'dart:async';
import 'dart:developer';
import 'dart:ffi';

import 'package:calendar/models/team_model.dart';
import 'package:calendar/realm/schemas.dart';
import 'package:flutter/material.dart';
import 'package:localstorage/localstorage.dart';
import 'package:realm/realm.dart';

class AppState extends ChangeNotifier {
  List<TeamModel> allTeams = [];
  TeamModel? activeTeam;
  String? teamUserType;
  bool didInit = false;

  final LocalStorage _appStorage = LocalStorage('app');

  // needed to keep the garbage collector from clearing the stream
  StreamSubscription<RealmResultsChanges<Team>>? stream;

  init(Realm? realm) async {
    if (realm != null) await _getTeams(realm);
    didInit = true;
    notifyListeners();
  }

  void setActiveTeam(Realm realm, TeamModel newActiveTeam) {
    activeTeam = newActiveTeam;
    teamUserType = realm.syncSession.user.customData['teamUserTypes']
        [activeTeam!.id.toString()];

    _appStorage.setItem('active-team-id', newActiveTeam.id.toString());

    notifyListeners();
  }

  Future<void> _getTeams(Realm realm) async {
    final query = realm.all<Team>();
    await _appStorage.ready;
    var savedActiveTeamId = _appStorage.getItem('active-team-id');

    if (savedActiveTeamId != null) {
      try {
        var savedActiveProfile = query.firstWhere(
            (element) => element.id.toString() == savedActiveTeamId);

        setActiveTeam(realm, TeamModel(realm, savedActiveProfile));
      } catch (err) {
        //ignore
      }
    }

    final allTeamsSub = realm.subscriptions.findByName('allTeamsSub');
    if (allTeamsSub == null) {
      realm.subscriptions.update((mutableSubscriptions) {
        mutableSubscriptions.add(query, name: 'allTeamsSub');
      });
    }

    allTeams = [];

    if (stream != null) await stream!.cancel();

    stream = query.changes.listen((changes) {
      for (final deletionIndex in changes.deleted) {
        allTeams.removeAt(deletionIndex); // update view model collection
        notifyListeners();
      }

      // Handle inserts
      for (final insertionIndex in changes.inserted) {
        allTeams.insert(
            insertionIndex, TeamModel(realm, changes.results[insertionIndex]));
        if (activeTeam == null) setActiveTeam(realm, allTeams[0]);
        notifyListeners();
      }

      // Handle modifications
      for (final modifiedIndex in changes.modified) {
        allTeams[modifiedIndex] =
            TeamModel(realm, changes.results[modifiedIndex]);
        if (activeTeam == null) setActiveTeam(realm, allTeams[0]);
        notifyListeners();
      }

      // Handle initialization (or any mismatch really, but that shouldn't happen)
      if (changes.results.length != allTeams.length) {
        allTeams =
            changes.results.map((item) => TeamModel(realm, item)).toList();
        if (activeTeam == null) setActiveTeam(realm, allTeams[0]);

        notifyListeners();
      }
    }, onError: (err) {
      log('stream error');
      inspect(err);
    }, onDone: () {
      log('stream done');
    });

    notifyListeners();
  }
}
