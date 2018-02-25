import 'package:dribbble_client/dribbble_client.dart';
import 'package:mvi_sealed_unions/di.dart';
import 'package:mvi_sealed_unions/screen_collection.dart';
import 'dart:async';
import 'package:mvi_sealed_unions/screen_state_update.dart';

class DribbbleInteractor {
  final DribbbleClient _client;
  String _nextLink;

  DribbbleInteractor({DribbbleClient client})
      : _client = client ?? DependencyInjector.instance.client;

  Stream<ScreenStateUpdate> fetchFirstPageData() async* {
    yield new ScreenStateUpdate.firstPage(new Page.loading());

    try {
      final collection = new ScreenCollection.from(
        await _client.fetchPopularShots(),
      );
      _nextLink = collection.nextLink;
      yield new ScreenStateUpdate.firstPage(new Page.collection(collection));
    } catch (e) {
      yield new ScreenStateUpdate.firstPage(new Page.error(e.toString()));
    }
  }

  Stream<ScreenStateUpdate> refreshPageData(Completer<Null> completer) async* {
    try {
      final collection = new ScreenCollection.from(
        await _client.fetchPopularShots(),
      );
      _nextLink = collection.nextLink;
      yield new ScreenStateUpdate.firstPage(new Page.collection(collection));
    } catch (e) {
      yield new ScreenStateUpdate.firstPage(new Page.error(e.toString()));
    } finally {
      completer.complete();
    }
  }

  Stream<ScreenStateUpdate> nextPageData() async* {
    yield new ScreenStateUpdate.nextPage(new Page.loading());

    try {
      final collection = new ScreenCollection.from(
        await _client.fetchShots(
          Uri.parse(_nextLink),
        ),
      );

      _nextLink = collection.nextLink;

      yield new ScreenStateUpdate.nextPage(new Page.collection(collection));
    } catch (e) {
      yield new ScreenStateUpdate.nextPage(new Page.error(e.toString()));
    }
  }
}
