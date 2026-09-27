import 'package:flutter/material.dart';

/// ReuseHub brand logo widget.
///
/// This simply displays the actual logo image files — no text or shapes
/// are drawn in code. Provide two image assets:
///
///   assets/images/logo_icon.png   -> icon only (no text), used when
///                                     showText is false
///   assets/images/logo_full.png   -> full logo including "ReuseHub"
///                                     wordmark + tagline baked into
///                                     the image, used when showText
///                                     is true
///
/// Declare both in pubspec.yaml:
///   flutter:
///     assets:
///       - assets/images/logo_icon.png
///       - assets/images/logo_full.png
class ReUseLogo extends StatelessWidget {
  final double size;
  final bool showText;
  final bool showTagline;
  final bool isHorizontal;
  final Color? textColor;
  final bool isDarkBackground;

  const ReUseLogo({
    super.key,
    this.size = 100,
    this.showText = true,
    this.showTagline = true,
    this.isHorizontal = false,
    this.textColor,
    this.isDarkBackground = false,
  });

  @override
  Widget build(BuildContext context) {
    // Icon-only mode (no text/tagline requested)
    if (!showText) {
      return Image.asset(
        'assets/images/image.png',
        width: size,
        height: size,
        fit: BoxFit.contain,
      );
    }

    // Full logo image (icon + wordmark + tagline all baked into one
    // image) — width scales with `size`, height follows the image's
    // own aspect ratio automatically.
    return Image.asset(
      'assets/images/image.png',
      width: size * 2.2,
      fit: BoxFit.contain,
    );
  }
}