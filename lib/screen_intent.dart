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
        this.nextPageIntent = nextPageIntent ??
            new EndOfScrollControllerIntent(new ScrollController());
}

class EndOfScrollControllerIntent extends StreamView<Null> {
  final ScrollController controller;

  EndOfScrollControllerIntent._(this.controller, Stream<Null> stream)
      : super(stream);

  factory EndOfScrollControllerIntent(
    ScrollController controller, {
    double offset: 500.0,
  }) {
    final streamController = new StreamController<Null>.broadcast(sync: true);

    controller.addListener(() {
      if (controller.position.maxScrollExtent - controller.offset < offset) {
        streamController.add(null);
      }
    });

    return new EndOfScrollControllerIntent._(
        controller, streamController.stream);
  }
}
