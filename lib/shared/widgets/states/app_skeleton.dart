import 'package:flutter/material.dart';

/// Base shimmer block — every skeleton shape below is built from this
/// rather than each screen hand-rolling its own placeholder box.
class _ShimmerBox extends StatefulWidget {
  final double? width;
  final double height;
  final BorderRadius borderRadius;

  const _ShimmerBox(
      {this.width, required this.height, required this.borderRadius});

  @override
  State<_ShimmerBox> createState() => _ShimmerBoxState();
}

class _ShimmerBoxState extends State<_ShimmerBox>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1400))
      ..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final t = _controller.value;
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: widget.borderRadius,
            gradient: LinearGradient(
              begin: Alignment(-1.0 + 2 * t, 0),
              end: Alignment(1.0 + 2 * t, 0),
              colors: const [
                Color(0x11000000),
                Color(0x22000000),
                Color(0x11000000)
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Shaped skeletons per content type (Section 3.7: "never a bare spinner on
/// a content screen") — pick the constructor matching what's actually
/// loading so the loading state previews the real layout.
class AppSkeleton extends StatelessWidget {
  final _SkeletonShape _shape;
  final int _count;

  const AppSkeleton._(this._shape, this._count);

  /// A vertical list of card-shaped placeholders — e.g. the event feed,
  /// My Registrations, My Tickets.
  const AppSkeleton.cardList({int count = 4})
      : this._(_SkeletonShape.cardList, count);

  /// A single detail-page shaped placeholder — cover image block, title,
  /// a few text lines.
  const AppSkeleton.detailPage() : this._(_SkeletonShape.detailPage, 0);

  /// A form-shaped placeholder — a handful of label+field pairs.
  const AppSkeleton.form({int fieldCount = 4})
      : this._(_SkeletonShape.form, fieldCount);

  @override
  Widget build(BuildContext context) {
    switch (_shape) {
      case _SkeletonShape.cardList:
        return _CardListSkeleton(count: _count);
      case _SkeletonShape.detailPage:
        return const _DetailPageSkeleton();
      case _SkeletonShape.form:
        return _FormSkeleton(fieldCount: _count);
    }
  }
}

enum _SkeletonShape { cardList, detailPage, form }

class _CardListSkeleton extends StatelessWidget {
  final int count;
  const _CardListSkeleton({required this.count});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: count,
      separatorBuilder: (_, __) => const SizedBox(height: 16),
      itemBuilder: (context, index) => const _ShimmerBox(
        height: 160,
        borderRadius: BorderRadius.all(Radius.circular(20)),
      ),
    );
  }
}

class _DetailPageSkeleton extends StatelessWidget {
  const _DetailPageSkeleton();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: const [
        _ShimmerBox(
            height: 220, borderRadius: BorderRadius.all(Radius.circular(20))),
        SizedBox(height: 20),
        _ShimmerBox(
            height: 24,
            width: 220,
            borderRadius: BorderRadius.all(Radius.circular(8))),
        SizedBox(height: 12),
        _ShimmerBox(
            height: 16, borderRadius: BorderRadius.all(Radius.circular(6))),
        SizedBox(height: 8),
        _ShimmerBox(
            height: 16,
            width: 260,
            borderRadius: BorderRadius.all(Radius.circular(6))),
      ],
    );
  }
}

class _FormSkeleton extends StatelessWidget {
  final int fieldCount;
  const _FormSkeleton({required this.fieldCount});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: fieldCount,
      separatorBuilder: (_, __) => const SizedBox(height: 20),
      itemBuilder: (context, index) => const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _ShimmerBox(
              height: 14,
              width: 100,
              borderRadius: BorderRadius.all(Radius.circular(6))),
          SizedBox(height: 8),
          _ShimmerBox(
              height: 46, borderRadius: BorderRadius.all(Radius.circular(12))),
        ],
      ),
    );
  }
}
