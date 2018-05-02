import 'package:sealed_union_demo/common/list_item.dart';
import 'package:sealed_union_demo/search/search_model.dart';

typedef SearchUpdate = SearchModel Function(SearchModel prev);

SearchModel noTerm(SearchModel prev) => SearchModel.noTerm();

SearchModel firstPageLoading(SearchModel prev) => SearchModel.loading();

SearchUpdate firstPageSuccess(List<ListItem> items) =>
    (SearchModel prev) => items.isEmpty
        ? SearchModel.empty()
        : SearchModel.populated(items..add(ListItem.loading()));

SearchUpdate firstPageError(String message) => (SearchModel prev) {
      return SearchModel.error(message);
    };

SearchUpdate nextPageSuccess(List<ListItem> items) => (SearchModel prev) =>
    SearchModel.populated(List.from(SearchModel.toItems(prev))
      ..removeLast()
      ..addAll(items)
      ..add(ListItem.loading()));

SearchUpdate nextPageError(String message) => (SearchModel prev) =>
    SearchModel.populated(List.from(SearchModel.toItems(prev))
      ..removeLast()
      ..add(ListItem.loadingFailed()));
