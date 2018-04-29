import 'dart:async';

import 'package:giphy_client/giphy_client.dart';
import 'package:sealed_union_demo/di.dart';
import 'package:sealed_union_demo/search/search_update.dart';

class SearchInteractor {
  final GiphyClient _client;
  int _offset = 0;

  SearchInteractor({GiphyClient client})
      : _client = client ?? DependencyInjector.instance.client;

  Stream<SearchUpdate> search(String query) async* {
    if (query.isEmpty) {
      yield SearchUpdate.noTerm();
    } else {
      yield SearchUpdate.firstPage(SearchPage.loading());

      try {
        final collection = await _client.search(query);
        _updateOffset(collection);
        yield SearchUpdate.firstPage(SearchPage.from(collection));
      } catch (e) {
        yield SearchUpdate.firstPage(SearchPage.error(e.toString()));
      }
    }
  }

  Stream<SearchUpdate> refreshPageData(
    String query,
    Completer<Null> completer,
  ) async* {
    try {
      final collection = await _client.search(query);
      _updateOffset(collection);
      yield SearchUpdate.firstPage(SearchPage.from(collection));
    } catch (e) {
      yield SearchUpdate.firstPage(SearchPage.error(e.toString()));
    } finally {
      completer.complete();
    }
  }

  Stream<SearchUpdate> nextPageData(String query) async* {
    yield SearchUpdate.nextPage(SearchPage.loading());

    try {
      final collection = await _client.search(query, offset: _offset);
      _updateOffset(collection);
      yield SearchUpdate.nextPage(SearchPage.from(collection));
    } catch (e) {
      yield SearchUpdate.nextPage(SearchPage.error(e.toString()));
    }
  }

  void _updateOffset(GiphyCollection collection) {
    _offset = collection.pagination.offset + collection.pagination.count;
  }
}
