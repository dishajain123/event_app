import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/app_exception.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/states/app_empty_state.dart';
import '../../../../shared/widgets/states/app_error_state.dart';
import '../../../../shared/widgets/states/app_skeleton.dart';
import '../../application/media_providers.dart';
import '../../data/models/event_media.dart';

class MediaGalleryScreen extends ConsumerWidget {
  final String eventId;
  const MediaGalleryScreen({super.key, required this.eventId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mediaAsync = ref.watch(eventMediaProvider(eventId));

    return Scaffold(
      appBar: AppBar(title: const Text('Gallery')),
      body: mediaAsync.when(
        loading: () => const AppSkeleton.cardList(),
        error: (error, stackTrace) => AppErrorState(
          error: error is AppException
              ? error
              : UnknownException(error.toString()),
          onRetry: () => ref.invalidate(eventMediaProvider(eventId)),
        ),
        data: (items) {
          if (items.isEmpty) {
            return const AppEmptyState(
              icon: Icons.photo_library_outlined,
              title: 'No media yet',
              description:
                  'Photos and videos from this event will appear here once published.',
            );
          }
          return GridView.builder(
            padding: const EdgeInsets.all(AppSpacing.md),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: AppSpacing.sm,
              mainAxisSpacing: AppSpacing.sm,
            ),
            itemCount: items.length,
            itemBuilder: (context, index) => _MediaTile(item: items[index]),
          );
        },
      ),
    );
  }
}

class _MediaTile extends StatelessWidget {
  final EventMedia item;
  const _MediaTile({required this.item});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => showDialog(
        context: context,
        builder: (context) => Dialog(
          child: InteractiveViewer(
            child: Image.network(
              item.publicUrl,
              errorBuilder: (context, error, stackTrace) =>
                  const Icon(Icons.broken_image_outlined),
            ),
          ),
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(
              item.publicUrl,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                color: AppColors.backgroundAlt,
                child: const Icon(Icons.image_not_supported_outlined,
                    color: AppColors.inkSubtle),
              ),
            ),
            if (item.isHighlight)
              const Positioned(
                top: 8,
                right: 8,
                child: Icon(Icons.star_rounded, color: Colors.amber, size: 20),
              ),
          ],
        ),
      ),
    );
  }
}
