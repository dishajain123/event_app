import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../../../core/network/app_exception.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/badges/status_badge.dart';
import '../../../../shared/widgets/states/app_error_state.dart';
import '../../../../shared/widgets/states/app_skeleton.dart';
import '../../application/tickets_providers.dart';
import '../../data/models/ticket.dart';

const _ticketStatusTones = {
  TicketStatus.issued: StatusTone.success,
  TicketStatus.checkedIn: StatusTone.accent,
  TicketStatus.cancelled: StatusTone.neutral,
};

/// VERIFICATION NOTE (same caveat as razorpay_checkout_service.dart):
/// `QrImageView` is `qr_flutter` v4.x's widget class name (renamed from
/// `QrImage` in v3.x) — written from training knowledge since pub.dev
/// isn't reachable from this sandbox to confirm against the actual
/// installed package source. If this doesn't compile, it's the first
/// thing to check.
class TicketDetailScreen extends ConsumerWidget {
  final String ticketId;
  const TicketDetailScreen({super.key, required this.ticketId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ticketAsync = ref.watch(ticketDetailProvider(ticketId));

    return Scaffold(
      appBar: AppBar(title: const Text('Ticket')),
      body: SafeArea(
        child: ticketAsync.when(
          loading: () => const AppSkeleton.detailPage(),
          error: (error, stackTrace) => AppErrorState(
            error: error is AppException ? error : UnknownException(error.toString()),
            onRetry: () => ref.invalidate(ticketDetailProvider(ticketId)),
          ),
          data: (ticket) => ListView(
            padding: const EdgeInsets.all(AppSpacing.xl),
            children: [
              Center(
                child: StatusBadge(
                  label: ticket.status.label,
                  tone: _ticketStatusTones[ticket.status] ?? StatusTone.neutral,
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              Center(
                child: Container(
                  padding: const EdgeInsets.all(AppSpacing.xl),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 24, offset: const Offset(0, 8)),
                    ],
                  ),
                  child: ticket.status == TicketStatus.cancelled
                      ? const SizedBox(
                          width: 220,
                          height: 220,
                          child: Center(
                            child: Icon(Icons.qr_code_2_rounded, size: 64, color: AppColors.inkSubtle),
                          ),
                        )
                      : QrImageView(
                          // BUG FIX: the QR code must encode BOTH
                          // qr_payload and qr_signature — POST
                          // /tickets/resolve needs both to verify and
                          // look up the ticket, but only qr_payload was
                          // being embedded here, meaning a scan could
                          // never actually be resolved. '|' is a safe
                          // delimiter: qr_payload already uses ':'
                          // internally, and qr_signature is a hex HMAC
                          // digest — neither ever contains '|'. The
                          // scanner (staff_mode/check_in) splits on this
                          // same delimiter to recover both parts.
                          data: '${ticket.qrPayload}|${ticket.qrSignature}',
                          version: QrVersions.auto,
                          size: 220,
                          backgroundColor: Colors.white,
                        ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Center(child: Text(ticket.ticketCode, style: AppTypography.bodyStrong)),
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
            ],
          ),
        ),
      ),
    );
  }
}
