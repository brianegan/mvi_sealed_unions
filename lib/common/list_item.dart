import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:giphy_client/giphy_client.dart';
import 'package:meta/meta.dart';
import 'package:sealed_unions/sealed_unions.dart';

// A list item can be one of 3 things: An Image, a loading indicator, or an
// error indicator. Therefore, it is a Union 3 to represent these 3 states.
class ListItem
    extends Union3Impl<ListItemImage, ListItemLoading, ListItemLoadingFailed> {
  static const Triplet<ListItemImage, ListItemLoading, ListItemLoadingFailed>
      factory =
      const Triplet<ListItemImage, ListItemLoading, ListItemLoadingFailed>();

  ListItem._(
      Union3<ListItemImage, ListItemLoading, ListItemLoadingFailed> union)
      : super(union);

  factory ListItem.image(GiphyGif gif) {
    return ListItem._(factory.first(ListItemImage.from(gif)));
  }

  factory ListItem.loading() {
    return ListItem._(factory.second(ListItemLoading()));
  }

  factory ListItem.loadingFailed() {
    return ListItem._(factory.third(ListItemLoadingFailed()));
  }
}

class ListItemLoading {}

class ListItemLoadingFailed {}

class ListItemImage {
  static const bgLightest = const Color.fromRGBO(255, 255, 255, 0.10);
  static const bgLight = const Color.fromRGBO(255, 255, 255, 0.08);
  static const bgMedium = const Color.fromRGBO(255, 255, 255, 0.06);
  static const bgDark = const Color.fromRGBO(255, 255, 255, 0.04);
  static const bgDarkest = const Color.fromRGBO(255, 255, 255, 0.02);

  final double aspectRatio;
  final String thumbnailUrl;
  final String url;
  final Color backgroundColor;

  ListItemImage({
    @required this.aspectRatio,
    @required this.thumbnailUrl,
    @required this.url,
    Color backgroundColor,
  }) : this.backgroundColor = backgroundColor ?? _getRandomBackground();

  factory ListItemImage.from(GiphyGif gif) {
    return ListItemImage(
      aspectRatio: int.parse(gif.images.fixedHeight.width) /
          int.parse(gif.images.fixedHeight.height),
      thumbnailUrl: gif.images.fixedHeightStill.url,
      url: gif.images.fixedHeight.url,
    );
  }

  static Color _getRandomBackground() {
    switch (Random().nextInt(4)) {
      case 0:
        return bgLightest;
      case 1:
        return bgLight;
      case 2:
        return bgMedium;
      case 3:
        return bgDark;
      default:
        return bgDarkest;
    }
  }
}
