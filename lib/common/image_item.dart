import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:sealed_union_demo/common/list_item.dart';
import 'package:transparent_image/transparent_image.dart';

class ImageItem extends StatelessWidget {
  final ListItemImage image;

  ImageItem({
    Key key,
    @required this.image,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: image.backgroundColor,
      child: Hero(
        tag: image,
        child: AspectRatio(
          aspectRatio: image.aspectRatio,
          child: GestureDetector(
            child: FadeInImage.memoryNetwork(
              fadeInDuration: Duration(milliseconds: 200),
              placeholder: kTransparentImage,
              image: image.thumbnailUrl,
              fit: BoxFit.cover,
            ),
            onTap: () {
              fullScreen(context);
            },
          ),
        ),
      ),
    );
  }

  void fullScreen(BuildContext context) {
    Navigator.of(context).push(PageRouteBuilder<Null>(
      pageBuilder: (
        BuildContext context,
        Animation<double> animation,
        Animation<double> secondaryAnimation,
      ) {
        return Scaffold(
          body: GestureDetector(
            onVerticalDragDown: (DragDownDetails _) {
              Navigator.pop(context);
            },
            child: Container(
              color: Colors.black,
              child: Center(
                child: AspectRatio(
                  aspectRatio: image.aspectRatio,
                  child: Hero(
                    tag: image,
                    child: Stack(
                      children: <Widget>[
                        Positioned.fill(
                          child: Image.network(
                            image.thumbnailUrl,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Center(child: CircularProgressIndicator()),
                        Positioned.fill(
                          child: Image.network(
                            image.url,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    ));
  }
}
