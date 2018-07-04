import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:rxdart/rxdart.dart';

// A base class that turns a normal Stream into a BehaviorSubject. This will
// ensure the latest ViewModel will be immediately emitted, and provides a way
// to synchronously read the latest value.
//
// This is important when working with the StreamBuilder, as it will prevent
// the StreamBuilder from building with empty data, which often causes the UI
// flash from no content to content quickly.
class Presenter<State> extends Stream<State> {
  final BehaviorSubject<State> _subject;

  Presenter({
    @required Stream<State> stream,
    State initialState,
  }) : _subject = _createSubject<State>(stream, initialState);

  // Get the current state. Useful for initial renders or re-renders when we
  // have already fetched the data
  State get latest => _subject.value;

  @mustCallSuper
  void dispose() => _subject.close();

  static BehaviorSubject<State> _createSubject<State>(
    Stream<State> model,
    State initialState,
  ) {
    StreamSubscription<State> subscription;
    BehaviorSubject<State> _subject;

    _subject = BehaviorSubject<State>(
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
  StreamSubscription<State> listen(
    void Function(State event) onData, {
    Function onError,
    void Function() onDone,
    bool cancelOnError,
  }) =>
      _subject.listen(
        onData,
        onError: onError,
        onDone: onDone,
        cancelOnError: cancelOnError,
      );
}
