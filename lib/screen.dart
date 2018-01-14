import 'dart:async';
import 'dart:typed_data';

import 'package:dribbble_client/dribbble_client.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mvi_sealed_unions/screen_collection.dart';
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
        (collection) {
          return new CollectionWidget(
            collection: collection,
            controller: _intent.nextPageIntent.scrollController,
          );
        },
        (loading) => new CircularProgressIndicator(),
        (error) => new Text(error.message),
        (empty) => new Text("Empty Response"),
      ),
    );
  }
}

class CollectionWidget extends StatelessWidget {
  final ScreenCollection collection;
  final ScrollController controller;

  CollectionWidget({
    Key key,
    @required this.collection,
    @required this.controller,
  })
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return new CustomScrollView(
      controller: controller,
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
          children: collection.items
              .map((ScreenItem item) => item.join(
                    (shot) => new ShotItem(shot: shot.shot),
                    (_) => new LoadingItem(),
                  ))
              .toList(growable: false),
        )
      ],
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
              child: new FadeInImage.memoryNetwork(
                fadeInDuration: new Duration(milliseconds: 200),
                placeholder: kTransparentImage,
                image: shot.images.teaser,
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

final Uint8List kTransparentImage = new Uint8List.fromList(<int>[
  0x89,
  0x50,
  0x4E,
  0x47,
  0x0D,
  0x0A,
  0x1A,
  0x0A,
  0x00,
  0x00,
  0x00,
  0x0D,
  0x49,
  0x48,
  0x44,
  0x52,
  0x00,
  0x00,
  0x00,
  0x01,
  0x00,
  0x00,
  0x00,
  0x01,
  0x08,
  0x06,
  0x00,
  0x00,
  0x00,
  0x1F,
  0x15,
  0xC4,
  0x89,
  0x00,
  0x00,
  0x00,
  0x0A,
  0x49,
  0x44,
  0x41,
  0x54,
  0x78,
  0x9C,
  0x63,
  0x00,
  0x01,
  0x00,
  0x00,
  0x05,
  0x00,
  0x01,
  0x0D,
  0x0A,
  0x2D,
  0xB4,
  0x00,
  0x00,
  0x00,
  0x00,
  0x49,
  0x45,
  0x4E,
  0x44,
  0xAE,
]);
