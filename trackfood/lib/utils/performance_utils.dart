import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter/scheduler.dart';

/// Utility-Klasse für Performance-Optimierungen
/// Basierend auf Flutter Best Practices für 60/120 FPS Performance
class PerformanceUtils {
  PerformanceUtils._();

  /// Optimiertes Haptic Feedback für iOS
  static void lightImpact() {
    HapticFeedback.lightImpact();
  }

  static void mediumImpact() {
    HapticFeedback.mediumImpact();
  }

  static void heavyImpact() {
    HapticFeedback.heavyImpact();
  }

  static void selectionClick() {
    HapticFeedback.selectionClick();
  }

  /// Debounced Function Call
  /// Verhindert zu häufige API-Aufrufe bei Benutzereingaben
  static Timer? _debounceTimer;
  
  static void debounce(Duration duration, VoidCallback action) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(duration, action);
  }

  /// Optimierte Bild-Caching-Einstellungen
  static void optimizeImageCache() {
    // Erhöhe die maximale Anzahl der gecachten Bilder
    PaintingBinding.instance.imageCache.maximumSize = 1000;
    // Erhöhe den maximalen Speicher für Bild-Cache (100MB)
    PaintingBinding.instance.imageCache.maximumSizeBytes = 100 * 1024 * 1024;
  }

  /// Frame-Rate Monitoring für Development
  static void monitorFrameRate() {
    WidgetsBinding.instance.addTimingsCallback((List<FrameTiming> timings) {
      for (final timing in timings) {
        final frameTime = timing.totalSpan.inMilliseconds;
        if (frameTime > 16) { // Über 16ms = unter 60 FPS
          debugPrint('Slow frame detected: ${frameTime}ms');
        }
      }
    });
  }

  /// Preload wichtiger Bilder
  static Future<void> preloadImages(BuildContext context, List<String> imagePaths) async {
    for (final path in imagePaths) {
      try {
        await precacheImage(AssetImage(path), context);
      } catch (e) {
        debugPrint('Failed to preload image: $path - $e');
      }
    }
  }

  /// Optimierte Scroll-Physics für iOS
  static ScrollPhysics get iOSScrollPhysics => const BouncingScrollPhysics(
    parent: AlwaysScrollableScrollPhysics(),
  );

  /// Memory-effiziente ListView Builder
  static Widget optimizedListView({
    required int itemCount,
    required Widget Function(BuildContext, int) itemBuilder,
    ScrollController? controller,
    EdgeInsets? padding,
  }) {
    return ListView.builder(
      physics: iOSScrollPhysics,
      controller: controller,
      padding: padding,
      itemCount: itemCount,
      itemBuilder: itemBuilder,
      // Optimierungen für Performance
      cacheExtent: 500, // Cachegröße für off-screen items
      addAutomaticKeepAlives: false, // Verhindert automatisches alive-halten
      addRepaintBoundaries: true, // Verbessert Repaint-Performance
    );
  }

  /// Optimierte GridView Builder
  static Widget optimizedGridView({
    required int itemCount,
    required Widget Function(BuildContext, int) itemBuilder,
    required SliverGridDelegate gridDelegate,
    ScrollController? controller,
    EdgeInsets? padding,
  }) {
    return GridView.builder(
      physics: iOSScrollPhysics,
      controller: controller,
      padding: padding,
      gridDelegate: gridDelegate,
      itemCount: itemCount,
      itemBuilder: itemBuilder,
      // Performance-Optimierungen
      cacheExtent: 300,
      addAutomaticKeepAlives: false,
      addRepaintBoundaries: true,
    );
  }
}

/// Mixin für automatisches Lifecycle-Management
mixin PerformanceLifecycleMixin<T extends StatefulWidget> on State<T> {
  @override
  void initState() {
    super.initState();
    // Optimiere Bild-Cache beim Start
    PerformanceUtils.optimizeImageCache();
  }

  @override
  void dispose() {
    // Cleanup Resources
    super.dispose();
  }

  /// Sichere setState-Methode
  void safeSetState(VoidCallback fn) {
    if (mounted) {
      setState(fn);
    }
  }
}

/// Widget für Performance-optimierte Animationen
class OptimizedAnimatedContainer extends StatelessWidget {
  final Widget child;
  final Duration duration;
  final Curve curve;
  final Color? color;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final BoxDecoration? decoration;
  final double? width;
  final double? height;

  const OptimizedAnimatedContainer({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 300),
    this.curve = Curves.easeInOut,
    this.color,
    this.padding,
    this.margin,
    this.decoration,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: AnimatedContainer(
        duration: duration,
        curve: curve,
        width: width,
        height: height,
        padding: padding,
        margin: margin,
        decoration: decoration,
        child: child,
      ),
    );
  }
}

/// Performance-optimierte Custom Scroll View
class OptimizedCustomScrollView extends StatelessWidget {
  final List<Widget> slivers;
  final ScrollController? controller;
  final ScrollPhysics? physics;

  const OptimizedCustomScrollView({
    super.key,
    required this.slivers,
    this.controller,
    this.physics,
  });

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      controller: controller,
      physics: physics ?? PerformanceUtils.iOSScrollPhysics,
      cacheExtent: 500,
      slivers: slivers.map((sliver) => RepaintBoundary(child: sliver)).toList(),
    );
  }
}

