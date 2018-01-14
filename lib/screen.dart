import 'dart:async';

import 'package:dribbble_client/dribbble_client.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mvi_sealed_unions/screen_intent.dart';
import 'package:mvi_sealed_unions/screen_item.dart';
import 'package:mvi_sealed_unions/screen_model.dart';
import 'package:mvi_sealed_unions/screen_state.dart';

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
          _intent.refreshPageIntent,
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
      body: new StreamBuilder(
        stream: _presenter,
        builder: (BuildContext context, AsyncSnapshot<ScreenState> snapshot) {
          return snapshot.hasData ? _body(snapshot.data) : new Container();
        },
      ),
    );
  }

  Widget _body(ScreenState state) {
    return new RefreshIndicator(
      child: _content(state),
      onRefresh: _intent.refreshPageIntent,
    );
  }

  Widget _content(ScreenState state) {
    return new Center(
      child: state.join(
        (data) {
          return new CustomScrollView(
            controller: _intent.nextPageIntent.scrollController,
            scrollDirection: Axis.vertical,
            slivers: <Widget>[
              new SliverAppBar(
                title: new Text("Dribbble Mvi"),
                elevation: 4.0,
              ),
              new SliverGrid.count(
                childAspectRatio: 4 / 3,
                crossAxisCount:
                    MediaQuery.of(context).orientation == Orientation.portrait
                        ? 1
                        : 2,
                children: data.items
                    .map((ScreenItem item) => item.join(
                          (shot) => new ShotItem(shot: shot.shot),
                          (_) => new LoadingItem(),
                        ))
                    .toList(growable: false),
              )
            ],
          );
        },
        (loading) => new CircularProgressIndicator(),
        (error) => new Text(error.message),
        (empty) {
          return new Text("Empty Response");
        },
      ),
    );
  }
}

class ShotItem extends StatelessWidget {
  final DribbbleShot shot;

  ShotItem({Key key, @required this.shot}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return new Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        new Hero(
          tag: shot,
          child: new AspectRatio(
            aspectRatio: 4 / 3,
            child: new GestureDetector(
              child: new Image.network(
                shot.images.teaser,
                fit: BoxFit.cover,
              ),
              onTap: () {
                fullScreen(context);
              },
            ),
          ),
        ),
      ],
    );
  }

  void fullScreen(BuildContext context) {
    Navigator.of(context).push(new PageRouteBuilder<Null>(
      pageBuilder: (
        BuildContext context,
        Animation<double> animation,
        Animation<double> secondaryAnimation,
      ) {
        return new Scaffold(
          body: new GestureDetector(
            onVerticalDragDown: (DragDownDetails _) {
              Navigator.pop(context);
            },
            child: new Container(
              color: Colors.black,
              child: new Center(
                child: new AspectRatio(
                  aspectRatio: shot.width / shot.height,
                  child: new Hero(
                    tag: shot,
                    child: new Stack(
                      children: <Widget>[
                        new Positioned.fill(
                          child: new Image.network(
                            shot.images.teaser,
                            fit: BoxFit.cover,
                          ),
                        ),
                        new Center(child: new CircularProgressIndicator()),
                        new Positioned.fill(
                          child: new Image.network(
                            shot.images.hiDpi ??
                                shot.images.normal ??
                                shot.images.teaser,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    ));
  }
}

class LoadingItem extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new Center(
      child: new Padding(
        padding: new EdgeInsets.all(8.0),
        child: new CircularProgressIndicator(),
      ),
    );
  }
}
