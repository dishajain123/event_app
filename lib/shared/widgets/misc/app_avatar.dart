import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';

/// A new, additive shared widget — one avatar implementation for profile
/// photos, networking directory entries, and staff-mode attendee rows.
/// [imageUrl] is always backend-supplied by the caller (never a bundled
/// placeholder); when it's null or fails to load, this falls back to a
/// gradient initials circle derived from [name] — never a broken-image
/// icon or a generic silhouette.
class AppAvatar extends StatelessWidget {
  final String? imageUrl;
  final String name;
  final double size;

  const AppAvatar({
    super.key,
    required this.name,
    this.imageUrl,
    this.size = 44,
  });

  String get _initials {
    final parts = name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty);
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return (parts.first.substring(0, 1) + parts.last.substring(0, 1))
        .toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final fallback = Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.accent, AppColors.accentViolet],
        ),
      ),
      child: Text(
        _initials,
        style: AppTypography.bodyStrong.copyWith(
          color: Colors.white,
          fontSize: size * 0.36,
        ),
      ),
    );

    if (imageUrl == null || imageUrl!.isEmpty) return fallback;

    return ClipOval(
      child: CachedNetworkImage(
        imageUrl: imageUrl!,
        width: size,
        height: size,
        fit: BoxFit.cover,
        placeholder: (context, url) => fallback,
        errorWidget: (context, url, error) => fallback,
      ),
    );
  }
}