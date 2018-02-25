import 'package:dribbble_client/dribbble_client.dart';
import 'package:mvi_sealed_unions/screen_item.dart';

class ScreenCollection {
  final List<ScreenItem> items;
  final String nextLink;

  ScreenCollection(this.items, {this.nextLink});

  factory ScreenCollection.empty() {
    return new ScreenCollection([]);
  }

  factory ScreenCollection.from(DribbbleCollection<DribbbleShot> collection) {
    return new ScreenCollection(
      collection.items
          .map((DribbbleShot shot) => new ScreenItem.shot(shot))
          .toList(),
      nextLink: collection.nextLink,
    );
  }

  ScreenCollection append(ScreenCollection updates) {
    return new ScreenCollection(
      <ScreenItem>[]..addAll(items)..addAll(updates.items),
      nextLink: updates.nextLink ?? nextLink
    );
  }

  bool get hasNext => nextLink != null && nextLink.isNotEmpty;

  @override
  String toString() {
    return 'ScreenCollection{collection: $items, nextLink: $nextLink}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ScreenCollection &&
          runtimeType == other.runtimeType &&
          items == other.items &&
          nextLink == other.nextLink;

  @override
  int get hashCode => items.hashCode ^ nextLink.hashCode;
}
