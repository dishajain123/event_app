import 'package:flutter/material.dart';

/// Base shimmer block — every skeleton shape below is built from this
/// rather than each screen hand-rolling its own placeholder box. Sweep is
/// now eased (not linear) and slightly wider, reading closer to native
/// iOS/Android shimmer than a mechanical linear sweep.
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
  late final Animation<double> _sweep;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1500))
      ..repeat();
    _sweep = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _sweep,
      builder: (context, child) {
        final t = _sweep.value;
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: widget.borderRadius,
            gradient: LinearGradient(
              begin: Alignment(-1.6 + 3.2 * t, 0),
              end: Alignment(-0.6 + 3.2 * t, 0),
              colors: const [
                Color(0x0F1B1D3D),
                Color(0x241B1D3D),
                Color(0x0F1B1D3D),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Shaped skeletons per content type — pick the constructor matching what's
/// actually loading so the loading state previews the real layout. Public
/// API is unchanged: [AppSkeleton.cardList], [AppSkeleton.detailPage],
/// [AppSkeleton.form] take the same parameters as before.
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
        height: 168,
        borderRadius: BorderRadius.all(Radius.circular(22)),
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
            height: 220, borderRadius: BorderRadius.all(Radius.circular(22))),
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
              height: 46, borderRadius: BorderRadius.all(Radius.circular(14))),
        ],
      ),
    );
  }
}