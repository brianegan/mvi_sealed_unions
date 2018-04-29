import 'package:giphy_client/giphy_client.dart';
import 'package:mvi_sealed_unions/common/screen_item.dart';
import 'package:sealed_unions/sealed_unions.dart';

class TrendingModel extends Union4Impl<TrendingScreenCollection,
    TrendingScreenLoading, TrendingScreenError, TrendingScreenEmpty> {
  static final Quartet<TrendingScreenCollection, TrendingScreenLoading,
          TrendingScreenError, TrendingScreenEmpty> factory =
      const Quartet<TrendingScreenCollection, TrendingScreenLoading,
          TrendingScreenError, TrendingScreenEmpty>();

  TrendingModel._(
      Union4<TrendingScreenCollection, TrendingScreenLoading,
              TrendingScreenError, TrendingScreenEmpty>
          union)
      : super(union);

  factory TrendingModel.initial() =>
      TrendingModel.from(TrendingScreenCollection.empty());

  factory TrendingModel.from(TrendingScreenCollection collection) {
    return collection.items.isEmpty
        ? TrendingModel.empty()
        : TrendingModel._(factory.first(collection));
  }

  factory TrendingModel.loading() {
    return TrendingModel._(factory.second(TrendingScreenLoading()));
  }

  factory TrendingModel.error(String error) {
    return TrendingModel._(factory.third(TrendingScreenError(error)));
  }

  factory TrendingModel.empty() {
    return TrendingModel._(factory.fourth(TrendingScreenEmpty()));
  }

  static TrendingScreenCollection toCollection(TrendingModel state) {
    final empty = TrendingScreenCollection.empty();

    return state.join(
      (data) => data,
      (loading) => empty,
      (_) => empty,
      (_) => empty,
    );
  }
}

class TrendingScreenLoading {}

class TrendingScreenEmpty {}

class TrendingScreenError {
  final String message;

  TrendingScreenError(this.message);
}

class TrendingScreenCollection {
  final List<ScreenItem> items;
  final int offset;
  final int count;

  TrendingScreenCollection(this.items, {this.offset, this.count});

  factory TrendingScreenCollection.empty() {
    return TrendingScreenCollection([]);
  }

  factory TrendingScreenCollection.from(GiphyCollection collection) {
    return TrendingScreenCollection(
      collection.data.map((GiphyGif gif) => ScreenItem.gif(gif)).toList(),
      offset: collection.pagination.offset,
      count: collection.pagination.count,
    );
  }

  TrendingScreenCollection append(TrendingScreenCollection updates) {
    return TrendingScreenCollection(
        <ScreenItem>[]..addAll(items)..addAll(updates.items),
        offset: updates.offset ?? offset,
        count: updates.count);
  }

  @override
  String toString() {
    return 'ScreenCollection{collection: $items, nextLink: $offset}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TrendingScreenCollection &&
          runtimeType == other.runtimeType &&
          items == other.items &&
          offset == other.offset;

  @override
  int get hashCode => items.hashCode ^ offset.hashCode;
}
