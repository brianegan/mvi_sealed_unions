import 'dart:async';

import 'package:rxdart/rxdart.dart';
import 'package:sealed_union_demo/common/presenter.dart';
import 'package:sealed_union_demo/search/search_interactor.dart';
import 'package:sealed_union_demo/search/search_model.dart';
import 'package:sealed_union_demo/search/search_update.dart';

class SearchPresenter extends Presenter<SearchModel> {
  static final _initialModel = SearchModel.noTerm();

  final BehaviorSubject<String> _updateQueryController;
  final PublishSubject<Completer<Null>> _refreshController;
  final PublishSubject<void> _nextPageController;

  SearchPresenter._(
    Stream<SearchModel> _stream,
    this._nextPageController,
    this._updateQueryController,
    this._refreshController,
  ) : super(stream: _stream, initialModel: _initialModel);

  factory SearchPresenter(SearchInteractor interactor) {
    final updateQueryController = BehaviorSubject<String>(sync: true);
    final refreshController = PublishSubject<Completer<Null>>(sync: true);
    final nextPageController = PublishSubject<void>(sync: true);
    final updates = Observable<SearchUpdate>.merge([
      updateQueryController.stream
          .debounce(Duration(milliseconds: 300))
          .distinct()
          .switchMap(interactor.search),
      refreshController.stream.flatMap((completer) =>
          interactor.refreshPageData(updateQueryController.value, completer)),
      nextPageController.stream.exhaustMap((_) {
        return interactor.nextPageData(updateQueryController.value);
      })
    ]);

    return SearchPresenter._(
      updates.scan((prev, update, _) => update.apply(prev), _initialModel),
      nextPageController,
      updateQueryController,
      refreshController,
    );
  }

  Future<Null> refresh() {
    final completer = Completer<Null>();
    _refreshController.add(completer);
    return completer.future;
  }

  void updateQuery(String query) => _updateQueryController.add(query);

  void loadNextPage() {
    _nextPageController.add(null);
  }

  void close() {
    super.close();
    _updateQueryController.close();
    _nextPageController.close();
    _refreshController.close();
  }
}
