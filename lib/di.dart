import 'package:giphy_client/giphy_client.dart';

class DependencyInjector {
  static final DependencyInjector instance = DependencyInjector._(
    GiphyClient(apiKey: '9cMC39G6YEkGNCaCMOT574TSycobSTok'),
  );

  final GiphyClient client;

  DependencyInjector._(this.client);

  @override
  String toString() {
    return 'DependencyInjector{client: $client}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DependencyInjector &&
          runtimeType == other.runtimeType &&
          client == other.client;

  @override
  int get hashCode => client.hashCode;
}
