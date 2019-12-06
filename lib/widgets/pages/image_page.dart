import 'package:flutter/material.dart';
import 'package:true_chat/api/models/message.dart';

class ImagePage extends StatelessWidget {
  const ImagePage({Key key, this.imageDTO}) : super(key: key);

  final ImageDTO imageDTO;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          Container(
            alignment: Alignment.center,
            child: Hero(
              tag: 'pk ${imageDTO.pk}',
              child: Image.network(imageDTO.imageURL),
            ),
          ),
          Positioned(
            child: AppBar(
              leading: IconButton(
                icon: Icon(Icons.arrow_back),
                onPressed: () => Navigator.of(context).pop(),
              ),
              title: Text(
                imageDTO.name,
                style: Theme.of(context)
                    .textTheme
                    .body1
                    .copyWith(color: Colors.white),
              ),
              backgroundColor: Colors.transparent,
              elevation: 0,
            ),
          )
        ],
      ),
      backgroundColor: Colors.black,
    );
  }
}
