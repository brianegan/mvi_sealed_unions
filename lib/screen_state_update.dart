import 'package:mvi_sealed_unions/screen_collection.dart';
import 'package:mvi_sealed_unions/screen_state.dart';

import 'package:sealed_unions/factories/quartet_factory.dart';
import 'package:sealed_unions/implementations/union_4_impl.dart';
import 'package:sealed_unions/union_4.dart';

/// [ScreenStateUpdate] implementation of `UnionN` which might be considered as
/// an equivalent of a `Sealed Class` class.
/// Consider [FirstPage], [NextPage], [UpdateLoading] and [UpdateError] as a
/// subclasses of the [ScreenStatePartial#Union4] `SealedClass`
class ScreenStateUpdate
    extends Union4Impl<FirstPage, NextPage, UpdateLoading, UpdateError> {
  static const Quartet<FirstPage, NextPage, UpdateLoading, UpdateError>
      factory =
      const Quartet<FirstPage, NextPage, UpdateLoading, UpdateError>();

  ScreenStateUpdate._(Union4<FirstPage, NextPage, UpdateLoading, UpdateError> union)
      : super(union);

  /// returns a new [ScreenStateUpdate] with modified `UnionN.first()` state
  factory ScreenStateUpdate.firstPage(ScreenCollection data) =>
      new ScreenStateUpdate._(factory.first(new FirstPage(data)));

  /// returns a new [ScreenStateUpdate] with modified `UnionN.second()` state
  factory ScreenStateUpdate.nextPage(ScreenCollection newData) =>
      new ScreenStateUpdate._(factory.second(new NextPage(newData)));

  /// returns a new [ScreenStateUpdate] with modified `UnionN.third()` state
  factory ScreenStateUpdate.loading() =>
      new ScreenStateUpdate._(factory.third(new UpdateLoading()));

  /// returns a new [ScreenStateUpdate] with modified `UnionN.fourth()` state
  factory ScreenStateUpdate.error(String message) =>
      new ScreenStateUpdate._(factory.fourth(new UpdateError(message)));

  ScreenState apply(ScreenState prev) {
    return join(
      (firstPage) => new ScreenState.from(firstPage.collection),
      (nextPage) => new ScreenState.from(
          ScreenState.toCollection(prev).append(nextPage.collection)),
      (loading) => new ScreenState.loading(),
      (error) => new ScreenState.error(error.message),
    );
  }

  @override
  String toString() => 'ScreenStatePartial{$this}';

  static String toNextLink(ScreenStateUpdate update) {
    return update.join(
      (firstPage) => firstPage.collection.nextLink,
      (nextPage) => nextPage.collection.nextLink,
      (_) => '',
      (_) => '',
    );
  }
}

/// Data
class FirstPage {
  final ScreenCollection collection;

  const FirstPage(this.collection);
}

/// Data
class NextPage {
  final ScreenCollection collection;

  const NextPage(this.collection);
}

/// Loading state, stores a [percent]
class UpdateLoading {
  const UpdateLoading();
}

/// Error state stores the [message]
class UpdateError {
  final String message;

  const UpdateError(this.message);
}
