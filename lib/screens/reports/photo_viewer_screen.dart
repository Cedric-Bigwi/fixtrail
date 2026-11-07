import 'package:flutter/material.dart';
import '../../widgets/network_photo.dart';

/// Full-screen, pinch-to-zoom photo viewer.
class PhotoViewerScreen extends StatelessWidget {
  final String url;
  const PhotoViewerScreen({super.key, required this.url});

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        body: LayoutBuilder(
          builder: (context, c) => InteractiveViewer(
            minScale: 1,
            maxScale: 5,
            child: NetworkPhoto(
              url: url,
              fit: BoxFit.contain,
              width: c.maxWidth,
              height: c.maxHeight,
            ),
          ),
        ),
      );
}
