import 'package:flutter_stream_friends/flutter_stream_friends.dart';

class ScreenIntent {
  final VoidStreamCallback firstPageIntent;
  final RefreshStreamCallback refreshPageIntent;
  final InfiniteScrollStream nextPageIntent;

  ScreenIntent({
    VoidStreamCallback firstPageIntent,
    RefreshStreamCallback refreshPageIntent,
    InfiniteScrollStream nextPageIntent,
  })
      : this.firstPageIntent = firstPageIntent ?? new VoidStreamCallback(),
        this.refreshPageIntent =
            refreshPageIntent ?? new RefreshStreamCallback(),
        this.nextPageIntent =
            nextPageIntent ?? new InfiniteScrollStream();
}

