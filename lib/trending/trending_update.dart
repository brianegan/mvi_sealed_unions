import 'package:sealed_union_demo/common/list_item.dart';
import 'package:sealed_union_demo/trending/trending_model.dart';

typedef TrendingUpdate = TrendingModel Function(TrendingModel prev);

TrendingModel firstPageLoading(TrendingModel prev) => TrendingModel.loading();

TrendingUpdate firstPageSuccess(List<ListItem> items) =>
    (TrendingModel prev) => TrendingModel.from(items..add(ListItem.loading()));

TrendingUpdate firstPageError(String message) =>
    (TrendingModel prev) => TrendingModel.error(message);

TrendingUpdate nextPageSuccess(List<ListItem> items) {
  return (TrendingModel prev) {
    return TrendingModel.from(List.from(TrendingModel.toItems(prev))
      ..removeLast()
      ..addAll(items)
      ..add(ListItem.loading()));
  };
}

TrendingUpdate nextPageError(String message) {
  return (TrendingModel prev) {
    return TrendingModel.from(List.from(TrendingModel.toItems(prev))
      ..removeLast()
      ..add(ListItem.loadingFailed()));
  };
}
