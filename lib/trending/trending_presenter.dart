import 'dart:async';

import 'package:rxdart/rxdart.dart';
import 'package:sealed_union_demo/common/presenter.dart';
import 'package:sealed_union_demo/trending/trending_interactor.dart';
import 'package:sealed_union_demo/trending/trending_model.dart';
import 'package:sealed_union_demo/trending/trending_update.dart';

/// Provides a Stream<TrendingModel>, the latest value of the Stream, and
/// methods to update the state of the screen to the TrendingScreen.
///
/// It works by listening to a series of Streams and transforming those
/// Streams into a new State. It does this by converting inputs from the View
/// layer into a series of TrendingUpdates. The updates are then applied
/// to the previous state of the app using the scan operator from RxDart.
class TrendingPresenter extends Presenter<TrendingModel> {
  final Sink<void> _firstPageSink;
  final Sink<Completer<Null>> _refreshSink;
  final Sink<void> _nextPageSink;

  factory TrendingPresenter(TrendingInteractor interactor) {
    final firstPageSubject = PublishSubject<void>(sync: true);
    final refreshSubject = PublishSubject<Completer<Null>>(sync: true);
    final nextPageSubject = PublishSubject<void>(sync: true);
    final updates = Observable<TrendingUpdate>.merge([
      firstPageSubject.stream.flatMap(interactor.fetchFirstPage),
      refreshSubject.stream.flatMap(interactor.refresh),
      nextPageSubject.stream.exhaustMap(interactor.nextPage)
    ]);

    return TrendingPresenter._(
      updates.scan((prev, update, _) => update(prev), TrendingModel.initial()),
      firstPageSubject,
      refreshSubject,
      nextPageSubject,
    );
  }

  TrendingPresenter._(
    Stream<TrendingModel> _stream,
    this._firstPageSink,
    this._refreshSink,
    this._nextPageSink,
  ) : super(stream: _stream, initialState: TrendingModel.initial());

  void loadFirstPage() => _firstPageSink.add(null);

  Future<Null> refresh() {
    final completer = Completer<Null>();
    _refreshSink.add(completer);
    return completer.future;
  }

  void loadNextPage() => _nextPageSink.add(null);

  void dispose() {
    _firstPageSink.close();
    _nextPageSink.close();
    _refreshSink.close();
    super.dispose();
  }
}
