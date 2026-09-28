import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

/// Version flag so you can switch background style per release.
const int kCurrentSplashThemeVersion = 1;

/// Background modes supported by EraScaffold.
enum EraBackgroundMode { staticGradient, staticImage, video }

/// Decide which background to use for this version.
/// Later you can hook this to remote config / backend.
EraBackgroundMode getEraBackgroundMode() {
  switch (kCurrentSplashThemeVersion) {
    case 1:
      return EraBackgroundMode.staticImage; // luxury island as default
    case 2:
      return EraBackgroundMode.video;
    default:
      return EraBackgroundMode.staticGradient;
  }
}

/// Asset paths for the luxury theme.
const String kEraLuxuryBackgroundImagePath =
    'assets/images/splash_luxury_beach.png';
const String kEraLuxuryBackgroundVideoPath =
    'assets/videos/splash_luxury_beach_loop.mp4';

/// Reusable scaffold that draws the luxury splash-style background
/// (gradient/image/video) and then overlays your page content.
class EraScaffold extends StatelessWidget {
  final PreferredSizeWidget? appBar;
  final Widget body;
  final Widget? floatingActionButton;
  final bool resizeToAvoidBottomInset;

  const EraScaffold({
    super.key,
    this.appBar,
    required this.body,
    this.floatingActionButton,
    this.resizeToAvoidBottomInset = true,
  });

  @override
  Widget build(BuildContext context) {
    final mode = getEraBackgroundMode();

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      appBar: appBar,
      floatingActionButton: floatingActionButton,
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 1) Background layer
          switch (mode) {
            EraBackgroundMode.staticGradient => const _GradientBackground(),
            EraBackgroundMode.staticImage => const _ImageBackground(),
            EraBackgroundMode.video => const _VideoBackground(),
          },

          // 2) Subtle overlay so text/cards stay readable
          Container(color: Colors.black.withValues(alpha: 0.25)),

          // 3) Page content
          SafeArea(
            child: Padding(padding: const EdgeInsets.all(12.0), child: body),
          ),
        ],
      ),
    );
  }
}

class _GradientBackground extends StatelessWidget {
  const _GradientBackground();

  @override
  Widget build(BuildContext context) {
    // Backup gradient: sky-to-water feeling.
    return const DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFF87CEFA), // sky blue
            Color(0xFF00B4DB), // lighter turquoise
            Color(0xFF0083B0), // deeper water blue
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
    );
  }
}

class _ImageBackground extends StatelessWidget {
  const _ImageBackground();

  @override
  Widget build(BuildContext context) {
    return Image.asset(kEraLuxuryBackgroundImagePath, fit: BoxFit.cover);
  }
}

class _VideoBackground extends StatefulWidget {
  const _VideoBackground();

  @override
  State<_VideoBackground> createState() => _VideoBackgroundState();
}

class _VideoBackgroundState extends State<_VideoBackground> {
  late VideoPlayerController _controller;
  bool _ready = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.asset(kEraLuxuryBackgroundVideoPath)
      ..setLooping(true)
      ..setVolume(0)
      ..initialize().then((_) {
        if (!mounted) return;
        setState(() => _ready = true);
        _controller.play();
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_ready) {
      // Fallback while video loads
      return const _ImageBackground();
    }

    return FittedBox(
      fit: BoxFit.cover,
      child: SizedBox(
        width: _controller.value.size.width,
        height: _controller.value.size.height,
        child: VideoPlayer(_controller),
      ),
    );
  }
}
