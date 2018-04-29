import 'dart:async';

import 'package:rxdart/rxdart.dart';
import 'package:sealed_union_demo/common/presenter.dart';
import 'package:sealed_union_demo/trending/trending_interactor.dart';
import 'package:sealed_union_demo/trending/trending_screen_model.dart';
import 'package:sealed_union_demo/trending/trending_screen_update.dart';

class TrendingPresenter extends Presenter<TrendingModel> {
  static final _initialModel = TrendingModel.initial();

  final PublishSubject<void> _firstPageController;
  final PublishSubject<Completer<Null>> _refreshController;
  final PublishSubject<void> _nextPageController;

  factory TrendingPresenter(TrendingInteractor interactor) {
    final firstPageController = PublishSubject<void>(sync: true);
    final refreshController = PublishSubject<Completer<Null>>(sync: true);
    final nextPageController = PublishSubject<void>(sync: true);
    final updates = Observable<TrendingScreenUpdate>.merge([
      firstPageController.stream.flatMap(interactor.fetchFirstPageData),
      refreshController.stream.flatMap(interactor.refreshPageData),
      nextPageController.stream.exhaustMap(interactor.nextPageData)
    ]);

    return TrendingPresenter._(
      updates.scan((prev, update, _) => update.apply(prev), _initialModel),
      firstPageController,
      refreshController,
      nextPageController,
    );
  }

  TrendingPresenter._(
    Stream<TrendingModel> _stream,
    this._firstPageController,
    this._refreshController,
    this._nextPageController,
  ) : super(stream: _stream, initialModel: _initialModel);

  void loadFirstPage() => _firstPageController.add(null);

  Future<Null> refresh() {
    final completer = Completer<Null>();
    _refreshController.add(completer);
    return completer.future;
  }

  void loadNextPage() => _nextPageController.add(null);

  void close() {
    _firstPageController.close();
    _nextPageController.close();
    _refreshController.close();
    super.close();
  }
}
