import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:jamaat_timings/models.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:jamaat_timings/timings_page.dart';

class MosquesListItem extends StatelessWidget {
  MosquesListItem({
    Key key, @required this.mosqueDetail
  }) : super(key: key);

  static const double height = 366.0;
  final MosqueDetail mosqueDetail;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final TextStyle titleStyle =
        theme.textTheme.headline.copyWith(color: Colors.white);
    final TextStyle descriptionStyle = theme.textTheme.subhead;

    return new SafeArea(
      top: false,
      bottom: false,
      child: new Container(
        padding: const EdgeInsets.all(8.0),
        height: height,
        child: new Card(
          child: new Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              // photo and title
              new SizedBox(
                height: 184.0,
                child: new Stack(
                  children: <Widget>[
                    new Positioned.fill(
                      child: new Image(
                        image: new CachedNetworkImageProvider(mosqueDetail.imageUrl),
                        fit: BoxFit.cover,
                      ),
                    ),
                    new Positioned(
                      bottom: 16.0,
                      left: 16.0,
                      right: 16.0,
                      child: new FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: new Text(
                          mosqueDetail.name,
                          style: titleStyle,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // description and share/explore buttons
              new Expanded(
                child: new Padding(
                  padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 0.0),
                  child: new DefaultTextStyle(
                    softWrap: false,
                    overflow: TextOverflow.ellipsis,
                    style: descriptionStyle,
                    child: new Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        // three line description
                        new Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: new Text(
                            mosqueDetail.briefAddr,
                            style: descriptionStyle.copyWith(
                                color: Colors.black54),
                          ),
                        ),
                        new Text(mosqueDetail.addressLine1),
                        new Text(mosqueDetail.addressLine2),
                      ],
                    ),
                  ),
                ),
              ),
              // share, explore buttons
              new ButtonTheme.bar(
                child: new ButtonBar(
                  alignment: MainAxisAlignment.start,
                  children: <Widget>[
                    new FlatButton(
                      child: const Text('LOCATE'),
                      textColor: Theme.of(context).accentColor,
                      onPressed: () {/* do nothing */},
                    ),
                    new FlatButton(
                      child: const Text('TIMINGS'),
                      textColor: Theme.of(context).accentColor,
                      onPressed: () {
                        Navigator.push(context,
                            MaterialPageRoute(builder: (context) => TimingsPage(mosqueDetails: mosqueDetail)),);
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
