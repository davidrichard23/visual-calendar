import 'dart:async';
import 'dart:developer';

import 'package:calendar/realm/init_realm.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:realm/realm.dart';

enum QueryType {
  all,
  queryString,
}

class WithId {
  ObjectId id;
  WithId({required this.id});
}

class RealmQueryBuilder<T extends RealmObject> extends StatefulWidget {
  final void Function<T extends RealmObject>(RealmResults<T>) onUpdate;
  final Widget child;
  final QueryType queryType;
  final String queryName;
  final String? queryString;
  final List<Object>? queryArgs;

  const RealmQueryBuilder(
      {super.key,
      required this.onUpdate,
      required this.child,
      required this.queryType,
      required this.queryName,
      this.queryString,
      this.queryArgs});

  @override
  State<RealmQueryBuilder> createState() => _RealmQueryBuilderState<T>();
}

class _RealmQueryBuilderState<T extends RealmObject>
    extends State<RealmQueryBuilder> {
  RealmResults<T>? _prevItems;
  late RealmResults<T>? query;

  // fixes hot reload issue
  @override
  void reassemble() {
    super.reassemble();
    setState(() {
      _prevItems = null;
      query = null;
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    initQuery();
  }

  @override
  void didUpdateWidget(oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.queryString == widget.queryString &&
        oldWidget.queryName == widget.queryName &&
        oldWidget.queryType == widget.queryType) return;

    initQuery();
  }

  initQuery() {
    RealmManager realmManager =
        Provider.of<RealmManager>(context, listen: true);

    switch (widget.queryType) {
      case QueryType.all:
        final newQuery = realmManager.realm!.all<T>();
        setState(() {
          query = newQuery;
          _prevItems = query;
        });
        Timer(const Duration(milliseconds: 10), () {
          widget.onUpdate<T>(query!);
        });
        break;
      case QueryType.queryString:
        RealmResults<T> newQuery;
        if (widget.queryArgs == null) {
          newQuery = realmManager.realm!.all<T>().query(widget.queryString!);
        } else {
          newQuery = realmManager.realm!
              .all<T>()
              .query(widget.queryString!, widget.queryArgs!);
        }
        setState(() {
          query = newQuery;
          _prevItems = query;
        });
        Timer(const Duration(milliseconds: 10), () {
          widget.onUpdate<T>(query!);
        });
        break;
      default:
        throw 'Not a valid QueryType';
    }
  }

  @override
  Widget build(BuildContext context) {
    RealmManager realmManager =
        Provider.of<RealmManager>(context, listen: true);

    if (query == null) return Container();

    final userItemSub =
        realmManager.realm!.subscriptions.findByName(widget.queryName);
    if (userItemSub == null) {
      realmManager.realm!.subscriptions.update((mutableSubscriptions) {
        mutableSubscriptions.add(query!, name: widget.queryName);
      });
    }

    return StreamBuilder<RealmResultsChanges<T>>(
        stream: query!.changes,
        builder: (context, snapshot) {
          final data = snapshot.data;

          if (realmManager.realm!.isClosed) {
            return Container();
          }
          if (data == null) {
            // While we wait for data to load..
            return Container(
              padding: const EdgeInsets.only(top: 25),
              child: const Center(child: Text("No Items yet!")),
            );
          }

          handleUpdate(RealmResults<T> items) {
            _prevItems = items;

            Timer(const Duration(milliseconds: 10), () {
              widget.onUpdate<T>(items);
            });
          }

          try {
            // this line triggers the hot reload error that is caught below so other
            // widgets dont have to deal with it
            data.results.isEmpty;
            // inspect(data);

            if (_prevItems == null ||
                data.inserted.isNotEmpty ||
                data.modified.isNotEmpty ||
                data.deleted.isNotEmpty ||
                data.newModified.isNotEmpty ||
                data.moved.isNotEmpty) {
              handleUpdate(data.results);
            }
          } on RealmException catch (err) {
            // cant figure out why i get this error, but it seems to only happen
            // on hot reload so we're just going to ignore it for now
            if (!err.message.contains('Error code: 18')) {
              rethrow;
            }
          }

          return widget.child;
        });
  }
}
