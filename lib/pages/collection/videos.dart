import 'package:flutter/material.dart';
import 'package:quiet/pages/collection/empty.dart';

class CollectionVideos extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CollectionEmpty(
      message: 'Videos favoritos aquí',
    );
  }
}
