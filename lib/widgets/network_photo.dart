import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../core/theme.dart';

/// Network image with spinner, error logging and tap-to-retry.
/// Uses Image.network (not a disk-cache package) because file caching is
/// unreliable on Flutter Web. [fallback] replaces the retry UI (used by thumbnails).
class NetworkPhoto extends StatefulWidget {
  final String url;
  final BoxFit fit;
  final double? height;
  final double? width;
  final Widget? fallback;
  const NetworkPhoto(
      {super.key,
      required this.url,
      this.fit = BoxFit.cover,
      this.height,
      this.width,
      this.fallback});

  @override
  State<NetworkPhoto> createState() => _NetworkPhotoState();
}

class _NetworkPhotoState extends State<NetworkPhoto> {
  int _attempt = 0;

  String get _url {
    if (_attempt == 0) return widget.url;
    return widget.url.contains('?')
        ? '${widget.url}&r=$_attempt'
        : '${widget.url}?r=$_attempt';
  }

  @override
  Widget build(BuildContext context) {
    return Image.network(
      _url,
      key: ValueKey(_url),
      fit: widget.fit,
      width: widget.width,
      height: widget.height,
      // If the browser blocks pixel access (CORS), fall back to a plain <img>.
      webHtmlElementStrategy: WebHtmlElementStrategy.fallback,
      loadingBuilder: (context, child, progress) {
        if (progress == null) return child;
        return Container(
          width: widget.width,
          height: widget.height,
          color: AppColors.sand,
          child: Center(
            child: SizedBox(
              height: 26,
              width: 26,
              child: CircularProgressIndicator(strokeWidth: 2.4, color: AppColors.teal),
            ),
          ),
        );
      },
      errorBuilder: (context, error, stack) {
        debugPrint('Photo failed to load: $_url -> $error');
        if (widget.fallback != null) return widget.fallback!;
        return GestureDetector(
          onTap: () => setState(() => _attempt++),
          child: Container(
            width: widget.width,
            height: widget.height,
            color: AppColors.sand,
            child: Center(
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Icon(Icons.refresh_rounded, color: AppColors.muted, size: 30),
                const SizedBox(height: 6),
                Text('Could not load photo - tap to retry',
                    style: TextStyle(color: AppColors.muted, fontSize: 13)),
              ]),
            ),
          ),
        );
      },
    );
  }
}
