import 'package:flutter/material.dart';

class BouncyTappable extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;
  final double scaleFactor;
  final Duration duration;

  const BouncyTappable({
    super.key,
    required this.child,
    required this.onTap,
    this.scaleFactor = 0.96,
    this.duration = const Duration(milliseconds: 100),
  });

  @override
  State<BouncyTappable> createState() => _BouncyTappableState();
}

class _BouncyTappableState extends State<BouncyTappable>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
      value: 1.0,
    );
    _scaleAnimation = Tween<double>(
      begin: widget.scaleFactor,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  DateTime? _tapTime;

  void _onTapDown(TapDownDetails details) {
    _tapTime = DateTime.now();
    _controller.reverse();
  }

  void _onTapUp(TapUpDetails details) {
    if (_tapTime != null) {
      final elapsed = DateTime.now().difference(_tapTime!).inMilliseconds;
      const minScaleDuration = 80; // Minimum time in ms to stay scaled down
      if (elapsed < minScaleDuration) {
        Future.delayed(Duration(milliseconds: minScaleDuration - elapsed), () {
          if (mounted) {
            _controller.forward();
          }
        });
      } else {
        _controller.forward();
      }
    } else {
      _controller.forward();
    }
  }

  void _onTapCancel() {
    _controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      onTap: widget.onTap,
      behavior: HitTestBehavior.opaque,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: widget.child,
      ),
    );
  }
}
