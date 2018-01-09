import 'package:mvi_sealed_unions/screen_updates.dart';

import 'package:sealed_unions/factories/quartet_factory.dart';
import 'package:sealed_unions/implementations/union_4_impl.dart';
import 'package:sealed_unions/union_4.dart';

/// [ScreenUpdate] implementation of `UnionN` which might be considered as
/// an equivalent of a `Sealed Class` class.
/// Consider [FirstPage], [NextPage], [Loading] and [PartialError] as a
/// subclasses of the [ScreenStatePartial#Union4] `SealedClass`
class ScreenUpdate
    extends Union4Impl<FirstPage, NextPage, Loading, PartialError> {
  static const Quartet<FirstPage, NextPage, Loading, PartialError> factory =
      const Quartet<FirstPage, NextPage, Loading, PartialError>();

  ScreenUpdate._(Union4<FirstPage, NextPage, Loading, PartialError> union)
      : super(union);

  ScreenState reduce(ScreenState previous) {
    return join(
      (firstPage) => new ScreenState.from(firstPage.data),
      (nextPage) => new ScreenState.from(new List()
        ..addAll(ScreenState.toList(previous))
        ..addAll(nextPage.data)),
      (loading) => new ScreenState.loading(ScreenState.toList(previous)),
      (error) => new ScreenState.error(error.message),
    );
  }

  /// returns a new [ScreenUpdate] with modified `UnionN.first()` state
  factory ScreenUpdate.firstPage(List<String> data) =>
      new ScreenUpdate._(factory.first(new FirstPage(data)));

  /// returns a new [ScreenUpdate] with modified `UnionN.second()` state
  factory ScreenUpdate.nextPage(List<String> newData) =>
      new ScreenUpdate._(factory.second(new NextPage(newData)));

  /// returns a new [ScreenUpdate] with modified `UnionN.third()` state
  factory ScreenUpdate.loading() =>
      new ScreenUpdate._(factory.third(new Loading()));

  /// returns a new [ScreenUpdate] with modified `UnionN.fourth()` state
  factory ScreenUpdate.error(String message) =>
      new ScreenUpdate._(factory.fourth(new PartialError(message)));

  @override
  String toString() => 'ScreenStatePartial{$this}';
}

/// Data
class FirstPage {
  final List<String> data;

  const FirstPage(this.data);
}

/// Data
class NextPage {
  final List<String> data;

  const NextPage(this.data);
}

/// Loading state, stores a [percent]
class Loading {
  const Loading();
}

/// Error state stores the [message]
class PartialError {
  final String message;

  const PartialError(this.message);
}
