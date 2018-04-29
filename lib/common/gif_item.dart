import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:giphy_client/giphy_client.dart';
import 'package:transparent_image/transparent_image.dart';

class GifItem extends StatelessWidget {
  final GiphyGif gif;
  final Color backgroundColor;

  GifItem({
    Key key,
    @required this.gif,
    @required this.backgroundColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: backgroundColor,
      child: Hero(
        tag: gif,
        child: AspectRatio(
          aspectRatio: int.parse(gif.images.original.width) /
              int.parse(gif.images.original.height),
          child: GestureDetector(
            child: FadeInImage.memoryNetwork(
              fadeInDuration: Duration(milliseconds: 200),
              placeholder: kTransparentImage,
              image: gif.images.fixedHeightStill.url,
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
        final image = gif.images.original;

        return Scaffold(
          body: GestureDetector(
            onVerticalDragDown: (DragDownDetails _) {
              Navigator.pop(context);
            },
            child: Container(
              color: Colors.black,
              child: Center(
                child: AspectRatio(
                  aspectRatio: int.parse(image.width) / int.parse(image.height),
                  child: Hero(
                    tag: gif,
                    child: Stack(
                      children: <Widget>[
                        Positioned.fill(
                          child: Image.network(
                            gif.images.fixedHeightStill.url,
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
