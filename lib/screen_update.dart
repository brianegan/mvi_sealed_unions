import 'package:mvi_sealed_unions/screen_collection.dart';
import 'package:mvi_sealed_unions/screen_state.dart';

import 'package:sealed_unions/factories/quartet_factory.dart';
import 'package:sealed_unions/implementations/union_4_impl.dart';
import 'package:sealed_unions/union_4.dart';

/// [ScreenUpdate] implementation of `UnionN` which might be considered as
/// an equivalent of a `Sealed Class` class.
/// Consider [FirstPage], [NextPage], [UpdateLoading] and [UpdateError] as a
/// subclasses of the [ScreenStatePartial#Union4] `SealedClass`
class ScreenUpdate
    extends Union4Impl<FirstPage, NextPage, UpdateLoading, UpdateError> {
  static const Quartet<FirstPage, NextPage, UpdateLoading, UpdateError>
      factory =
      const Quartet<FirstPage, NextPage, UpdateLoading, UpdateError>();

  ScreenUpdate._(Union4<FirstPage, NextPage, UpdateLoading, UpdateError> union)
      : super(union);

  /// returns a new [ScreenUpdate] with modified `UnionN.first()` state
  factory ScreenUpdate.firstPage(ScreenCollection data) =>
      new ScreenUpdate._(factory.first(new FirstPage(data)));

  /// returns a new [ScreenUpdate] with modified `UnionN.second()` state
  factory ScreenUpdate.nextPage(ScreenCollection newData) =>
      new ScreenUpdate._(factory.second(new NextPage(newData)));

  /// returns a new [ScreenUpdate] with modified `UnionN.third()` state
  factory ScreenUpdate.loading() =>
      new ScreenUpdate._(factory.third(new UpdateLoading()));

  /// returns a new [ScreenUpdate] with modified `UnionN.fourth()` state
  factory ScreenUpdate.error(String message) =>
      new ScreenUpdate._(factory.fourth(new UpdateError(message)));

  ScreenState update(ScreenState state) {
    return join(
      (firstPage) => new ScreenState.from(firstPage.collection),
      (nextPage) => new ScreenState.from(
          ScreenState.toCollection(state).append(nextPage.collection)),
      (loading) => new ScreenState.loading(),
      (error) => new ScreenState.error(error.message),
    );
  }

  @override
  String toString() => 'ScreenStatePartial{$this}';

  static String toNextLink(ScreenUpdate update) {
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
