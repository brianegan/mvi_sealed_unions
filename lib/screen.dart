import 'dart:async';

import 'package:dribbble_client/dribbble_client.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mvi_sealed_unions/di.dart';
import 'package:mvi_sealed_unions/screen_collection.dart';
import 'package:mvi_sealed_unions/screen_intent.dart';
import 'package:mvi_sealed_unions/screen_item.dart';
import 'package:mvi_sealed_unions/screen_model.dart';
import 'package:mvi_sealed_unions/screen_state.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:transparent_image/transparent_image.dart';

class ShotsList extends StatefulWidget {
  final ScreenIntent _intent;
  final Stream<ScreenState> _presenter;

  ShotsList._(Key key, this._presenter, this._intent) : super(key: key);

  factory ShotsList({
    Key key,
    ScreenIntent intent,
    Stream<ScreenState> presenter,
  }) {
    final _intent = intent ?? new ScreenIntent();
    final _presenter = presenter ??
        model(
          _intent.firstPageIntent,
          _intent.refreshPageIntent,
          _intent.nextPageIntent,
          DependencyInjector.instance.interactor,
        );

    return new ShotsList._(key, _presenter, _intent);
  }

  @override
  _ScreenState createState() => new _ScreenState();
}

class _ScreenState extends State<ShotsList> {
  ScreenIntent _intent;
  Stream<ScreenState> _presenter;

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
    final crossAxisCount =
        MediaQuery.of(context).orientation == Orientation.portrait ? 2 : 3;

    return new CustomScrollView(
      controller: controller,
      scrollDirection: Axis.vertical,
      slivers: <Widget>[
        new SliverAppBar(
          title: new Text("Dribbble Demo"),
          elevation: 4.0,
        ),
        new SliverStaggeredGrid.count(
          crossAxisCount: crossAxisCount,
          children: collection.items
              .map((ScreenItem item) => item.join(
                    (shot) => new ShotItem(
                          shot: shot.shot,
                          backgroundColor: shot.backgroundColor,
                          controller: controller,
                        ),
                    (_) => new LoadingItem(),
                  ))
              .toList(growable: false),
          staggeredTiles: _getTiles(context, collection.items, crossAxisCount),
        ),
      ],
    );
  }

  List<StaggeredTile> _getTiles(
    BuildContext context,
    List<ScreenItem> items,
    int crossAxisCount,
  ) {
    final List<StaggeredTile> tiles = new List(items.length);
    final orientation = MediaQuery.of(context).orientation;

    for (var i = 0; i < items.length; i++) {
      final ratio = (3 / 4);

      if (orientation == Orientation.portrait) {
        tiles[i] = items[i].join(
          (shot) => i % 5 == 0
              ? new StaggeredTile.extent(
                  2, (MediaQuery.of(context).size.width) * ratio)
              : new StaggeredTile.extent(
                  1, (MediaQuery.of(context).size.width / 2) * ratio),
          (_) => new StaggeredTile.extent(2, 100.0),
        );
      } else if (orientation == Orientation.landscape) {
        tiles[i] = items[i].join(
          (shot) {
            return i % 7 == 0
                ? new StaggeredTile.extent(
                    2, (MediaQuery.of(context).size.width / 3 * 2) * ratio)
                : new StaggeredTile.extent(
                    1, (MediaQuery.of(context).size.width / 3) * ratio);
          },
          (_) => new StaggeredTile.extent(3, 200.0),
        );
      }
    }

    return tiles;
  }
}

class ShotItem extends StatelessWidget {
  final DribbbleShot shot;
  final Color backgroundColor;
  final ScrollController controller;

  ShotItem({
    Key key,
    @required this.shot,
    @required this.backgroundColor,
    @required this.controller,
  })
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return new Container(
      color: backgroundColor,
      child: new Stack(
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
          new Positioned(
            right: 12.0,
            bottom: 12.0,
            child: new AnimatedPreview(
              animated: shot.animated,
            ),
          )
        ],
      ),
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

class AnimatedPreview extends StatelessWidget {
  final bool animated;

  AnimatedPreview({Key key, this.animated}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return animated
        ? new Container(
            decoration: new BoxDecoration(
              color: new Color.fromRGBO(0, 0, 0, 0.4),
              borderRadius: new BorderRadius.all(new Radius.circular(3.0)),
            ),
            padding: new EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
            child: new Text("GIF"),
          )
        : new Container();
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
