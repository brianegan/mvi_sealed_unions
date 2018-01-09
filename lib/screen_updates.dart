import 'package:sealed_unions/sealed_unions.dart';

class ScreenState
    extends Union4Impl<List<String>, ScreenLoading, ScreenError, ScreenEmpty> {
  static final Quartet<List<String>, ScreenLoading, ScreenError, ScreenEmpty>
      factory =
      const Quartet<List<String>, ScreenLoading, ScreenError, ScreenEmpty>();

  ScreenState._(
      Union4<List<String>, ScreenLoading, ScreenError, ScreenEmpty> union)
      : super(union);

  factory ScreenState.initial() =>
      new ScreenState.from(new List.unmodifiable(<String>[]));

  factory ScreenState.from(List<String> data) {
    return data.isEmpty
        ? new ScreenState.empty()
        : new ScreenState._(factory.first(data));
  }

  factory ScreenState.loading(List<String> prev) {
    return new ScreenState._(factory.second(new ScreenLoading(prev)));
  }

  factory ScreenState.error(String error) {
    return new ScreenState._(factory.third(new ScreenError(error)));
  }

  factory ScreenState.empty() {
    return new ScreenState._(factory.fourth(new ScreenEmpty()));
  }

  static List<String> toList(ScreenState state) {
    return state.join(
      (data) => data,
      (loading) => loading.prev,
      (_) => [],
      (_) => [],
    );
  }
}

class ScreenLoading {
  List<String> prev;

  ScreenLoading(this.prev);
}

class ScreenEmpty {}

class ScreenError {
  final String message;

  ScreenError(this.message);
}
