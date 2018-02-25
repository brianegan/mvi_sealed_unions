import 'dart:math';
import 'dart:ui';

import 'package:dribbble_client/dribbble_client.dart';
import 'package:flutter/material.dart';
import 'package:sealed_unions/sealed_unions.dart';

class ScreenItem extends Union2Impl<ScreenItemShot, ScreenItemLoading> {
  static const Doublet<ScreenItemShot, ScreenItemLoading> factory =
      const Doublet<ScreenItemShot, ScreenItemLoading>();

  ScreenItem._(Union2<ScreenItemShot, ScreenItemLoading> union) : super(union);

  factory ScreenItem.shot(DribbbleShot shot) {
    return new ScreenItem._(factory.first(new ScreenItemShot(shot)));
  }

  factory ScreenItem.loading() {
    return new ScreenItem._(factory.second(new ScreenItemLoading()));
  }
}

class ScreenItemLoading {}

class ScreenItemShot {
  final DribbbleShot shot;
  final Color backgroundColor;

  ScreenItemShot(this.shot, {Color backgroundColor})
      : this.backgroundColor = backgroundColor ?? _getRandomBackground();

  static Color _getRandomBackground() {
    switch (new Random().nextInt(3)) {
      case 0:
        return Colors.black12;
      case 1:
        return Colors.black26;
      case 2:
        return Colors.black38;
      default:
        return Colors.black45;
    }
  }
}
