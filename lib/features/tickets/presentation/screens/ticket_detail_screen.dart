import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:barcode_widget/barcode_widget.dart';
import '../../../../core/network/app_exception.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/badges/status_badge.dart';
import '../../../../shared/widgets/buttons/app_button.dart';
import '../../../../shared/widgets/scaffolds/app_background.dart';
import '../../../../shared/widgets/states/app_error_state.dart';
import '../../../../shared/widgets/states/app_skeleton.dart';
import '../../application/tickets_providers.dart';
import '../../data/models/ticket.dart';

const _ticketStatusTones = {
  TicketStatus.issued: StatusTone.success,
  TicketStatus.checkedIn: StatusTone.accent,
  TicketStatus.cancelled: StatusTone.neutral,
};

/// The provider watched and the transfer flow's repository call are
/// unchanged from before — only the barcode card and surrounding layout
/// were restyled.
class TicketDetailScreen extends ConsumerWidget {
  final String ticketId;
  const TicketDetailScreen({super.key, required this.ticketId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ticketAsync = ref.watch(ticketDetailProvider(ticketId));

    return Scaffold(
      appBar: AppBar(title: const Text('Ticket')),
      body: AppBackground(
        child: SafeArea(
          child: ticketAsync.when(
            loading: () => const AppSkeleton.detailPage(),
            error: (error, stackTrace) => AppErrorState(
              error: error is AppException
                  ? error
                  : UnknownException(error.toString()),
              onRetry: () => ref.invalidate(ticketDetailProvider(ticketId)),
            ),
            data: (ticket) => ListView(
              padding: const EdgeInsets.all(AppSpacing.xl),
              children: [
                Center(
                  child: StatusBadge(
                    label: ticket.status.label,
                    tone:
                        _ticketStatusTones[ticket.status] ?? StatusTone.neutral,
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [AppColors.accent, AppColors.accentViolet],
                    ),
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.accent.withValues(alpha: 0.28),
                        blurRadius: 30,
                        offset: const Offset(0, 14),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Container(
                    padding: const EdgeInsets.all(AppSpacing.xl),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Center(
                      child: ticket.status == TicketStatus.cancelled
                          ? const SizedBox(
                              width: double.infinity,
                              height: 120,
                              child: Center(
                                child: Icon(Icons.block_rounded,
                                    size: 48, color: AppColors.inkSubtle),
                              ),
                            )
                          : BarcodeWidget(
                              barcode: Barcode.code128(),
                              data:
                                  '${ticket.barcodePayload}|${ticket.barcodeSignature}',
                              width: 280,
                              height: 110,
                              drawText: false,
                              color: AppColors.ink,
                            ),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                Center(
                    child: Text(ticket.ticketCode,
                        style: AppTypography.bodyStrong)),
                const SizedBox(height: AppSpacing.sm),
                Center(
                  child: Text(
                    ticket.status == TicketStatus.checkedIn
                        ? 'Checked in ${ticket.checkedInAt}'
                        : 'Show this code at check-in',
                    style: AppTypography.caption,
                    textAlign: TextAlign.center,
                  ),
                ),
                if (ticket.status == TicketStatus.issued ||
                    ticket.status == TicketStatus.active) ...[
                  const SizedBox(height: AppSpacing.xl),
                  AppButton(
                    label: 'Transfer ticket',
                    variant: AppButtonVariant.secondary,
                    fullWidth: true,
                    icon: Icons.swap_horiz_rounded,
                    onPressed: () async {
                      final controller = TextEditingController();
                      final recipient = await showDialog<String>(
                        context: context,
                        builder: (dialogContext) => AlertDialog(
                          title: const Text('Transfer ticket'),
                          content: TextField(
                            controller: controller,
                            decoration: const InputDecoration(
                                labelText: 'Recipient user ID'),
                          ),
                          actions: [
                            TextButton(
                                onPressed: () => Navigator.pop(dialogContext),
                                child: const Text('Cancel')),
                            FilledButton(
                                onPressed: () => Navigator.pop(
                                    dialogContext, controller.text.trim()),
                                child: const Text('Send')),
                          ],
                        ),
                      );
                      if (recipient == null ||
                          recipient.isEmpty ||
                          !context.mounted) {
                        return;
                      }
                      try {
                        await ref
                            .read(ticketsRepositoryProvider)
                            .transfer(ticket.id, recipient);
                        ref.invalidate(ticketDetailProvider(ticketId));
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('Transfer request sent.')));
                        }
                      } catch (error) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(error.toString())));
                        }
                      }
                    },
                  ),
                ],
                if (ticket.validDates.isNotEmpty ||
                    ticket.validFrom != null ||
                    ticket.validUntil != null) ...[
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    ticket.validDates.isNotEmpty
                        ? 'Valid dates: ${ticket.validDates.join(', ')}'
                        : 'Validity: ${ticket.validFrom ?? 'event start'} to ${ticket.validUntil ?? 'event end'}',
                    style: AppTypography.caption,
                    textAlign: TextAlign.center,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}