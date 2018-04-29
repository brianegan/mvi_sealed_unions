import 'package:after_layout/after_layout.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mvi_sealed_unions/common/screen_item_list.dart';
import 'package:mvi_sealed_unions/search/search_screen.dart';
import 'package:mvi_sealed_unions/trending/trending_interactor.dart';
import 'package:mvi_sealed_unions/trending/trending_presenter.dart';
import 'package:mvi_sealed_unions/trending/trending_screen_model.dart';

class TrendingScreen extends StatefulWidget {
  final TrendingPresenter Function() initPresenter;

  TrendingScreen({
    Key key,
    this.initPresenter,
  }) : super(key: key);

  @override
  _TrendingScreenState createState() => _TrendingScreenState();
}

class _TrendingScreenState extends State<TrendingScreen>
    with AfterLayoutMixin<TrendingScreen> {
  final ScrollController _controller = ScrollController();
  TrendingPresenter _presenter;

  @override
  void initState() {
    _presenter = widget.initPresenter != null
        ? widget.initPresenter()
        : TrendingPresenter(TrendingInteractor());

    _controller.addListener(_endOfListListener);

    super.initState();
  }

  @override
  void afterFirstLayout(BuildContext context) {
    _presenter.loadFirstPage();
  }

  @override
  void dispose() {
    _controller.removeListener(_endOfListListener);
    _presenter.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder(
        initialData: _presenter.latest,
        stream: _presenter,
        builder: (
          BuildContext context,
          AsyncSnapshot<TrendingModel> snapshot,
        ) {
          return snapshot.hasData
              ? RefreshableList(
                  controller: _controller,
                  presenter: _presenter,
                  state: snapshot.data,
                )
              : Container();
        },
      ),
    );
  }

  void _endOfListListener() {
    final extent = _controller.position.maxScrollExtent;
    final offset = _controller.offset;

    if (extent - offset < 500) {
      _presenter.loadNextPage();
    }
  }
}

class RefreshableList extends StatelessWidget {
  final ScrollController controller;
  final TrendingPresenter presenter;
  final TrendingModel state;

  const RefreshableList({
    Key key,
    this.controller,
    this.presenter,
    this.state,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: presenter.refresh,
      child: Center(
        child: state.join(
          (collection) =>
              TrendingGifs(collection: collection, controller: controller),
          (loading) => CircularProgressIndicator(),
          (error) => Text(error.message),
          (empty) => Text('Empty Response'),
        ),
      ),
    );
  }
}

class TrendingGifs extends StatelessWidget {
  final TrendingScreenCollection collection;
  final ScrollController controller;

  TrendingGifs({
    Key key,
    @required this.collection,
    @required this.controller,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      controller: controller,
      scrollDirection: Axis.vertical,
      slivers: <Widget>[
        SliverAppBar(
          title: Text(
            'MAD GIFS',
            style: TextStyle(
              fontFamily: 'Joystix',
              fontSize: 22.0,
            ),
          ),
          floating: true,
          snap: true,
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.search),
              onPressed: () {
                Navigator.push<Null>(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SearchScreen(),
                  ),
                );
              },
            )
          ],
          elevation: 0.0,
          backgroundColor: Colors.black,
        ),
        ScreenItemList(items: collection.items),
      ],
    );
  }
}
