import 'package:flutter_stream_friends/flutter_stream_friends.dart';

class ScreenIntent {
  final VoidStreamCallback firstPageIntent;
  final RefreshStreamCallback nextPageIntent;

  ScreenIntent({
    VoidStreamCallback firstPageIntent,
    RefreshStreamCallback nextPageIntent,
  })
      : this.firstPageIntent = firstPageIntent ?? new VoidStreamCallback(),
        this.nextPageIntent = nextPageIntent ?? new RefreshStreamCallback();
}
