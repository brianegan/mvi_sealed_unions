import 'package:sealed_union_demo/common/list_item.dart';
import 'package:sealed_union_demo/search/search_model.dart';

abstract class SearchUpdate {
  SearchModel call(SearchModel prev);
}

class NoTerm implements SearchUpdate {
  SearchModel call(SearchModel prev) => SearchModel.noTerm();
}

class FirstPageLoading implements SearchUpdate {
  SearchModel call(SearchModel prev) => SearchModel.loading();
}

class FirstPageSuccess implements SearchUpdate {
  final List<ListItem> items;

  FirstPageSuccess(this.items);

  @override
  SearchModel call(SearchModel prev) => items.isEmpty
      ? SearchModel.empty()
      : SearchModel.populated(items..add(ListItem.loading()));
}

class FirstPageError implements SearchUpdate {
  final String message;

  FirstPageError(this.message);

  @override
  SearchModel call(SearchModel prev) {
    return SearchModel.error(message);
  }
}

class NextPageSuccess implements SearchUpdate {
  final List<ListItem> items;

  NextPageSuccess(this.items);

  @override
  SearchModel call(SearchModel prev) {
    return SearchModel.populated(List.from(SearchModel.toItems(prev))
      ..removeLast()
      ..addAll(items)
      ..add(ListItem.loading()));
  }
}

class NextPageError implements SearchUpdate {
  final String message;

  NextPageError(this.message);

  @override
  SearchModel call(SearchModel prev) {
    return SearchModel.populated(List.from(SearchModel.toItems(prev))
      ..removeLast()
      ..add(ListItem.loadingFailed()));
  }
}
