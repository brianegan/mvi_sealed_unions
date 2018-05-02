import 'dart:async';

import 'package:giphy_client/giphy_client.dart';
import 'package:sealed_union_demo/common/list_item.dart';
import 'package:sealed_union_demo/di.dart';
import 'package:sealed_union_demo/search/search_update.dart';

class SearchInteractor {
  final GiphyClient _client;
  int _offset = 0;

  SearchInteractor({GiphyClient client})
      : _client = client ?? DependencyInjector.instance.client;

  Stream<SearchUpdate> search(String query) async* {
    if (query.isEmpty) {
      yield noTerm;
    } else {
      yield firstPageLoading;

      try {
        final collection = await _client.search(query);
        _updateOffset(collection);
        yield firstPageSuccess(_toListItems(collection));
      } catch (e) {
        yield firstPageError(e.toString());
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
      yield firstPageSuccess(_toListItems(collection));
    } catch (e) {
      yield firstPageError(e.toString());
    } finally {
      completer.complete();
    }
  }

  Stream<SearchUpdate> nextPageData(String query) async* {
    try {
      final collection = await _client.search(query, offset: _offset);
      _updateOffset(collection);
      yield nextPageSuccess(_toListItems(collection));
    } catch (e) {
      yield nextPageError(e.toString());
    }
  }

  void _updateOffset(GiphyCollection collection) {
    _offset = collection.pagination.offset + collection.pagination.count;
  }
}

List<ListItem> _toListItems(GiphyCollection collection) =>
    collection.data.map((GiphyGif gif) => ListItem.image(gif)).toList();
