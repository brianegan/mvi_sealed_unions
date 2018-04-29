import 'package:giphy_client/giphy_client.dart';
import 'package:sealed_union_demo/common/screen_item.dart';
import 'package:sealed_union_demo/search/search_model.dart';
import 'package:sealed_unions/sealed_unions.dart';

class SearchUpdate extends Union3Impl<SearchPage, SearchPage, NoSearchTerm> {
  static const Triplet<SearchPage, SearchPage, NoSearchTerm> factory =
      const Triplet<SearchPage, SearchPage, NoSearchTerm>();

  SearchUpdate._(Union3<SearchPage, SearchPage, NoSearchTerm> union)
      : super(union);

  factory SearchUpdate.firstPage(SearchPage page) =>
      SearchUpdate._(factory.first(page));

  factory SearchUpdate.nextPage(SearchPage page) =>
      SearchUpdate._(factory.second(page));

  factory SearchUpdate.noTerm() =>
      SearchUpdate._(factory.third(NoSearchTerm()));

  SearchModel apply(SearchModel prev) {
    return join(
      (firstPage) {
        return firstPage.join(
          (loading) => SearchModel.loading(),
          (items) => SearchModel.from(items),
          (error) => SearchModel.error(error.message),
        );
      },
      (nextPage) {
        final _prevItems = SearchModel.toItems(prev);

        return nextPage.join(
          (loading) => SearchModel
              .from(List.from(_prevItems)..add(ScreenItem.loading())),
          (collection) => SearchModel.from(List.from(_prevItems)
            ..removeLast()
            ..addAll(collection)),
          (error) => SearchModel.from(List.from(_prevItems)
            ..removeLast()
            ..add(ScreenItem.loadingFailed())),
        );
      },
      (_) => SearchModel.noTerm(),
    );
  }

  @override
  String toString() => 'ScreenStatePartial{$this}';
}

class NoSearchTerm {}

class SearchPage
    extends Union3Impl<SearchPageLoading, List<ScreenItem>, SearchPageError> {
  static const Triplet<SearchPageLoading, List<ScreenItem>, SearchPageError>
      factory =
      const Triplet<SearchPageLoading, List<ScreenItem>, SearchPageError>();

  SearchPage._(
      Union3<SearchPageLoading, List<ScreenItem>, SearchPageError> union)
      : super(union);

  factory SearchPage.loading() =>
      SearchPage._(factory.first(SearchPageLoading()));

  factory SearchPage.from(GiphyCollection collection) =>
      SearchPage._(factory.second(
        collection.data.map((GiphyGif gif) => ScreenItem.gif(gif)).toList(),
      ));

  factory SearchPage.error(String message) =>
      SearchPage._(factory.third(SearchPageError(message)));
}

/// Loading state, stores a [percent]
class SearchPageLoading {
  const SearchPageLoading();
}

/// Error state stores the [message]
class SearchPageError {
  final String message;

  const SearchPageError(this.message);
}
