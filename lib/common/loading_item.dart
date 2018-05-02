import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

class LoadingItem extends StatefulWidget {
  final void Function() loadNextPage;

  const LoadingItem({
    Key key,
    @required this.loadNextPage,
  }) : super(key: key);

  @override
  LoadingItemState createState() {
    return LoadingItemState();
  }
}

class LoadingItemState extends State<LoadingItem> {
  @override
  void initState() {
    widget.loadNextPage();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(8.0),
        child: CircularProgressIndicator(),
      ),
    );
  }
}
