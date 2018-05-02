import 'package:giphy_client/giphy_client.dart';
import 'package:sealed_union_demo/common/list_item.dart';
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

  factory SearchModel.populated(List<ListItem> items) =>
      SearchModel(_factory.fifth(SearchResults(items)));

  factory SearchModel.empty() =>
      SearchModel(_factory.fourth(SearchNoResults()));

  static List<ListItem> toItems(SearchModel prev) {
    final empty = <ListItem>[];

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
  final List<ListItem> items;

  SearchResults(this.items);

  factory SearchResults.from(GiphyCollection collection) {
    return SearchResults(
      collection.data.map((GiphyGif gif) => ListItem.image(gif)).toList(),
    );
  }
}
