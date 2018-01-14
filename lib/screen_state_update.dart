import 'package:mvi_sealed_unions/screen_collection.dart';
import 'package:mvi_sealed_unions/screen_item.dart';
import 'package:mvi_sealed_unions/screen_state.dart';

import 'package:sealed_unions/sealed_unions.dart';

/// [ScreenStateUpdate] implementation of `UnionN` which might be considered as
/// an equivalent of a `Sealed Class` class.
/// Consider [FirstPage], [NextPage], [UpdateLoading] and [UpdateError] as a
/// subclasses of the [ScreenStatePartial#Union4] `SealedClass`
class ScreenStateUpdate extends Union2Impl<Page, Page> {
  static const Doublet<Page, Page> factory = const Doublet<Page, Page>();

  ScreenStateUpdate._(Union2<Page, Page> union) : super(union);

  /// returns a new [ScreenStateUpdate] with modified `UnionN.first()` state
  factory ScreenStateUpdate.firstPage(Page page) =>
      new ScreenStateUpdate._(factory.first(page));

  /// returns a new [ScreenStateUpdate] with modified `UnionN.second()` state
  factory ScreenStateUpdate.nextPage(Page page) =>
      new ScreenStateUpdate._(factory.second(page));

  ScreenState apply(ScreenState prev) {
    return join(
      (firstPage) {
        return firstPage.join(
          (loading) => new ScreenState.loading(),
          (collection) => new ScreenState.from(collection),
          (error) => new ScreenState.error(error.message),
        );
      },
      (nextPage) {
        final _prevCollection = ScreenState.toCollection(prev);

        return nextPage.join(
          (loading) {
            return new ScreenState.from(
              new ScreenCollection(
                new List.from(_prevCollection.items)
                  ..add(new ScreenItem.loading()),
                nextLink: _prevCollection.nextLink,
              ),
            );
          },
          (collection) {
            return new ScreenState.from(
              new ScreenCollection(
                new List.from(_prevCollection.items)
                  ..removeLast()
                  ..addAll(collection.items),
                nextLink: collection.nextLink,
              ),
            );
          },
          (error) => new ScreenState.error(error.message),
        );
      },
    );
  }

  @override
  String toString() => 'ScreenStatePartial{$this}';

  static String toNextLink(ScreenStateUpdate update) {
    return update.join(
      (firstPage) => Page.toNextLink(firstPage),
      (nextPage) => Page.toNextLink(nextPage),
    );
  }
}

class Page extends Union3Impl<UpdateLoading, ScreenCollection, UpdateError> {
  static const Triplet<UpdateLoading, ScreenCollection, UpdateError> factory =
      const Triplet<UpdateLoading, ScreenCollection, UpdateError>();

  Page._(Union3<UpdateLoading, ScreenCollection, UpdateError> union)
      : super(union);

  factory Page.loading() => new Page._(factory.first(new UpdateLoading()));

  factory Page.collection(ScreenCollection collection) =>
      new Page._(factory.second(collection));

  factory Page.error(String message) =>
      new Page._(factory.third(new UpdateError(message)));

  static String toNextLink(Page page) {
    return page.join(
      (loading) => '',
      (collection) => collection.nextLink,
      (error) => '',
    );
  }
}

/// Loading state, stores a [percent]
class UpdateLoading {
  const UpdateLoading();
}

/// Error state stores the [message]
class UpdateError {
  final String message;

  const UpdateError(this.message);
}
