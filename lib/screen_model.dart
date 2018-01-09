import 'dart:async';

import 'package:mvi_sealed_unions/screen_updates.dart';
import 'package:mvi_sealed_unions/screen_state_partial.dart';
import 'package:meta/meta.dart';
import 'package:rxdart/rxdart.dart';

@immutable
class ScreenModel extends StreamView<ScreenState> {
  static ScreenState initialValue = new ScreenState.initial();

  /// Observes a refresh event, triggering a fetch on async data
  ScreenModel(
    Stream<Null> firstPageIntent,
    Stream<Completer<Null>> nextPageIntent,
  )
      : super(buildStream(firstPageIntent, nextPageIntent));

  static Stream<ScreenState> buildStream(
    Stream<Null> firstPageIntent,
    Stream<Completer<Null>> nextPageIntent,
  ) {
    return new Observable.merge([
      new Observable<Null>(firstPageIntent).flatMap((_) {
        return fetchFirstPageData();
      }),
      new Observable<Completer<Null>>(nextPageIntent).flatMap((completer) {
        return fetchNextPageData(completer);
      })
    ]).scan(
      (ScreenState state, ScreenUpdate partial, int index) {
        return partial.reduce(state);
      },
      initialValue,
    );
  }

  /// emits data as a stream
  static Stream<ScreenUpdate> fetchFirstPageData() async* {
    yield new ScreenUpdate.loading();
    try {
      List<String> data = await fetchDataFromServer();
      if (data.isNotEmpty) {
        /// emits a new [LoadingStatePartial] with updated state
        yield new ScreenUpdate.firstPage(data);
      }
    } on Exception catch (e) {
      yield new ScreenUpdate.error(e.toString());
    }
  }

  /// emits data as a stream
  static Stream<ScreenUpdate> fetchNextPageData(
      Completer<Null> completer) async* {
    try {
      List<String> data = await fetchDataFromServer();
      if (data.isNotEmpty) {
        /// emits a new [LoadingStatePartial] with updated state
        yield new ScreenUpdate.nextPage(data);
      }
    } on Exception catch (e) {
      yield new ScreenUpdate.error(e.toString());
    } finally {
      completer.complete();
    }
  }

  static Future<List<String>> fetchDataFromServer() async {
    return new Future.delayed(
      new Duration(seconds: 1),
      () => ['One', 'Two', 'Three'],
    );
  }
}
