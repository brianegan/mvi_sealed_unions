import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:sealed_union_demo/common/item_list.dart';
import 'package:sealed_union_demo/search/search_interactor.dart';
import 'package:sealed_union_demo/search/search_model.dart';
import 'package:sealed_union_demo/search/search_presenter.dart';

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
  SearchPresenter _presenter;

  @override
  void initState() {
    _presenter = widget.initPresenter != null
        ? widget.initPresenter()
        : SearchPresenter(SearchInteractor());

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
      body: StreamBuilder<SearchModel>(
        initialData: _presenter.latest,
        stream: _presenter,
        builder: (context, snapshot) {
          return RefreshIndicator(
            onRefresh: _presenter.refresh,
            child: CustomScrollView(
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
                  (results) => ItemList(
                        items: results.items,
                        loadNextPage: _presenter.loadNextPage,
                      ),
                )
              ],
            ),
          );
        },
      ),
    );
  }
}

class SearchMessage extends StatelessWidget {
  final Widget child;

  const SearchMessage({Key key, this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SliverFillRemaining(
      child: Center(
        child: Center(child: child),
      ),
    );
  }
}
