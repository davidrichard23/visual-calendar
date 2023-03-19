import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:realm/realm.dart';
import './schemas.dart';

class RealmManager with ChangeNotifier {
  Realm? realm;
  bool isClientResetting = false;
  bool isSynced = false;

  init(User currentUser) {
    realm?.close();
    Configuration config = Configuration.flexibleSync(
      currentUser,
      [
        Team.schema,
        TeamInvite.schema,
        Event.schema,
        EventTask.schema,
        RecurrencePattern.schema,
        ImageData.schema,
        FocalPoint.schema,
      ],
      clientResetHandler: RecoverOrDiscardUnsyncedChangesHandler(
        // The following callbacks are optional.
        onBeforeReset: (beforeResetRealm) {
          log('Client Resetting - before');
          isClientResetting = true;
          // Executed right before a client reset is about to happen.
          // If an exception is thrown here the recovery and discard callbacks are not called.
        },
        onAfterRecovery: (beforeResetRealm, afterResetRealm) {
          log('Client Resetting - after recovery');
          // Executed right after an automatic recovery from a client reset has completed.
          isClientResetting = false;
        },
        onAfterDiscard: (beforeResetRealm, afterResetRealm) {
          log('Client Resetting - after discard');
          // Executed after an automatic recovery from a client reset has failed but the Discard has completed.
          isClientResetting = false;
        },
        onManualResetFallback: (clientResetError) {
          log('Client Resetting - manual reset fallback');
          // Handle the reset manually in case some of the callbacks above throws an exception
          realm?.close();
          // Attempt the client reset.
          try {
            clientResetError.resetRealm();
            // Navigate the user back to the main page or reopen the
            // the Realm and reinitialize the current page.
            init(currentUser);
          } catch (err) {
            // Reset failed.
            // Notify user that they'll need to update the app
            log('Client reset error: ');
            inspect(err);
          }
          isClientResetting = false;
        },
      ),
    );

    // final config = Configuration.local([
    //   Team.schema,
    //   TeamInvite.schema,
    //   Event.schema,
    //   EventTask.schema,
    //   RecurrencePattern.schema
    // ], shouldDeleteIfMigrationNeeded: true);

    realm = Realm(
      config,
    );

    final defaultTeamSub = realm!.subscriptions.findByName('defaultTeamSub');
    if (defaultTeamSub == null) {
      realm!.subscriptions.update((mutableSubscriptions) {
        mutableSubscriptions.add(realm!.all<Team>(), name: 'defaultTeamSub');
      });
    }

    final defaultTeamInviteSub =
        realm!.subscriptions.findByName('defaultTeamInviteSub');
    if (defaultTeamInviteSub == null) {
      realm!.subscriptions.update((mutableSubscriptions) {
        mutableSubscriptions.add(realm!.all<TeamInvite>(),
            name: 'defaultTeamInviteSub');
      });
    }

    final defaultEventSub = realm!.subscriptions.findByName('defaultEventSub');
    if (defaultEventSub == null) {
      realm!.subscriptions.update((mutableSubscriptions) {
        mutableSubscriptions.add(realm!.all<Event>(), name: 'defaultEventSub');
      });
    }

    final defaultEventTaskSub =
        realm!.subscriptions.findByName('defaultEventTaskSub');
    if (defaultEventTaskSub == null) {
      realm!.subscriptions.update((mutableSubscriptions) {
        mutableSubscriptions.add(realm!.all<EventTask>(),
            name: 'defaultEventTaskSub');
      });
    }

    final defaultImageDataSub =
        realm!.subscriptions.findByName('defaultImageDataSub');
    if (defaultImageDataSub == null) {
      realm!.subscriptions.update((mutableSubscriptions) {
        mutableSubscriptions.add(realm!.all<ImageData>(),
            name: 'defaultImageDataSub');
      });
    }

    notifyListeners();
  }

  Future<void> waitForTeamPermissionsUpdate() async {
    var existingTeams = realm!.syncSession.user.customData['teamAdminIds'];

    var maxRetries = 10;
    var retryCount = 0;

    while (retryCount < maxRetries) {
      await realm!.syncSession.user.refreshCustomData();
      if (realm!.syncSession.user.customData['teamAdminIds'].length !=
          existingTeams.length) {
        break;
      }

      await Future.delayed(const Duration(milliseconds: 1000));
      retryCount += 1;
    }

    // bail if failed
    if (retryCount == maxRetries) return;

    await realm!.syncSession.user.refreshCustomData();
    realm?.syncSession.pause();
    init(realm!.syncSession.user);
    realm!.syncSession.resume();

    isClientResetting = true;

    // wait for the client reset to finish
    retryCount = 0;
    while (retryCount < maxRetries) {
      await Future.delayed(const Duration(milliseconds: 1000));
      if (!isClientResetting) break;
      retryCount += 1;
    }
  }

  void waitForSubscriptionSync() async {
    try {
      isSynced = false;
      await realm!.subscriptions.waitForSynchronization();
      isSynced = true;
      notifyListeners();
    } catch (err) {
      log('syncError');
      inspect(err);
    }
  }

  close() {
    realm?.close();
    notifyListeners();
  }
}
