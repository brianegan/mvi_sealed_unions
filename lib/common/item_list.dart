import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:sealed_union_demo/common/image_item.dart';
import 'package:sealed_union_demo/common/list_item.dart';
import 'package:sealed_union_demo/common/loading_item.dart';

// Renders ListItems as a Staggered Grid
class ItemList extends StatelessWidget {
  static const _ratio = 3 / 4;

  final List<ListItem> items;
  final void Function() loadNextPage;

  ItemList({
    Key key,
    @required this.items,
    @required this.loadNextPage,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final orientation = mediaQuery.orientation;
    final crossAxisCount = orientation == Orientation.portrait ? 2 : 3;
    final width = mediaQuery.size.width;

    return SliverStaggeredGrid.countBuilder(
      itemBuilder: (context, index) {
        final item = items[index];

        return item.join(
          (image) => ImageItem(image: image),
          (_) => LoadingItem(
                loadNextPage: loadNextPage,
              ),
          (_) => Text('Loading Error'),
        );
      },
      itemCount: items.length,
      staggeredTileBuilder: (index) {
        return _buildTile(index, crossAxisCount, orientation, width);
      },
      crossAxisCount: crossAxisCount,
    );
  }

  StaggeredTile _buildTile(
    int index,
    int crossAxisCount,
    Orientation orientation,
    double width,
  ) {
    final item = items[index];

    if (orientation == Orientation.landscape) {
      return item.join(
        (image) {
          return index % 7 == 0
              ? StaggeredTile.extent(2, (width / 3 * 2) * _ratio)
              : StaggeredTile.extent(1, (width / 3) * _ratio);
        },
        (_) => StaggeredTile.extent(3, 200.0),
        (_) => StaggeredTile.extent(3, 200.0),
      );
    }

    return item.join(
      (image) => index % 5 == 0
          ? StaggeredTile.extent(2, (width) * _ratio)
          : StaggeredTile.extent(1, (width / 2) * _ratio),
      (_) => StaggeredTile.extent(2, 100.0),
      (_) => StaggeredTile.extent(2, 100.0),
    );
  }
}
