import 'package:dribbble_client/dribbble_client.dart';
import 'package:mvi_sealed_unions/dribbble_interactor.dart';

class DependencyInjector {
  static final DependencyInjector instance = new DependencyInjector._from(
    new DribbbleClient(
      'dd698d7962c3e2dca9b9b9ecdd02efce20cf8cfe3a18e88c594da00c96fda44c',
      'ce13a2a044de07325b5dd788ce1b6e23ee90dd2f0b7c322d957506300f9d513b',
      '12e429b56efd6dc11fd13d30d6e585169bde33710d6fbc4f46bd585d893a6f3d',
    ),
  );

  final DribbbleClient client;
  final DribbbleInteractor interactor;

  DependencyInjector._(this.client, this.interactor);

  factory DependencyInjector._from(DribbbleClient client) {
    final interactor = new DribbbleInteractor(client: client);

    return new DependencyInjector._(client, interactor);
  }

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
