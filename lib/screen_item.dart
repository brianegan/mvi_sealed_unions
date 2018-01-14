import 'package:dribbble_client/dribbble_client.dart';
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

  ScreenItemShot(this.shot);
}
