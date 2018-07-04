import 'dart:async';

import 'package:rxdart/rxdart.dart';
import 'package:sealed_union_demo/common/presenter.dart';
import 'package:sealed_union_demo/search/search_interactor.dart';
import 'package:sealed_union_demo/search/search_model.dart';
import 'package:sealed_union_demo/search/search_update.dart';

class SearchPresenter extends Presenter<SearchModel> {
  static final _initialModel = SearchModel.noTerm();

  final Sink<String> _querySink;
  final Sink<Completer<Null>> _refreshSink;
  final Sink<void> _nextPageSink;

  factory SearchPresenter(SearchInteractor interactor) {
    final querySubject = BehaviorSubject<String>(sync: true);
    final refreshSubject = PublishSubject<Completer<Null>>(sync: true);
    final nextPageSubject = PublishSubject<void>(sync: true);
    final updates = Observable<SearchUpdate>.merge([
      querySubject.stream
          .debounce(Duration(milliseconds: 300))
          .distinct()
          .switchMap(interactor.search),
      refreshSubject.stream.flatMap((completer) =>
          interactor.refreshPageData(querySubject.value, completer)),
      nextPageSubject.stream
          .exhaustMap((_) => interactor.nextPageData(querySubject.value))
    ]);

    return SearchPresenter._(
      updates.scan((prev, update, _) => update(prev), _initialModel),
      nextPageSubject,
      querySubject,
      refreshSubject,
    );
  }

  SearchPresenter._(
    Stream<SearchModel> _stream,
    this._nextPageSink,
    this._querySink,
    this._refreshSink,
  ) : super(stream: _stream, initialState: _initialModel);

  Future<Null> refresh() {
    final completer = Completer<Null>();
    _refreshSink.add(completer);
    return completer.future;
  }

  void updateQuery(String query) => _querySink.add(query);

  void loadNextPage() {
    _nextPageSink.add(null);
  }

  @override
  void dispose() {
    super.dispose();
    _querySink.close();
    _nextPageSink.close();
    _refreshSink.close();
  }
}
