import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mvi_sealed_unions/screen_intent.dart';
import 'package:mvi_sealed_unions/screen_model.dart';
import 'package:mvi_sealed_unions/screen_updates.dart';

class Screen extends StatefulWidget {
  final ScreenIntent _intent;
  final ScreenModel _presenter;

  Screen._(Key key, this._presenter, this._intent) : super(key: key);

  factory Screen({
    Key key,
    ScreenIntent intent,
    ScreenModel presenter,
  }) {
    final _intent = intent ?? new ScreenIntent();
    final _presenter = presenter ??
        new ScreenModel(
          _intent.firstPageIntent,
          _intent.nextPageIntent,
        );

    return new Screen._(key, _presenter, _intent);
  }

  @override
  _ScreenState createState() => new _ScreenState();
}

class _ScreenState extends State<Screen> {
  ScreenIntent _intent;
  ScreenModel _presenter;

  @override
  void initState() {
    super.initState();

    _intent = widget._intent;
    _presenter = widget._presenter;
    scheduleMicrotask(() {
      _intent.firstPageIntent();
    });
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(title: new Text('Sealed Union Example')),
      body: new StreamBuilder(
        stream: _presenter,
        initialData: new ScreenState.initial(),
        builder: (BuildContext context, AsyncSnapshot<ScreenState> snapshot) {
          return _body(snapshot.data);
        },
      ),
    );
  }

  Widget _body(ScreenState state) {
    return new RefreshIndicator(
      child: _content(state),
      onRefresh: _intent.nextPageIntent,
    );
  }

  Widget _content(ScreenState state) {
    return new Center(
      child: state.join(
        (data) {
          return new ListView.builder(
            itemCount: data.length,
            itemBuilder: (context, index) {
              return new ListTile(title: new Text(data[index]));
            },
          );
        },
        (loading) => new CircularProgressIndicator(),
        (error) => new Text(error.message),
        (empty) => new Text("Empty Response"),
      ),
    );
  }
}
