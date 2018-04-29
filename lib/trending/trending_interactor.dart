import 'dart:async';

import 'package:giphy_client/giphy_client.dart';
import 'package:mvi_sealed_unions/di.dart';
import 'package:mvi_sealed_unions/trending/trending_screen_model.dart';
import 'package:mvi_sealed_unions/trending/trending_screen_update.dart';

class TrendingInteractor {
  final GiphyClient _client;
  int _offset = 0;

  TrendingInteractor({GiphyClient client})
      : _client = client ?? DependencyInjector.instance.client;

  Stream<TrendingScreenUpdate> fetchFirstPageData([void _]) async* {
    yield TrendingScreenUpdate.firstPage(Page.loading());

    try {
      final collection = TrendingScreenCollection.from(await _client.trending());
      _offset = collection.offset + collection.count;
      yield TrendingScreenUpdate.firstPage(Page.collection(collection));
    } catch (e) {
      yield TrendingScreenUpdate.firstPage(Page.error(e.toString()));
    }
  }

  Stream<TrendingScreenUpdate> refreshPageData(Completer<Null> completer) async* {
    try {
      final collection = TrendingScreenCollection.from(await _client.trending());
      _offset = collection.offset + collection.count;
      yield TrendingScreenUpdate.firstPage(Page.collection(collection));
    } catch (e) {
      yield TrendingScreenUpdate.firstPage(Page.error(e.toString()));
    } finally {
      completer.complete();
    }
  }

  Stream<TrendingScreenUpdate> nextPageData([void _]) async* {
    yield TrendingScreenUpdate.nextPage(Page.loading());

    try {
      final collection = TrendingScreenCollection.from(
        await _client.trending(offset: _offset),
      );
      _offset = collection.offset + collection.count;
      yield TrendingScreenUpdate.nextPage(Page.collection(collection));
    } catch (e) {
      yield TrendingScreenUpdate.nextPage(Page.error(e.toString()));
    }
  }
}
