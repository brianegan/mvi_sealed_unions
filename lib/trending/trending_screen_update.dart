import 'package:mvi_sealed_unions/common/screen_item.dart';
import 'package:mvi_sealed_unions/trending/trending_screen_model.dart';
import 'package:sealed_unions/sealed_unions.dart';

/// [TrendingScreenUpdate] implementation of `UnionN` which might be considered as
/// an equivalent of a `Sealed Class` class.
/// Consider [FirstPage], [NextPage], [UpdateLoading] and [UpdateError] as a
/// subclasses of the [ScreenStatePartial#Union4] `SealedClass`
class TrendingScreenUpdate extends Union2Impl<Page, Page> {
  static const Doublet<Page, Page> factory = const Doublet<Page, Page>();

  TrendingScreenUpdate._(Union2<Page, Page> union) : super(union);

  /// returns a [TrendingScreenUpdate] with modified `UnionN.first()` state
  factory TrendingScreenUpdate.firstPage(Page page) =>
      TrendingScreenUpdate._(factory.first(page));

  /// returns a [TrendingScreenUpdate] with modified `UnionN.second()` state
  factory TrendingScreenUpdate.nextPage(Page page) =>
      TrendingScreenUpdate._(factory.second(page));

  TrendingModel apply(TrendingModel prev) {
    return join(
      (firstPage) {
        return firstPage.join(
          (loading) => TrendingModel.loading(),
          (collection) => TrendingModel.from(collection),
          (error) => TrendingModel.error(error.message),
        );
      },
      (nextPage) {
        final _prevCollection = TrendingModel.toCollection(prev);

        return nextPage.join(
          (loading) {
            return TrendingModel.from(
              TrendingScreenCollection(
                List.from(_prevCollection.items)..add(ScreenItem.loading()),
                offset: _prevCollection.offset,
              ),
            );
          },
          (collection) {
            return TrendingModel.from(
              TrendingScreenCollection(
                List.from(_prevCollection.items)
                  ..removeLast()
                  ..addAll(collection.items),
                offset: collection.offset,
              ),
            );
          },
          (error) => TrendingModel.from(
                TrendingScreenCollection(
                  List.from(_prevCollection.items)
                    ..removeLast()
                    ..add(ScreenItem.loadingFailed()),
                ),
              ),
        );
      },
    );
  }

  @override
  String toString() => 'ScreenStatePartial{$this}';
}

class Page
    extends Union3Impl<UpdateLoading, TrendingScreenCollection, UpdateError> {
  static const Triplet<UpdateLoading, TrendingScreenCollection, UpdateError>
      factory =
      const Triplet<UpdateLoading, TrendingScreenCollection, UpdateError>();

  Page._(Union3<UpdateLoading, TrendingScreenCollection, UpdateError> union)
      : super(union);

  factory Page.loading() => Page._(factory.first(UpdateLoading()));

  factory Page.collection(TrendingScreenCollection collection) =>
      Page._(factory.second(collection));

  factory Page.error(String message) =>
      Page._(factory.third(UpdateError(message)));
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
