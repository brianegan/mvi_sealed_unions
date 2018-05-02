import 'package:sealed_union_demo/common/list_item.dart';
import 'package:sealed_unions/sealed_unions.dart';

/// Defines the "ViewModel" for the Trending Screen. The Trending Screen can
/// be in 1 of 4 states: Render List, Render Loading, Render Error, or Render
/// Empty. Therefore, it is a "Union4" to represent these states.
class TrendingModel extends Union4Impl<List<ListItem>, TrendingScreenLoading,
    TrendingScreenError, TrendingScreenEmpty> {
  static final Quartet<List<ListItem>, TrendingScreenLoading,
          TrendingScreenError, TrendingScreenEmpty> factory =
      const Quartet<List<ListItem>, TrendingScreenLoading, TrendingScreenError,
          TrendingScreenEmpty>();

  TrendingModel._(
      Union4<List<ListItem>, TrendingScreenLoading, TrendingScreenError,
              TrendingScreenEmpty>
          union)
      : super(union);

  factory TrendingModel.initial() => TrendingModel.from(<ListItem>[]);

  factory TrendingModel.from(List<ListItem> items) {
    return items.isEmpty
        ? TrendingModel.empty()
        : TrendingModel._(factory.first(items));
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

  static List<ListItem> toItems(TrendingModel state) {
    final empty = <ListItem>[];

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
