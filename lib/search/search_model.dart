import 'package:giphy_client/giphy_client.dart';
import 'package:mvi_sealed_unions/common/screen_item.dart';
import 'package:sealed_unions/sealed_unions.dart';

class SearchModel extends Union5Impl<SearchNoTerm, SearchLoading, SearchError,
    SearchNoResults, SearchResults> {
  static final Quintet<SearchNoTerm, SearchLoading, SearchError,
          SearchNoResults, SearchResults> _factory =
      Quintet<SearchNoTerm, SearchLoading, SearchError, SearchNoResults,
          SearchResults>();

  SearchModel(
      Union5<SearchNoTerm, SearchLoading, SearchError, SearchNoResults,
              SearchResults>
          union)
      : super(union);

  factory SearchModel.noTerm() => SearchModel(_factory.first(SearchNoTerm()));

  factory SearchModel.loading() =>
      SearchModel(_factory.second(SearchLoading()));

  factory SearchModel.error(String message) =>
      SearchModel(_factory.third(SearchError(message)));

  factory SearchModel.from(List<ScreenItem> items) => items.isEmpty
      ? SearchModel(_factory.fourth(SearchNoResults()))
      : SearchModel(_factory.fifth(SearchResults(items)));

  static List<ScreenItem> toItems(SearchModel prev) {
    final empty = <ScreenItem>[];

    return prev.join(
      (_) => empty,
      (_) => empty,
      (_) => empty,
      (_) => empty,
      (results) => results.items,
    );
  }
}

class SearchNoTerm {}

class SearchLoading {}

class SearchError {
  final String message;

  SearchError(this.message);
}

class SearchNoResults {}

class SearchResults {
  final List<ScreenItem> items;

  SearchResults(this.items);

  factory SearchResults.from(GiphyCollection collection) {
    return SearchResults(
      collection.data.map((GiphyGif gif) => ScreenItem.gif(gif)).toList(),
    );
  }
}
