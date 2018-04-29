import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mvi_sealed_unions/common/screen_item_list.dart';
import 'package:mvi_sealed_unions/search/search_interactor.dart';
import 'package:mvi_sealed_unions/search/search_model.dart';
import 'package:mvi_sealed_unions/search/search_presenter.dart';

class SearchScreen extends StatefulWidget {
  final SearchPresenter Function() initPresenter;

  SearchScreen({
    Key key,
    this.initPresenter,
  }) : super(key: key);

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final ScrollController _controller = ScrollController();
  SearchPresenter _presenter;

  @override
  void initState() {
    _presenter = widget.initPresenter != null
        ? widget.initPresenter()
        : SearchPresenter(SearchInteractor());

    _controller.addListener(_endOfListListener);

    super.initState();
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
      body: StreamBuilder<SearchModel>(
        initialData: _presenter.latest,
        stream: _presenter,
        builder: (context, snapshot) {
          return RefreshIndicator(
            onRefresh: _presenter.refresh,
            child: CustomScrollView(
              controller: _controller,
              slivers: <Widget>[
                SliverAppBar(
                  backgroundColor: Colors.black,
                  floating: true,
                  snap: true,
                  title: Padding(
                    padding: EdgeInsets.only(top: 7.0),
                    child: TextField(
                      autofocus: true,
                      onChanged: _presenter.updateQuery,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                      ),
                      style: TextStyle(
                        fontFamily: 'Joystix',
                        fontSize: 20.0,
                        decorationColor: Colors.black,
                        height: 0.8,
                      ),
                    ),
                  ),
                ),
                snapshot.data.join(
                  (noTerm) =>
                      SearchMessage(child: Text('Please enter a search term')),
                  (loading) =>
                      SearchMessage(child: CircularProgressIndicator()),
                  (error) => SearchMessage(child: Text(error.message)),
                  (noResults) => SearchMessage(child: Text('No Results')),
                  (results) => ScreenItemList(items: results.items),
                )
              ],
            ),
          );
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

class SearchMessage extends StatelessWidget {
  final Widget child;

  const SearchMessage({Key key, this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SliverList(
      delegate: SliverChildListDelegate([
        Container(
          height: MediaQuery.of(context).size.height -
              kToolbarHeight -
              MediaQuery.of(context).padding.top,
          child: Center(child: child),
        )
      ]),
    );
  }
}
