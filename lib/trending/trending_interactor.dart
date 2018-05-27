import 'dart:async';

import 'package:giphy_client/giphy_client.dart';
import 'package:sealed_union_demo/common/list_item.dart';
import 'package:sealed_union_demo/di.dart';
import 'package:sealed_union_demo/trending/trending_update.dart';

/// The interactor is responsible for converting the data layer into Streams of
/// TrendingUpdates.
class TrendingInteractor {
  final GiphyClient _client;
  int _offset = 0;

  TrendingInteractor({GiphyClient client})
      : _client = client ?? DependencyInjector.instance.client;

  Stream<TrendingUpdate> fetchFirstPage([void _]) async* {
    yield FirstPageLoading();

    try {
      final collection = await _client.trending();
      _updateOffset(collection);
      yield FirstPageSuccess(_toListItems(collection));
    } catch (e) {
      yield FirstPageError(e.toString());
    }
  }

  Stream<TrendingUpdate> refresh(Completer<Null> completer) async* {
    try {
      final collection = await _client.trending();
      _updateOffset(collection);
      yield FirstPageSuccess(_toListItems(collection));
    } catch (e) {
      yield FirstPageError(e.toString());
    } finally {
      completer.complete();
    }
  }

  Stream<TrendingUpdate> nextPage([void _]) async* {
    try {
      final collection = await _client.trending(offset: _offset);
      _updateOffset(collection);
      yield NextPageSuccess(_toListItems(collection));
    } catch (e) {
      yield NextPageError();
    }
  }

  void _updateOffset(GiphyCollection collection) {
    _offset = collection.pagination.offset + collection.pagination.count;
  }
}

List<ListItem> _toListItems(GiphyCollection collection) =>
    collection.data.map((GiphyGif gif) => ListItem.image(gif)).toList();
