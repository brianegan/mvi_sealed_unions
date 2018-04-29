import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:mvi_sealed_unions/common/gif_item.dart';
import 'package:mvi_sealed_unions/common/loading_item.dart';
import 'package:mvi_sealed_unions/common/screen_item.dart';

class ScreenItemList extends StatelessWidget {
  static const _ratio = 3 / 4;

  final List<ScreenItem> items;

  ScreenItemList({
    Key key,
    @required this.items,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final crossAxisCount =
        MediaQuery.of(context).orientation == Orientation.portrait ? 2 : 3;

    return SliverStaggeredGrid(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final item = items[index];
          return item.join(
            (gif) => GifItem(
                  gif: gif.gif,
                  backgroundColor: gif.backgroundColor,
                ),
            (_) => LoadingItem(),
            (_) => Text('Loading Error'),
          );
        },
        childCount: items.length,
        addAutomaticKeepAlives: true,
        addRepaintBoundaries: true,
      ),
      gridDelegate: SliverStaggeredGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        mainAxisSpacing: 0.0,
        crossAxisSpacing: 0.0,
        staggeredTileBuilder: (index) =>
            _buildTile(context, index, crossAxisCount),
        staggeredTileCount: items.length,
      ),
    );
  }

  StaggeredTile _buildTile(
    BuildContext context,
    int index,
    int crossAxisCount,
  ) {
    final item = items[index];
    final orientation = MediaQuery.of(context).orientation;

    if (orientation == Orientation.landscape) {
      return item.join(
        (gif) {
          return index % 7 == 0
              ? StaggeredTile.extent(
                  2, (MediaQuery.of(context).size.width / 3 * 2) * _ratio)
              : StaggeredTile.extent(
                  1, (MediaQuery.of(context).size.width / 3) * _ratio);
        },
        (_) => StaggeredTile.extent(3, 200.0),
        (_) => StaggeredTile.extent(3, 200.0),
      );
    }

    return item.join(
      (gif) => index % 5 == 0
          ? StaggeredTile.extent(
              2, (MediaQuery.of(context).size.width) * _ratio)
          : StaggeredTile.extent(
              1, (MediaQuery.of(context).size.width / 2) * _ratio),
      (_) => StaggeredTile.extent(2, 100.0),
      (_) => StaggeredTile.extent(2, 100.0),
    );
  }
}
