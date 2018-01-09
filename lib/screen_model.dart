import 'dart:async';

import 'package:flutter/widgets.dart';
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
    Stream<DragDownDetails> refreshPageIntent,
  )
      : super(buildStream(firstPageIntent, nextPageIntent, refreshPageIntent));

  static Stream<ScreenState> buildStream(
    Stream<Null> firstPageIntent,
    Stream<Completer<Null>> refreshPageIntent,
    Stream<DragDownDetails> nextPageIntent,
  ) {
    return new Observable.merge([
      new Observable<Null>(firstPageIntent).flatMap((_) {
        return fetchFirstPageData();
      }),
      new Observable<Completer<Null>>(refreshPageIntent).flatMap((completer) {
        return refreshPageData(completer);
      }),
      new Observable<DragDownDetails>(nextPageIntent).flatMap((details) {
        return nextPageData(details);
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
  static Stream<ScreenUpdate> nextPageData(DragDownDetails details) async* {
    print(details);
    try {
      List<String> data = await fetchDataFromServer();
      if (data.isNotEmpty) {
        /// emits a new [LoadingStatePartial] with updated state
        yield new ScreenUpdate.nextPage(data);
      }
    } on Exception catch (e) {
      yield new ScreenUpdate.error(e.toString());
    }
  }

  /// emits data as a stream
  static Stream<ScreenUpdate> refreshPageData(
      Completer<Null> completer) async* {
    try {
      List<String> data = await fetchDataFromServer();
      if (data.isNotEmpty) {
        /// emits a new [LoadingStatePartial] with updated state
        yield new ScreenUpdate.firstPage(data);
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
      () {
        return [
          'One',
          'Two',
          'Three',
          'One',
          'Two',
          'Three',
          'One',
          'Two',
          'Three',
          'One',
          'Two',
          'Three',
        ];
      },
    );
  }
}
