import 'dart:async';

import 'package:mvi_sealed_unions/dribbble_interactor.dart';
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
    Stream<Null> nextPageIntent, {
    DribbbleInteractor interactor,
  })
      : super(buildStream(
          firstPageIntent,
          refreshPageIntent,
          nextPageIntent,
          interactor ?? new DribbbleInteractor(),
        ));

  static Stream<ScreenState> buildStream(
    Stream<Null> firstPageIntent,
    Stream<Completer<Null>> refreshPageIntent,
    Stream<Null> nextPageIntent,
    DribbbleInteractor interactor,
  ) {
    return new Observable<ScreenUpdate>.merge([
      new Observable<Null>(firstPageIntent)
          .flatMap((_) => interactor.fetchFirstPageData()),
      new Observable<Completer<Null>>(refreshPageIntent)
          .flatMap((completer) => interactor.refreshPageData(completer)),
      new Observable<Null>(nextPageIntent)
          .flatMap((_) => interactor.nextPageData())
    ]).scan(
      (ScreenState state, ScreenUpdate partial, int index) {
        return partial.update(state);
      },
      initialValue,
    );
  }
}
