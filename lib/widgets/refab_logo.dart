import 'package:flutter/material.dart';
import 'reuse_logo.dart';

/// Legacy alias for ReUseLogo to maintain compatibility across all app screens
class ReFabLogo extends StatelessWidget {
  final double size;
  final bool showText;
  final bool showTagline;
  final bool isHorizontal;
  final Color? textColor;
  final bool isDarkBackground;

  const ReFabLogo({
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
    return ReUseLogo(
      size: size,
      showText: showText,
      showTagline: showTagline,
      isHorizontal: isHorizontal,
      textColor: textColor,
      isDarkBackground: isDarkBackground,
    );
  }
}
