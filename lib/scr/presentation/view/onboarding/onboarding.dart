import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gym/scr/core/constants/app_colors.dart';
import 'package:gym/scr/core/constants/app_image.dart';
import 'package:gym/scr/core/utils/helper/text_helper.dart';
import 'package:gym/scr/core/utils/navigation/app_routes.dart';
import 'package:gym/scr/presentation/widgets/common/common_button.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key, this.onFinished});

  final VoidCallback? onFinished;

  static const _OnboardingPageData _page = _OnboardingPageData(
    title: 'Train with intent',
    subtitle:
        'Start focused workouts built around strength, energy, and steady progress.',
  );

  static const List<String> _backgroundImages = [
    onboardingImageOne,
    onboardingImageTwo,
    onboardingImageThree,
  ];

  static Future<void> precacheImages(BuildContext context) {
    final imageCacheWidth = resolveImageCacheWidth(context);

    unawaited(_precacheRemainingBackgroundImages(context, imageCacheWidth));

    return _precacheBackgroundImage(
      context,
      _backgroundImages.first,
      imageCacheWidth,
    );
  }

  static Future<void> _precacheRemainingBackgroundImages(
    BuildContext context,
    int imageCacheWidth,
  ) async {
    try {
      await Future.wait(
        _backgroundImages.skip(1).map((imagePath) {
          return _precacheBackgroundImage(context, imagePath, imageCacheWidth);
        }),
      );
    } catch (_) {
      return;
    }
  }

  static Future<void> _precacheBackgroundImage(
    BuildContext context,
    String imagePath,
    int imageCacheWidth,
  ) {
    return precacheImage(
      ResizeImage.resizeIfNeeded(imageCacheWidth, null, AssetImage(imagePath)),
      context,
    );
  }

  static int resolveImageCacheWidth(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final targetWidth = (mediaQuery.size.width * mediaQuery.devicePixelRatio)
        .round()
        .clamp(1, 1440);
    return targetWidth;
  }

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with SingleTickerProviderStateMixin {
  static const _backgroundRotationInterval = Duration(seconds: 4);
  static const _backgroundFadeDuration = Duration(milliseconds: 900);

  AnimationController? _contentController;
  Animation<double> _contentOpacity = const AlwaysStoppedAnimation(1);
  Animation<Offset> _contentSlide = const AlwaysStoppedAnimation(Offset.zero);
  Timer? _backgroundTimer;
  int _backgroundImageIndex = 0;
  bool _didPrecacheImages = false;

  @override
  void initState() {
    super.initState();

    final contentController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 780),
    );
    _contentController = contentController;
    _contentOpacity = CurvedAnimation(
      parent: contentController,
      curve: Curves.easeOut,
    );
    _contentSlide =
        Tween<Offset>(begin: const Offset(0, 0.28), end: Offset.zero).animate(
          CurvedAnimation(
            parent: contentController,
            curve: Curves.easeOutCubic,
          ),
        );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }

      contentController.forward();
    });

    _startBackgroundRotation();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_didPrecacheImages) {
      return;
    }

    _didPrecacheImages = true;
    OnboardingScreen.precacheImages(context);
  }

  void _handleGetStarted() {
    final onFinished = widget.onFinished;
    if (onFinished != null) {
      onFinished();
      return;
    }

    Get.offNamed<void>(AppRoutes.login);
  }

  void _startBackgroundRotation() {
    if (OnboardingScreen._backgroundImages.length < 2) {
      return;
    }

    _backgroundTimer = Timer.periodic(_backgroundRotationInterval, (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        _backgroundImageIndex =
            (_backgroundImageIndex + 1) %
            OnboardingScreen._backgroundImages.length;
      });
    });
  }

  @override
  void dispose() {
    _backgroundTimer?.cancel();
    _contentController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final page = OnboardingScreen._page;
    final backgroundImage =
        OnboardingScreen._backgroundImages[_backgroundImageIndex];
    final imageCacheWidth = OnboardingScreen.resolveImageCacheWidth(context);
    final isCompact = MediaQuery.sizeOf(context).height < 680;

    return Scaffold(
      backgroundColor: AppColors.background,
      extendBody: true,
      extendBodyBehindAppBar: true,
      body: Stack(
        fit: StackFit.expand,
        children: [
          Positioned.fill(
            child: AnimatedSwitcher(
              duration: _backgroundFadeDuration,
              switchInCurve: Curves.easeOut,
              switchOutCurve: Curves.easeIn,
              layoutBuilder: (currentChild, previousChildren) {
                return Stack(
                  fit: StackFit.expand,
                  children: [...previousChildren, ?currentChild],
                );
              },
              child: SizedBox.expand(
                key: ValueKey(backgroundImage),
                child: Image.asset(
                  backgroundImage,
                  cacheWidth: imageCacheWidth,
                  fit: BoxFit.cover,
                  frameBuilder:
                      (context, child, frame, wasSynchronouslyLoaded) {
                        if (wasSynchronouslyLoaded || frame != null) {
                          return child;
                        }

                        return const SizedBox.expand();
                      },
                  gaplessPlayback: true,
                  alignment: Alignment.topCenter,
                ),
              ),
            ),
          ),
          const Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColors.transparent,
                    AppColors.overlayLight,
                    AppColors.overlayMedium,
                  ],
                  stops: [0, 0.48, 1],
                ),
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: EdgeInsets.fromLTRB(24, 24, 24, isCompact ? 24 : 36),
              child: Align(
                alignment: Alignment.bottomCenter,
                child: SlideTransition(
                  position: _contentSlide,
                  child: FadeTransition(
                    opacity: _contentOpacity,
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 420),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            page.title,
                            textAlign: TextAlign.center,
                            style: TextHelper.onboardingTitle,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            page.subtitle,
                            textAlign: TextAlign.center,
                            style: TextHelper.onboardingSubtitle,
                          ),
                          const SizedBox(height: 32),
                          CommonButton(
                            label: 'Get Started',
                            onPressed: _handleGetStarted,
                            height: 56,
                            borderRadius: 8,
                            fontSize: 16,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OnboardingPageData {
  const _OnboardingPageData({required this.title, required this.subtitle});

  final String title;
  final String subtitle;
}
