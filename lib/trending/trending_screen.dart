import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:sealed_union_demo/common/item_list.dart';
import 'package:sealed_union_demo/common/list_item.dart';
import 'package:sealed_union_demo/search/search_screen.dart';
import 'package:sealed_union_demo/trending/trending_interactor.dart';
import 'package:sealed_union_demo/trending/trending_model.dart';
import 'package:sealed_union_demo/trending/trending_presenter.dart';

/// Renders an infinite list of Trending Images.
///
/// It creates a Presenter, which provides a Stream<TrendingModel>, the latest
/// value of the Stream, and methods to update the state of the app.
///
/// It then renders the Stream<TrendingModel> using a StreamBuilder, and calls
/// methods on the presenter to update state.
class TrendingScreen extends StatefulWidget {
  final TrendingPresenter Function() initPresenter;

  TrendingScreen({
    Key key,
    this.initPresenter,
  }) : super(key: key);

  @override
  _TrendingScreenState createState() => _TrendingScreenState();
}

class _TrendingScreenState extends State<TrendingScreen> {
  TrendingPresenter _presenter;

  @override
  void initState() {
    _presenter = widget.initPresenter != null
        ? widget.initPresenter()
        : TrendingPresenter(TrendingInteractor());

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _presenter.loadFirstPage();
    });

    super.initState();
  }

  @override
  void dispose() {
    _presenter.dispose();
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
                  presenter: _presenter,
                  state: snapshot.data,
                )
              : Container();
        },
      ),
    );
  }
}

class RefreshableList extends StatelessWidget {
  final TrendingPresenter presenter;
  final TrendingModel state;

  const RefreshableList({
    Key key,
    this.presenter,
    this.state,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: presenter.refresh,
      child: Center(
        child: state.join(
          (items) {
            return TrendingImages(
              items: items,
              loadNextPage: presenter.loadNextPage,
            );
          },
          (loading) => CircularProgressIndicator(),
          (error) => Text(error.message),
          (empty) => Text('Empty Response'),
        ),
      ),
    );
  }
}

class TrendingImages extends StatelessWidget {
  final List<ListItem> items;
  final void Function() loadNextPage;

  TrendingImages({
    Key key,
    @required this.items,
    @required this.loadNextPage,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
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
        ItemList(
          items: items,
          loadNextPage: loadNextPage,
        ),
      ],
    );
  }
}
