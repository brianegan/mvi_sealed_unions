import 'dart:async';
import 'package:mvi_sealed_unions/screen_collection.dart';
import 'package:mvi_sealed_unions/screen_state_update.dart';
import 'package:mvi_sealed_unions/di.dart';

class DribbbleInteractor {
  String nextLink;
  bool fetching = false;

  /// emits data as a stream
  Stream<ScreenStateUpdate> fetchFirstPageData() async* {
    if (fetching) return;
    fetching = true;

    yield new ScreenStateUpdate.loading();
    try {
      final shots =
          await DependencyInjector.instance.client.fetchPopularShots();
      ScreenCollection collection = new ScreenCollection.from(shots);
      nextLink = collection.nextLink;
      if (collection.items.isNotEmpty) {
        /// emits a new [LoadingStatePartial] with updated state
        yield new ScreenStateUpdate.firstPage(collection);
      }
    } catch (e) {
      yield new ScreenStateUpdate.error(e.toString());
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
      final shots =
          await DependencyInjector.instance.client.fetchPopularShots();
      ScreenCollection collection = new ScreenCollection.from(shots);
      nextLink = collection.nextLink;
      if (collection.items.isNotEmpty) {
        /// emits a new [LoadingStatePartial] with updated state
        yield new ScreenStateUpdate.firstPage(collection);
      }
    } catch (e) {
      yield new ScreenStateUpdate.error(e.toString());
    } finally {
      fetching = false;
      completer.complete();
    }
  }

  /// emits data as a stream
  Stream<ScreenStateUpdate> nextPageData() async* {
    if (fetching) return;
    fetching = true;

    try {
      final shots = await DependencyInjector.instance.client.fetchShots(
        Uri.parse(nextLink),
      );
      ScreenCollection collection = new ScreenCollection.from(shots);
      nextLink = collection.nextLink;
      if (collection.items.isNotEmpty) {
        /// emits a new [LoadingStatePartial] with updated state
        yield new ScreenStateUpdate.nextPage(collection);
      }
    } catch (e) {
      yield new ScreenStateUpdate.error(e.toString());
    } finally {
      fetching = false;
    }
  }
}
