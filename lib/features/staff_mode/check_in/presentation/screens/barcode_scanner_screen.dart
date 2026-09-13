import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../../../../shared/widgets/buttons/app_button.dart';
import '../../../../../shared/widgets/inputs/app_text_field.dart';
import '../../../../tickets/application/tickets_providers.dart';
import '../../../../tickets/data/models/ticket.dart';
import '../../application/check_in_providers.dart';
import '../../data/check_in_repository.dart';

/// All state (`_queuedCount`/`_attentionCount`/`_syncing`), the
/// connectivity-triggered auto-sync, [_handleDetect]/[_submitManualEntry]/
/// [_handleResult]/[_syncQueue]'s repository calls, and the
/// Code-128-payload-split logic are unchanged from before. Only the
/// presentation was refreshed — scanner reticle corners, staff-accent
/// badge tint, rounder feedback banners.
class BarcodeScannerScreen extends ConsumerStatefulWidget {
  const BarcodeScannerScreen({super.key});

  @override
  ConsumerState<BarcodeScannerScreen> createState() =>
      _BarcodeScannerScreenState();
}

enum _FeedbackKind { success, duplicate, error, queued }

class _BarcodeScannerScreenState extends ConsumerState<BarcodeScannerScreen> {
  final _controller = MobileScannerController(
    formats: const [BarcodeFormat.code128],
  );
  bool _processing = false;
  bool _manualEntryOpen = false;
  final _manualCodeController = TextEditingController();

  _FeedbackKind? _feedbackKind;
  String? _feedbackMessage;

  int _queuedCount = 0;
  int _attentionCount = 0;
  bool _syncing = false;
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;

  // "Scans by me" — refreshed after every successful/duplicate online scan
  // against whichever event the just-scanned ticket belongs to (this
  // screen itself has no event route param, so the event is only known
  // once a ticket resolves).
  MyScanStats? _scanStats;

  Future<void> _refreshScanStats(String eventId) async {
    try {
      final stats =
          await ref.read(ticketsRepositoryProvider).myScanStats(eventId);
      if (mounted) setState(() => _scanStats = stats);
    } catch (_) {
      // Non-critical — the scanner keeps working even if the stats
      // refresh fails; just don't update the badge this time.
    }
  }

  @override
  void initState() {
    super.initState();
    _refreshQueuedCount();
    // Auto-sync the moment connectivity returns — a volunteer shouldn't
    // have to remember to tap "Sync now" the instant signal comes back;
    // the manual button (below) exists for the case they want to trigger
    // it sooner, or confirm it actually ran.
    _connectivitySubscription =
        Connectivity().onConnectivityChanged.listen((results) {
      if (!results.contains(ConnectivityResult.none)) {
        _syncQueue();
      }
    });
  }

  Future<void> _refreshQueuedCount() async {
    final repository = ref.read(checkInRepositoryProvider);
    final queued = await repository.listQueued();
    if (mounted) {
      setState(() {
        _queuedCount =
            queued.where((item) => item.syncStatus == 'pending').length;
        _attentionCount =
            queued.where((item) => item.syncStatus == 'failed').length;
      });
    }
  }

