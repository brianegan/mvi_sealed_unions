import 'package:mvi_sealed_unions/screen_collection.dart';
import 'package:sealed_unions/sealed_unions.dart';

class ScreenState extends Union4Impl<ScreenCollection, ScreenLoading,
    ScreenError, ScreenEmpty> {
  static final Quartet<ScreenCollection, ScreenLoading, ScreenError,
          ScreenEmpty> factory =
      const Quartet<ScreenCollection, ScreenLoading, ScreenError,
          ScreenEmpty>();

  ScreenState._(
      Union4<ScreenCollection, ScreenLoading, ScreenError, ScreenEmpty> union)
      : super(union);

  factory ScreenState.initial() =>
      new ScreenState.from(new ScreenCollection.empty());

  factory ScreenState.from(ScreenCollection collection) {
    return collection.items.isEmpty
        ? new ScreenState.empty()
        : new ScreenState._(factory.first(collection));
  }

  factory ScreenState.loading() {
    return new ScreenState._(factory.second(new ScreenLoading()));
  }

  factory ScreenState.error(String error) {
    return new ScreenState._(factory.third(new ScreenError(error)));
  }

  factory ScreenState.empty() {
    return new ScreenState._(factory.fourth(new ScreenEmpty()));
  }

  static ScreenCollection toCollection(ScreenState state) {
    final empty = new ScreenCollection.empty();

    return state.join(
      (data) => data,
      (loading) => empty,
      (_) => empty,
      (_) => empty,
    );
  }
}

class ScreenLoading {}

class ScreenEmpty {}

class ScreenError {
  final String message;

  ScreenError(this.message);
}
