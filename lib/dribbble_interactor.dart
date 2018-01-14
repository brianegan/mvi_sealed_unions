import 'package:mvi_sealed_unions/screen_collection.dart';
import 'dart:async';
import 'package:mvi_sealed_unions/screen_state_update.dart';
import 'package:mvi_sealed_unions/di.dart';

class DribbbleInteractor {
  String nextLink;
  bool fetching = false;

  /// emits data as a stream
  Stream<ScreenStateUpdate> fetchFirstPageData() async* {
    if (fetching) return;
    fetching = true;
    yield new ScreenStateUpdate.firstPage(new Page.loading());

    try {
      final collection = new ScreenCollection.from(
        await DependencyInjector.instance.client.fetchPopularShots(),
      );
      nextLink = collection.nextLink;
      yield new ScreenStateUpdate.firstPage(new Page.collection(collection));
    } catch (e) {
      yield new ScreenStateUpdate.firstPage(new Page.error(e.toString()));
    } finally {
      fetching = false;
    }
  }

  /// emits data as a stream
  Stream<ScreenStateUpdate> refreshPageData(
    Completer<Null> completer,
  ) async* {
    if (fetching) return;
    fetching = true;

    try {
      final collection = new ScreenCollection.from(
        await DependencyInjector.instance.client.fetchPopularShots(),
      );
      nextLink = collection.nextLink;
      yield new ScreenStateUpdate.firstPage(new Page.collection(collection));
    } catch (e) {
      yield new ScreenStateUpdate.firstPage(new Page.error(e.toString()));
    } finally {
      fetching = false;
      completer.complete();
    }
  }

  /// emits data as a stream
  Stream<ScreenStateUpdate> nextPageData() async* {
    if (fetching) return;
    fetching = true;
    yield new ScreenStateUpdate.nextPage(new Page.loading());

    try {
      final collection = new ScreenCollection.from(
        await DependencyInjector.instance.client.fetchShots(
          Uri.parse(nextLink),
        ),
      );

      nextLink = collection.nextLink;

      yield new ScreenStateUpdate.nextPage(new Page.collection(collection));
    } catch (e) {
      yield new ScreenStateUpdate.nextPage(new Page.error(e.toString()));
    } finally {
      fetching = false;
    }
  }
}
