import 'dart:async';

import 'package:mvi_sealed_unions/di.dart';
import 'package:mvi_sealed_unions/screen_collection.dart';
import 'package:mvi_sealed_unions/screen_state.dart';
import 'package:mvi_sealed_unions/screen_update.dart';
import 'package:meta/meta.dart';
import 'package:rxdart/rxdart.dart';

@immutable
class ScreenModel extends StreamView<ScreenState> {
  static ScreenState initialValue = new ScreenState.initial();

  /// Observes a refresh event, triggering a fetch on async data
  ScreenModel(
    Stream<Null> firstPageIntent,
    Stream<Completer<Null>> refreshPageIntent,
    Stream<Null> nextPageIntent,
  )
      : super(buildStream(firstPageIntent, refreshPageIntent, nextPageIntent));

  static Stream<ScreenState> buildStream(
    Stream<Null> firstPageIntent,
    Stream<Completer<Null>> refreshPageIntent,
    Stream<Null> nextPageIntent,
  ) {
    final nextPageController = new StreamController<ScreenUpdate>();
    final pageLoads = new Observable<ScreenUpdate>.merge([
      new Observable<Null>(firstPageIntent).flatMap((_) {
        return fetchFirstPageData();
      }),
      new Observable<Completer<Null>>(refreshPageIntent).flatMap((completer) {
        return refreshPageData(completer);
      }),
      nextPageController.stream
    ]).asBroadcastStream();

    new Observable<Null>(nextPageIntent)
        .withLatestFrom<ScreenUpdate, String>(pageLoads, (details, update) {
          return ScreenUpdate.toNextLink(update);
        })
        .where((nextLink) => nextLink != null && nextLink.isNotEmpty)
        .distinct()
        .flatMap<ScreenUpdate>((nextLink) {
          return nextPageData(nextLink);
        })
        .listen((nextPageData) => nextPageController.add(nextPageData));

    return new Observable<ScreenUpdate>.merge([
      pageLoads,
    ]).scan(
      (ScreenState state, ScreenUpdate partial, int index) {
        return partial.update(state);
      },
      initialValue,
    );
  }

  /// emits data as a stream
  static Stream<ScreenUpdate> fetchFirstPageData() async* {
    yield new ScreenUpdate.loading();
    try {
      final shots =
          await DependencyInjector.instance.client.fetchPopularShots();
      ScreenCollection collection = new ScreenCollection.from(shots);
      if (collection.items.isNotEmpty) {
        /// emits a new [LoadingStatePartial] with updated state
        yield new ScreenUpdate.firstPage(collection);
      } else {
        print("Hello");
      }
    } catch (e) {
      yield new ScreenUpdate.error(e.toString());
    }
  }

  /// emits data as a stream
  static Stream<ScreenUpdate> nextPageData(String nextLink) async* {
    try {
      final shots = await DependencyInjector.instance.client.fetchShots(
        Uri.parse(nextLink),
      );
      ScreenCollection collection = new ScreenCollection.from(shots);
      if (collection.items.isNotEmpty) {
        /// emits a new [LoadingStatePartial] with updated state
        yield new ScreenUpdate.nextPage(collection);
      }
    } catch (e) {
      yield new ScreenUpdate.error(e.toString());
    }
  }

  /// emits data as a stream
  static Stream<ScreenUpdate> refreshPageData(
    Completer<Null> completer,
  ) async* {
    try {
      final shots =
          await DependencyInjector.instance.client.fetchPopularShots();
      ScreenCollection collection = new ScreenCollection.from(shots);
      if (collection.items.isNotEmpty) {
        /// emits a new [LoadingStatePartial] with updated state
        yield new ScreenUpdate.firstPage(collection);
      }
    } catch (e) {
      yield new ScreenUpdate.error(e.toString());
    } finally {
      completer.complete();
    }
  }
}
