import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:rxdart/rxdart.dart';

class Presenter<ViewModel> extends Stream<ViewModel> {
  final BehaviorSubject<ViewModel> _subject;

  Presenter({
    @required Stream<ViewModel> stream,
    ViewModel initialModel,
  }) : _subject = _createSubject<ViewModel>(stream, initialModel);

  // Get the current state. Useful for initial renders or re-renders when we
  // have already fetched the data
  ViewModel get latest => _subject.value;

  @mustCallSuper
  void close() => _subject.close();

  static BehaviorSubject<ViewModel> _createSubject<ViewModel>(
    Stream<ViewModel> model,
    ViewModel initialState,
  ) {
    StreamSubscription<ViewModel> subscription;
    BehaviorSubject<ViewModel> _subject;

    _subject = BehaviorSubject<ViewModel>(
      seedValue: initialState,
      onListen: () {
        subscription = model.listen(
          _subject.add,
          onError: _subject.addError,
          onDone: _subject.close,
        );
      },
      onCancel: () => subscription.cancel(),
      sync: true,
    );

    return _subject;
  }

  @override
  StreamSubscription<ViewModel> listen(
    void Function(ViewModel event) onData, {
    Function onError,
    void Function() onDone,
    bool cancelOnError,
  }) =>
      _subject.stream.listen(
        onData,
        onError: onError,
        onDone: onDone,
        cancelOnError: cancelOnError,
      );
}
