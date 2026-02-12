// dart format width=80

/// GENERATED CODE - DO NOT MODIFY BY HAND
/// *****************************************************
///  FlutterGen
/// *****************************************************

// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: deprecated_member_use,directives_ordering,implicit_dynamic_list_literal,unnecessary_import

import 'package:flutter/widgets.dart';

class Assets {
  const Assets._();

  static const AssetGenImage lOGOPng = AssetGenImage('assets/LOGO.png');
  static const String logoSvg = 'assets/logo.svg';
  static const String layer1 = 'assets/Layer_1.svg';
  static const String animation = 'assets/animation.json';
  static const AssetGenImage appIcon = AssetGenImage('assets/app_icon.png');
  static const String appleIcon = 'assets/apple_icon.svg';
  static const AssetGenImage background = AssetGenImage(
    'assets/background.png',
  );
  static const AssetGenImage bannerImage = AssetGenImage(
    'assets/banner_image.png',
  );
  static const AssetGenImage c1bdd49aC54a4c569c766e8904ff020d = AssetGenImage(
    'assets/c1bdd49a-c54a-4c56-9c76-6e8904ff020d.jpeg',
  );
  static const AssetGenImage cellIllustration = AssetGenImage(
    'assets/cell_illustration.png',
  );
  static const AssetGenImage communityPng = AssetGenImage(
    'assets/community.png',
  );
  static const String communitySvg = 'assets/community.svg';
  static const String communityIcon = 'assets/community_icon.svg';
  static const String cycles = 'assets/cycles.svg';
  static const String embryoanimation = 'assets/embryoanimation.json';
  static const String facebookIcon = 'assets/facebook_icon.svg';
  static const String frame = 'assets/frame.svg';
  static const String googleIcon = 'assets/google_icon.svg';
  static const AssetGenImage homeGradientBg = AssetGenImage(
    'assets/home_gradient_bg.png',
  );
  static const String onboarding2 = 'assets/onboarding2.json';
  static const String onboarding3 = 'assets/onboarding3.json';
  static const String profile = 'assets/profile.svg';
  static const String rippleloading = 'assets/rippleloading.json';
  static const String scanIcon = 'assets/scan_icon.svg';
  static const String scanNavIcon = 'assets/scan_nav_icon.svg';
  static const AssetGenImage splashBackground = AssetGenImage(
    'assets/splash_background.png',
  );
  static const String vector1 = 'assets/vector_1.svg';
  static const AssetGenImage yumemiLogo = AssetGenImage(
    'assets/yumemi_logo.png',
  );

  /// List of all assets
  static List<dynamic> get values => [
    lOGOPng,
    logoSvg,
    layer1,
    animation,
    appIcon,
    appleIcon,
    background,
    bannerImage,
    c1bdd49aC54a4c569c766e8904ff020d,
    cellIllustration,
    communityPng,
    communitySvg,
    communityIcon,
    cycles,
    embryoanimation,
    facebookIcon,
    frame,
    googleIcon,
    homeGradientBg,
    onboarding2,
    onboarding3,
    profile,
    rippleloading,
    scanIcon,
    scanNavIcon,
    splashBackground,
    vector1,
    yumemiLogo,
  ];
}

class AssetGenImage {
  const AssetGenImage(
    this._assetName, {
    this.size,
    this.flavors = const {},
    this.animation,
  });

  final String _assetName;

  final Size? size;
  final Set<String> flavors;
  final AssetGenImageAnimation? animation;

  Image image({
    Key? key,
    AssetBundle? bundle,
    ImageFrameBuilder? frameBuilder,
    ImageErrorWidgetBuilder? errorBuilder,
    String? semanticLabel,
    bool excludeFromSemantics = false,
    double? scale,
    double? width,
    double? height,
    Color? color,
    Animation<double>? opacity,
    BlendMode? colorBlendMode,
    BoxFit? fit,
    AlignmentGeometry alignment = Alignment.center,
    ImageRepeat repeat = ImageRepeat.noRepeat,
    Rect? centerSlice,
    bool matchTextDirection = false,
    bool gaplessPlayback = true,
    bool isAntiAlias = false,
    String? package,
    FilterQuality filterQuality = FilterQuality.medium,
    int? cacheWidth,
    int? cacheHeight,
  }) {
    return Image.asset(
      _assetName,
      key: key,
      bundle: bundle,
      frameBuilder: frameBuilder,
      errorBuilder: errorBuilder,
      semanticLabel: semanticLabel,
      excludeFromSemantics: excludeFromSemantics,
      scale: scale,
      width: width,
      height: height,
      color: color,
      opacity: opacity,
      colorBlendMode: colorBlendMode,
      fit: fit,
      alignment: alignment,
      repeat: repeat,
      centerSlice: centerSlice,
      matchTextDirection: matchTextDirection,
      gaplessPlayback: gaplessPlayback,
      isAntiAlias: isAntiAlias,
      package: package,
      filterQuality: filterQuality,
      cacheWidth: cacheWidth,
      cacheHeight: cacheHeight,
    );
  }

  ImageProvider provider({AssetBundle? bundle, String? package}) {
    return AssetImage(_assetName, bundle: bundle, package: package);
  }

  String get path => _assetName;

  String get keyName => _assetName;
}

class AssetGenImageAnimation {
  const AssetGenImageAnimation({
    required this.isAnimation,
    required this.duration,
    required this.frames,
  });

  final bool isAnimation;
  final Duration duration;
  final int frames;
}
