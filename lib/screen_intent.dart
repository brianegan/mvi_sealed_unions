import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_stream_friends/flutter_stream_friends.dart';

class ScreenIntent {
  final VoidStreamCallback firstPageIntent;
  final RefreshStreamCallback refreshPageIntent;
  final EndOfScrollControllerIntent nextPageIntent;

  ScreenIntent({
    VoidStreamCallback firstPageIntent,
    RefreshStreamCallback refreshPageIntent,
    EndOfScrollControllerIntent nextPageIntent,
  })
      : this.firstPageIntent = firstPageIntent ?? new VoidStreamCallback(),
        this.refreshPageIntent =
            refreshPageIntent ?? new RefreshStreamCallback(),
        this.nextPageIntent =
            nextPageIntent ?? new EndOfScrollControllerIntent();
}

class EndOfScrollControllerIntent extends StreamView<Null> {
  final ScrollController scrollController;

  EndOfScrollControllerIntent._(this.scrollController, Stream<Null> stream)
      : super(stream);

  factory EndOfScrollControllerIntent({
    ScrollController scrollController,
    double offset: 500.0,
  }) {
    final _scrollController = scrollController ?? new ScrollController();
    final streamController = new StreamController<Null>.broadcast(sync: true);

    _scrollController.addListener(() {
      if (_scrollController.position.maxScrollExtent -
              _scrollController.offset <
          offset) {
        streamController.add(null);
      }
    });

    return new EndOfScrollControllerIntent._(
      _scrollController,
      streamController.stream,
    );
  }
}
