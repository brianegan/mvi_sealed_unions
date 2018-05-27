import 'package:sealed_union_demo/common/list_item.dart';
import 'package:sealed_union_demo/trending/trending_model.dart';

abstract class TrendingUpdate {
  TrendingModel call(TrendingModel prev);
}

class FirstPageLoading implements TrendingUpdate {
  @override
  TrendingModel call(TrendingModel prev) => TrendingModel.loading();
}

class FirstPageSuccess implements TrendingUpdate {
  final List<ListItem> items;

  FirstPageSuccess(this.items);

  @override
  TrendingModel call(TrendingModel prev) => TrendingModel.from(items);
}

class FirstPageError implements TrendingUpdate {
  final String message;

  FirstPageError(this.message);

  @override
  TrendingModel call(TrendingModel prev) => TrendingModel.error(message);
}

class NextPageSuccess implements TrendingUpdate {
  final List<ListItem> items;

  NextPageSuccess(this.items);

  @override
  TrendingModel call(TrendingModel prev) {
    return TrendingModel.from(List.from(TrendingModel.toItems(prev))
      ..removeLast()
      ..addAll(items)
      ..add(ListItem.loading()));
  }
}

class NextPageError implements TrendingUpdate {
  @override
  TrendingModel call(TrendingModel prev) {
    return TrendingModel.from(List.from(TrendingModel.toItems(prev))
      ..removeLast()
      ..add(ListItem.loadingFailed()));
  }
}
