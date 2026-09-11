import 'package:flutter/material.dart';

/// A lightweight tap wrapper that adds a subtle press-scale + fade,
/// the kind of tactile feedback expected of a polished product. Wrap any
/// card, tile, or button-like surface. Does nothing if [onTap] is null.
class Pressable extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final double pressedScale;
  final Duration duration;

  const Pressable({
    super.key,
    required this.child,
    this.onTap,
    this.pressedScale = 0.97,
    this.duration = const Duration(milliseconds: 120),
  });

  @override
  State<Pressable> createState() => _PressableState();
}

class _PressableState extends State<Pressable> {
  bool _down = false;

  void _set(bool value) {
    if (widget.onTap == null || _down == value) return;
    setState(() => _down = value);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: (_) => _set(true),
      onTapUp: (_) => _set(false),
      onTapCancel: () => _set(false),
      child: AnimatedScale(
        scale: _down ? widget.pressedScale : 1.0,
        duration: widget.duration,
        curve: Curves.easeOut,
        child: AnimatedOpacity(
          opacity: _down ? 0.92 : 1.0,
          duration: widget.duration,
          child: widget.child,
        ),
      ),
    );
  }
}
