import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:giphy_client/giphy_client.dart';
import 'package:sealed_unions/sealed_unions.dart';

class ScreenItem extends Union3Impl<ScreenItemGif, ScreenItemLoading,
    ScreenItemLoadingFailed> {
  static const Triplet<ScreenItemGif, ScreenItemLoading,
          ScreenItemLoadingFailed> factory =
      const Triplet<ScreenItemGif, ScreenItemLoading,
          ScreenItemLoadingFailed>();

  ScreenItem._(
      Union3<ScreenItemGif, ScreenItemLoading, ScreenItemLoadingFailed> union)
      : super(union);

  factory ScreenItem.gif(GiphyGif gif) {
    return ScreenItem._(factory.first(ScreenItemGif(gif)));
  }

  factory ScreenItem.loading() {
    return ScreenItem._(factory.second(ScreenItemLoading()));
  }

  factory ScreenItem.loadingFailed() {
    return ScreenItem._(factory.third(ScreenItemLoadingFailed()));
  }
}

class ScreenItemLoading {}

class ScreenItemLoadingFailed {}

class ScreenItemGif {
  static const bgLightest = const Color.fromRGBO(255, 255, 255, 0.10);
  static const bgLight = const Color.fromRGBO(255, 255, 255, 0.08);
  static const bgMedium = const Color.fromRGBO(255, 255, 255, 0.06);
  static const bgDark = const Color.fromRGBO(255, 255, 255, 0.04);
  static const bgDarkest = const Color.fromRGBO(255, 255, 255, 0.02);

  final GiphyGif gif;
  final Color backgroundColor;

  ScreenItemGif(this.gif, {Color backgroundColor})
      : this.backgroundColor = backgroundColor ?? _getRandomBackground();

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