  Future<void> _syncQueue() async {
    if (_syncing) return;
    setState(() => _syncing = true);
    final repository = ref.read(checkInRepositoryProvider);
    final summary = await repository.syncQueue();
    await _refreshQueuedCount();
    if (mounted) {
      setState(() => _syncing = false);
      if (summary.succeeded > 0 || summary.failed > 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              summary.failed == 0
                  ? 'Synced ${summary.succeeded} queued check-in${summary.succeeded == 1 ? '' : 's'}.'
                  : summary.requiresAttention > 0
                      ? 'Synced ${summary.succeeded}; ${summary.requiresAttention} require attention.'
                      : 'Synced ${summary.succeeded}; retry pending for ${summary.failed}.',
            ),
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _manualCodeController.dispose();
    _connectivitySubscription?.cancel();
    super.dispose();
  }

  Future<void> _handleDetect(BarcodeCapture capture) async {
    if (_processing) return;
    final barcodes = capture.barcodes;
    final rawValue = barcodes.isNotEmpty ? barcodes.first.rawValue : null;
    if (rawValue == null) return;

    // The Code 128 value encodes "barcode_payload|barcode_signature".
    final parts = rawValue.split('|');
    if (parts.length != 2) {
      _showFeedback(_FeedbackKind.error,
          'Unrecognized code — this may not be an event ticket.');
      return;
    }

    setState(() => _processing = true);
    final repository = ref.read(checkInRepositoryProvider);
    final result = await repository.processScan(
        scanPayload: parts[0], barcodeSignature: parts[1]);
    _handleResult(result);
  }

  Future<void> _submitManualEntry() async {
    final code = _manualCodeController.text.trim();
    if (code.isEmpty) return;
    setState(() => _processing = true);
    final repository = ref.read(checkInRepositoryProvider);
    final result = await repository.processManualEntry(ticketCode: code);
    _manualCodeController.clear();
    _handleResult(result);
  }

  void _handleResult(CheckInResult result) {
    if (!mounted) return;
    switch (result) {
      case CheckInSuccess(:final ticket):
        _showFeedback(_FeedbackKind.success, 'Checked in ${ticket.ticketCode}');
        _refreshScanStats(ticket.eventId);
      case CheckInQueuedOffline():
        _showFeedback(
            _FeedbackKind.queued, 'No connection — queued to sync later.');
        _refreshQueuedCount();
      case CheckInDuplicate():
        _showFeedback(_FeedbackKind.duplicate, 'Already checked in.');
      case CheckInFailed(:final message):
        _showFeedback(_FeedbackKind.error, message);
    }
  }

  void _showFeedback(_FeedbackKind kind, String message) {
    setState(() {
      _processing = false;
      _feedbackKind = kind;
      _feedbackMessage = message;
    });
    // Auto-clear after a moment so the scanner is visibly ready for the
    // next scan again — this screen's whole purpose is being scanned
    // against repeatedly, fast, at a gate.
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _feedbackKind = null);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: const Text('Scan Ticket'),
        actions: [
          if (_queuedCount > 0)
            IconButton(
              icon: Badge(
                backgroundColor: AppColors.staffModeAccent,
                label: Text('$_queuedCount'),
                child: _syncing
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white),
                      )
                    : const Icon(Icons.cloud_upload_outlined),
              ),
              tooltip: '$_queuedCount queued — tap to sync now',
              onPressed: _syncing ? null : _syncQueue,
            ),
          IconButton(
            icon: const Icon(Icons.flash_on_rounded),
            onPressed: () => _controller.toggleTorch(),
          ),
          IconButton(
            icon: const Icon(Icons.keyboard_rounded),
            onPressed: () =>
                setState(() => _manualEntryOpen = !_manualEntryOpen),
          ),
        ],
      ),
      body: Stack(
        children: [
          MobileScanner(controller: _controller, onDetect: _handleDetect),
          const _ScannerOverlay(),
          if (_scanStats != null)
            Positioned(
              // Sits below where the transient feedback banner renders
              // (top: AppSpacing.xl) so the two never overlap right after
              // a scan.
              top: AppSpacing.xl + 76,
              left: AppSpacing.lg,
              right: AppSpacing.lg,
              child: _ScanStatsPill(stats: _scanStats!),
            ),
          if (_feedbackKind != null)
            _FeedbackBanner(
                kind: _feedbackKind!, message: _feedbackMessage ?? ''),
          if (_manualEntryOpen)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: _ManualEntrySheet(
                controller: _manualCodeController,
                loading: _processing,
                onSubmit: _submitManualEntry,
              ),
            ),
          if (_attentionCount > 0)
            Positioned(
              left: AppSpacing.lg,
              right: AppSpacing.lg,
              bottom: AppSpacing.lg,
              child: Material(
                color: AppColors.danger,
                borderRadius: BorderRadius.circular(16),
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline_rounded,
                          color: Colors.white, size: 18),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Text(
                            '$_attentionCount check-in operation${_attentionCount == 1 ? '' : 's'} require attention.',
                            style: AppTypography.bodyStrong
                                .copyWith(color: Colors.white)),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Shows how many participants THIS staff member has personally checked
/// in at the current event, plus who they most recently scanned — closes
/// a real gap where a volunteer scanning at a gate had no way to see
/// their own scan count or confirm who they just let through.
class _ScanStatsPill extends StatelessWidget {
  final MyScanStats stats;
  const _ScanStatsPill({required this.stats});

  @override
  Widget build(BuildContext context) {
    final last = stats.lastScanned;
    return Material(
      color: Colors.black.withValues(alpha: 0.55),
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md, vertical: AppSpacing.sm),
        child: Row(
          children: [
            const Icon(Icons.how_to_reg_rounded,
                color: AppColors.staffModeAccent, size: 18),
            const SizedBox(width: AppSpacing.sm),
            Text('${stats.scannedCount} scanned by you',
                style: AppTypography.bodyStrong
                    .copyWith(color: Colors.white)),
            if (last != null) ...[
              const SizedBox(width: AppSpacing.sm),
              Container(width: 1, height: 14, color: Colors.white24),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  'Last: ${last.participantName ?? last.ticketCode}',
                  style: AppTypography.caption
                      .copyWith(color: Colors.white70),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ScannerOverlay extends StatelessWidget {
  const _ScannerOverlay();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Center(
        child: SizedBox(
          width: 260,
          height: 260,
          child: CustomPaint(painter: _ReticlePainter()),
        ),
      ),
    );
  }
}

/// Four bracket corners rather than a plain full rectangle — reads closer
/// to a native camera/scan UI than a solid outlined square.
class _ReticlePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.9)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    const len = 32.0;
    const r = 20.0;

    void corner(Offset origin, double dx, double dy) {
      final path = Path()
        ..moveTo(origin.dx, origin.dy + dy * len)
        ..lineTo(origin.dx, origin.dy + dy * r)
        ..arcToPoint(Offset(origin.dx + dx * r, origin.dy),
            radius: const Radius.circular(r))
        ..lineTo(origin.dx + dx * len, origin.dy);
      canvas.drawPath(path, paint);
    }

    corner(const Offset(0, 0), 1, 1);
    corner(Offset(size.width, 0), -1, 1);
    corner(Offset(0, size.height), 1, -1);
    corner(Offset(size.width, size.height), -1, -1);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _FeedbackBanner extends StatelessWidget {
  final _FeedbackKind kind;
  final String message;
  const _FeedbackBanner({required this.kind, required this.message});

  (Color, IconData) get _style => switch (kind) {
        _FeedbackKind.success => (
            AppColors.success,
            Icons.check_circle_rounded
          ),
        _FeedbackKind.duplicate => (AppColors.warning, Icons.info_rounded),
        _FeedbackKind.queued => (AppColors.info, Icons.cloud_off_rounded),
        _FeedbackKind.error => (AppColors.danger, Icons.error_rounded),
      };

  @override
  Widget build(BuildContext context) {
    final (color, icon) = _style;
    return Positioned(
      top: AppSpacing.xl,
      left: AppSpacing.lg,
      right: AppSpacing.lg,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.4),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(message,
                  style:
                      AppTypography.bodyStrong.copyWith(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}

class _ManualEntrySheet extends StatelessWidget {
  final TextEditingController controller;
  final bool loading;
  final VoidCallback onSubmit;
  const _ManualEntrySheet(
      {required this.controller,
      required this.loading,
      required this.onSubmit});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: AppSpacing.lg,
        right: AppSpacing.lg,
        top: AppSpacing.lg,
        bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.lg,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: AppSpacing.lg),
              decoration: BoxDecoration(
                color: AppColors.inkSubtle.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
          const Text('Enter ticket code', style: AppTypography.title),
          const SizedBox(height: AppSpacing.sm),
          const Text('For a damaged or unreadable barcode.',
              style: AppTypography.caption),
          const SizedBox(height: AppSpacing.md),
          AppTextField(
              controller: controller,
              hint: 'TKT-XXXXXXXXXXXXXXXX',
              autofocus: true),
          const SizedBox(height: AppSpacing.lg),
          AppButton(
              label: 'Check in',
              fullWidth: true,
              size: AppButtonSize.large,
              loading: loading,
              onPressed: onSubmit),
        ],
      ),
    );
  }
}