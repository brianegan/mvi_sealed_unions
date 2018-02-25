import 'dart:async';

import 'package:mvi_sealed_unions/dribbble_interactor.dart';
import 'package:mvi_sealed_unions/screen_state.dart';
import 'package:mvi_sealed_unions/screen_state_update.dart';
import 'package:rxdart/rxdart.dart';

final ScreenState initialState = new ScreenState.initial();

Stream<ScreenState> model(
  Stream<Null> firstPageIntent,
  Stream<Completer<Null>> refreshPageIntent,
  Stream<Null> nextPageIntent,
  DribbbleInteractor interactor,
) {
  final updates = new Observable<ScreenStateUpdate>.merge([
    new Observable<Null>(firstPageIntent)
        .flatMap((_) => interactor.fetchFirstPageData()),
    new Observable<Completer<Null>>(refreshPageIntent)
        .flatMap((completer) => interactor.refreshPageData(completer)),
    new Observable<Null>(nextPageIntent)
        .exhaustMap((_) => interactor.nextPageData())
  ]);

  return updates.scan(
    (prev, update, _) => update.apply(prev),
    initialState,
  );
}
