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
import '../../application/check_in_providers.dart';
import '../../data/check_in_repository.dart';

/// VERIFICATION NOTE (same caveat as razorpay_checkout_service.dart,
/// ticket_detail_screen.dart, and check_in_repository.dart's
/// connectivity check): `MobileScanner`, `MobileScannerController`, and
/// `BarcodeCapture`/`Barcode.rawValue` are `mobile_scanner` v5.x's public
/// API, written from training knowledge — not verified against the real
/// installed source, since pub.dev isn't reachable from this sandbox.
class QrScannerScreen extends ConsumerStatefulWidget {
  const QrScannerScreen({super.key});

  @override
  ConsumerState<QrScannerScreen> createState() => _QrScannerScreenState();
}

enum _FeedbackKind { success, duplicate, error, queued }

class _QrScannerScreenState extends ConsumerState<QrScannerScreen> {
  final _controller = MobileScannerController();
  bool _processing = false;
  bool _manualEntryOpen = false;
  final _manualCodeController = TextEditingController();

  _FeedbackKind? _feedbackKind;
  String? _feedbackMessage;

  int _queuedCount = 0;
  bool _syncing = false;
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;

  @override
  void initState() {
    super.initState();
    _refreshQueuedCount();
    // Auto-sync the moment connectivity returns — a volunteer shouldn't
    // have to remember to tap "Sync now" the instant signal comes back;
    // the manual button (below) exists for the case they want to trigger
    // it sooner, or confirm it actually ran.
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen((results) {
      if (!results.contains(ConnectivityResult.none)) {
        _syncQueue();
      }
    });
  }

  Future<void> _refreshQueuedCount() async {
    final repository = ref.read(checkInRepositoryProvider);
    final queued = await repository.listQueued();
    if (mounted) setState(() => _queuedCount = queued.length);
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
                  : 'Synced ${summary.succeeded}, ${summary.failed} still need attention.',
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

    // The QR encodes "qr_payload|qr_signature" (see ticket_detail_screen.dart's
    // fix note) — split back into the two values the backend needs.
    final parts = rawValue.split('|');
    if (parts.length != 2) {
      _showFeedback(_FeedbackKind.error, 'Unrecognized code — this may not be an event ticket.');
      return;
    }

    setState(() => _processing = true);
    final repository = ref.read(checkInRepositoryProvider);
    final result = await repository.processScan(scanPayload: parts[0], qrSignature: parts[1]);
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
      case CheckInSuccess():
        _showFeedback(_FeedbackKind.success, 'Checked in successfully.');
      case CheckInQueuedOffline():
        _showFeedback(_FeedbackKind.queued, 'No connection — queued to sync later.');
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
                label: Text('$_queuedCount'),
                child: _syncing
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
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
            onPressed: () => setState(() => _manualEntryOpen = !_manualEntryOpen),
          ),
        ],
      ),
      body: Stack(
        children: [
          MobileScanner(controller: _controller, onDetect: _handleDetect),
          _ScannerOverlay(),
          if (_feedbackKind != null)
            _FeedbackBanner(kind: _feedbackKind!, message: _feedbackMessage ?? ''),
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
        ],
      ),
    );
  }
}

class _ScannerOverlay extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Center(
        child: Container(
          width: 240,
          height: 240,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.white.withOpacity(0.8), width: 3),
            borderRadius: BorderRadius.circular(24),
          ),
        ),
      ),
    );
  }
}

class _FeedbackBanner extends StatelessWidget {
  final _FeedbackKind kind;
  final String message;
  const _FeedbackBanner({required this.kind, required this.message});

  (Color, IconData) get _style => switch (kind) {
        _FeedbackKind.success => (AppColors.success, Icons.check_circle_rounded),
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
        decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(16)),
        child: Row(
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(message, style: AppTypography.bodyStrong.copyWith(color: Colors.white)),
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
  const _ManualEntrySheet({required this.controller, required this.loading, required this.onSubmit});

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
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Enter ticket code', style: AppTypography.title),
          const SizedBox(height: AppSpacing.sm),
          Text('For a damaged or unreadable QR code.', style: AppTypography.caption),
          const SizedBox(height: AppSpacing.md),
          AppTextField(controller: controller, hint: 'TKT-XXXXXXXXXXXXXXXX', autofocus: true),
          const SizedBox(height: AppSpacing.lg),
          AppButton(label: 'Check in', fullWidth: true, loading: loading, onPressed: onSubmit),
        ],
      ),
    );
  }
}
