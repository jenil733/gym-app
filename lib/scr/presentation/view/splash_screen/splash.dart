import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gym/scr/core/constants/app_colors.dart';
import 'package:gym/scr/core/constants/app_image.dart';
import 'package:gym/scr/core/services/local_storage.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({
    super.key,
    this.logoAssetPath = appLogo,
    this.nextRouteName,
    this.preloadNextScreen,
    this.splashDuration = const Duration(milliseconds: 2600),
  });

  final String logoAssetPath;
  final String? nextRouteName;
  final Future<void> Function(BuildContext context)? preloadNextScreen;
  final Duration splashDuration;

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _introController;
  late final Animation<double> _logoOpacity;
  late final Animation<double> _logoScale;
  late final Animation<Offset> _textSlide;
  Timer? _navigationTimer;
  bool _didStartPreload = false;
  bool _isSplashDurationDone = false;
  bool _isPreloadDone = false;
  bool _isRouteResolved = false;
  bool _didOpenNextScreen = false;
  String? _resolvedNextRoute;

  @override
  void initState() {
    super.initState();

    _introController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..forward();

    _logoOpacity = CurvedAnimation(
      parent: _introController,
      curve: const Interval(0, 0.65, curve: Curves.easeOut),
    );
    _logoScale = Tween<double>(begin: 0.72, end: 1).animate(
      CurvedAnimation(parent: _introController, curve: Curves.easeOutBack),
    );
    _textSlide = Tween<Offset>(begin: const Offset(0, 0.22), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: _introController,
            curve: const Interval(0.28, 1, curve: Curves.easeOutCubic),
          ),
        );

    _isPreloadDone = widget.preloadNextScreen == null;
    _resolveNextRoute();
    _navigationTimer = Timer(widget.splashDuration, () {
      _isSplashDurationDone = true;
      _openNextScreenIfReady();
    });
  }

  Future<void> _resolveNextRoute() async {
    final configuredRoute = widget.nextRouteName;
    if (configuredRoute != null) {
      _resolvedNextRoute = configuredRoute;
      _isRouteResolved = true;
      _openNextScreenIfReady();
      return;
    }

    final storage = Get.isRegistered<LocalStorageService>()
        ? Get.find<LocalStorageService>()
        : LocalStorageService();
    await storage.init();
    final token = storage.getString('auth_token')?.trim();
    if (!mounted) {
      return;
    }
    _resolvedNextRoute = token != null && token.isNotEmpty
        ? '/main'
        : '/onboarding';
    _isRouteResolved = true;
    _openNextScreenIfReady();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_didStartPreload) {
      return;
    }

    _didStartPreload = true;
    final preloadNextScreen = widget.preloadNextScreen;
    if (preloadNextScreen == null) {
      return;
    }

    preloadNextScreen(context).catchError((Object _) {}).whenComplete(() {
      if (!mounted) {
        return;
      }

      _isPreloadDone = true;
      _openNextScreenIfReady();
    });
  }

  void _openNextScreenIfReady() {
    if (!mounted ||
        !_isRouteResolved ||
        _resolvedNextRoute == null ||
        _didOpenNextScreen ||
        !_isSplashDurationDone ||
        !_isPreloadDone) {
      return;
    }

    _didOpenNextScreen = true;
    Get.offNamed<void>(_resolvedNextRoute!);
  }

  @override
  void dispose() {
    _navigationTimer?.cancel();
    _introController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.black, AppColors.background, AppColors.black],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 28),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final logoHeight = (constraints.maxHeight - 48).clamp(
                  180.0,
                  300.0,
                );
                final logoWidth = logoHeight * 0.8;
                final bottomGap = constraints.maxHeight < 360 ? 12.0 : 30.0;

                return Column(
                  children: [
                    const Spacer(),
                    FadeTransition(
                      opacity: _logoOpacity,
                      child: ScaleTransition(
                        scale: _logoScale,
                        child: _LogoMark(
                          logoAssetPath: widget.logoAssetPath,
                          width: logoWidth,
                          height: logoHeight,
                        ),
                      ),
                    ),
                    SizedBox(height: bottomGap),
                    SlideTransition(
                      position: _textSlide,
                      child: FadeTransition(opacity: _introController),
                    ),
                    const Spacer(),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _LogoMark extends StatelessWidget {
  const _LogoMark({
    required this.logoAssetPath,
    required this.width,
    required this.height,
  });

  final String logoAssetPath;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.black,
        borderRadius: BorderRadius.circular(8),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(6),
        child: Image.asset(
          logoAssetPath,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) {
            return const DecoratedBox(
              decoration: BoxDecoration(color: AppColors.surfaceHigh),
              child: Icon(
                Icons.fitness_center_rounded,
                color: AppColors.primary,
                size: 54,
              ),
            );
          },
        ),
      ),
    );
  }
}
